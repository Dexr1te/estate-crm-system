import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';

class DetailScaffold extends StatelessWidget {
  final String title;

  final String? trailingLabel;

  final List<Widget> actions;

  final List<Widget> children;

  final Widget? bottomAction;

  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;

  const DetailScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.trailingLabel,
    this.bottomAction,
    this.onBack,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final gap = AppMetrics.blockGap(context);

    Widget body = SingleChildScrollView(
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
          if (bottomAction != null) ...[
            SizedBox(height: gap + 6),
            bottomAction!,
          ],
          Padding(padding: AppMetrics.ctaPadding(context)),
        ],
      ),
    );

    if (onRefresh != null) {
      body = RefreshIndicator(
          onRefresh: onRefresh!, color: t.primary, child: body);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: t.background,
      body: Column(
        children: [
          DetailAppBar(
            title: title,
            actions: actions,
            trailingLabel: trailingLabel,
            onBack: onBack,
          ),
          Expanded(child: AppMetrics.constrain(body)),
        ],
      ),
    );
  }
}

class DetailAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final String? trailingLabel;
  final VoidCallback? onBack;

  const DetailAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.trailingLabel,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
            bottom: BorderSide(color: t.border, width: AppMetrics.borderWidth)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack ??
                    () => context.canPop() ? context.pop() : context.go('/'),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: t.textPrimary),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              if (trailingLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingLabel!,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary),
                ),
              ],
              for (final a in actions) ...[const SizedBox(width: 2), a],
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> detailActions({
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  String? editTooltip,
  String? deleteTooltip,
}) =>
    [
      if (onEdit != null)
        AppIconTile(
            icon: Icons.edit_outlined, onPressed: onEdit, tooltip: editTooltip),
      if (onDelete != null)
        AppIconTile(
            icon: Icons.delete_outline_rounded,
            onPressed: onDelete,
            danger: true,
            tooltip: deleteTooltip),
    ];
