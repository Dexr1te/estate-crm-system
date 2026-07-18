import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

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

              // Group deals by client ID
              final grouped = <int, List<ClientListItem>>{};
              for (final c in filtered) {
                grouped.putIfAbsent(c.id, () => []).add(c);
              }
              final uniqueClients =
                  grouped.values.map((deals) => deals.first).toList();

              return RefreshIndicator(
                onRefresh: () async =>
                    ctx.read<ClientsBloc>().add(ClientsLoadEvent()),
                color: cs.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: uniqueClients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final client = uniqueClients[i];
                    final clientRows = grouped[client.id]!;
                    final dealCount = clientRows
                        .where((c) =>
                            c.propertyTitle != null ||
                            c.budget != null ||
                            c.status != null)
                        .length;
                    return ClientCard(
                      client: client,
                      dealCount: dealCount,
                      canDelete: context.isAdmin,
                      onTap: () => context.go('/clients/${client.id}'),
                      onEdit: () => context.go('/clients/${client.id}/edit'),
                      onDelete: () async {
                        final ok = await showConfirmDialog(ctx,
                            title: 'Delete Client',
                            content: 'Delete "${client.fullName}"?');
                        if (ok && ctx.mounted) {
                          ctx
                              .read<ClientsBloc>()
                              .add(ClientsDeleteEvent(client.id));
                        }
                      },
                    );
                  },
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
