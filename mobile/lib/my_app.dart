import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/goal/goal_bloc.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final LocaleBloc _localeBloc;
  late final GoalBloc _goalBloc;
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
    Injector.apiClient.onSessionExpired = () {
      if (!_authBloc.isClosed) _authBloc.add(AuthLogoutEvent());
    };
    _themeBloc = ThemeBloc()..add(ThemeLoadEvent());
    _localeBloc = LocaleBloc()..add(LocaleLoadEvent());
    _goalBloc = GoalBloc()..add(GoalLoadEvent());
    _dashboardBloc = DashboardBloc(Injector.dashboardRepository,
        Injector.meetingsRepository, Injector.dealsRepository);
    _clientsBloc = ClientsBloc(Injector.clientsRepository);
    _propertiesBloc = PropertiesBloc(Injector.propertiesRepository);
    _dealsBloc = DealsBloc(Injector.dealsRepository);
    _meetingsBloc = MeetingsBloc(Injector.meetingsRepository);
    router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    Injector.apiClient.onSessionExpired = null;
    _authBloc.close();
    _themeBloc.close();
    _localeBloc.close();
    _goalBloc.close();
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
        BlocProvider.value(value: _localeBloc),
        BlocProvider.value(value: _goalBloc),
        BlocProvider.value(value: _dashboardBloc),
        BlocProvider.value(value: _clientsBloc),
        BlocProvider.value(value: _propertiesBloc),
        BlocProvider.value(value: _dealsBloc),
        BlocProvider.value(value: _meetingsBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev is AuthAuthenticated && curr is! AuthAuthenticated,
        listener: (_, __) {
          _dashboardBloc.add(DashboardResetEvent());
          _clientsBloc.add(ClientsResetEvent());
          _propertiesBloc.add(PropertiesResetEvent());
          _dealsBloc.add(DealsResetEvent());
          _meetingsBloc.add(MeetingsResetEvent());
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          buildWhen: (prev, curr) => prev.mode != curr.mode,
          builder: (context, themeState) =>
              BlocBuilder<LocaleBloc, LocaleState>(
            buildWhen: (prev, curr) => prev.locale != curr.locale,
            builder: (context, localeState) => MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              theme: AppTheme.light,
              darkTheme: AppThemeDark.dark,
              themeMode: themeState.mode,
              locale: localeState.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              builder: (context, child) => MediaQuery.withClampedTextScaling(
                minScaleFactor: 1.0,
                maxScaleFactor: 1.3,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
