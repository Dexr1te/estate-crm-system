import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/message_templates/presentation/bloc/message_templates_bloc.dart';
import 'package:real_estate_crm/features/message_templates/presentation/bloc/message_templates_event.dart';
import 'package:real_estate_crm/features/message_templates/presentation/bloc/message_templates_state.dart';
import 'package:real_estate_crm/features/message_templates/presentation/widgets/message_template_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager keeps the messages the agency's agents send clients.
class MessageTemplatesScreen extends StatelessWidget {
  const MessageTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => MessageTemplatesBloc(Injector.messageTemplatesRepository)
          ..add(MessageTemplatesLoadEvent()),
        child: const _TemplatesView(),
      );
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  Future<void> _edit(BuildContext context, [MessageTemplate? template]) async {
    final bloc = context.read<MessageTemplatesBloc>();
    final draft = await showMessageTemplateSheet(context, initial: template);
    if (draft != null) {
      bloc.add(MessageTemplatesSaveEvent(
          id: template?.id, title: draft.title, body: draft.body));
    }
  }

  Future<void> _delete(BuildContext context, MessageTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MessageTemplatesBloc>();
    final ok = await showConfirmDialog(
      context,
      title: l10n.templatesDeleteTitle,
      content: l10n.templatesDeleteBody(template.title),
    );
    if (ok) bloc.add(MessageTemplatesDeleteEvent(template.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageTemplatesBloc, MessageTemplatesState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final t = context.tokens;
        final loaded = state.status == MessageTemplatesStatus.loaded;
        return DetailScaffold(
          title: l10n.templatesTitle,
          bottomAction: loaded
              ? AppFilledButton(
                  key: const Key('template-new'),
                  label: l10n.templatesAdd,
                  loading: state.saving,
                  onPressed: state.saving ? null : () => _edit(context),
                )
              : null,
          children: [
            Text(
              l10n.templatesIntro,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.textSecondary),
            ),
            if (state.status == MessageTemplatesStatus.loading)
              const _TemplateBones(),
            if (state.status == MessageTemplatesStatus.error)
              EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.templatesLoadFailed,
                action: AppGhostButton(
                  label: l10n.coreRetry,
                  onPressed: () => context
                      .read<MessageTemplatesBloc>()
                      .add(MessageTemplatesLoadEvent()),
                ),
              ),
            if (loaded && state.templates.isEmpty)
              EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.templatesEmpty,
                subtitle: l10n.templatesEmptyBody,
              ),
            if (loaded)
              for (final template in state.templates)
                MessageTemplateCard(
                  key: ValueKey('template-${template.id}'),
                  template: template,
                  onTap: state.saving ? null : () => _edit(context, template),
                  onDelete:
                      state.saving ? null : () => _delete(context, template),
                ),
          ],
        );
      },
    );
  }
}

/// A template in the manager's list: its title, the start of its text, and
/// a way to delete it. Tapping it opens the editor.
class MessageTemplateCard extends StatelessWidget {
  final MessageTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MessageTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  template.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      height: 1.4,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppIconTile(
            key: ValueKey('template-delete-${template.id}'),
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.templatesDelete,
            onPressed: onDelete ?? () {},
          ),
        ],
      ),
    );
  }
}

class _TemplateBones extends StatelessWidget {
  const _TemplateBones();

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Bone(),
            SizedBox(height: 14),
            _Bone(),
            SizedBox(height: 14),
            _Bone(),
          ],
        ),
      );
}

class _Bone extends StatelessWidget {
  const _Bone();

  @override
  Widget build(BuildContext context) => const ShimmerCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBar(widthFactor: 0.45, height: 13),
            SizedBox(height: 12),
            ShimmerBar(widthFactor: 0.9),
            SizedBox(height: 8),
            ShimmerBar(widthFactor: 0.7),
          ],
        ),
      );
}
