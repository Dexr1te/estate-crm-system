import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_state.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/member_card.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_stats_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ManagerConsoleScreen extends StatefulWidget {
  const ManagerConsoleScreen({super.key});

  @override
  State<ManagerConsoleScreen> createState() => _ManagerConsoleScreenState();
}

class _ManagerConsoleScreenState extends State<ManagerConsoleScreen> {
  int _tab = 0;

  Future<void> _addMember(BuildContext context, MyTeamBloc bloc) async {
    final body = await _showAddMemberSheet(context);
    if (body != null && !bloc.isClosed) {
      bloc.add(MyTeamAddMemberEvent(
        email: body.email,
        fullName: body.fullName,
        phone: body.phone,
      ));
    }
  }

  Future<void> _removeMember(
    BuildContext context,
    MyTeamBloc bloc,
    MyTeamLoaded state,
    TeamMemberResponse member,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (member.status == UserAccountStatus.pendingInvite) {
      final ok = await showConfirmDialog(
        context,
        title: l10n.teamsRemoveMemberTitle(member.fullName),
        content: l10n.teamsRemoveInviteBody(member.fullName),
        confirmLabel: l10n.teamsRemoveMember,
        icon: Icons.person_remove_outlined,
      );
      if (ok && !bloc.isClosed) {
        bloc.add(MyTeamRemoveMemberEvent(member.id, wasInvitePending: true));
      }
      return;
    }

    final candidates = state.members
        .where((m) => m.id != member.id && m.isActive)
        .where((m) => m.status == UserAccountStatus.active)
        .toList();
    final me =
        state.members.firstWhere((m) => m.isTeamManager, orElse: () => member);

    final picked = await showEntityPicker(
      context,
      title: l10n.teamsSuccessor,
      searchHint: l10n.teamsFullName,
      emptyLabel: l10n.teamsNoMembers,
      items: [
        for (final candidate in candidates)
          PickerItem(
            id: candidate.id,
            title: candidate.id == me.id
                ? l10n.teamsSuccessorMe
                : candidate.fullName,
            subtitle: candidate.email,
          ),
      ],
    );
    if (picked == null || !context.mounted) return;

    final ok = await showConfirmDialog(
      context,
      title: l10n.teamsRemoveMemberTitle(member.fullName),
      content: l10n.teamsRemoveMemberBody(
          candidates.firstWhere((c) => c.id == picked.id).fullName),
      confirmLabel: l10n.teamsRemoveMember,
      icon: Icons.person_remove_outlined,
    );
    if (ok && !bloc.isClosed) {
      bloc.add(MyTeamRemoveMemberEvent(member.id, replacementId: picked.id));
    }
  }

  Future<void> _memberActions(
    BuildContext context,
    MyTeamBloc bloc,
    MyTeamLoaded state,
    TeamMemberResponse member,
  ) async {
    if (member.isTeamManager) return;
    final l10n = AppLocalizations.of(context);
    final remove = await showAppBottomSheet<bool>(
      context,
      title: member.fullName,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: l10n.teamsEmail, value: member.email),
          if (member.phone != null && member.phone!.isNotEmpty)
            InfoRow(label: l10n.teamsPhoneOptional, value: member.phone!),
          const SizedBox(height: 16),
          AppGhostButton(
            label: l10n.teamsRemoveMember,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (remove == true && context.mounted) {
      await _removeMember(context, bloc, state, member);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyTeamBloc(Injector.teamsRepository)..add(MyTeamLoadEvent()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final t = context.tokens;
          final pad = AppMetrics.pagePadding(context);
          final bloc = context.read<MyTeamBloc>();

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: AppMetrics.constrain(
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 10, pad, 12),
                      child: BlocBuilder<MyTeamBloc, MyTeamState>(
                        builder: (ctx, state) => ScreenTitle(
                          state is MyTeamLoaded
                              ? state.team.name
                              : l10n.teamsMyTeam,
                          subtitle: state is MyTeamLoaded
                              ? l10n.teamsMemberCount(state.team.memberCount)
                              : null,
                          reserveSubtitle: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: BlocBuilder<MyTeamBloc, MyTeamState>(
                        builder: (ctx, state) => SegmentedTabs(
                          labels: [
                            l10n.teamsMembers,
                            state is MyTeamLoaded && state.pending.isNotEmpty
                                ? '${l10n.teamsPending} · ${state.pending.length}'
                                : l10n.teamsPending,
                          ],
                          selectedIndex: _tab,
                          onSelected: (index) => setState(() => _tab = index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocConsumer<MyTeamBloc, MyTeamState>(
                        listener: (ctx, state) {
                          showActionOutcome(ctx, state);
                          if (state is MyTeamError) {
                            ScaffoldMessenger.of(ctx)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  content: Text(
                                      apiFailureLabel(l10n, state.failure)),
                                  backgroundColor: t.dangerSolid));
                          }
                        },
                        builder: (ctx, state) {
                          if (state is MyTeamLoading ||
                              state is MyTeamInitial) {
                            return ShimmerList(
                              count: 3,
                              padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
                              cardBuilder: () => const MemberCardBone(),
                            );
                          }
                          if (state is MyTeamError) {
                            return ErrorWidget2(
                                message: apiFailureLabel(l10n, state.failure),
                                onRetry: () => ctx
                                    .read<MyTeamBloc>()
                                    .add(MyTeamLoadEvent()));
                          }
                          if (state is! MyTeamLoaded) {
                            return const SizedBox.shrink();
                          }

                          return RefreshIndicator(
                            color: t.primary,
                            onRefresh: () async =>
                                ctx.read<MyTeamBloc>().add(MyTeamLoadEvent()),
                            child: _tab == 0
                                ? _MembersList(
                                    state: state,
                                    padding:
                                        EdgeInsets.fromLTRB(pad, 0, pad, 16),
                                    onMember: (member) => _memberActions(
                                        ctx, bloc, state, member),
                                    onStats: () => showTeamStatsSheet(
                                        context, state.team.id),
                                  )
                                : _PendingList(
                                    state: state,
                                    padding:
                                        EdgeInsets.fromLTRB(pad, 0, pad, 16),
                                    onCancel: (request) => bloc.add(
                                        MyTeamCancelRequestEvent(request.id)),
                                  ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          pad, 0, pad, 16 + AppMetrics.bottomInset(context)),
                      child: AppFilledButton(
                        label: l10n.teamsAddAgent,
                        onPressed: () => _addMember(context, bloc),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  final MyTeamLoaded state;
  final EdgeInsetsGeometry padding;
  final ValueChanged<TeamMemberResponse> onMember;
  final VoidCallback onStats;

  const _MembersList({
    required this.state,
    required this.padding,
    required this.onMember,
    required this.onStats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.members.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          EmptyState(
            title: l10n.teamsNoMembers,
            subtitle: l10n.teamsNoMembersBody,
            icon: Icons.groups_outlined,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: padding,
      itemCount: state.members.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (_, i) {
        if (i == 0) {
          return SectionHeader(
            title: l10n.teamsMembers,
            actionLabel: l10n.teamsAgents,
            onAction: onStats,
          );
        }
        final member = state.members[i - 1];
        return MemberCard(
          member: member,
          onTap: member.isTeamManager ? null : () => onMember(member),
        );
      },
    );
  }
}

class _PendingList extends StatelessWidget {
  final MyTeamLoaded state;
  final EdgeInsetsGeometry padding;
  final ValueChanged<TeamJoinRequestResponse> onCancel;

  const _PendingList({
    required this.state,
    required this.padding,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    if (state.pending.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          EmptyState(
            title: l10n.teamsNoPending,
            subtitle: l10n.teamsNoPendingBody,
            icon: Icons.hourglass_empty_rounded,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: padding,
      itemCount: state.pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (_, i) {
        final request = state.pending[i];
        return AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppGhostButton(
                label: l10n.teamsCancelRequest,
                height: 38,
                onPressed: () => onCancel(request),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddMemberForm {
  final String email, fullName;
  final String? phone;
  const _AddMemberForm(this.email, this.fullName, this.phone);
}

Future<_AddMemberForm?> _showAddMemberSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final l10n = AppLocalizations.of(context);

  return showAppBottomSheet<_AddMemberForm>(
    context,
    title: l10n.teamsAddAgent,
    builder: (ctx) => Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.teamsAddAgentHint,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.45,
                color: ctx.tokens.textSecondary),
          ),
          const SizedBox(height: 14),
          LabelledField(
            label: l10n.teamsEmail,
            required: true,
            child: AppTextField(
              controller: email,
              hint: 'name@estatecrm.ru',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || !v.contains('@'))
                  ? l10n.teamsEnterValidEmail
                  : null,
            ),
          ),
          const SizedBox(height: 9),
          LabelledField(
            label: l10n.teamsFullName,
            required: true,
            child: AppTextField(
              controller: name,
              hint: l10n.teamsFullName,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.teamsRequired : null,
            ),
          ),
          const SizedBox(height: 9),
          LabelledField(
            label: l10n.teamsPhoneOptional,
            child: AppTextField(
              controller: phone,
              hint: '+7 ___ ___-__-__',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 18),
          AppFilledButton(
            label: l10n.teamsAddAgentAction,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                ctx,
                _AddMemberForm(
                  email.text.trim(),
                  name.text.trim(),
                  phone.text.trim().isEmpty ? null : phone.text.trim(),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
