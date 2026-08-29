import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The pipeline drawn as one column per stage.
///
/// A phone has no room for two columns side by side, so the columns are pages —
/// which rules out the desktop gesture of dragging a card from one column into
/// the next. Instead a long press lifts the card and the foot of the board
/// becomes the stages it can land on, so every destination is one short drag
/// away no matter which column is showing.
class DealBoard extends StatefulWidget {
  final List<DealResponse> deals;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final void Function(DealResponse deal, DealStatus to) onMove;
  final ValueChanged<DealResponse> onOpen;
  final Future<void> Function() onRefresh;
  final double padding;

  const DealBoard({
    super.key,
    required this.deals,
    required this.controller,
    required this.onPageChanged,
    required this.onMove,
    required this.onOpen,
    required this.onRefresh,
    required this.padding,
  });

  @override
  State<DealBoard> createState() => _DealBoardState();
}

class _DealBoardState extends State<DealBoard> {
  DealResponse? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dragging = _dragging;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: widget.controller,
                onPageChanged: widget.onPageChanged,
                itemCount: DealStatus.values.length,
                itemBuilder: (_, i) {
                  final status = DealStatus.values[i];
                  return _StageColumn(
                    status: status,
                    deals:
                        widget.deals.where((d) => d.status == status).toList(),
                    padding: widget.padding,
                    onOpen: widget.onOpen,
                    onRefresh: widget.onRefresh,
                    onDragChanged: (deal) => setState(() => _dragging = deal),
                  );
                },
              ),
              if (dragging != null)
                Positioned(
                  left: widget.padding,
                  right: widget.padding,
                  bottom: 6,
                  child: _DropRail(deal: dragging, onMove: widget.onMove),
                ),
            ],
          ),
        ),
        // Held rather than hidden while a card is up: the rail floats over the
        // list, and letting the bar collapse would shuffle the column out from
        // under the finger that is still dragging.
        _HintBar(
          text: l10n.dealsBoardDragHint,
          faded: dragging != null,
          padding: widget.padding,
        ),
      ],
    );
  }
}

class _StageColumn extends StatelessWidget {
  final DealStatus status;
  final List<DealResponse> deals;
  final double padding;
  final ValueChanged<DealResponse> onOpen;
  final Future<void> Function() onRefresh;
  final ValueChanged<DealResponse?> onDragChanged;

  const _StageColumn({
    required this.status,
    required this.deals,
    required this.padding,
    required this.onOpen,
    required this.onRefresh,
    required this.onDragChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total =
        deals.fold<double>(0, (sum, d) => sum + (d.dealPrice ?? d.budget ?? 0));

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 0, padding, 10),
            child: _ColumnHeader(
                status: status, count: deals.length, total: total),
          ),
          Expanded(
            child: deals.isEmpty
                ? EmptyState(
                    icon: Icons.handshake_outlined,
                    title: l10n.dealsBoardStageEmpty,
                  )
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    color: context.tokens.primary,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                      itemCount: deals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemBuilder: (_, i) => _DraggableCard(
                        deal: deals[i],
                        // The lifted card keeps the width it had in the
                        // column; a feedback widget is otherwise unconstrained
                        // and would shrink to its text.
                        width: constraints.maxWidth - padding * 2,
                        onOpen: onOpen,
                        onDragChanged: onDragChanged,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final DealStatus status;
  final int count;
  final double total;

  const _ColumnHeader({
    required this.status,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dealStageColor(t, status),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            dealStatusLabel(l10n, status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            l10n.dealsBoardColumnMeta(count, formatPrice(total)),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 11.5,
              color: t.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DraggableCard extends StatelessWidget {
  final DealResponse deal;
  final double width;
  final ValueChanged<DealResponse> onOpen;
  final ValueChanged<DealResponse?> onDragChanged;

  const _DraggableCard({
    required this.deal,
    required this.width,
    required this.onOpen,
    required this.onDragChanged,
  });

  @override
  Widget build(BuildContext context) => LongPressDraggable<DealResponse>(
        data: deal,
        onDragStarted: () => onDragChanged(deal),
        // Fires for a drop that landed and one that did not, which is every way
        // a drag can end.
        onDragEnd: (_) => onDragChanged(null),
        feedback: SizedBox(
          width: width,
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _BoardCard(deal: deal),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: _BoardCard(deal: deal)),
        child: _BoardCard(deal: deal, onTap: () => onOpen(deal)),
      );
}

class _BoardCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback? onTap;

  const _BoardCard({required this.deal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final stale = DealCard.staleDays(deal);
    final amount = deal.dealPrice ?? deal.budget ?? 0;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: t.textPrimary,
            ),
          ),
          if (deal.clientName.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              deal.clientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  formatPrice(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
              ),
              if (stale != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.dealsStaleWarning(stale),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: t.dangerText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The stages a lifted card can be dropped on — every stage but its own.
class _DropRail extends StatelessWidget {
  final DealResponse deal;
  final void Function(DealResponse deal, DealStatus to) onMove;

  const _DropRail({required this.deal, required this.onMove});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final targets = DealStatus.values.where((s) => s != deal.status).toList();
    final shape = BorderRadius.circular(AppMetrics.radiusLg);

    return Material(
      color: t.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      borderRadius: shape,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(color: t.border, width: AppMetrics.borderWidth),
        ),
        child: Row(
          children: [
            for (var i = 0; i < targets.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _DropSlot(
                  status: targets[i],
                  onAccept: (dropped) => onMove(dropped, targets[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropSlot extends StatelessWidget {
  final DealStatus status;
  final ValueChanged<DealResponse> onAccept;

  const _DropSlot({required this.status, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final color = dealStageColor(t, status);

    return DragTarget<DealResponse>(
      onWillAcceptWithDetails: (d) => d.data.status != status,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, __) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.16) : t.surfaceVariant,
            borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
            border: Border.all(
              color: active ? color : Colors.transparent,
              width: AppMetrics.borderWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(height: 7),
              Text(
                dealStatusLabel(l10n, status),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: active ? color : t.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HintBar extends StatelessWidget {
  final String text;
  final bool faded;
  final double padding;

  const _HintBar({
    required this.text,
    required this.faded,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedOpacity(
      opacity: faded ? 0 : 1,
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 6, padding, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drag_indicator_rounded, size: 15, color: t.textHint),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11,
                  height: 1.3,
                  color: t.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
