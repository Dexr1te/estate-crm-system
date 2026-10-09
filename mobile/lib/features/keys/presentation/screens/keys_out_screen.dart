import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/keys_out_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/key_out_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Every listing whose keys are out, the overdue ones first: who to chase
/// for them. A row opens its listing, where the keys are taken back.
class KeysOutScreen extends StatefulWidget {
  const KeysOutScreen({super.key});

  @override
  State<KeysOutScreen> createState() => _KeysOutScreenState();
}

class _KeysOutScreenState extends State<KeysOutScreen> {
  final _bloc = KeysOutBloc(Injector.keysRepository)..add(KeysOutLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _open(int propertyId) async {
    await context.push('/properties/$propertyId');
    if (mounted) _bloc.add(KeysOutLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<KeysOutBloc, KeysOutState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.keysOutTitle,
          trailingLabel: state is KeysOutLoaded ? '${state.keys.length}' : null,
          onRefresh: () async => _bloc.add(KeysOutLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, KeysOutState state, AppLocalizations l10n) {
    if (state is KeysOutError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.keysOutLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(KeysOutLoadEvent())),
        ),
      ];
    }
    if (state is! KeysOutLoaded) {
      return [for (var i = 0; i < 4; i++) const KeyOutRowBone()];
    }
    if (state.keys.isEmpty) {
      return [
        EmptyState(
          icon: Icons.key_outlined,
          title: l10n.keysOutEmpty,
          subtitle: l10n.keysOutEmptyHint,
        ),
      ];
    }
    return [
      for (final handover in state.keys)
        KeyOutRow(
          handover: handover,
          onTap: () => _open(handover.propertyId),
        ),
    ];
  }
}
