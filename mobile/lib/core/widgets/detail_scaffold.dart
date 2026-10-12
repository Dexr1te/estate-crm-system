import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_platform.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';
import 'package:real_estate_crm/core/widgets/app_surface.dart';
import 'package:real_estate_crm/core/widgets/text_measure.dart';

class DetailScaffold extends StatefulWidget {
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

  static const double pinnedMinRoom = 360;

  @override
  State<DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends State<DetailScaffold> {
  final _scrolledUnder = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _scrolledUnder.dispose();
    super.dispose();
  }

  bool _onNotification(Notification notification) {
    final ScrollMetrics? metrics = switch (notification) {
      ScrollMetricsNotification(depth: 0, :final metrics) => metrics,
      ScrollUpdateNotification(depth: 0, :final metrics) => metrics,
      _ => null,
    };
    if (metrics != null && metrics.axis == Axis.vertical) {
      _scrolledUnder.value = metrics.extentAfter > 0.5;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final gap = AppMetrics.blockGap(context);
    final action = widget.bottomAction;
    final room = MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        MediaQuery.paddingOf(context).top;
    final pinned = action != null && room >= DetailScaffold.pinnedMinRoom;
    final children = widget.children;

    Widget body = NotificationListener<Notification>(
      onNotification: _onNotification,
      child: SingleChildScrollView(
        physics: widget.onRefresh == null
            ? null
            : const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
        child: PagePadded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
              if (action != null && !pinned) ...[
                SizedBox(height: gap + 6),
                action,
              ],
              Padding(
                  padding: pinned
                      ? EdgeInsets.only(bottom: gap + 6)
                      : AppMetrics.ctaPadding(context)),
            ],
          ),
        ),
      ),
    );

    if (widget.onRefresh != null) {
      body = RefreshIndicator(
          onRefresh: widget.onRefresh!, color: t.primary, child: body);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: pinned
          ? PinnedActionBar(scrolledUnder: _scrolledUnder, child: action)
          : null,
      body: Column(
        children: [
          DetailAppBar(
            title: widget.title,
            actions: widget.actions,
            trailingLabel: widget.trailingLabel,
            onBack: widget.onBack,
          ),
          Expanded(child: AppMetrics.constrain(body)),
        ],
      ),
    );
  }
}

class PinnedActionBar extends StatelessWidget {
  final Widget child;
  final ValueListenable<bool>? scrolledUnder;

  const PinnedActionBar({super.key, required this.child, this.scrolledUnder});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final content = Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppMetrics.wideMaxContentWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [child],
              ),
            ),
          ),
        ),
      ),
    );

    Widget bar(bool under) => DecoratedBox(
          key: const ValueKey('pinned-action-bar'),
          decoration: BoxDecoration(
            color: t.background,
            border: Border(
              top: BorderSide(
                  color: under ? t.border : t.background, width: 0.5),
            ),
          ),
          child: content,
        );

    final listenable = scrolledUnder;
    if (listenable == null) return bar(false);
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (_, under, __) => bar(under),
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
    final pad = AppMetrics.pagePadding(context);
    const glyphInset = (AppMetrics.minHitTarget - 20) / 2;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            6, 6, actions.isEmpty ? pad : pad - glyphInset, 8),
        child: Row(
          children: [
            AppIconTile(
              icon: backIconFor(Theme.of(context).platform),
              strong: true,
              onPressed: onBack ??
                  () => context.canPop() ? context.pop() : context.go('/'),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
            const SizedBox(width: 6),
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
    );
  }
}

IconData backIconFor(TargetPlatform platform) =>
    AppPlatform.isCupertino(platform)
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_back;

const _trailingStyle = TextStyle(
  fontFamily: AppFonts.sans,
  fontSize: AppType.footnote,
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
