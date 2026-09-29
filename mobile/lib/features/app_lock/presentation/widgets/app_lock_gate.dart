import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/app_lock/presentation/screens/lock_screen.dart';

/// Puts the lock, or a plain cover, over the whole app. The app underneath
/// stays built — its screens and scroll positions are there after the PIN —
/// but is not painted, so neither a passer-by nor the OS snapshot for the
/// app switcher sees a client's name.
class AppLockGate extends StatefulWidget {
  final AppLockController controller;
  final Widget child;

  const AppLockGate({super.key, required this.controller, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
        onStateChange: (s) => widget.controller.lifecycleChanged(s));
    widget.controller.addListener(_dropFocus);
  }

  void _dropFocus() {
    if (!widget.controller.isLocked) return;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_dropFocus);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lock = widget.controller;
    return ListenableBuilder(
      listenable: lock,
      child: widget.child,
      builder: (context, child) {
        final hidden = lock.isLocked || lock.isCovered;
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: hidden,
              child: ExcludeSemantics(excluding: hidden, child: child),
            ),
            if (lock.isLocked)
              LockScreen(controller: lock)
            else if (lock.isCovered)
              const PrivacyCover(),
          ],
        );
      },
    );
  }
}

/// The brand on the app's background and nothing else.
class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
        key: const ValueKey('privacy-cover'),
        color: context.tokens.background,
        child: const Center(child: BrandMark(size: 72)),
      );
}
