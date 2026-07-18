import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create once — never recreated on rebuild
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final DashboardBloc _dashboardBloc;
  late final ClientsBloc _clientsBloc;
  late final PropertiesBloc _propertiesBloc;
  late final DealsBloc _dealsBloc;
  late final MeetingsBloc _meetingsBloc;
  // ignore: prefer_typing_uninitialized_variables
  late final router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(Injector.authRepository)..add(AuthCheckEvent());
    _themeBloc = ThemeBloc()..add(ThemeLoadEvent());
    _dashboardBloc =
        DashboardBloc(Injector.dashboardRepository, Injector.meetingsRepository);
    _clientsBloc = ClientsBloc(Injector.clientsRepository);
    _propertiesBloc = PropertiesBloc(Injector.propertiesRepository);
    _dealsBloc = DealsBloc(Injector.dealsRepository);
    _meetingsBloc = MeetingsBloc(Injector.meetingsRepository);
    router = createRouter(_authBloc); // created once
  }

  @override
  void dispose() {
    _authBloc.close();
    _themeBloc.close();
    _dashboardBloc.close();
    _clientsBloc.close();
    _propertiesBloc.close();
    _dealsBloc.close();
    _meetingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeBloc),
        BlocProvider.value(value: _dashboardBloc),
        BlocProvider.value(value: _clientsBloc),
        BlocProvider.value(value: _propertiesBloc),
        BlocProvider.value(value: _dealsBloc),
        BlocProvider.value(value: _meetingsBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        // Only rebuild when theme actually changes, not on every state
        buildWhen: (prev, curr) => prev.mode != curr.mode,
        builder: (context, themeState) => MaterialApp.router(
          title: 'Estate CRM',
          theme: AppTheme.light,
          darkTheme: AppThemeDark.dark,
          themeMode: themeState.mode,
          routerConfig: router, // stable reference — no freeze!
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
