import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_card.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_stats_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

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
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final t = context.tokens;
          final pad = AppMetrics.pagePadding(context);

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: AppMetrics.constrain(
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 10, pad, 14),
                      child: ScreenTitle(l10n.teamsMyTeam),
                    ),
                    Expanded(
                      child: BlocConsumer<TeamsBloc, TeamsState>(
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
                              cardBuilder: () => const ShimmerBox(
                                  width: double.infinity,
                                  height: 66,
                                  radius: 14),
                            );
                          }
                          if (state is TeamsError) {
                            return ErrorWidget2(
                                message: state.message,
                                onRetry: () =>
                                    ctx.read<TeamsBloc>().add(TeamsLoadEvent()));
                          }
                          if (state is! TeamsLoaded) {
                            return const SizedBox.shrink();
                          }

                          if (state.teams.isEmpty) {
                            return EmptyState(
                                title: l10n.teamsNoTeamYet,
                                icon: Icons.groups_outlined,
                                subtitle: l10n.teamsNoTeamSubtitle);
                          }

                          return RefreshIndicator(
                            onRefresh: () async =>
                                ctx.read<TeamsBloc>().add(TeamsLoadEvent()),
                            color: t.primary,
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                              itemCount: state.teams.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 9),
                              itemBuilder: (_, i) => TeamCard(
                                team: state.teams[i],
                                onTap: () => showTeamStatsSheet(
                                    context, state.teams[i].id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          pad, 0, pad, 16 + AppMetrics.bottomInset(context)),
                      child: AppFilledButton(
                        label: l10n.teamsInviteAgent,
                        onPressed: () => _inviteAgent(context),
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

/// Invite-agent sheet (name/email/phone). Role and scope default server-side.
Future<Map<String, dynamic>?> _showInviteAgentSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final l10n = AppLocalizations.of(context);

  return showAppBottomSheet<Map<String, dynamic>>(
    context,
    title: l10n.teamsInviteAgent,
    builder: (ctx) => Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            label: l10n.teamsSendInvite,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, {
                'fullName': name.text.trim(),
                'email': email.text.trim(),
                if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
              });
            },
          ),
        ],
      ),
    ),
  );
}
