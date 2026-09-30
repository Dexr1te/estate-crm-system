import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:real_estate_crm/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/agents/data/datasources/agents_remote_datasource.dart';
import 'package:real_estate_crm/features/agents/data/repositories/agents_repository_impl.dart';
import 'package:real_estate_crm/features/agents/domain/repositories/agents_repository.dart';
import 'package:real_estate_crm/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:real_estate_crm/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:real_estate_crm/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:real_estate_crm/features/app_lock/data/app_lock_repository_impl.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_repository.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';
import 'package:real_estate_crm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:real_estate_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/checklist/data/datasources/checklist_remote_datasource.dart';
import 'package:real_estate_crm/features/checklist/data/repositories/checklist_repository_impl.dart';
import 'package:real_estate_crm/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:real_estate_crm/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/data/datasources/cold_clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:real_estate_crm/features/clients/data/repositories/cold_clients_repository_impl.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:real_estate_crm/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/deals/data/datasources/deal_comments_remote_datasource.dart';
import 'package:real_estate_crm/features/deals/data/datasources/deals_remote_datasource.dart';
import 'package:real_estate_crm/features/deals/data/repositories/deal_comments_repository_impl.dart';
import 'package:real_estate_crm/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/documents/data/datasources/documents_remote_datasource.dart';
import 'package:real_estate_crm/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:real_estate_crm/features/documents/domain/repositories/documents_repository.dart';
import 'package:real_estate_crm/features/exports/data/datasources/exports_remote_datasource.dart';
import 'package:real_estate_crm/features/exports/data/repositories/exports_repository_impl.dart';
import 'package:real_estate_crm/features/exports/domain/repositories/exports_repository.dart';
import 'package:real_estate_crm/features/imports/data/datasources/imports_remote_datasource.dart';
import 'package:real_estate_crm/features/imports/data/repositories/imports_repository_impl.dart';
import 'package:real_estate_crm/features/imports/domain/repositories/imports_repository.dart';
import 'package:real_estate_crm/features/meetings/data/datasources/meetings_remote_datasource.dart';
import 'package:real_estate_crm/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/message_templates/data/datasources/message_templates_remote_datasource.dart';
import 'package:real_estate_crm/features/message_templates/data/repositories/message_templates_repository_impl.dart';
import 'package:real_estate_crm/features/message_templates/domain/repositories/message_templates_repository.dart';
import 'package:real_estate_crm/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:real_estate_crm/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:real_estate_crm/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:real_estate_crm/features/properties/data/datasources/properties_remote_datasource.dart';
import 'package:real_estate_crm/features/properties/data/repositories/properties_repository_impl.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/route/data/repositories/day_route_repository_impl.dart';
import 'package:real_estate_crm/features/route/domain/repositories/day_route_repository.dart';
import 'package:real_estate_crm/features/search/data/repositories/search_repository_impl.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_crm/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:real_estate_crm/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:real_estate_crm/features/teams/data/datasources/teams_remote_datasource.dart';
import 'package:real_estate_crm/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';

class Injector {
  Injector._();

  static final SessionStore session = SessionStore();
  static final ApiClient _apiClient =
      ApiClient(session, offlineCache: OfflineCache.device());

  static ApiClient get apiClient => _apiClient;

  static AuthRepository authRepository =
      AuthRepositoryImpl(AuthRemoteDataSource(_apiClient), session);

  static ClientsRepository clientsRepository =
      ClientsRepositoryImpl(ClientsRemoteDataSource(_apiClient));

  static ColdClientsRepository coldClientsRepository =
      ColdClientsRepositoryImpl(ColdClientsRemoteDataSource(_apiClient));

  static PropertiesRepository propertiesRepository =
      PropertiesRepositoryImpl(PropertiesRemoteDataSource(_apiClient));

  static DealsRepository dealsRepository =
      DealsRepositoryImpl(DealsRemoteDataSource(_apiClient));

  static DealCommentsRepository dealCommentsRepository =
      DealCommentsRepositoryImpl(DealCommentsRemoteDataSource(_apiClient));

  static ChecklistRepository checklistRepository =
      ChecklistRepositoryImpl(ChecklistRemoteDataSource(_apiClient));

  static MessageTemplatesRepository messageTemplatesRepository =
      MessageTemplatesRepositoryImpl(
          MessageTemplatesRemoteDataSource(_apiClient));

  static DocumentsRepository documentsRepository =
      DocumentsRepositoryImpl(DocumentsRemoteDataSource(_apiClient));

  /// The PIN on the app, kept per user in the keychain.
  static AppLockRepository appLockRepository = AppLockRepositoryImpl();

  static AppLockController appLock =
      AppLockController(repository: appLockRepository);

  static FileGateway fileGateway = const DeviceFileGateway();

  static ShareGateway shareGateway = const DeviceShareGateway();

  /// Listings set aside for comparison, kept per signed-in user.
  static ComparisonTray comparisonTray =
      ComparisonTray(scope: () => session.cacheScope);

  static QuickActions quickActions = const QuickActions();

  static MeetingsRepository meetingsRepository =
      MeetingsRepositoryImpl(MeetingsRemoteDataSource(_apiClient));

  static NotificationsRepository notificationsRepository =
      NotificationsRepositoryImpl(NotificationsRemoteDataSource(_apiClient));

  static Duration? notificationsPollInterval = const Duration(seconds: 60);

  static TasksRepository tasksRepository =
      TasksRepositoryImpl(TasksRemoteDataSource(_apiClient));

  static DashboardRepository dashboardRepository =
      DashboardRepositoryImpl(DashboardRemoteDataSource(_apiClient));

  static AnalyticsRepository analyticsRepository =
      AnalyticsRepositoryImpl(AnalyticsRemoteDataSource(_apiClient));

  static AgentsRepository agentsRepository =
      AgentsRepositoryImpl(AgentsRemoteDataSource(_apiClient));

  static AdminRepository adminRepository =
      AdminRepositoryImpl(AdminRemoteDataSource(_apiClient));

  static TeamsRepository teamsRepository =
      TeamsRepositoryImpl(TeamsRemoteDataSource(_apiClient));

  static ImportsRepository importsRepository =
      ImportsRepositoryImpl(ImportsRemoteDataSource(_apiClient));

  static DayRouteRepository get dayRouteRepository =>
      DayRouteRepositoryImpl(meetingsRepository, propertiesRepository);

  static ExportsRepository exportsRepository =
      ExportsRepositoryImpl(ExportsRemoteDataSource(_apiClient));

  static SearchRepository get searchRepository => SearchRepositoryImpl(
      clientsRepository, propertiesRepository, dealsRepository);

  static String appVersion = '';

  static Future<void> bootstrap() async {
    await session.load();
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version} (${info.buildNumber})';
    } catch (_) {}
  }
}
