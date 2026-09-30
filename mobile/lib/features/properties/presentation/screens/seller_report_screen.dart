import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_price_history.dart';
import 'package:real_estate_crm/features/properties/report/seller_report_text.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the agency has done for one listing, for its owner: how long it has
/// been up, the viewings and what came of them, what the public link brought
/// in, how the price moved and how many buyers it fits. Shared as plain text.
class SellerReportScreen extends StatefulWidget {
  final int propertyId;
  const SellerReportScreen({super.key, required this.propertyId});

  @override
  State<SellerReportScreen> createState() => _SellerReportScreenState();
}

class _SellerReportScreenState extends State<SellerReportScreen> {
  SellerReport? _report;
  ApiFailure? _failure;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failure = null);
    try {
      final report = await Injector.propertiesRepository
          .getSellerReport(widget.propertyId);
      if (!mounted) return;
      setState(() => _report = report);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _report = null;
        _failure = ApiFailure.from(e);
      });
    }
  }

  Future<void> _share() async {
    final report = _report;
    if (report == null || _sharing) return;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _sharing = true);
    var outcome = ShareOutcome.failed;
    try {
      outcome = await Injector.shareGateway.share(
        text: sellerReportText(report, l10n, locale),
        subject: l10n.propertiesReportTextHeading(report.title),
      );
    } catch (_) {
      outcome = ShareOutcome.failed;
    }
    if (!mounted) return;
    setState(() => _sharing = false);
    if (outcome == ShareOutcome.failed) {
      showActionUnavailable(context, l10n.propertiesReportShareFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = _report;
    final failure = _failure;

    return DetailScaffold(
      title: l10n.propertiesReport,
      onRefresh: report == null ? null : _load,
      bottomAction: report == null
          ? null
          : AppFilledButton(
              key: const ValueKey('seller-report-share'),
              label: l10n.propertiesReportShare,
              loading: _sharing,
              onPressed: _share,
            ),
      children: [
        if (failure != null)
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.propertiesReportLoadFailed,
            subtitle: apiFailureLabel(l10n, failure),
            action: AppGhostButton(label: l10n.coreRetry, onPressed: _load),
          )
        else if (report == null)
          const ShimmerGroup(
            child: Column(children: [
              ShimmerHeroCard(lines: 2, buttons: 0),
              SizedBox(height: 14),
              ShimmerMetricsCard(),
              SizedBox(height: 14),
              ShimmerInfoCard(rows: 4, heading: true),
              SizedBox(height: 14),
              ShimmerInfoCard(rows: 3, heading: true),
            ]),
          )
        else ...[
          _ReportHeader(report: report),
          MetricsCard(
            key: const ValueKey('seller-report-metrics'),
            metrics: [
              Metric(
                  value: '${report.daysOnMarket}',
                  caption: l10n.propertiesReportDaysOnMarket),
              Metric(
                  value: '${report.matchingBuyers}',
                  caption: l10n.propertiesReportMatchingBuyers),
              Metric(
                  value: '${report.viewings.held}',
                  caption: l10n.propertiesReportViewingsHeld),
              Metric(
                  value: '${report.viewings.upcoming}',
                  caption: l10n.propertiesReportViewingsUpcoming),
              Metric(
                  value: '${report.publicLink.views}',
                  caption: l10n.propertiesReportLinkViews),
              Metric(
                  value: '${report.publicLink.leads}',
                  caption: l10n.propertiesReportLinkLeads),
            ],
          ),
          _OutcomesCard(viewings: report.viewings),
          _PriceCard(price: report.price),
        ],
      ],
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final SellerReport report;
  const _ReportHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    String date(DateTime d) => formatFullDate(d.toLocal(), locale);
    final meta = [
      if (report.soldAt != null)
        l10n.propertiesReportSoldOn(date(report.soldAt!))
      else if (report.listedAt != null)
        l10n.propertiesReportListedOn(date(report.listedAt!)),
      if (report.generatedOn != null)
        l10n.propertiesReportAsOf(date(report.generatedOn!)),
    ].join(' · ');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              PropertyStatusChip(status: report.status),
            ],
          ),
          if (report.address.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              report.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  color: t.textSecondary),
            ),
          ],
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              meta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _OutcomesCard extends StatelessWidget {
  final SellerReportViewings viewings;
  const _OutcomesCard({required this.viewings});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final next = viewings.nextAt;

    return AppCard(
      key: const ValueKey('seller-report-outcomes'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesReportOutcomes),
          const SizedBox(height: 12),
          if (viewings.total == 0)
            Text(
              l10n.propertiesReportNoViewings,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            )
          else ...[
            for (final outcome in ViewingOutcome.values) ...[
              InfoRow(
                key: ValueKey('seller-report-outcome-${outcome.name}'),
                label: viewingOutcomeLabel(l10n, outcome),
                value: '${viewings.count(outcome)}',
              ),
              const SizedBox(height: 9),
            ],
            InfoRow(
              label: l10n.propertiesReportAwaitingOutcome,
              value: '${viewings.awaitingOutcome}',
            ),
          ],
          if (next != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.propertiesReportNextViewing(
                  formatFullDate(next.toLocal(), locale)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final SellerReportPrice price;
  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final changed = price.changes.isNotEmpty;

    return AppCard(
      key: const ValueKey('seller-report-price'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesReportPrice),
          const SizedBox(height: 12),
          if (changed) ...[
            InfoRow(
                label: l10n.propertiesReportOriginalPrice,
                value: formatPrice(price.original)),
            const SizedBox(height: 9),
          ],
          InfoRow(
              label: l10n.propertiesReportCurrentPrice,
              value: formatPrice(price.current)),
          if (changed) ...[
            const SizedBox(height: 9),
            InfoRow(
              label: l10n.propertiesReportPriceChange,
              value: formatPriceChangePercent(
                  price.original, price.current, locale),
            ),
            const SizedBox(height: 14),
            EyebrowLabel(l10n.propertiesReportPriceChanges),
            const SizedBox(height: 9),
            for (final c in price.changes) ...[
              InfoRow(
                label: c.changedAt == null
                    ? '—'
                    : formatFullDate(c.changedAt!.toLocal(), locale),
                value:
                    '${formatPrice(c.oldPrice)} → ${formatPrice(c.newPrice)}',
              ),
              const SizedBox(height: 7),
            ],
          ] else ...[
            const SizedBox(height: 10),
            Text(
              l10n.propertiesReportPriceUnchanged,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
