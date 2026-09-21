import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/join_requests_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class WaitingForTeamScreen extends StatefulWidget {
  const WaitingForTeamScreen({super.key});

  @override
  State<WaitingForTeamScreen> createState() => _WaitingForTeamScreenState();
}

class _WaitingForTeamScreenState extends State<WaitingForTeamScreen>
    with WidgetsBindingObserver {
  late final JoinRequestsBloc _bloc = JoinRequestsBloc(Injector.teamsRepository)
    ..add(JoinRequestsLoadEvent());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_bloc.isClosed) {
      _bloc.add(JoinRequestsLoadEvent());
      context.read<AuthBloc>().add(AuthRefreshMeEvent());
    }
  }

  Future<void> _decline(
      BuildContext context, TeamJoinRequestResponse request) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.authDeclineRequestTitle,
      content: l10n.authDeclineRequestBody(request.teamName),
      confirmLabel: l10n.authDeclineRequest,
      icon: Icons.close_rounded,
    );
    if (ok && !_bloc.isClosed) {
      _bloc.add(JoinRequestsDeclineEvent(request.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    final email = context
        .select<AuthBloc, String>((bloc) => bloc.currentUser?.email ?? '');

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: SafeArea(
          child: AppMetrics.constrain(
            BlocConsumer<JoinRequestsBloc, JoinRequestsState>(
              listener: (ctx, state) {
                showActionOutcome(ctx, state);
                if (state is JoinRequestsAccepted) {
                  ctx.read<AuthBloc>().add(AuthRefreshMeEvent());
                }
              },
              builder: (ctx, state) {
                final requests = state is JoinRequestsLoaded
                    ? state.requests
                    : const <TeamJoinRequestResponse>[];
                return RefreshIndicator(
                  color: t.primary,
                  onRefresh: () async {
                    ctx.read<AuthBloc>().add(AuthRefreshMeEvent());
                    ctx.read<JoinRequestsBloc>().add(JoinRequestsLoadEvent());
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppIconTile(
                            icon: Icons.person_outline_rounded,
                            tooltip: l10n.profileTitle,
                            onPressed: () => ctx.go('/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ScreenTitle(
                        l10n.authWaitingTitle,
                        subtitle: l10n.authWaitingSubtitle,
                      ),
                      const SizedBox(height: 16),
                      _EmailCard(email: email),
                      const SizedBox(height: 22),
                      SectionHeader(title: l10n.teamsPending),
                      const SizedBox(height: 10),
                      if (state is JoinRequestsLoading ||
                          state is JoinRequestsInitial)
                        const ShimmerGroup(child: _RequestCardBone())
                      else if (state is JoinRequestsError)
                        ErrorWidget2(
                          message: apiFailureLabel(l10n, state.failure),
                          onRetry: () => ctx
                              .read<JoinRequestsBloc>()
                              .add(JoinRequestsLoadEvent()),
                        )
                      else if (requests.isEmpty)
                        EmptyState(
                          title: l10n.authWaitingNoRequests,
                          subtitle: l10n.authWaitingNoRequestsBody,
                          icon: Icons.mark_email_unread_outlined,
                        )
                      else
                        for (final request in requests) ...[
                          _RequestCard(
                            request: request,
                            onAccept: () => ctx
                                .read<JoinRequestsBloc>()
                                .add(JoinRequestsAcceptEvent(request.id)),
                            onDecline: () => _decline(ctx, request),
                          ),
                          const SizedBox(height: 9),
                        ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  final String email;
  const _EmailCard({required this.email});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EyebrowLabel(l10n.authEmail),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppIconTile(
            icon: Icons.copy_rounded,
            tooltip: l10n.authWaitingCopyEmail,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: email));
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    SnackBar(content: Text(l10n.authWaitingEmailCopied)));
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TeamJoinRequestResponse request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialAvatar(name: request.teamName, size: 38),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authInvitedByTeam(request.teamName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    if (request.invitedByName != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        l10n.authInvitedBy(request.invitedByName!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12.5,
                            color: t.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppFilledButton(
                  label: l10n.authAcceptRequest,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AppGhostButton(
                  label: l10n.authDeclineRequest,
                  onPressed: onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCardBone extends StatelessWidget {
  const _RequestCardBone();

  @override
  Widget build(BuildContext context) => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 160, height: 14),
            SizedBox(height: 8),
            ShimmerBox(width: 100, height: 12),
            SizedBox(height: 16),
            ShimmerBox(width: double.infinity, height: 44, radius: 12),
          ],
        ),
      );
}
