import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';
import 'package:real_estate_crm/core/widgets/text_measure.dart';

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
                child: LayoutBuilder(builder: (context, constraints) {
                  final titleText = Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  );
                  final label = trailingLabel;
                  if (label == null) return titleText;
                  final labelText = Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _trailingStyle.copyWith(color: t.textSecondary),
                  );
                  // A counter like kk "2 қадамнан 1-і" at large text can be
                  // wider than the room the title leaves it. Past 40% of the
                  // row it goes under the title rather than off the edge.
                  final below =
                      singleLineTextWidth(context, label, _trailingStyle) >
                          constraints.maxWidth * 0.4;
                  if (below) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [titleText, labelText],
                    );
                  }
                  return Row(children: [
                    Expanded(child: titleText),
                    const SizedBox(width: 8),
                    labelText,
                  ]);
                }),
              ),
              for (final a in actions) ...[const SizedBox(width: 2), a],
            ],
          ),
        ),
      ),
    );
  }
}

const _trailingStyle = TextStyle(
  fontFamily: AppFonts.sans,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

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
