// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get adminActivate => 'Белсендіру';

  @override
  String get adminAssignTeam => 'Команда тағайындау';

  @override
  String get adminAssignToTeam => 'Командаға тағайындау';

  @override
  String get adminAuditEmptyBody =>
      'Мұнда команда әрекеттері көрінеді: мәміле құру, күй ауыстыру, шақырулар.';

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
  String adminDeleteCascade(Object name, Object successor) {
    return '$name клиенттері, нысандары, мәмілелері мен кездесулері $successor адамына көшеді. Аккаунт біржола жойылады, кері қайтару мүмкін емес.';
  }

  @override
  String get adminDeleteHandoverEmpty => 'Беретін адам жоқ';

  @override
  String get adminDeleteHandoverSearch => 'Қызметкерлерді іздеу';

  @override
  String get adminDeleteHandoverTitle => 'Жазбаларды кімге беру';

  @override
  String get adminDeleteUser => 'Пайдаланушыны жою';

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
  String get adminInviteHelper => 'Код поштаға келеді және 7 күн жарамды.';

  @override
  String get adminInviteInstructions =>
      'Олар қосымшаны ашып, кіру экранындағы «Шақыруыңыз бар ма?» түймесін басып, осы кодты қойып, өз құпия сөзін таңдайды.';

  @override
  String get adminInviteUser => 'Пайдаланушыны шақыру';

  @override
  String adminInvitedAs(Object email, Object name, Object role) {
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
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Сізге берілген шақыру кодын енгізіп, құпия сөз таңдаңыз.';

  @override
  String get authAcceptYourInvite => 'Шақыруыңызды қабылдаңыз';

  @override
  String get authActivate => 'Белсендіру';

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
  String get authForgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get authForgotPasswordSubtitle =>
      'Кіретін поштаңызды енгізіңіз — жаңа құпия сөз таңдауға сілтеме жібереміз.';

  @override
  String get authForgotPasswordTitle => 'Құпия сөзді қалпына келтіру';

  @override
  String get authHaveAnInvite => 'Шақыруыңыз бар ма?';

  @override
  String get authInviteCode => 'Шақыру коды';

  @override
  String get authInviteCodeRequired => 'Шақыру кодын енгізіңіз';

  @override
  String authInviteSignOutBody(Object email) {
    return 'Қазір $email ретінде кіргенсіз. Шақыруды қабылдау үшін алдымен осы аккаунттан шығу қажет.';
  }

  @override
  String get authInviteSignOutConfirm => 'Шығып, жалғастыру';

  @override
  String get authInviteSignOutTitle => 'Шақыруды қабылдайсыз ба?';

  @override
  String get authNewPassword => 'Жаңа құпия сөз';

  @override
  String get authPassword => 'Құпия сөз';

  @override
  String get authPasswordHelp => 'Кемінде 8 таңба, бір сан.';

  @override
  String get authPasswordMinLength => 'Кемінде 6 таңба';

  @override
  String get authPasswordRequired => 'Құпия сөзді енгізіңіз';

  @override
  String get authPasswordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get authResetCode => 'Қалпына келтіру коды';

  @override
  String get authResetCodeRequired => 'Қалпына келтіру кодын енгізіңіз';

  @override
  String authResetLinkSentBody(Object email) {
    return 'Егер $email тіркелген болса, жаңа құпия сөз таңдау сілтемесі жіберілді. Ол 24 сағат жарамды.';
  }

  @override
  String get authResetLinkSentTitle => 'Поштаңызды тексеріңіз';

  @override
  String get authResetPasswordSubtitle =>
      'Хаттағы кодты қойып, құпия сөз таңдаңыз.';

  @override
  String get authResetPasswordTitle => 'Жаңа құпия сөз';

  @override
  String get authSendResetLink => 'Сілтеме жіберу';

  @override
  String get authSetPasswordContinue => 'Құпия сөзді орнатып, жалғастыру';

  @override
  String get authSetPasswordSignIn => 'Құпиясөз қойып, кіру';

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
  String get clientsAddShort => 'Клиент';

  @override
  String get clientsAgent => 'Агент';

  @override
  String clientsAgentMeta(Object name) {
    return 'агент $name';
  }

  @override
  String get clientsBuyer => 'Сатып алушы';

  @override
  String get clientsCancel => 'Бас тарту';

  @override
  String clientsClientCreatedId(Object id) {
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
  String clientsCounter(Object active, Object total) {
    return 'барлығы $total · жұмыста $active';
  }

  @override
  String get clientsCreateClient => 'Клиент құру';

  @override
  String get clientsCreated => 'Құрылды';

  @override
  String clientsDealCount(num count) {
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
  String clientsDeleteCascade(num count, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'және $count байланысты мәміле біржола жойылады',
      one: 'және 1 байланысты мәміле біржола жойылады',
      zero: 'біржола жойылады',
    );
    return '$name $_temp0. Бұны қайтару мүмкін емес.';
  }

  @override
  String get clientsDeleteClient => 'Клиентті жою';

  @override
  String clientsDeleteConfirm(Object name) {
    return '«$name» жойылсын ба?';
  }

  @override
  String get clientsEdit => 'Өңдеу';

  @override
  String get clientsEditClient => 'Клиентті өңдеу';

  @override
  String get clientsEmail => 'Электрондық пошта';

  @override
  String get clientsFilterAll => 'Барлығы';

  @override
  String get clientsFilterBuyers => 'Сатып алушылар';

  @override
  String get clientsFilterSellers => 'Сатушылар';

  @override
  String get clientsFullName => 'Толық аты-жөні';

  @override
  String get clientsFullNameLabel => 'Толық аты';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Қате email';

  @override
  String get clientsMessage => 'Жазу';

  @override
  String get clientsNameRequired => 'Атын енгізіңіз';

  @override
  String get clientsNewClient => 'Жаңа клиент';

  @override
  String get clientsNoClientsFound => 'Клиенттер табылмады';

  @override
  String get clientsNoEmail => 'Эл. пошта көрсетілмеген';

  @override
  String get clientsNoPhone => 'Телефон көрсетілмеген';

  @override
  String get clientsNotes => 'Ескертпелер';

  @override
  String get clientsNotesHint => 'Осы клиент туралы қосымша ескертпелер…';

  @override
  String get clientsPhone => 'Телефон';

  @override
  String get clientsSearchHint => 'Аты, телефоны бойынша іздеу…';

  @override
  String get clientsSeller => 'Сатушы';

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
  String clientsUpdatedAt(Object date) {
    return 'Жаңартылды $date';
  }

  @override
  String get coreCall => 'Қоңырау шалу';

  @override
  String get coreCancel => 'Бас тарту';

  @override
  String get coreClientTypeBuyer => 'Сатып алушы';

  @override
  String get coreClientTypeSeller => 'Сатушы';

  @override
  String get coreDataScopeAll => 'Барлығы';

  @override
  String get coreDataScopeOwn => 'Өзінікі';

  @override
  String get coreDataScopeTeam => 'Команда';

  @override
  String get coreDelete => 'Жою';

  @override
  String get coreErrorBadRequest =>
      'Сұрау қате. Енгізілген деректерді тексеріңіз.';

  @override
  String get coreErrorConflict => 'Мұндай жазба бұрыннан бар.';

  @override
  String get coreErrorCredentials => 'Пошта немесе құпия сөз қате.';

  @override
  String get coreErrorForbidden => 'Бұл әрекетке құқығыңыз жоқ.';

  @override
  String get coreErrorNotFound => 'Табылмады.';

  @override
  String get coreErrorOffline =>
      'Сервермен байланыс жоқ. Интернетті тексеріңіз.';

  @override
  String get coreErrorServer => 'Сервер қатесі. Кейінірек қайталаңыз.';

  @override
  String get coreErrorTimeout => 'Күту уақыты бітті. Интернетті тексеріңіз.';

  @override
  String get coreErrorUnknown => 'Бірдеңе дұрыс болмады. Қайталап көріңіз.';

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
  String get coreNoResults => 'Ештеңе табылмады';

  @override
  String get coreNotSelected => 'Таңдалмаған';

  @override
  String get coreOpen => 'Ашу';

  @override
  String get corePropertyTypeApartment => 'Пәтер';

  @override
  String get corePropertyTypeCommercial => 'Коммерция';

  @override
  String get corePropertyTypeHouse => 'Үй';

  @override
  String get corePropertyTypeLand => 'Жер учаскесі';

  @override
  String get corePropertyTypeOffice => 'Кеңсе';

  @override
  String get coreRetry => 'Қайталау';

  @override
  String get coreRoleAdmin => 'Әкімші';

  @override
  String get coreRoleAgent => 'Агент';

  @override
  String get coreRoleManager => 'Менеджер';

  @override
  String get coreSave => 'Сақтау';

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
  String dashboardActiveDeals(Object count) {
    return '$count белсенді';
  }

  @override
  String get dashboardActiveDealsLabel => 'Белсенді мәмілелер';

  @override
  String get dashboardAddClient => 'Клиент қосу';

  @override
  String get dashboardAddProperty => 'Нысан қосу';

  @override
  String dashboardAgentDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мәміле',
      one: '1 мәміле',
    );
    return '$_temp0';
  }

  @override
  String dashboardAgentMeta(Object name) {
    return 'агент: $name';
  }

  @override
  String get dashboardAttention => 'Назар аудару керек';

  @override
  String get dashboardClients => 'Клиенттер';

  @override
  String get dashboardClosedWon => 'Сәтті жабылды';

  @override
  String get dashboardConversion => 'Конверсия';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · команда сводкасы';
  }

  @override
  String dashboardDecidedDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мәміле аяқталды',
      one: '1 мәміле аяқталды',
      zero: 'Әзірге ештеңе жабылмаған',
    );
    return '$_temp0';
  }

  @override
  String get dashboardGoalClear => 'Мақсатты алып тастау';

  @override
  String get dashboardGoalEyebrow => 'МАҚСАТ';

  @override
  String get dashboardGoalReached =>
      'Мақсатқа жетті. Бұдан әрі бәрі жоспардан тыс.';

  @override
  String dashboardGoalRemaining(Object amount) {
    return 'Мақсатқа $amount қалды';
  }

  @override
  String get dashboardGoalSheetField => 'Сома';

  @override
  String get dashboardGoalSheetHint =>
      'Жеңіске жеткен мәмілелер есептеледі. Тек осы құрылғыда сақталады.';

  @override
  String get dashboardGoalSheetTitle => 'Айлық мақсат';

  @override
  String get dashboardGoalTitle => 'Осы айда жабылды';

  @override
  String get dashboardGoalUnset => 'Айлық мақсат қою үшін басыңыз';

  @override
  String dashboardGreeting(Object greeting, Object name) {
    return '$greeting, $name';
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
  String dashboardIdleDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн қозғалыссыз',
      one: '1 күн қозғалыссыз',
    );
    return '$_temp0';
  }

  @override
  String get dashboardLeaderboard => 'Үздік агенттер';

  @override
  String dashboardLoadTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кездесу',
      one: '1 кездесу',
      zero: 'ештеңе жоспарланбаған',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMeetingLoad => 'Алдағы екі апта';

  @override
  String get dashboardMeetingsLabel => 'Кездесулер';

  @override
  String get dashboardMeetingsSubtitle => 'кездесулер';

  @override
  String get dashboardNewDeal => 'Жаңа мәміле';

  @override
  String get dashboardNextMeeting => 'Жақын кездесу';

  @override
  String get dashboardNoDealsYet => 'Мәмілелер әзірге жоқ';

  @override
  String get dashboardNoDealsYetHint =>
      'Мәміле қосқаннан кейін мұнда воронка пайда болады';

  @override
  String get dashboardNoMoreMeetingsToday => 'Бүгінге басқа кездесу жоқ';

  @override
  String get dashboardNoPhone => 'Клиенттің телефоны көрсетілмеген';

  @override
  String get dashboardNoUpcomingMeetings => 'Алдағы кездесулер жоқ';

  @override
  String get dashboardNothingScheduled => 'Кездесулер жоспарланбаған';

  @override
  String get dashboardNothingScheduledHint =>
      'Кездесу тағайындаңыз — ол осында көрінеді';

  @override
  String get dashboardOverviewSubtitle => 'Бүгінгі шолуыңыз';

  @override
  String get dashboardOverviewTitle => 'Шолу';

  @override
  String get dashboardQuickActions => 'Жылдам әрекеттер';

  @override
  String dashboardRelativeInHours(Object count) {
    return '$count сағ ішінде';
  }

  @override
  String dashboardRelativeInMinutes(Object count) {
    return '$count мин ішінде';
  }

  @override
  String get dashboardRelativeNow => 'қазір';

  @override
  String get dashboardRelativeToday => 'бүгін';

  @override
  String get dashboardRelativeTomorrow => 'ертең';

  @override
  String get dashboardScheduleMeeting => 'Кездесу жоспарлау';

  @override
  String get dashboardSeeAll => 'Барлығы';

  @override
  String get dashboardTeamPipeline => 'Команда воронкасы';

  @override
  String get dashboardToday => 'Бүгін';

  @override
  String dashboardTodayCount(Object count) {
    return 'бүгін $count';
  }

  @override
  String get dashboardTopAgents => 'Үздік агенттер';

  @override
  String get dashboardTotalDeals => 'Барлық мәмілелер';

  @override
  String get dashboardUpcoming => 'Алдағы';

  @override
  String get dashboardUpcomingMeetings => 'Алдағы кездесулер';

  @override
  String get dashboardValueByStage => 'Кезеңдер бойынша сома';

  @override
  String get dealsAddDeal => 'Мәміле қосу';

  @override
  String get dealsAddShort => 'Мәміле';

  @override
  String get dealsAgent => 'Агент';

  @override
  String dealsAgentRef(Object id) {
    return 'Агент №$id';
  }

  @override
  String dealsAgentValue(Object name) {
    return 'Агент: $name';
  }

  @override
  String get dealsBudget => 'Бюджет';

  @override
  String dealsBudgetValue(Object price) {
    return 'Бюджет: $price';
  }

  @override
  String get dealsCancel => 'Бас тарту';

  @override
  String get dealsClient => 'Клиент';

  @override
  String dealsClientRef(Object id) {
    return 'Клиент №$id';
  }

  @override
  String get dealsClosed => 'Жабылды';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active белсенді · $total';
  }

  @override
  String get dealsCreateDeal => 'Мәміле құру';

  @override
  String get dealsCreated => 'Құрылды';

  @override
  String get dealsDealPrice => 'Мәміле бағасы';

  @override
  String dealsDeleteCascade(Object title) {
    return '«$title» біржола жойылады. Бұны қайтару мүмкін емес.';
  }

  @override
  String dealsDeleteConfirm(Object title) {
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
  String dealsFilterWithCount(Object count, Object label) {
    return '$label $count';
  }

  @override
  String get dealsFinancials => 'Қаржы';

  @override
  String get dealsIdCopied => 'Мәміле ID көшірілді';

  @override
  String dealsIdLabel(Object id) {
    return 'Мәміле ID: $id';
  }

  @override
  String get dealsLoading => 'Жүктелуде…';

  @override
  String get dealsNewTitle => 'Жаңа мәміле';

  @override
  String dealsNextCall(Object when) {
    return 'қоңырау $when';
  }

  @override
  String get dealsNoResults => 'Нәтиже жоқ';

  @override
  String get dealsNoResultsSubtitle => 'Кезең сүзгісін өзгертіңіз';

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
  String dealsPropertyRef(Object id) {
    return 'Нысан №$id';
  }

  @override
  String get dealsSearchHint => 'Аты немесе ID бойынша іздеу…';

  @override
  String get dealsSelectAgentError => 'Агентті таңдаңыз';

  @override
  String get dealsSelectClientError => 'Клиентті таңдаңыз';

  @override
  String dealsSelectLabel(Object label) {
    return '$label таңдаңыз';
  }

  @override
  String dealsStaleWarning(Object days) {
    return '$days күн белсенділік жоқ';
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
  String dealsTapToSelect(Object label) {
    return '$label таңдау үшін басыңыз';
  }

  @override
  String get dealsTimeline => 'Хронология';

  @override
  String get dealsTimelineClosed => 'Мәміле жабылды';

  @override
  String get dealsTimelineCreated => 'Құрылды';

  @override
  String get dealsTimelineUpdated => 'Жаңартылды';

  @override
  String get dealsTitle => 'Мәмілелер';

  @override
  String get dealsTitleLabel => 'Атауы';

  @override
  String get dealsTitleRequired => 'Атауы міндетті';

  @override
  String get dealsUpdateDeal => 'Мәмілені жаңарту';

  @override
  String get meetingsAddShort => 'Кездесу';

  @override
  String get meetingsAgendaHint => 'Кездесу күн тәртібі, талқылау тақырыптары…';

  @override
  String get meetingsAgent => 'Агент';

  @override
  String meetingsAgentNumber(Object id) {
    return 'Агент №$id';
  }

  @override
  String get meetingsCancel => 'Бас тарту';

  @override
  String get meetingsClient => 'Клиент';

  @override
  String meetingsClientNumber(Object id) {
    return 'Клиент №$id';
  }

  @override
  String get meetingsCompleted => 'Аяқталды';

  @override
  String get meetingsCouldNotLoadOptions =>
      'Клиенттер мен агенттерді жүктеу мүмкін болмады.';

  @override
  String meetingsCounter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осы аптада $count',
      one: 'осы аптада 1',
    );
    return '$_temp0';
  }

  @override
  String get meetingsDate => 'Күні';

  @override
  String get meetingsDeal => 'Мәміле';

  @override
  String meetingsDealNumber(Object id) {
    return 'Мәміле №$id';
  }

  @override
  String get meetingsDelete => 'Жою';

  @override
  String meetingsDeleteCascade(Object title) {
    return '«$title» біржола жойылады. Бұны қайтару мүмкін емес.';
  }

  @override
  String get meetingsDeleteConfirm => 'Бұл кездесуді жою керек пе?';

  @override
  String get meetingsDeleteMeeting => 'Кездесуді жою';

  @override
  String get meetingsDescription => 'Сипаттама';

  @override
  String get meetingsDetails => 'Мәліметтер';

  @override
  String get meetingsDirections => 'Бағыт';

  @override
  String get meetingsEdit => 'Өңдеу';

  @override
  String get meetingsEditMeeting => 'Кездесуді өңдеу';

  @override
  String get meetingsGroupToday => 'Бүгін';

  @override
  String get meetingsGroupTomorrow => 'Ертең';

  @override
  String get meetingsLoading => 'Жүктелуде…';

  @override
  String get meetingsLocation => 'Орны';

  @override
  String get meetingsMarkComplete => 'Аяқталды деп белгілеу';

  @override
  String get meetingsMustBeInFuture => 'Болашақтағы уақытты таңдаңыз';

  @override
  String get meetingsNoAgentsToAssign => 'Тағайындайтын адам жоқ';

  @override
  String get meetingsNoLocation => 'Кездесудің орны көрсетілмеген';

  @override
  String get meetingsNoMeetings => 'Кездесулер жоқ';

  @override
  String get meetingsNoResults => 'Нәтиже жоқ';

  @override
  String get meetingsNoResultsSubtitle => 'Бұл аралықта ештеңе жоспарланбаған';

  @override
  String get meetingsNote => 'Кездесу жазбасы';

  @override
  String get meetingsNothingUpcoming => 'Алдағы кездесулер жоқ';

  @override
  String get meetingsNothingUpcomingSubtitle =>
      'Өткен кездесулер тарихта қалады.';

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
  String get meetingsSelectDateTime => 'Күн мен уақытты таңдаңыз';

  @override
  String meetingsSelectEntity(Object label) {
    return '$label таңдаңыз';
  }

  @override
  String get meetingsStatus => 'Күйі';

  @override
  String get meetingsStatusHeld => 'Өтті';

  @override
  String get meetingsStatusScheduled => 'Жоспарланған';

  @override
  String meetingsTapToSelect(Object label) {
    return '$label таңдау үшін басыңыз';
  }

  @override
  String get meetingsTime => 'Уақыты';

  @override
  String get meetingsTitle => 'Кездесулер';

  @override
  String get meetingsTitleFieldLabel => 'Атауы';

  @override
  String get meetingsTitleRequired => 'Атауы міндетті';

  @override
  String get meetingsUpcomingEyebrow => 'Ең жақыны';

  @override
  String get meetingsUpdateMeeting => 'Кездесуді жаңарту';

  @override
  String get meetingsWhen => 'Қашан';

  @override
  String get meetingsWhoAndWhere => 'Кіммен және қайда';

  @override
  String get msgAgentInvited => 'Агент шақырылды';

  @override
  String get msgClientCreated => 'Клиент құрылды';

  @override
  String get msgClientDeleted => 'Клиент жойылды';

  @override
  String get msgClientUpdated => 'Клиент жаңартылды';

  @override
  String get msgDealCreated => 'Мәміле құрылды';

  @override
  String get msgDealDeleted => 'Мәміле жойылды';

  @override
  String get msgDealUpdated => 'Мәміле жаңартылды';

  @override
  String get msgInviteResent => 'Шақыру қайта жіберілді';

  @override
  String get msgMeetingCompleted => 'Кездесу аяқталды';

  @override
  String get msgMeetingCreated => 'Кездесу құрылды';

  @override
  String get msgMeetingDeleted => 'Кездесу жойылды';

  @override
  String get msgMeetingUpdated => 'Кездесу жаңартылды';

  @override
  String get msgProfileUpdated => 'Профиль жаңартылды';

  @override
  String get msgPropertyCreated => 'Нысан құрылды';

  @override
  String get msgPropertyDeleted => 'Нысан жойылды';

  @override
  String get msgPropertyUpdated => 'Нысан жаңартылды';

  @override
  String get msgRoleUpdated => 'Рөл жаңартылды';

  @override
  String get msgStatusUpdated => 'Мәртебе жаңартылды';

  @override
  String get msgTeamAssigned => 'Команда тағайындалды';

  @override
  String get msgTeamCreated => 'Команда құрылды';

  @override
  String get msgTeamUpdated => 'Команда жаңартылды';

  @override
  String get msgUserActivated => 'Пайдаланушы белсендірілді';

  @override
  String get msgUserDeactivated => 'Пайдаланушы өшірілді';

  @override
  String get msgUserDeleted => 'Пайдаланушы жойылды';

  @override
  String get profileAbout => 'Қолданба туралы';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileAgentId => 'Агент ID';

  @override
  String get profileAgentIdCopied => 'Агент ID көшірілді';

  @override
  String get profileApp => 'Қосымша';

  @override
  String get profileBuiltForTeams => 'Жылжымайтын мүлік командаларына арналған';

  @override
  String get profileCancel => 'Бас тарту';

  @override
  String get profileDarkMode => 'Қараңғы режим';

  @override
  String get profileDeleteAccount => 'Аккаунтты жою';

  @override
  String profileDeleteAccountConfirm(Object successor) {
    return 'Клиенттеріңіз, нысандарыңыз, мәмілелеріңіз және кездесулеріңіз $successor қарамағына өтеді. Аккаунт біржола жойылады.';
  }

  @override
  String get profileDeleteHandoverEmpty => 'Жазбаларды тапсыратын адам жоқ';

  @override
  String get profileDeleteHandoverSearch => 'Әріптестерді іздеу';

  @override
  String get profileDeleteHandoverTitle => 'Жазбаларыңыз кімге өтеді';

  @override
  String get profileEditName => 'Атын өзгерту';

  @override
  String get profileEditProfile => 'Профильді өзгерту';

  @override
  String get profileEmail => 'Электрондық пошта';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFollowSystem => 'Жүйе бойынша';

  @override
  String get profileFullName => 'Толық аты';

  @override
  String get profileLanguage => 'Тіл';

  @override
  String get profileLegal => 'Құжаттар';

  @override
  String get profileLinkFailed => 'Сілтемені ашу мүмкін болмады';

  @override
  String get profileName => 'Аты';

  @override
  String get profileNameUpdated => 'Аты жергілікті жаңартылды';

  @override
  String get profilePreferences => 'Баптаулар';

  @override
  String get profilePrivacyPolicy => 'Құпиялылық саясаты';

  @override
  String get profileReminders => 'Кездесу еске салғыштары';

  @override
  String get profileRemindersOff => 'Өшірулі';

  @override
  String get profileRole => 'Рөлі';

  @override
  String get profileSave => 'Сақтау';

  @override
  String get profileSettings => 'Баптаулар';

  @override
  String get profileSignOut => 'Шығу';

  @override
  String get profileSignOutConfirm => 'Шынымен шығып кеткіңіз келе ме?';

  @override
  String get profileSupport => 'Қолдау';

  @override
  String get profileSystemDefault => 'Жүйелік';

  @override
  String get profileTheme => 'Безендіру';

  @override
  String get profileThemeDark => 'Қараңғы';

  @override
  String get profileThemeLight => 'Ашық';

  @override
  String get profileThemeSystem => 'Жүйедегідей';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileVersion => 'Нұсқа';

  @override
  String get propertiesAdd => 'Қосу';

  @override
  String get propertiesAddFirstListing => 'Алғашқы нысаныңызды қосыңыз';

  @override
  String get propertiesAddShort => 'Нысан';

  @override
  String get propertiesAddressLabel => 'Мекенжайы';

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
  String propertiesAreaValue(Object area) {
    return '$area м²';
  }

  @override
  String get propertiesBack => 'Артқа';

  @override
  String get propertiesBasicInfo => 'Негізгі ақпарат';

  @override
  String get propertiesCancel => 'Болдырмау';

  @override
  String get propertiesCityLabel => 'Қала';

  @override
  String propertiesCounter(Object reserved, Object total) {
    return 'базада $total · броньда $reserved';
  }

  @override
  String get propertiesCreateProperty => 'Нысанды құру';

  @override
  String get propertiesDelete => 'Жою';

  @override
  String propertiesDeleteCascade(Object title) {
    return '«$title» біржола жойылады. Бұны қайтару мүмкін емес.';
  }

  @override
  String propertiesDeleteConfirm(Object title) {
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
  String propertiesFieldRequired(Object label) {
    return '$label міндетті';
  }

  @override
  String get propertiesFilters => 'Сүзгілер';

  @override
  String get propertiesFloor => 'Қабат';

  @override
  String propertiesFloorOf(Object floor, Object total) {
    return '$total ішінен $floor';
  }

  @override
  String get propertiesLocation => 'Орналасуы';

  @override
  String get propertiesNewProperty => 'Жаңа нысан';

  @override
  String get propertiesNextDetails => 'Әрі қарай — егжей-тегжейі';

  @override
  String get propertiesNoProperties => 'Нысандар жоқ';

  @override
  String get propertiesNoResultsSubtitle =>
      'Сұранысты немесе сүзгіні өзгертіңіз';

  @override
  String get propertiesPriceLabel => 'Бағасы';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price бір м² үшін';
  }

  @override
  String get propertiesProperty => 'Нысан';

  @override
  String propertiesPropertyCreated(Object id) {
    return 'Нысан құрылды (ID: $id)';
  }

  @override
  String get propertiesPropertyIdCopied => 'Нысан ID көшірілді';

  @override
  String propertiesPropertyIdLabel(Object id) {
    return 'Нысан ID: $id';
  }

  @override
  String get propertiesPropertyNotFound => 'Нысан табылмады';

  @override
  String get propertiesRooms => 'Бөлмелер';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms бөлме';
  }

  @override
  String get propertiesSearchHint => 'Іздеу...';

  @override
  String get propertiesSearchHintFull => 'Мекенжай, ТК, ID…';

  @override
  String get propertiesStatus => 'Мәртебесі';

  @override
  String propertiesStepOf(Object current, Object total) {
    return '$total қадамнан $current-і';
  }

  @override
  String get propertiesTitle => 'Нысандар';

  @override
  String get propertiesTitleLabel => 'Атауы';

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
  String remindersBody(Object time) {
    return 'Басталуы $time';
  }

  @override
  String remindersBodyWithClient(Object client, Object time) {
    return 'Басталуы $time, клиент $client';
  }

  @override
  String get remindersFallbackTitle => 'Кездесу';

  @override
  String get remindersLeadDay => 'Бір тәулік бұрын';

  @override
  String get remindersLeadHour => 'Бір сағат бұрын';

  @override
  String get remindersLeadQuarter => '15 минут бұрын';

  @override
  String get remindersPermissionDenied =>
      'EstateCRM хабарландырулары өшірулі. Оларды телефон параметрлерінен қосыңыз.';

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
  String teamsManagerLabel(Object name) {
    return 'Менеджер: $name';
  }

  @override
  String get teamsManagerOptional => 'Менеджер (міндетті емес)';

  @override
  String teamsMemberCount(num count) {
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
