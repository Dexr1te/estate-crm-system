import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/auto_lock_options.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/pin_panel.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum PinSetupMode { enable, change, disable }

enum _Step { current, choose, repeat, autoLock }

/// Turning the lock on (choose, repeat, pick when it locks), changing the PIN
/// (current, choose, repeat) and turning it off (current). Pops true once the
/// change is saved.
class AppLockSetupScreen extends StatefulWidget {
  final AppLockController controller;
  final PinSetupMode mode;

  const AppLockSetupScreen(
      {super.key, required this.controller, required this.mode});

  @override
  State<AppLockSetupScreen> createState() => _AppLockSetupScreenState();
}

class _AppLockSetupScreenState extends State<AppLockSetupScreen> {
  late _Step _step =
      widget.mode == PinSetupMode.enable ? _Step.choose : _Step.current;
  String _entered = '';
  String _current = '';
  String _chosen = '';
  String? _error;
  int _errorTick = 0;
  bool _busy = false;
  AutoLock _autoLock = AutoLock.immediately;

  AppLockController get _lock => widget.controller;

  int get _target => switch (_step) {
        _Step.current => _lock.pinLength,
        _Step.repeat => _chosen.length,
        _ => AppLockController.maxPinLength,
      };

  void _digit(String d) {
    if (_busy || _entered.length >= _target) return;
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == _target) unawaited(_advance());
  }

  void _delete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  void _fail(String message) {
    setState(() {
      _error = message;
      _entered = '';
      _errorTick++;
    });
    unawaited(HapticFeedback.heavyImpact());
  }

  Future<void> _advance() async {
    final l10n = AppLocalizations.of(context);
    final pin = _entered;
    switch (_step) {
      case _Step.current:
        setState(() => _busy = true);
        final result = widget.mode == PinSetupMode.disable
            ? await _lock.disable(pin)
            : await _lock.verify(pin);
        if (!mounted) return;
        setState(() => _busy = false);
        if (result != PinCheck.accepted) {
          final retry = _lock.retryIn;
          return _fail(retry != null
              ? l10n.lockRetryIn(formatRetry(retry))
              : l10n.lockWrongPin);
        }
        if (widget.mode == PinSetupMode.disable) {
          Navigator.of(context).pop(true);
          return;
        }
        setState(() {
          _current = pin;
          _entered = '';
          _step = _Step.choose;
        });
      case _Step.choose:
        if (pin.length < AppLockController.minPinLength) {
          return _fail(l10n.lockTooShort);
        }
        setState(() {
          _chosen = pin;
          _entered = '';
          _step = _Step.repeat;
        });
      case _Step.repeat:
        if (pin != _chosen) {
          _fail(l10n.lockMismatch);
          setState(() {
            _chosen = '';
            _step = _Step.choose;
          });
          return;
        }
        if (widget.mode == PinSetupMode.enable) {
          setState(() {
            _entered = '';
            _step = _Step.autoLock;
          });
          return;
        }
        setState(() => _busy = true);
        final result = await _lock.changePin(_current, pin);
        if (!mounted) return;
        if (result == PinCheck.accepted) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _busy = false);
          _fail(l10n.lockWrongPin);
        }
      case _Step.autoLock:
        setState(() => _busy = true);
        await _lock.enable(_chosen, _autoLock);
        if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final title = switch (widget.mode) {
      PinSetupMode.change => l10n.lockChangePin,
      _ => l10n.lockAppLock,
    };

    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          DetailAppBar(title: title),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _step == _Step.autoLock
                      ? _autoLockStep(l10n)
                      : _pinStep(l10n),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinStep(AppLocalizations l10n) {
    final choosing = _step == _Step.choose;
    return PinPanel(
      title: switch (_step) {
        _Step.current => l10n.lockCurrentPinTitle,
        _Step.repeat => l10n.lockConfirmPinTitle,
        _ => l10n.lockNewPinTitle,
      },
      message: _error ?? (choosing ? l10n.lockDigitsHint : null),
      messageIsError: _error != null,
      dots: _target,
      filled: _entered.length,
      errorTick: _errorTick,
      enabled: !_busy,
      onDigit: _digit,
      onDelete: _delete,
      footer: [
        if (choosing)
          AppFilledButton(
            key: const ValueKey('pin-continue'),
            label: l10n.lockContinue,
            onPressed: _busy || _entered.isEmpty ? null : _advance,
          ),
      ],
    );
  }

  Widget _autoLockStep(AppLocalizations l10n) => CenteredScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AutoLockOptions(
              title: l10n.lockAutoLockTitle,
              selected: _autoLock,
              onSelected: (a) => setState(() => _autoLock = a),
            ),
            const SizedBox(height: 22),
            AppFilledButton(
              key: const ValueKey('pin-turn-on'),
              label: l10n.lockTurnOn,
              loading: _busy,
              onPressed: _busy ? null : _advance,
            ),
          ],
        ),
      );
}
