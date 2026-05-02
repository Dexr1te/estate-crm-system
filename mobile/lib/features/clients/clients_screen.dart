import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'clients_bloc.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<ClientsBloc>().add(ClientsLoadEvent());
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClientListItem> _filter(List<ClientListItem> all) {
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all
        .where((c) =>
            c.fullName.toLowerCase().contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false) ||
            (c.phone?.contains(q) ?? false))
        .toList();
  }

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
                child: Text('Clients',
                    style: tt.titleLarge?.copyWith(fontSize: 22))),
            FilledButton.icon(
              onPressed: () => context.go('/clients/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Client'),
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
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                    hintText: 'Search clients...',
                    prefixIcon: Icon(Icons.search, size: 20)))),
        const SizedBox(height: 16),
        Expanded(
            child: BlocConsumer<ClientsBloc, ClientsState>(
          listener: (ctx, state) {
            if (state is ClientsError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error));
            }
            if (state is ClientsActionSuccess) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            if (state is ClientsLoading) {
              return ShimmerList(cardBuilder: () => const ClientCardSkeleton());
            }
            if (state is ClientsError) {
              return ErrorWidget2(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<ClientsBloc>().add(ClientsLoadEvent()));
            }
            if (state is ClientsLoaded) {
              final filtered = _filter(state.clients);
              if (filtered.isEmpty) {
                return EmptyState(
                    title: 'No clients found',
                    icon: Icons.people_outline,
                    subtitle: _search.isNotEmpty
                        ? 'Try a different search'
                        : 'Add your first client');
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ctx.read<ClientsBloc>().add(ClientsLoadEvent()),
                color: cs.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ClientCard(
                    client: filtered[i],
                    onTap: () => context.go('/clients/${filtered[i].id}'),
                    onEdit: () => context.go('/clients/${filtered[i].id}/edit'),
                    onDelete: () async {
                      final ok = await showConfirmDialog(ctx,
                          title: 'Delete Client',
                          content: 'Delete "${filtered[i].fullName}"?');
                      if (ok && ctx.mounted) {
                        ctx
                            .read<ClientsBloc>()
                            .add(ClientsDeleteEvent(filtered[i].id));
                      }
                    },
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

class _ClientCard extends StatelessWidget {
  final ClientListItem client;
  final VoidCallback onTap, onEdit, onDelete;
  const _ClientCard(
      {required this.client,
      required this.onTap,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
        child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primary.withAlpha(26),
                  child: Text(
                      client.fullName.isNotEmpty
                          ? client.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Sora'))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(client.fullName,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (client.email != null)
                      Text(client.email!, style: tt.bodySmall),
                  ])),
              if (client.status != null) DealStatusChip(status: client.status!),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
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
            if (client.propertyTitle != null || client.budget != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(children: [
                if (client.propertyTitle != null)
                  Expanded(
                      child: Row(children: [
                    Icon(Icons.home_outlined,
                        size: 14, color: tt.bodySmall?.color),
                    const SizedBox(width: 4),
                    Flexible(
                        child: Text(client.propertyTitle!,
                            style: tt.bodySmall,
                            overflow: TextOverflow.ellipsis))
                  ])),
                if (client.budget != null)
                  Row(children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 14, color: tt.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(formatPrice(client.budget!),
                        style:
                            tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))
                  ]),
              ]),
            ],
            if (client.nextMeetingAt != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.accent),
                const SizedBox(width: 4),
                Text('Next: ${formatDateTime(client.nextMeetingAt!)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500))
              ]),
            ],
          ])),
    ));
  }
}
