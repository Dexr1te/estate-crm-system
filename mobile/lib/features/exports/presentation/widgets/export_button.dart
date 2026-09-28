import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Only managers and admins take the book out; the server refuses anyone
/// else, and the action is not offered to them.
bool canExport(BuildContext context) => context.isAdminOrManager;

/// [child] for someone who may export, nothing for anyone else; follows the
/// session as it signs in.
class ExportGate extends StatelessWidget {
  final Widget child;
  const ExportGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, _) => canExport(ctx) ? child : const SizedBox.shrink(),
      );
}

/// Asks for the options, downloads the file and hands it to the share sheet.
/// [onBusy] is told when the download starts and ends.
Future<void> runExport(
  BuildContext context, {
  required ExportKind kind,
  required ExportFilters filters,
  required ValueChanged<bool> onBusy,
}) async {
  final l10n = AppLocalizations.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final delimiter =
      await showExportSheet(context, kind: kind, filters: filters);
  if (delimiter == null || !context.mounted) return;

  onBusy(true);
  String? problem;
  try {
    final file = await Injector.exportsRepository
        .export(kind, filters: filters, lang: lang, delimiter: delimiter);
    final outcome = await Injector.shareGateway.shareFile(
      SharedFile(
        fileName: file.fileName,
        bytes: file.bytes,
        mimeType: ExportFile.mimeType,
      ),
      subject: exportTitle(l10n, kind),
    );
    if (outcome == ShareOutcome.failed) problem = l10n.exportFailed;
  } catch (error) {
    problem = ApiFailure.from(error).serverCode == 'EXPORT_TOO_MANY_ROWS'
        ? l10n.exportTooMany
        : l10n.exportFailed;
  }
  onBusy(false);
  if (problem != null && context.mounted) {
    showActionUnavailable(context, problem);
  }
}

/// The header action of a list screen: exports what the list shows now.
class ExportButton extends StatefulWidget {
  final ExportKind kind;
  final ExportFilters filters;

  const ExportButton({super.key, required this.kind, required this.filters});

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _busy = false;

  void _setBusy(bool busy) {
    if (mounted) setState(() => _busy = busy);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExportGate(
        child: Semantics(
      button: true,
      enabled: !_busy,
      label: l10n.exportAction,
      child: AppIconTile(
        key: ValueKey('export-${widget.kind.path}'),
        icon: _busy ? Icons.hourglass_top_rounded : Icons.ios_share_rounded,
        tooltip: l10n.exportAction,
        onPressed: () {
          if (_busy) return;
          runExport(context,
              kind: widget.kind, filters: widget.filters, onBusy: _setBusy);
        },
      ),
    ));
  }
}
