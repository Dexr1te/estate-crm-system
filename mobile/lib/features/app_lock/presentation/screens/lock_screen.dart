import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/pin_panel.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String formatRetry(Duration left) {
  final seconds = (left.inMilliseconds / 1000).ceil();
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Everything the app shows while it is locked.
class LockScreen extends StatefulWidget {
  final AppLockController controller;
  const LockScreen({super.key, required this.controller});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _entered = '';
  int _errorTick = 0;
  bool _wrong = false;
  bool _busy = false;
  bool _confirming = false;
  Timer? _ticker;

  AppLockController get _lock => widget.controller;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _lock.retryIn != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _digit(String d) {
    if (_busy || _lock.retryIn != null) return;
    if (_entered.length >= _lock.pinLength) return;
    setState(() {
      _entered += d;
      _wrong = false;
    });
    if (_entered.length == _lock.pinLength) _submit();
  }

  void _delete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final result = await _lock.unlock(_entered);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _entered = '';
      if (result != PinCheck.accepted) {
        _wrong = true;
        _errorTick++;
      }
    });
    if (result != PinCheck.accepted) unawaited(HapticFeedback.heavyImpact());
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    await _lock.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _confirming ? _confirm(context) : _panel(context),
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final retry = _lock.retryIn;
    final String? message;
    if (retry != null) {
      message = l10n.lockRetryIn(formatRetry(retry));
    } else if (_lock.canSignOut) {
      message = l10n.lockTooManyAttempts;
    } else {
      message = _wrong ? l10n.lockWrongPin : null;
    }

    return PinPanel(
      header: const BrandMark(size: 52),
      title: l10n.lockEnterPin,
      message: message,
      messageIsError: message != null,
      dots: _lock.pinLength,
      filled: _entered.length,
      errorTick: _errorTick,
      enabled: !_busy && retry == null,
      onDigit: _digit,
      onDelete: _delete,
      footer: [
        if (_lock.canSignOut)
          AppDangerButton(
              label: l10n.lockSignOutAgain, onPressed: () => _signOut()),
        PinTextAction(
          label: l10n.lockForgotPin,
          color: t.textSecondary,
          onPressed: _busy ? null : () => setState(() => _confirming = true),
        ),
      ],
    );
  }

  Widget _confirm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return CenteredScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.lockForgotPin,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: t.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.lockForgotPinBody,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13.5,
                color: t.textSecondary),
          ),
          const SizedBox(height: 22),
          AppDangerButton(
              label: l10n.lockSignOutAgain, onPressed: () => _signOut()),
          const SizedBox(height: 10),
          AppGhostButton(
            label: l10n.lockCancel,
            onPressed: _busy ? null : () => setState(() => _confirming = false),
          ),
        ],
      ),
    );
  }
}
