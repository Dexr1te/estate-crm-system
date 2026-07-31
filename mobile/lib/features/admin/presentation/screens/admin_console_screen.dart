import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_state.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/audit_log_bloc.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/invite_result_dialog.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/invite_user_sheet.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/user_card.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/user_stats_sheet.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_card.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_form_sheet.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_stats_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// ADMIN-only console (screens 4m–4p): one screen with a segmented tab bar
/// over users, teams and the audit log.
class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pad = AppMetrics.pagePadding(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => AdminUsersBloc(Injector.adminRepository)
              ..add(AdminUsersLoadEvent())),
        BlocProvider(
            create: (_) =>
                TeamsBloc(Injector.teamsRepository)..add(TeamsLoadEvent())),
        BlocProvider(
            create: (_) => AuditLogBloc(Injector.adminRepository)
              ..add(AuditLogLoadEvent())),
      ],
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: AppMetrics.constrain(
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ScreenTitle(l10n.adminConsoleTitle),
                      const SizedBox(height: 14),
                      SegmentedTabs(
                        labels: [
                          l10n.adminTabUsers,
                          l10n.adminTabTeams,
                          l10n.adminTabAudit,
                        ],
                        selectedIndex: _tab,
                        onSelected: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: const [_UsersTab(), _TeamsTab(), _AuditTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Users ───────────────────────────

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  Future<void> _invite(BuildContext context) async {
    final body = await showInviteUserSheet(context);
    if (body != null && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminInviteUserEvent(body));
    }
  }

  Future<void> _changeRole(BuildContext context, AgentResponse u) async {
    final l10n = AppLocalizations.of(context);
    final role = await showAppBottomSheet<Role>(
      context,
      title: l10n.adminChangeRole,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < Role.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _SheetOption(
              label: roleLabel(l10n, Role.values[i]),
              selected: u.role == Role.values[i],
              onTap: () => Navigator.pop(ctx, Role.values[i]),
            ),
          ],
        ],
      ),
    );
    if (role != null && role != u.role && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminChangeRoleEvent(u.id, role));
    }
  }

  Future<void> _assignTeam(BuildContext context, AgentResponse u) async {
    final l10n = AppLocalizations.of(context);
    final teamsState = context.read<TeamsBloc>().state;
    final teams =
        teamsState is TeamsLoaded ? teamsState.teams : const <TeamResponse>[];
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.adminNoTeamsYet)));
      return;
    }
    final teamId = await showAppBottomSheet<int>(
      context,
      title: l10n.adminAssignToTeam,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < teams.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _SheetOption(
              label: teams[i].name,
              selected: false,
              onTap: () => Navigator.pop(ctx, teams[i].id),
            ),
          ],
        ],
      ),
    );
    if (teamId != null && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminAssignTeamEvent(u.id, teamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);

    return BlocConsumer<AdminUsersBloc, AdminUsersState>(
      listener: (ctx, state) {
        if (state is AdminInviteSuccess) showInviteResultDialog(ctx, state.user);
        showActionOutcome(ctx, state);
        if (state is AdminUsersError) {
          ScaffoldMessenger.of(ctx)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: t.dangerSolid));
        }
      },
      builder: (ctx, state) {
        if (state is AdminUsersLoading || state is AdminUsersInitial) {
          return ShimmerList(
            count: 5,
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
            cardBuilder: () => const UserCardBone(),
          );
        }
        if (state is AdminUsersError) {
          return ErrorWidget2(
              message: state.message,
              onRetry: () =>
                  ctx.read<AdminUsersBloc>().add(AdminUsersLoadEvent()));
        }
        if (state is! AdminUsersLoaded) return const SizedBox.shrink();

        if (state.users.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: EmptyState(
                    title: l10n.adminNoUsers, icon: Icons.people_outline),
              ),
              _InviteCta(onPressed: () => _invite(context), pad: pad),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    ctx.read<AdminUsersBloc>().add(AdminUsersLoadEvent()),
                color: t.primary,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                  itemCount: state.users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (_, i) {
                    final u = state.users[i];
                    return UserCard(
                      user: u,
                      onStats: () => showUserStatsSheet(context, u.id),
                      onChangeRole: () => _changeRole(context, u),
                      onAssignTeam: () => _assignTeam(context, u),
                      onResendInvite: () => context
                          .read<AdminUsersBloc>()
                          .add(AdminResendInviteEvent(u.id)),
                      onToggleActive: () => context.read<AdminUsersBloc>().add(
                          u.isActive
                              ? AdminDeactivateUserEvent(u.id)
                              : AdminActivateUserEvent(u.id)),
                    );
                  },
                ),
              ),
            ),
            _InviteCta(onPressed: () => _invite(context), pad: pad),
          ],
        );
      },
    );
  }
}

/// The full-width invite button that closes the Users tab, as drawn in 4m.
class _InviteCta extends StatelessWidget {
  final VoidCallback onPressed;
  final double pad;
  const _InviteCta({required this.onPressed, required this.pad});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            pad, 0, pad, 16 + AppMetrics.bottomInset(context)),
        child: AppFilledButton(
          label: AppLocalizations.of(context).adminInviteUser,
          onPressed: onPressed,
        ),
      );
}

// ─────────────────────────── Teams ───────────────────────────

class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  List<AgentResponse> _managers(BuildContext context) {
    final s = context.read<AdminUsersBloc>().state;
    if (s is AdminUsersLoaded) {
      return s.users.where((u) => u.role == Role.MANAGER).toList();
    }
    return const [];
  }

  Future<void> _create(BuildContext context) async {
    final body = await showTeamFormSheet(context, managers: _managers(context));
    if (body != null && context.mounted) {
      context.read<TeamsBloc>().add(TeamsCreateEvent(body));
    }
  }

  Future<void> _edit(BuildContext context, TeamResponse team) async {
    final body = await showTeamFormSheet(context,
        existing: team, managers: _managers(context));
    if (body != null && context.mounted) {
      context.read<TeamsBloc>().add(TeamsUpdateEvent(team.id, body));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);

    return BlocConsumer<TeamsBloc, TeamsState>(
      listener: (ctx, state) {
        showActionOutcome(ctx, state);
        if (state is TeamsError) {
          ScaffoldMessenger.of(ctx)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: t.dangerSolid));
        }
      },
      builder: (ctx, state) {
        if (state is TeamsLoading || state is TeamsInitial) {
          return ShimmerList(
            count: 3,
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
            cardBuilder: () => const UserCardBone(),
          );
        }
        if (state is TeamsError) {
          return ErrorWidget2(
              message: state.message,
              onRetry: () => ctx.read<TeamsBloc>().add(TeamsLoadEvent()));
        }
        if (state is! TeamsLoaded) return const SizedBox.shrink();

        return Column(
          children: [
            Expanded(
              child: state.teams.isEmpty
                  ? EmptyState(
                      title: l10n.adminNoTeams, icon: Icons.groups_outlined)
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ctx.read<TeamsBloc>().add(TeamsLoadEvent()),
                      color: t.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                        itemCount: state.teams.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 9),
                        itemBuilder: (_, i) => TeamCard(
                          team: state.teams[i],
                          onTap: () =>
                              showTeamStatsSheet(context, state.teams[i].id),
                          onEdit: () => _edit(context, state.teams[i]),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  pad, 0, pad, 16 + AppMetrics.bottomInset(context)),
              child: AppFilledButton(
                label: l10n.adminNewTeam,
                onPressed: () => _create(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── Audit ───────────────────────────

class _AuditTab extends StatelessWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pad = AppMetrics.pagePadding(context);

    return BlocBuilder<AuditLogBloc, AuditLogState>(
      builder: (ctx, state) {
        if (state is AuditLogLoading || state is AuditLogInitial) {
          return ShimmerList(
            count: 5,
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
            cardBuilder: () => const UserCardBone(),
          );
        }
        if (state is AuditLogError) {
          return ErrorWidget2(
              message: state.message,
              onRetry: () => ctx.read<AuditLogBloc>().add(AuditLogLoadEvent()));
        }
        if (state is! AuditLogLoaded) return const SizedBox.shrink();

        if (state.entries.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.adminNoAuditEntries,
            subtitle: l10n.adminAuditEmptyBody,
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ctx.read<AuditLogBloc>().add(AuditLogLoadEvent()),
          color: ctx.tokens.primary,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
                pad, 0, pad, 24 + AppMetrics.bottomInset(context)),
            itemCount: state.entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: (_, i) => _AuditRow(entry: state.entries[i]),
          ),
        );
      },
    );
  }
}

class _AuditRow extends StatelessWidget {
  final AuditLogResponse entry;
  const _AuditRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final meta = [
      if (entry.entityType != null)
        '${entry.entityType}${entry.entityId != null ? ' #${entry.entityId}' : ''}',
      if (entry.actorEmail != null) entry.actorEmail!,
      if (entry.createdAt != null) formatWeekdayDate(entry.createdAt!, locale),
    ].join(' · ');

    return AppCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.action,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: t.textPrimary),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              meta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// A selectable row inside a picker sheet.
class _SheetOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SheetOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: t.textPrimary),
            ),
          ),
          if (selected) Icon(Icons.check_rounded, size: 18, color: t.accent),
        ],
      ),
    );
  }
}
