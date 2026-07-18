import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/deals/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/meetings/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/properties/bloc/properties_bloc.dart';

class MyApp extends StatefulWidget {
  final ApiService api;
  const MyApp({super.key, required this.api});
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
    _authBloc = AuthBloc(widget.api)..add(AuthCheckEvent());
    _themeBloc = ThemeBloc()..add(ThemeLoadEvent());
    _dashboardBloc = DashboardBloc(widget.api);
    _clientsBloc = ClientsBloc(widget.api);
    _propertiesBloc = PropertiesBloc(widget.api);
    _dealsBloc = DealsBloc(widget.api);
    _meetingsBloc = MeetingsBloc(widget.api);
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
