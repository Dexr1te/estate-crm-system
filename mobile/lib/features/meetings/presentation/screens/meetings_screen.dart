import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

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
                  itemBuilder: (_, i) => MeetingCard(
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
