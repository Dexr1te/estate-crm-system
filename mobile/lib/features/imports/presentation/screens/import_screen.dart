import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_bloc.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_event.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_state.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_labels.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_preview_view.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// An agency's clients or listings brought in from a CSV: pick a file, check
/// what it would bring in, import, see what happened.
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ImportBloc(Injector.importsRepository),
        child: const _ImportFlow(),
      );
}

class _ImportFlow extends StatelessWidget {
  const _ImportFlow();

  void _onChange(BuildContext context, ImportState state) {
    final l10n = AppLocalizations.of(context);
    if (state.failure != null || state.fileProblem != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(importFailureLabel(l10n, state)),
          backgroundColor: context.tokens.dangerSolid,
        ));
    }
    if (state.phase == ImportPhase.done && (state.result?.created ?? 0) > 0) {
      // The lists behind this screen are stale the moment rows go in.
      if (state.kind == ImportKind.clients) {
        context.read<ClientsBloc?>()?.add(ClientsLoadEvent());
      } else {
        context.read<PropertiesBloc?>()?.add(PropertiesLoadEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ImportBloc, ImportState>(
      listenWhen: (a, b) =>
          b.failure != null ||
          b.fileProblem != null ||
          (a.phase != b.phase && b.phase == ImportPhase.done),
      listener: _onChange,
      builder: (context, state) {
        final bloc = context.read<ImportBloc>();
        switch (state.phase) {
          case ImportPhase.choosing:
            return DetailScaffold(
              title: l10n.importTitle,
              children: const [_HowTo(), _KindCards()],
            );
          case ImportPhase.reading:
            return DetailScaffold(
              title: l10n.importTitle,
              children: const [
                ShimmerInfoCard(rows: 2, heading: true),
                ShimmerInfoCard(rows: 4, heading: true),
                ShimmerInfoCard(rows: 3, heading: true),
              ],
            );
          case ImportPhase.preview:
          case ImportPhase.remapping:
          case ImportPhase.importing:
            return ImportPreviewView(
              state: state,
              onBack: () => bloc.add(ImportRestarted()),
            );
          case ImportPhase.done:
            return _ResultView(state: state);
        }
      },
    );
  }
}

class _HowTo extends StatelessWidget {
  const _HowTo();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      child: Text(
        AppLocalizations.of(context).importHowTo,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 13,
            height: 1.4,
            color: t.textSecondary),
      ),
    );
  }
}

class _KindCards extends StatelessWidget {
  const _KindCards();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KindCard(kind: ImportKind.clients),
        SizedBox(height: 12),
        _KindCard(kind: ImportKind.properties),
      ],
    );
  }
}

class _KindCard extends StatefulWidget {
  final ImportKind kind;
  const _KindCard({required this.kind});

  @override
  State<_KindCard> createState() => _KindCardState();
}

class _KindCardState extends State<_KindCard> {
  bool _templateBusy = false;

  Future<void> _pick() async {
    final file = await Injector.fileGateway.pickFile();
    if (file == null || !mounted) return;
    context.read<ImportBloc>().add(ImportFileChosen(widget.kind, file));
  }

  Future<void> _template() async {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    setState(() => _templateBusy = true);
    var outcome = ShareOutcome.failed;
    try {
      final bytes =
          await Injector.importsRepository.template(widget.kind, lang);
      outcome = await Injector.shareGateway.shareFile(
        SharedFile(
          fileName: '${widget.kind.path}-template.csv',
          bytes: Uint8List.fromList(bytes),
          mimeType: 'text/csv',
        ),
        subject: l10n.importTitle,
      );
    } catch (_) {
      outcome = ShareOutcome.failed;
    }
    if (!mounted) return;
    setState(() => _templateBusy = false);
    if (outcome == ShareOutcome.failed) {
      showActionUnavailable(context, l10n.importTemplateFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final clients = widget.kind == ImportKind.clients;

    return AppCard(
      key: ValueKey('import-kind-${widget.kind.path}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                  clients
                      ? Icons.people_alt_outlined
                      : Icons.home_work_outlined,
                  size: 20,
                  color: t.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  clients ? l10n.importKindClients : l10n.importKindProperties,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            clients
                ? l10n.importKindClientsHint
                : l10n.importKindPropertiesHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
          const SizedBox(height: 14),
          AppFilledButton(
            key: ValueKey('import-pick-${widget.kind.path}'),
            label: l10n.importChooseFile,
            onPressed: _pick,
          ),
          const SizedBox(height: 8),
          AppGhostButton(
            key: ValueKey('import-template-${widget.kind.path}'),
            label: l10n.importDownloadTemplate,
            icon: Icons.download_rounded,
            loading: _templateBusy,
            onPressed: _templateBusy ? null : _template,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ImportState state;
  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final result = state.result ?? ImportResult(kind: state.kind);
    final clients = state.kind == ImportKind.clients;

    return DetailScaffold(
      title: l10n.importTitle,
      bottomAction: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFilledButton(
            key: const ValueKey('import-open-list'),
            label: clients ? l10n.importOpenClients : l10n.importOpenProperties,
            onPressed: () => context.go(clients ? '/clients' : '/properties'),
          ),
          const SizedBox(height: 8),
          AppGhostButton(
            label: l10n.importAnother,
            onPressed: () => context.read<ImportBloc>().add(ImportRestarted()),
          ),
        ],
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 22, color: t.chartWon),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.importDoneTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoRow(
                  key: const ValueKey('import-created'),
                  label: l10n.importCreated,
                  value: '${result.created}'),
              if (clients)
                InfoRow(
                    label: l10n.importSkipped,
                    value: '${result.skippedDuplicates}'),
              InfoRow(label: l10n.importInvalid, value: '${result.invalid}'),
            ],
          ),
        ),
      ],
    );
  }
}
