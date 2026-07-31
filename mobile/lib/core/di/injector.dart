import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:real_estate_crm/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/agents/data/datasources/agents_remote_datasource.dart';
import 'package:real_estate_crm/features/agents/data/repositories/agents_repository_impl.dart';
import 'package:real_estate_crm/features/agents/domain/repositories/agents_repository.dart';
import 'package:real_estate_crm/features/teams/data/datasources/teams_remote_datasource.dart';
import 'package:real_estate_crm/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:real_estate_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:real_estate_crm/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/deals/data/datasources/deals_remote_datasource.dart';
import 'package:real_estate_crm/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/meetings/data/datasources/meetings_remote_datasource.dart';
import 'package:real_estate_crm/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/properties/data/datasources/properties_remote_datasource.dart';
import 'package:real_estate_crm/features/properties/data/repositories/properties_repository_impl.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';

class Injector {
  Injector._();

  static final SessionStore session = SessionStore();
  static final ApiClient _apiClient = ApiClient(session);

  static ApiClient get apiClient => _apiClient;

  static AuthRepository authRepository =
      AuthRepositoryImpl(AuthRemoteDataSource(_apiClient), session);

  static ClientsRepository clientsRepository =
      ClientsRepositoryImpl(ClientsRemoteDataSource(_apiClient));

  static PropertiesRepository propertiesRepository =
      PropertiesRepositoryImpl(PropertiesRemoteDataSource(_apiClient));

  static DealsRepository dealsRepository =
      DealsRepositoryImpl(DealsRemoteDataSource(_apiClient));

  static MeetingsRepository meetingsRepository =
      MeetingsRepositoryImpl(MeetingsRemoteDataSource(_apiClient));

  static DashboardRepository dashboardRepository =
      DashboardRepositoryImpl(DashboardRemoteDataSource(_apiClient));

  static AgentsRepository agentsRepository =
      AgentsRepositoryImpl(AgentsRemoteDataSource(_apiClient));

  static AdminRepository adminRepository =
      AdminRepositoryImpl(AdminRemoteDataSource(_apiClient));

  static TeamsRepository teamsRepository =
      TeamsRepositoryImpl(TeamsRemoteDataSource(_apiClient));

  static Future<void> bootstrap() => session.load();
}
