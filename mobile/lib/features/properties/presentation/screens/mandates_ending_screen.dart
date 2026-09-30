import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_state.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Every listing still for sale whose seller agreement ends within two weeks
/// or has ended, soonest first.
class MandatesEndingScreen extends StatefulWidget {
  const MandatesEndingScreen({super.key});

  @override
  State<MandatesEndingScreen> createState() => _MandatesEndingScreenState();
}

class _MandatesEndingScreenState extends State<MandatesEndingScreen> {
  final _bloc = MandatesBloc(Injector.propertiesRepository)
    ..add(MandatesLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<MandatesBloc, MandatesState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.propertiesMandatesTitle,
          trailingLabel:
              state is MandatesLoaded ? '${state.properties.length}' : null,
          onRefresh: () async => _bloc.add(MandatesLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, MandatesState state, AppLocalizations l10n) {
    if (state is MandatesError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.propertiesMandatesLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(MandatesLoadEvent())),
        ),
      ];
    }
    if (state is! MandatesLoaded) {
      return [for (var i = 0; i < 4; i++) const MandateRowBone()];
    }
    if (state.properties.isEmpty) {
      return [
        EmptyState(
          icon: Icons.handshake_outlined,
          title: l10n.propertiesMandatesEmpty,
          subtitle: l10n.propertiesMandatesEmptyHint,
        ),
      ];
    }
    return [
      for (final property in state.properties)
        MandateRow(
          property: property,
          onTap: () => context.push('/properties/${property.id}'),
        ),
    ];
  }
}
