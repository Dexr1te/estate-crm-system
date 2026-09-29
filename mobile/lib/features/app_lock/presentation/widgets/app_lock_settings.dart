import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/screens/app_lock_setup_screen.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/auto_lock_options.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Profile → Security: the switch, when it locks, and changing the PIN.
class AppLockSettings extends StatelessWidget {
  final AppLockController controller;
  const AppLockSettings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SettingsGroup(rows: [
        SettingsRow(
          label: l10n.lockAppLock,
          subLabel: l10n.lockAppLockHint,
          trailing: AppSwitch(
            key: const ValueKey('app-lock-switch'),
            value: controller.enabled,
            onChanged: (on) => _open(
                context,
                on ? PinSetupMode.enable : PinSetupMode.disable,
                on ? l10n.lockTurnedOn : l10n.lockTurnedOff),
          ),
        ),
        if (controller.enabled) ...[
          SettingsRow(
            label: l10n.lockAutoLock,
            value: autoLockLabel(l10n, controller.autoLock),
            showChevron: true,
            onTap: () => _pickAutoLock(context),
          ),
          SettingsRow(
            label: l10n.lockChangePin,
            showChevron: true,
            onTap: () =>
                _open(context, PinSetupMode.change, l10n.lockPinChanged),
          ),
        ],
      ]),
    );
  }

  Future<void> _open(
      BuildContext context, PinSetupMode mode, String done) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => AppLockSetupScreen(controller: controller, mode: mode),
    ));
    if (saved != true) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(done)));
  }

  void _pickAutoLock(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showAppBottomSheet(
      context,
      title: l10n.lockAutoLock,
      builder: (ctx) => AutoLockOptions(
        selected: controller.autoLock,
        onSelected: (AutoLock value) {
          controller.setAutoLock(value);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
