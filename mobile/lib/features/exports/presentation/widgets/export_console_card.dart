import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_button.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager console's way out: the whole book, one kind per row, with no
/// list filters.
class ExportConsoleCard extends StatelessWidget {
  const ExportConsoleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return ExportGate(
        child: AppCard(
      key: const ValueKey('export-console'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.exportConsoleTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.textPrimary)),
          const SizedBox(height: 4),
          Text(l10n.exportConsoleSubtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  color: t.textSecondary)),
          const SizedBox(height: 10),
          for (final kind in ExportKind.values) _ExportRow(kind: kind),
        ],
      ),
    ));
  }
}

class _ExportRow extends StatefulWidget {
  final ExportKind kind;
  const _ExportRow({required this.kind});

  @override
  State<_ExportRow> createState() => _ExportRowState();
}

class _ExportRowState extends State<_ExportRow> {
  bool _busy = false;

  void _setBusy(bool busy) {
    if (mounted) setState(() => _busy = busy);
  }

  String _label(AppLocalizations l10n) => switch (widget.kind) {
        ExportKind.clients => l10n.exportKindClients,
        ExportKind.properties => l10n.exportKindProperties,
        ExportKind.deals => l10n.exportKindDeals,
      };

  IconData get _icon => switch (widget.kind) {
        ExportKind.clients => Icons.people_outline_rounded,
        ExportKind.properties => Icons.home_work_outlined,
        ExportKind.deals => Icons.handshake_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return InkWell(
      key: ValueKey('export-console-${widget.kind.path}'),
      borderRadius: BorderRadius.circular(10),
      onTap: _busy
          ? null
          : () => runExport(context,
              kind: widget.kind, filters: ExportFilters.none, onBusy: _setBusy),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
        child: Row(
          children: [
            Icon(_icon, size: 18, color: t.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary)),
            ),
            Icon(_busy ? Icons.hourglass_top_rounded : Icons.ios_share_rounded,
                size: 16, color: t.textHint),
          ],
        ),
      ),
    );
  }
}
