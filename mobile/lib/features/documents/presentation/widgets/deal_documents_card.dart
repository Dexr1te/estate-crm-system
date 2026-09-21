import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_event.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealDocumentsCard extends StatelessWidget {
  const DealDocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return BlocConsumer<DocumentsBloc, DocumentsState>(
      listener: showActionOutcome,
      builder: (context, state) {
        final loaded = state is DocumentsLoaded ? state : null;
        final uploading = loaded?.uploading ?? false;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: EyebrowLabel(l10n.documentsTitle)),
                  if (loaded != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      l10n.documentsCount(loaded.documents.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          color: t.textHint),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 13),
              _Body(state: state),
              const SizedBox(height: 13),
              AppGhostButton(
                label: uploading ? l10n.documentsUploading : l10n.documentsAdd,
                height: AppMetrics.buttonHeightInline,
                onPressed: uploading
                    ? null
                    : () => context
                        .read<DocumentsBloc>()
                        .add(DocumentsUploadEvent()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final DocumentsState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final state = this.state;

    if (state is DocumentsError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            apiFailureLabel(l10n, state.failure),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 12, color: t.dangerText),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: 150,
            child: AppGhostButton(
              label: l10n.coreRetry,
              height: AppMetrics.buttonHeightInline,
              onPressed: () =>
                  context.read<DocumentsBloc>().add(DocumentsLoadEvent()),
            ),
          ),
        ],
      );
    }

    if (state is! DocumentsLoaded) {
      return const ShimmerGroup(
        child: Column(children: [
          _RowBone(),
          SizedBox(height: 14),
          _RowBone(),
        ]),
      );
    }

    if (state.documents.isEmpty) {
      return Text(
        l10n.documentsEmpty,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12.5,
            height: 1.45,
            color: t.textSecondary),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < state.documents.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          DocumentRow(
            document: state.documents[i],
            busy: state.busyIds.contains(state.documents[i].id),
          ),
        ],
      ],
    );
  }
}

class _RowBone extends StatelessWidget {
  const _RowBone();

  @override
  Widget build(BuildContext context) => const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 34, height: 34, radius: 10),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerBar(widthFactor: 0.55, height: 12),
                SizedBox(height: 8),
                ShimmerBar(widthFactor: 0.35, height: 10),
              ],
            ),
          ),
        ],
      );
}

class DocumentRow extends StatelessWidget {
  final DocumentResponse document;
  final bool busy;

  const DocumentRow({super.key, required this.document, required this.busy});

  bool _canDelete(BuildContext context) =>
      context.isAdminOrManager ||
      (document.uploadedById != null &&
          document.uploadedById == context.currentUserId);

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DocumentsBloc>();
    final ok = await showConfirmDialog(
      context,
      title: l10n.documentsDeleteTitle,
      content: l10n.documentsDeleteConfirm(document.fileName),
    );
    if (ok) bloc.add(DocumentsDeleteEvent(document.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final meta = [
      if (document.fileType.isNotEmpty) document.fileType.toUpperCase(),
      documentSizeLabel(l10n, document.fileSize),
      if (document.uploadedAt != null)
        formatFullDate(document.uploadedAt!, locale),
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        onTap: busy
            ? null
            : () => context.read<DocumentsBloc>().add(
                  DocumentsOpenEvent(document),
                ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(documentIcon(document.fileType),
                    size: 17, color: t.textSecondary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          color: t.textHint),
                    ),
                    if (document.uploadedByName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.documentsUploadedBy(document.uploadedByName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11,
                            color: t.textHint),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (busy)
                SizedBox(
                  width: AppMetrics.minHitTarget,
                  height: AppMetrics.minHitTarget,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: t.primary),
                    ),
                  ),
                )
              else if (_canDelete(context))
                AppIconTile(
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  tooltip: l10n.documentsDeleteTitle,
                  onPressed: () => _delete(context),
                )
              else
                SizedBox(
                  width: AppMetrics.minHitTarget,
                  height: AppMetrics.minHitTarget,
                  child: Icon(Icons.file_download_outlined,
                      size: 16, color: t.textHint),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String documentSizeLabel(AppLocalizations l10n, int bytes) {
  const kb = 1024;
  const mb = kb * 1024;

  if (bytes >= mb) return l10n.documentsSizeMb((bytes / mb).toStringAsFixed(1));
  if (bytes >= kb) return l10n.documentsSizeKb('${(bytes / kb).round()}');
  return l10n.documentsSizeBytes('$bytes');
}

IconData documentIcon(String fileType) {
  switch (fileType) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'heic':
    case 'webp':
    case 'gif':
      return Icons.image_outlined;
    case 'xls':
    case 'xlsx':
    case 'csv':
    case 'ods':
      return Icons.table_chart_outlined;
    case 'zip':
      return Icons.folder_zip_outlined;
    default:
      return Icons.description_outlined;
  }
}
