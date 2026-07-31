import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

class Metric {
  final String value;
  final String caption;
  final String? delta;
  final Color? deltaColor;
  final VoidCallback? onTap;

  const Metric({
    required this.value,
    required this.caption,
    this.delta,
    this.deltaColor,
    this.onTap,
  });
}

class MetricsCard extends StatelessWidget {
  final List<Metric> metrics;
  const MetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rows = <Widget>[];

    for (var i = 0; i < metrics.length; i += 2) {
      if (i > 0) {
        rows.add(Container(height: 1, color: t.border));
      }
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _Cell(metric: metrics[i])),
            Container(width: 1, color: t.border),
            Expanded(
              child: i + 1 < metrics.length
                  ? _Cell(metric: metrics[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ));
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Metric metric;
  const _Cell({required this.metric});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: t.textPrimary),
                ),
              ),
              if (metric.delta != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    metric.delta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: metric.deltaColor ?? t.textSecondary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            metric.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.textSecondary),
          ),
        ],
      ),
    );

    if (metric.onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: metric.onTap, child: body),
    );
  }
}
