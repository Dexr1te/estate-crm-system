// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get adminActivate => 'Белсендіру';

  @override
  String get adminAssignTeam => 'Команда тағайындау';

  @override
  String get adminAssignToTeam => 'Командаға тағайындау';

  @override
  String get adminChangeRole => 'Рөлді өзгерту';

  @override
  String get adminConsoleTitle => 'Әкімшілік';

  @override
  String get adminCopyCode => 'Кодты көшіру';

  @override
  String get adminCouldNotLoadStats => 'Статистиканы жүктеу мүмкін болмады';

  @override
  String get adminCreateInvite => 'Шақыру жасау';

  @override
  String get adminDataScope => 'Деректер аясы';

  @override
  String get adminDeactivate => 'Өшіру';

  @override
  String get adminDone => 'Дайын';

  @override
  String get adminEmail => 'Электрондық пошта';

  @override
  String get adminEnterValidEmail => 'Жарамды email енгізіңіз';

  @override
  String get adminFullName => 'Толық аты-жөні';

  @override
  String get adminInactive => 'БЕЛСЕНДІ ЕМЕС';

  @override
  String get adminInvite => 'Шақыру';

  @override
  String get adminInviteCodeCopied => 'Шақыру коды көшірілді';

  @override
  String get adminInviteCreated => 'Шақыру жасалды';

  @override
  String get adminInviteInstructions =>
      'Олар қосымшаны ашып, кіру экранындағы «Шақыруыңыз бар ма?» түймесін басып, осы кодты қойып, өз құпия сөзін таңдайды.';

  @override
  String get adminInviteUser => 'Пайдаланушыны шақыру';

  @override
  String adminInvitedAs(String name, String email, String role) {
    return '$name ($email) $role ретінде шақырылды.';
  }

  @override
  String get adminNewTeam => 'Жаңа команда';

  @override
  String get adminNoAuditEntries => 'Аудит жазбалары жоқ';

  @override
  String get adminNoInviteToken =>
      'Шақыру токені қайтарылмады. Бұл шешілмейінше пайдаланушы құпия сөз орната алмайды.';

  @override
  String get adminNoTeams => 'Командалар жоқ';

  @override
  String get adminNoTeamsYet => 'Әзірге командалар жоқ';

  @override
  String get adminNoUsers => 'Пайдаланушылар жоқ';

  @override
  String get adminPhoneOptional => 'Телефон (міндетті емес)';

  @override
  String get adminRequired => 'Міндетті';

  @override
  String get adminResendInvite => 'Шақыруды қайта жіберу';

  @override
  String get adminRole => 'Рөл';

  @override
  String get adminShareInviteCode => 'Осы шақыру кодын олармен бөлісіңіз:';

  @override
  String get adminStatActive => 'Белсенді';

  @override
  String get adminStatClients => 'Клиенттер';

  @override
  String get adminStatClosed => 'Жабылған';

  @override
  String get adminStatDeals => 'Мәмілелер';

  @override
  String get adminStatUpcoming => 'Алдағы';

  @override
  String get adminTabAudit => 'Аудит';

  @override
  String get adminTabTeams => 'Командалар';

  @override
  String get adminTabUsers => 'Пайдаланушылар';

  @override
  String get adminViewStats => 'Статистиканы қарау';

  @override
  String get authAcceptInviteSubtitle =>
      'Сізге берілген шақыру кодын енгізіп, құпия сөз таңдаңыз.';

  @override
  String get authAcceptYourInvite => 'Шақыруыңызды қабылдаңыз';

  @override
  String get authBackToSignIn => 'Кіруге оралу';

  @override
  String get authConfirmPassword => 'Құпия сөзді растаңыз';

  @override
  String get authEmail => 'Электрондық пошта';

  @override
  String get authEmailInvalid => 'Жарамды электрондық пошта енгізіңіз';

  @override
  String get authEmailRequired => 'Электрондық поштаны енгізіңіз';

  @override
  String get authHaveAnInvite => 'Шақыруыңыз бар ма?';

  @override
  String get authInviteCode => 'Шақыру коды';

  @override
  String get authInviteCodeRequired => 'Шақыру кодын енгізіңіз';

  @override
  String get authNewPassword => 'Жаңа құпия сөз';

  @override
  String get authPassword => 'Құпия сөз';

  @override
  String get authPasswordMinLength => 'Кемінде 6 таңба';

  @override
  String get authPasswordRequired => 'Құпия сөзді енгізіңіз';

  @override
  String get authPasswordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get authSetPasswordContinue => 'Құпия сөзді орнатып, жалғастыру';

  @override
  String get authSignIn => 'Кіру';

  @override
  String get authSignInSubtitle => 'Нысандарыңызды басқару үшін кіріңіз';

  @override
  String get authWelcomeBack => 'Қайта оралуыңызбен!';

  @override
  String get clientsAddClient => 'Клиент қосу';

  @override
  String get clientsAddFirstClient => 'Алғашқы клиентіңізді қосыңыз';

  @override
  String get clientsAgent => 'Агент';

  @override
  String get clientsBuyer => '🏠 Сатып алушы';

  @override
  String get clientsCancel => 'Бас тарту';

  @override
  String clientsClientCreatedId(int id) {
    return 'Клиент құрылды (ID: $id)';
  }

  @override
  String get clientsClientFallback => 'Клиент';

  @override
  String get clientsClientIdCopied => 'Клиент ID көшірілді';

  @override
  String get clientsClientNotFound => 'Клиент табылмады';

  @override
  String get clientsClientType => 'Клиент түрі';

  @override
  String get clientsContact => 'Байланыс';

  @override
  String get clientsContactInfo => 'Байланыс ақпараты';

  @override
  String get clientsCreateClient => 'Клиент құру';

  @override
  String get clientsCreated => 'Құрылды';

  @override
  String clientsDealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мәміле',
      one: '1 мәміле',
    );
    return '$_temp0';
  }

  @override
  String get clientsDeals => 'Мәмілелер';

  @override
  String get clientsDelete => 'Жою';

  @override
  String get clientsDeleteClient => 'Клиентті жою';

  @override
  String clientsDeleteConfirm(String name) {
    return '«$name» жойылсын ба?';
  }

  @override
  String get clientsEdit => 'Өңдеу';

  @override
  String get clientsEditClient => 'Клиентті өңдеу';

  @override
  String get clientsEmail => 'Электрондық пошта';

  @override
  String get clientsFullNameLabel => 'Толық аты *';

  @override
  String clientsIdBadge(int id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Қате email';

  @override
  String get clientsNameRequired => 'Атын енгізіңіз';

  @override
  String get clientsNewClient => 'Жаңа клиент';

  @override
  String get clientsNoClientsFound => 'Клиенттер табылмады';

  @override
  String get clientsNotes => 'Ескертпелер';

  @override
  String get clientsNotesHint => 'Осы клиент туралы қосымша ескертпелер…';

  @override
  String get clientsPhone => 'Телефон';

  @override
  String get clientsSearchHint => 'Клиенттерді іздеу...';

  @override
  String get clientsSeller => '💰 Сатушы';

  @override
  String get clientsTimestamps => 'Уақыт белгілері';

  @override
  String get clientsTitle => 'Клиенттер';

  @override
  String get clientsTryDifferentSearch => 'Басқа сұранысты байқап көріңіз';

  @override
  String get clientsUpdateClient => 'Клиентті жаңарту';

  @override
  String get clientsUpdated => 'Жаңартылды';

  @override
  String get coreCancel => 'Бас тарту';

  @override
  String get coreClientTypeBuyer => 'Сатып алушы';

  @override
  String get coreClientTypeSeller => 'Сатушы';

  @override
  String get coreDelete => 'Жою';

  @override
  String get coreLogout => 'Шығу';

  @override
  String get coreNavAdmin => 'Әкімшілік';

  @override
  String get coreNavClients => 'Клиенттер';

  @override
  String get coreNavDashboard => 'Басқару тақтасы';

  @override
  String get coreNavDeals => 'Мәмілелер';

  @override
  String get coreNavMeetings => 'Кездесулер';

  @override
  String get coreNavProperties => 'Нысандар';

  @override
  String get coreNavTeam => 'Команда';

  @override
  String get coreRetry => 'Қайталау';

  @override
  String get coreStatusAvailable => 'Қолжетімді';

  @override
  String get coreStatusLead => 'Лид';

  @override
  String get coreStatusLost => 'Жоғалтылды';

  @override
  String get coreStatusNegotiation => 'Келіссөздер';

  @override
  String get coreStatusReserved => 'Брондалған';

  @override
  String get coreStatusSold => 'Сатылды';

  @override
  String get coreStatusWon => 'Жеңіске жетті';

  @override
  String dashboardActiveDeals(int count) {
    return '$count белсенді';
  }

  @override
  String get dashboardAddClient => 'Клиент қосу';

  @override
  String get dashboardAddProperty => 'Нысан қосу';

  @override
  String get dashboardClients => 'Клиенттер';

  @override
  String get dashboardClosedWon => 'Сәтті жабылды';

  @override
  String dashboardGreeting(String greeting, String name) {
    return '$greeting, $name ✨';
  }

  @override
  String get dashboardGreetingAfternoon => 'Қайырлы күн';

  @override
  String get dashboardGreetingEvening => 'Қайырлы кеш';

  @override
  String get dashboardGreetingFallbackName => 'досым';

  @override
  String get dashboardGreetingMorning => 'Қайырлы таң';

  @override
  String get dashboardGreetingStillUp => 'Әлі оянсыз ба';

  @override
  String get dashboardMeetingsSubtitle => 'кездесулер';

  @override
  String get dashboardNewDeal => 'Жаңа мәміле';

  @override
  String get dashboardNoUpcomingMeetings => 'Алдағы кездесулер жоқ';

  @override
  String get dashboardOverviewSubtitle => 'Бүгінгі шолуыңыз';

  @override
  String get dashboardOverviewTitle => 'Шолу';

  @override
  String get dashboardQuickActions => 'Жылдам әрекеттер';

  @override
  String get dashboardScheduleMeeting => 'Кездесу жоспарлау';

  @override
  String get dashboardSeeAll => 'Барлығы';

  @override
  String get dashboardTotalDeals => 'Барлық мәмілелер';

  @override
  String get dashboardUpcoming => 'Алдағы';

  @override
  String get dashboardUpcomingMeetings => 'Алдағы кездесулер';

  @override
  String get dealsAddDeal => 'Мәміле қосу';

  @override
  String get dealsAgent => 'Агент';

  @override
  String dealsAgentValue(String name) {
    return 'Агент: $name';
  }

  @override
  String get dealsBudget => 'Бюджет';

  @override
  String dealsBudgetValue(String price) {
    return 'Бюджет: $price';
  }

  @override
  String get dealsCancel => 'Бас тарту';

  @override
  String get dealsClient => 'Клиент';

  @override
  String get dealsClosed => 'Жабылды';

  @override
  String get dealsCreateDeal => 'Мәміле құру';

  @override
  String get dealsCreated => 'Құрылды';

  @override
  String get dealsDealPrice => 'Мәміле бағасы';

  @override
  String dealsDeleteConfirm(String title) {
    return '«$title» жойылсын ба?';
  }

  @override
  String get dealsDeleteTitle => 'Мәмілені жою';

  @override
  String get dealsDetails => 'Мәліметтер';

  @override
  String get dealsEditTitle => 'Мәмілені өңдеу';

  @override
  String get dealsEmptySubtitle => 'Сату воронкасын бастаңыз';

  @override
  String get dealsEmptyTitle => 'Мәмілелер жоқ';

  @override
  String get dealsFallbackTitle => 'Мәміле';

  @override
  String get dealsFilterAll => 'Барлығы';

  @override
  String get dealsFinancials => 'Қаржы';

  @override
  String get dealsIdCopied => 'Мәміле ID көшірілді';

  @override
  String dealsIdLabel(int id) {
    return 'Мәміле ID: $id';
  }

  @override
  String get dealsLoading => 'Жүктелуде…';

  @override
  String get dealsNewTitle => 'Жаңа мәміле';

  @override
  String get dealsNoResults => 'Нәтиже жоқ';

  @override
  String get dealsNotFound => 'Мәміле табылмады';

  @override
  String get dealsNotes => 'Ескертпелер';

  @override
  String get dealsNotesHint => 'Осы мәміле туралы ескертпелер…';

  @override
  String get dealsPeopleProperty => 'Адамдар және нысан';

  @override
  String get dealsPipelineStage => 'Воронка кезеңі';

  @override
  String get dealsProperty => 'Нысан';

  @override
  String get dealsSearchHint => 'Аты немесе ID бойынша іздеу…';

  @override
  String get dealsSelectAgentError => 'Агентті таңдаңыз';

  @override
  String get dealsSelectClientError => 'Клиентті таңдаңыз';

  @override
  String dealsSelectLabel(String label) {
    return '$label таңдаңыз';
  }

  @override
  String get dealsStatusClosedLost => 'Сәтсіз жабылды';

  @override
  String get dealsStatusClosedWon => 'Сәтті жабылды';

  @override
  String get dealsStatusLead => 'Лид';

  @override
  String get dealsStatusNegotiation => 'Келіссөздер';

  @override
  String get dealsStatusNotes => 'Мәртебе және ескертпелер';

  @override
  String dealsTapToSelect(String label) {
    return '$label таңдау үшін басыңыз';
  }

  @override
  String get dealsTitle => 'Мәмілелер';

  @override
  String get dealsTitleLabel => 'Атауы *';

  @override
  String get dealsTitleRequired => 'Атауы міндетті';

  @override
  String get dealsUpdateDeal => 'Мәмілені жаңарту';

  @override
  String get meetingsAgendaHint => 'Кездесу күн тәртібі, талқылау тақырыптары…';

  @override
  String get meetingsAgent => 'Агент';

  @override
  String meetingsAgentNumber(int id) {
    return 'Агент №$id';
  }

  @override
  String get meetingsCancel => 'Бас тарту';

  @override
  String get meetingsClient => 'Клиент';

  @override
  String meetingsClientNumber(int id) {
    return 'Клиент №$id';
  }

  @override
  String get meetingsCompleted => 'Аяқталды';

  @override
  String get meetingsDeal => 'Мәміле';

  @override
  String meetingsDealNumber(int id) {
    return 'Мәміле №$id';
  }

  @override
  String get meetingsDelete => 'Жою';

  @override
  String get meetingsDeleteConfirm => 'Бұл кездесуді жою керек пе?';

  @override
  String get meetingsDeleteMeeting => 'Кездесуді жою';

  @override
  String get meetingsDescription => 'Сипаттама';

  @override
  String get meetingsDetails => 'Мәліметтер';

  @override
  String get meetingsEdit => 'Өңдеу';

  @override
  String get meetingsEditMeeting => 'Кездесуді өңдеу';

  @override
  String get meetingsLoading => 'Жүктелуде…';

  @override
  String get meetingsLocation => 'Орны';

  @override
  String get meetingsMarkComplete => 'Аяқталды деп белгілеу';

  @override
  String get meetingsNoMeetings => 'Кездесулер жоқ';

  @override
  String get meetingsNoResults => 'Нәтиже жоқ';

  @override
  String get meetingsPeopleAndDeal => 'Қатысушылар және мәміле';

  @override
  String get meetingsPleaseSelectAgent => 'Агентті таңдаңыз';

  @override
  String get meetingsPleaseSelectClient => 'Клиентті таңдаңыз';

  @override
  String get meetingsPleaseSelectDateTime => 'Күн мен уақытты таңдаңыз';

  @override
  String get meetingsSchedule => 'Жоспарлау';

  @override
  String get meetingsScheduleFirst => 'Алғашқы кездесуіңізді жоспарлаңыз';

  @override
  String get meetingsScheduleMeeting => 'Кездесуді жоспарлау';

  @override
  String get meetingsSearchByNameOrId => 'Аты немесе ID бойынша іздеу…';

  @override
  String get meetingsSelectDateTime => 'Күн мен уақытты таңдаңыз *';

  @override
  String meetingsSelectEntity(String label) {
    return '$label таңдаңыз';
  }

  @override
  String meetingsTapToSelect(String label) {
    return '$label таңдау үшін басыңыз';
  }

  @override
  String get meetingsTitle => 'Кездесулер';

  @override
  String get meetingsTitleFieldLabel => 'Атауы *';

  @override
  String get meetingsTitleRequired => 'Атауы міндетті';

  @override
  String get meetingsUpdateMeeting => 'Кездесуді жаңарту';

  @override
  String get profileAbout => 'Қолданба туралы';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileAgentId => 'Агент ID';

  @override
  String get profileAgentIdCopied => 'Агент ID көшірілді';

  @override
  String get profileBuiltForTeams => 'Жылжымайтын мүлік командаларына арналған';

  @override
  String get profileCancel => 'Бас тарту';

  @override
  String get profileDarkMode => 'Қараңғы режим';

  @override
  String get profileEditName => 'Атын өзгерту';

  @override
  String get profileEmail => 'Электрондық пошта';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFullName => 'Толық аты';

  @override
  String get profileLanguage => 'Тіл';

  @override
  String get profileNameUpdated => 'Аты жергілікті жаңартылды';

  @override
  String get profilePreferences => 'Баптаулар';

  @override
  String get profileRole => 'Рөлі';

  @override
  String get profileSave => 'Сақтау';

  @override
  String get profileSignOut => 'Шығу';

  @override
  String get profileSignOutConfirm => 'Шынымен шығып кеткіңіз келе ме?';

  @override
  String get profileSystemDefault => 'Жүйелік';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileVersion => 'Нұсқа';

  @override
  String get propertiesAdd => 'Қосу';

  @override
  String get propertiesAddFirstListing => 'Алғашқы нысаныңызды қосыңыз';

  @override
  String get propertiesAddressLabel => 'Мекенжайы *';

  @override
  String get propertiesAgent => 'Агент';

  @override
  String get propertiesAll => 'Барлығы';

  @override
  String get propertiesApply => 'Қолдану';

  @override
  String get propertiesArea => 'Ауданы';

  @override
  String get propertiesAreaLabel => 'Ауданы м²';

  @override
  String propertiesAreaValue(String area) {
    return '$area м²';
  }

  @override
  String get propertiesBasicInfo => 'Негізгі ақпарат';

  @override
  String get propertiesCancel => 'Болдырмау';

  @override
  String get propertiesCityLabel => 'Қала';

  @override
  String get propertiesCreateProperty => 'Нысанды құру';

  @override
  String get propertiesDelete => 'Жою';

  @override
  String propertiesDeleteConfirm(String title) {
    return '«$title» жойылсын ба?';
  }

  @override
  String get propertiesDeleteProperty => 'Нысанды жою';

  @override
  String get propertiesDescribeHint => 'Нысанды сипаттаңыз…';

  @override
  String get propertiesDescription => 'Сипаттама';

  @override
  String get propertiesDetails => 'Мәліметтер';

  @override
  String get propertiesEdit => 'Өңдеу';

  @override
  String get propertiesEditProperty => 'Нысанды өңдеу';

  @override
  String propertiesFieldRequired(String label) {
    return '$label міндетті';
  }

  @override
  String get propertiesFilters => 'Сүзгілер';

  @override
  String get propertiesFloor => 'Қабат';

  @override
  String get propertiesLocation => 'Орналасуы';

  @override
  String get propertiesNewProperty => 'Жаңа нысан';

  @override
  String get propertiesNoProperties => 'Нысандар жоқ';

  @override
  String get propertiesPriceLabel => 'Бағасы *';

  @override
  String get propertiesProperty => 'Нысан';

  @override
  String propertiesPropertyCreated(int id) {
    return 'Нысан құрылды (ID: $id)';
  }

  @override
  String get propertiesPropertyIdCopied => 'Нысан ID көшірілді';

  @override
  String propertiesPropertyIdLabel(int id) {
    return 'Нысан ID: $id';
  }

  @override
  String get propertiesPropertyNotFound => 'Нысан табылмады';

  @override
  String get propertiesRooms => 'Бөлмелер';

  @override
  String propertiesRoomsCount(int rooms) {
    return '$rooms бөлме';
  }

  @override
  String get propertiesSearchHint => 'Іздеу...';

  @override
  String get propertiesStatus => 'Мәртебесі';

  @override
  String get propertiesTitle => 'Нысандар';

  @override
  String get propertiesTitleLabel => 'Атауы *';

  @override
  String get propertiesTotalFloors => 'Барлық қабаттар';

  @override
  String get propertiesType => 'Түрі';

  @override
  String get propertiesTypeAndStatus => 'Түрі мен мәртебесі';

  @override
  String get propertiesUpdateProperty => 'Нысанды жаңарту';

  @override
  String get propertiesUpdateStatus => 'Мәртебені жаңарту';

  @override
  String get teamsActive => 'Белсенді';

  @override
  String get teamsAgents => 'Агенттер';

  @override
  String get teamsClients => 'Клиенттер';

  @override
  String get teamsCouldNotLoadStats => 'Статистиканы жүктеу мүмкін болмады';

  @override
  String get teamsCreate => 'Құру';

  @override
  String get teamsCreateTeam => 'Команда құру';

  @override
  String get teamsDeals => 'Мәмілелер';

  @override
  String get teamsEditTeam => 'Команданы өңдеу';

  @override
  String get teamsEmail => 'Электрондық пошта';

  @override
  String get teamsEnterValidEmail => 'Жарамды email енгізіңіз';

  @override
  String get teamsFullName => 'Толық аты-жөні';

  @override
  String get teamsInviteAgent => 'Агент шақыру';

  @override
  String teamsManagerLabel(String name) {
    return 'Менеджер: $name';
  }

  @override
  String get teamsManagerOptional => 'Менеджер (міндетті емес)';

  @override
  String teamsMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мүше',
    );
    return '$_temp0';
  }

  @override
  String get teamsMyTeam => 'Менің командам';

  @override
  String get teamsNoManager => 'Менеджерсіз';

  @override
  String get teamsNoTeamSubtitle => 'Сіз команданы басқармайсыз';

  @override
  String get teamsNoTeamYet => 'Әзірге команда жоқ';

  @override
  String get teamsPhoneOptional => 'Телефон (міндетті емес)';

  @override
  String get teamsRequired => 'Міндетті';

  @override
  String get teamsSave => 'Сақтау';

  @override
  String get teamsSendInvite => 'Шақыру жіберу';

  @override
  String get teamsTeamName => 'Команда атауы';

  @override
  String get teamsUpcoming => 'Алдағы';
}
