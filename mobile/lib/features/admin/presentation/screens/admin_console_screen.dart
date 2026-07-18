import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
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

/// ADMIN-only console: manage users, teams and view the audit log.
class AdminConsoleScreen extends StatelessWidget {
  const AdminConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                AdminUsersBloc(Injector.adminRepository)..add(AdminUsersLoadEvent())),
        BlocProvider(
            create: (_) =>
                TeamsBloc(Injector.teamsRepository)..add(TeamsLoadEvent())),
        BlocProvider(
            create: (_) =>
                AuditLogBloc(Injector.adminRepository)..add(AuditLogLoadEvent())),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin'),
            bottom: const TabBar(tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Teams'),
              Tab(text: 'Audit'),
            ]),
          ),
          body: const TabBarView(children: [
            _UsersTab(),
            _TeamsTab(),
            _AuditTab(),
          ]),
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
    final role = await showDialog<Role>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Change role'),
        children: Role.values
            .map((r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r),
                child: Text(r.name)))
            .toList(),
      ),
    );
    if (role != null && role != u.role && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminChangeRoleEvent(u.id, role));
    }
  }

  Future<void> _assignTeam(BuildContext context, AgentResponse u) async {
    final teamsState = context.read<TeamsBloc>().state;
    final teams = teamsState is TeamsLoaded ? teamsState.teams : const [];
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No teams yet')));
      return;
    }
    final teamId = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Assign to team'),
        children: teams
            .map((t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, t.id),
                child: Text(t.name)))
            .toList(),
      ),
    );
    if (teamId != null && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminAssignTeamEvent(u.id, teamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _invite(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Invite'),
      ),
      body: BlocConsumer<AdminUsersBloc, AdminUsersState>(
        listener: (ctx, state) {
          if (state is AdminInviteSuccess) {
            showInviteResultDialog(ctx, state.user);
          }
          if (state is AdminUsersActionSuccess) {
            ScaffoldMessenger.of(ctx)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AdminUsersError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
        },
        builder: (ctx, state) {
          if (state is AdminUsersLoading || state is AdminUsersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminUsersError) {
            return ErrorWidget2(
                message: state.message,
                onRetry: () =>
                    ctx.read<AdminUsersBloc>().add(AdminUsersLoadEvent()));
          }
          if (state is AdminUsersLoaded) {
            if (state.users.isEmpty) {
              return const EmptyState(
                  title: 'No users', icon: Icons.people_outline);
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ctx.read<AdminUsersBloc>().add(AdminUsersLoadEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: state.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('New team'),
      ),
      body: BlocConsumer<TeamsBloc, TeamsState>(
        listener: (ctx, state) {
          if (state is TeamsActionSuccess) {
            ScaffoldMessenger.of(ctx)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is TeamsError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
        },
        builder: (ctx, state) {
          if (state is TeamsLoading || state is TeamsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeamsError) {
            return ErrorWidget2(
                message: state.message,
                onRetry: () => ctx.read<TeamsBloc>().add(TeamsLoadEvent()));
          }
          if (state is TeamsLoaded) {
            if (state.teams.isEmpty) {
              return const EmptyState(
                  title: 'No teams', icon: Icons.groups_outlined);
            }
            return RefreshIndicator(
              onRefresh: () async => ctx.read<TeamsBloc>().add(TeamsLoadEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: state.teams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final t = state.teams[i];
                  return TeamCard(
                    team: t,
                    onTap: () => showTeamStatsSheet(context, t.id),
                    onEdit: () => _edit(context, t),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ─────────────────────────── Audit ───────────────────────────
class _AuditTab extends StatelessWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuditLogBloc, AuditLogState>(
      builder: (ctx, state) {
        if (state is AuditLogLoading || state is AuditLogInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuditLogError) {
          return ErrorWidget2(
              message: state.message,
              onRetry: () => ctx.read<AuditLogBloc>().add(AuditLogLoadEvent()));
        }
        if (state is AuditLogLoaded) {
          if (state.entries.isEmpty) {
            return const EmptyState(
                title: 'No audit entries', icon: Icons.receipt_long_outlined);
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ctx.read<AuditLogBloc>().add(AuditLogLoadEvent()),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: state.entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _AuditRow(entry: state.entries[i]),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _AuditRow extends StatelessWidget {
  final AuditLogResponse entry;
  const _AuditRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final subtitle = [
      if (entry.entityType != null)
        '${entry.entityType}${entry.entityId != null ? ' #${entry.entityId}' : ''}',
      if (entry.actorEmail != null) entry.actorEmail!,
      if (entry.createdAt != null) formatDateTime(entry.createdAt!),
    ].join(' • ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          const Icon(Icons.history, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.action,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: tt.bodySmall),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
