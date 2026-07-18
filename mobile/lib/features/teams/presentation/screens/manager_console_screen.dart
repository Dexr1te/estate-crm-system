import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_card.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_stats_sheet.dart';

/// MANAGER-only console: view their team(s) and invite agents into the team.
class ManagerConsoleScreen extends StatelessWidget {
  const ManagerConsoleScreen({super.key});

  Future<void> _inviteAgent(BuildContext context) async {
    final body = await _showInviteAgentSheet(context);
    if (body != null && context.mounted) {
      context.read<TeamsBloc>().add(TeamsInviteAgentEvent(body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamsBloc(Injector.teamsRepository)..add(TeamsLoadEvent()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('My Team')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _inviteAgent(context),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Invite agent'),
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
                      title: 'No team yet',
                      icon: Icons.groups_outlined,
                      subtitle: 'You are not managing a team');
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ctx.read<TeamsBloc>().add(TeamsLoadEvent()),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: state.teams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = state.teams[i];
                      return TeamCard(
                          team: t,
                          onTap: () => showTeamStatsSheet(context, t.id));
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

/// Simple invite-agent sheet (name/email/phone). Role/scope default server-side.
Future<Map<String, dynamic>?> _showInviteAgentSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite agent',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx, {
                      'fullName': name.text.trim(),
                      'email': email.text.trim(),
                      if (phone.text.trim().isNotEmpty)
                        'phone': phone.text.trim(),
                    });
                  },
                  child: const Text('Send invite'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
