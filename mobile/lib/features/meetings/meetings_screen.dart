import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'meetings_bloc.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});
  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(MeetingsLoadEvent());
  }

  Future<void> _delete(int id) async {
    final ok = await showConfirmDialog(context,
        title: 'Delete Meeting', content: 'Delete this meeting?');
    if (!ok) return;
    // ignore: use_build_context_synchronously
    context.read<MeetingsBloc>().add(MeetingsDeleteEvent(id));
  }

  void _complete(int id) =>
      context.read<MeetingsBloc>().add(MeetingsCompleteEvent(id));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(children: [
            Expanded(
                child: Text('Meetings',
                    style: tt.titleLarge?.copyWith(fontSize: 22))),
            FilledButton.icon(
              onPressed: () => context.go('/meetings/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Schedule'),
              style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ]),
        ),
        Expanded(
            child: BlocConsumer<MeetingsBloc, MeetingsState>(
          listener: (ctx, state) {
            if (state is MeetingsError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error));
            }
            if (state is MeetingsActionSuccess) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            if (state is MeetingsLoading) {
              return ShimmerList(
                  cardBuilder: () => const MeetingCardSkeleton());
            }
            if (state is MeetingsError) {
              return ErrorWidget2(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<MeetingsBloc>().add(MeetingsLoadEvent()));
            }
            if (state is MeetingsLoaded) {
              if (state.meetings.isEmpty) {
                return const EmptyState(
                    title: 'No meetings',
                    icon: Icons.calendar_today_outlined,
                    subtitle: 'Schedule your first meeting');
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ctx.read<MeetingsBloc>().add(MeetingsLoadEvent()),
                color: cs.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: state.meetings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MeetingCard(
                    meeting: state.meetings[i],
                    onComplete: () => _complete(state.meetings[i].id),
                    onEdit: () =>
                        context.go('/meetings/${state.meetings[i].id}/edit'),
                    onDelete: () => _delete(state.meetings[i].id),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        )),
      ])),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingResponse meeting;
  final VoidCallback onComplete, onEdit, onDelete;
  const _MeetingCard(
      {required this.meeting,
      required this.onComplete,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: meeting.completed
                      ? AppColors.success.withAlpha(26)
                      : cs.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                    meeting.completed
                        ? Icons.check_circle
                        : Icons.calendar_today,
                    color: meeting.completed ? AppColors.success : cs.primary,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(meeting.title,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(meeting.clientName, style: tt.bodySmall),
                  ])),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'complete') onComplete();
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (!meeting.completed)
                    const PopupMenuItem(
                        value: 'complete',
                        child: Row(children: [
                          Icon(Icons.check, size: 16, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Mark Complete')
                        ])),
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit')
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error))
                      ])),
                ],
                child:
                    Icon(Icons.more_vert, color: tt.bodySmall?.color, size: 20),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.access_time_outlined,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(formatDateTime(meeting.scheduledAt),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500)),
              if (meeting.location != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined,
                    size: 14, color: tt.bodySmall?.color),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(meeting.location!,
                        style: tt.bodySmall, overflow: TextOverflow.ellipsis)),
              ],
            ]),
            if (meeting.completed)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(26),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Completed',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  )),
          ])),
    );
  }
}
