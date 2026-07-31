import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientDetailScreen extends StatefulWidget {
  final int id;
  const ClientDetailScreen({super.key, required this.id});
  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientResponse? _client;
  List<DealResponse> _deals = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        Injector.clientsRepository.getClient(widget.id),
        Injector.dealsRepository.getDeals(),
      ]);
      if (!mounted) return;
      setState(() {
        _client = results[0] as ClientResponse;
        _deals = (results[1] as List<DealResponse>)
            .where((d) => d.clientId == widget.id)
            .toList();
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).clientsClientNotFound;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final client = _client!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.clientsDeleteClient,
      content: l10n.clientsDeleteCascade(_deals.length, client.fullName),
    );
    if (!ok || !mounted) return;
    context.read<ClientsBloc>().add(ClientsDeleteEvent(widget.id));
    context.go('/clients');
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: '${widget.id}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).clientsClientIdCopied),
          duration: const Duration(seconds: 1)));
  }

  Future<void> _call() async {
    final l10n = AppLocalizations.of(context);
    if (!await ContactActions.call(_client?.phone) && mounted) {
      showActionUnavailable(context, l10n.clientsNoPhone);
    }
  }

  Future<void> _message() async {
    final l10n = AppLocalizations.of(context);
    if (!await ContactActions.email(_client?.email) && mounted) {
      showActionUnavailable(context, l10n.clientsNoEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final client = _client;

    if (_loading || client == null) {
      return DetailScaffold(
        title: client?.fullName ?? l10n.clientsClientFallback,
        children: [
          if (_error != null)
            EmptyState(
                icon: Icons.person_off_outlined,
                title: _error!,
                action: AppGhostButton(label: l10n.coreRetry, onPressed: _load))
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerBox(
                    width: double.infinity,
                    height: 84,
                    radius: AppMetrics.radiusMd),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 190,
                    radius: AppMetrics.radiusMd),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 150,
                    radius: AppMetrics.radiusMd),
              ]),
            ),
        ],
      );
    }

    return DetailScaffold(
      title: client.fullName,
      onRefresh: _load,
      actions: detailActions(
        onEdit: () => context.push('/clients/${widget.id}/edit'),
        onDelete: context.isAdmin ? _delete : null,
        editTooltip: l10n.clientsEdit,
        deleteTooltip: l10n.clientsDelete,
      ),
      children: [
        _IdentityCard(client: client, onCopyId: _copyId),
        _ContactCard(client: client, onCall: _call, onMessage: _message),
        _DealsCard(deals: _deals),
        if (client.notes != null && client.notes!.trim().isNotEmpty)
          _NotesCard(client: client),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final ClientResponse client;
  final VoidCallback onCopyId;
  const _IdentityCard({required this.client, required this.onCopyId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.isDark ? t.surfaceVariant : t.primary,
            ),
            child: Text(
              client.fullName.trim().isNotEmpty
                  ? client.fullName.trim()[0].toUpperCase()
                  : '?',
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: t.accent),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 18,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    ClientTypeChip(type: client.type),
                    GestureDetector(
                      onTap: onCopyId,
                      child: StatusChip(
                          label: l10n.clientsIdBadge(client.id),
                          hue: StatusHue.neutral),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ClientResponse client;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  const _ContactCard(
      {required this.client, required this.onCall, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const dash = '—';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.clientsContact),
          const SizedBox(height: 12),
          InfoRow(label: l10n.clientsPhone, value: client.phone ?? dash),
          const SizedBox(height: 10),
          InfoRow(label: l10n.clientsEmail, value: client.email ?? dash),
          const SizedBox(height: 10),
          InfoRow(label: l10n.clientsAgent, value: client.agentName ?? dash),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppFilledButton(
                  label: l10n.coreCall,
                  onPressed: onCall,
                  height: AppMetrics.minHitTarget,
                  fontSize: 12.5,
                  radius: 11,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppGhostButton(
                  label: l10n.clientsMessage,
                  onPressed: onMessage,
                  height: AppMetrics.minHitTarget,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DealsCard extends StatelessWidget {
  final List<DealResponse> deals;
  const _DealsCard({required this.deals});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.clientsDeals)),
              Text('${deals.length}',
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (deals.isEmpty)
            Text(
              l10n.dealsEmptyTitle,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            )
          else
            for (var i = 0; i < deals.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _DealRow(deal: deals[i]),
            ],
        ],
      ),
    );
  }
}

class _DealRow extends StatelessWidget {
  final DealResponse deal;
  const _DealRow({required this.deal});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final price = deal.dealPrice ?? deal.budget;

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: () => context.push('/deals/${deal.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              DealStatusChip(status: deal.status),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  deal.propertyTitle ?? l10n.dealsFallbackTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ),
              if (price != null && price > 0) ...[
                const SizedBox(width: 8),
                Text(
                  formatPrice(price),
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final ClientResponse client;
  const _NotesCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.clientsNotes),
          const SizedBox(height: 9),
          Text(
            client.notes!,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.55,
                color: t.textSecondary),
          ),
          if (client.updatedAt != null) ...[
            const SizedBox(height: 11),
            Text(
              l10n.clientsUpdatedAt(
                  formatWeekdayDate(client.updatedAt!, locale)),
              style: TextStyle(
                  fontFamily: AppFonts.sans, fontSize: 11, color: t.textHint),
            ),
          ],
        ],
      ),
    );
  }
}
