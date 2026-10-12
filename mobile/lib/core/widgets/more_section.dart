import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MoreSection extends StatefulWidget {
  final String memoryKey;
  final List<Widget> children;

  const MoreSection({
    super.key,
    required this.memoryKey,
    required this.children,
  });

  static const toggleKey = ValueKey('more-toggle');
  static const contentKey = ValueKey('more-content');
  static const duration = Duration(milliseconds: 220);

  static final Map<String, bool> _remembered = {};

  static bool isOpen(String memoryKey) => _remembered[memoryKey] ?? false;

  @visibleForTesting
  static void forgetAll() => _remembered.clear();

  @override
  State<MoreSection> createState() => _MoreSectionState();
}

class _MoreSectionState extends State<MoreSection> {
  late bool _open = MoreSection.isOpen(widget.memoryKey);

  void _toggle() {
    setState(() => _open = !_open);
    MoreSection._remembered[widget.memoryKey] = _open;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final gap = AppMetrics.blockGap(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MoreToggle(open: _open, onTap: _toggle),
        AnimatedSize(
          duration: MoreSection.duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  key: MoreSection.contentKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final child in widget.children) ...[
                      SizedBox(height: gap),
                      child,
                    ],
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _MoreToggle extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _MoreToggle({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final shape = BorderRadius.circular(AppMetrics.radiusSm);

    return Semantics(
      button: true,
      expanded: open,
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        child: InkWell(
          key: MoreSection.toggleKey,
          borderRadius: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppMetrics.minHitTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      open ? l10n.coreShowLess : l10n.coreMore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: AppType.body,
                        fontWeight: FontWeight.w600,
                        color: t.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: MoreSection.duration,
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
