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
  String analyticsAgent(Object name) {
    return 'Агент: $name';
  }

  @override
  String get analyticsAllAgents => 'Барлық агенттер';

  @override
  String get analyticsAvgDaysToWin => 'Жабылғанға дейінгі күн';

  @override
  String get analyticsCreated => 'Құрылды';

  @override
  String analyticsDays(Object days) {
    return '$days күн';
  }

  @override
  String get analyticsEmptyBody =>
      'Осы кезеңде құрылған мәмілелер осында шығады.';

  @override
  String get analyticsEmptyTitle => 'Бұл кезеңде мәміле жоқ';

  @override
  String get analyticsFunnel => 'Воронка';

  @override
  String get analyticsLeadToWon => 'Лидтен сәтті мәмілеге дейін';

  @override
  String get analyticsLoadFailed => 'Аналитиканы жүктеу мүмкін болмады';

  @override
  String get analyticsLostReasons => 'Мәмілелер неге сәтсіз аяқталады';

  @override
  String get analyticsMonthly => 'Соңғы алты ай';

  @override
  String get analyticsNoLost => 'Бұл кезеңде жоғалған мәміле жоқ.';

  @override
  String get analyticsLeadSources => 'Клиенттер қайдан келеді';

  @override
  String get analyticsLeadSourcesHint =>
      'Кезеңде қосылған клиенттер және олардың қаншасы мәміле жасады.';

  @override
  String analyticsLeadSourceWon(Object count, Object rate) {
    return '$count мәміле жасады · $rate';
  }

  @override
  String get analyticsNoClients => 'Бұл кезеңде клиент қосылмаған.';

  @override
  String get analyticsNoValue => '—';

  @override
  String analyticsOfPrevious(Object percent) {
    return 'Алдыңғы кезеңнің $percent';
  }

  @override
  String get analyticsOpen => 'Воронка және аналитика';

  @override
  String get analyticsPeriodMonth => 'Осы ай';

  @override
  String get analyticsPeriodQuarter => 'Тоқсан';

  @override
  String get analyticsPeriodYear => 'Жыл';

  @override
  String get analyticsSelectAgent => 'Агентті таңдаңыз';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String analyticsWonLost(Object lost, Object won) {
    return 'Сәтті: $won · сәтсіз: $lost';
  }

  @override
  String get analyticsWonValue => 'Сәтті мәмілелер сомасы';

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Сізге берілген шақыру кодын енгізіп, құпия сөз таңдаңыз.';

  @override
  String get authAcceptRequest => 'Қабылдау';

  @override
  String get authAcceptTerms => 'Құпиялылық саясатымен келісемін';

  @override
  String get authAcceptTermsRequired => 'Құпиялылық саясатын қабылдаңыз';

  @override
  String get authAcceptYourInvite => 'Шақыруыңызды қабылдаңыз';

  @override
  String get authActivate => 'Белсендіру';

  @override
  String get authBackToSignIn => 'Кіруге оралу';

  @override
  String get authChangeEmail => 'Басқа адрес';

  @override
  String get authChooseRoleSubtitle =>
      'Бұл көретін нәрсеңізді анықтайды. Кейін жетекші өзгерте алады.';

  @override
  String get authChooseRoleTitle => 'Қалай жұмыс істейсіз?';

  @override
  String get authConfirmPassword => 'Құпия сөзді растаңыз';

  @override
  String get authContinue => 'Жалғастыру';

  @override
  String get authCreateAccountSubtitle =>
      'Поштаға алты таңбалы растау кодын жібереміз.';

  @override
  String get authCreateAccountTitle => 'Аккаунт жасаңыз';

  @override
  String get authCreateTeamAction => 'Құру және жалғастыру';

  @override
  String get authCreateTeamName => 'Агенттік атауы';

  @override
  String get authCreateTeamNameRequired => 'Атауын енгізіңіз';

  @override
  String get authCreateTeamSubtitle =>
      'Атауын агенттеріңіз көреді. Кейін өзгертуге болады.';

  @override
  String get authCreateTeamTitle => 'Агенттік құрыңыз';

  @override
  String get authDeclineRequest => 'Қабылдамау';

  @override
  String authDeclineRequestBody(Object team) {
    return '$team сіздің клиенттеріңізді көрмейді. Кейін қайта шақыра алады.';
  }

  @override
  String get authDeclineRequestTitle => 'Шақыруды қабылдамайсыз ба?';

  @override
  String get authEmail => 'Электрондық пошта';

  @override
  String get authEmailInvalid => 'Жарамды электрондық пошта енгізіңіз';

  @override
  String get authEmailRequired => 'Электрондық поштаны енгізіңіз';

  @override
  String get authEmailTaken => 'Бұл адреске аккаунт бар. Кіріңіз.';

  @override
  String get authForgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get authForgotPasswordSubtitle =>
      'Кіретін поштаңызды енгізіңіз — жаңа құпия сөз таңдауға сілтеме жібереміз.';

  @override
  String get authForgotPasswordTitle => 'Құпия сөзді қалпына келтіру';

  @override
  String get authFullName => 'Аты-жөні';

  @override
  String get authFullNameRequired => 'Атыңызды енгізіңіз';

  @override
  String get authHaveAnInvite => 'Шақыруыңыз бар ма?';

  @override
  String get authInviteCode => 'Шақыру коды';

  @override
  String get authInviteCodeRequired => 'Шақыру кодын енгізіңіз';

  @override
  String get authInvitePendingBody =>
      'Бұл адреске шақыру жіберілген. Оны ашыңыз немесе кодты енгізіп құпия сөз қойыңыз.';

  @override
  String get authInvitePendingTitle => 'Сізді бұрын шақырған';

  @override
  String authInviteSignOutBody(Object email) {
    return 'Қазір $email ретінде кіргенсіз. Шақыруды қабылдау үшін алдымен осы аккаунттан шығу қажет.';
  }

  @override
  String get authInviteSignOutConfirm => 'Шығып, жалғастыру';

  @override
  String get authInviteSignOutTitle => 'Шақыруды қабылдайсыз ба?';

  @override
  String authInvitedBy(Object name) {
    return '$name жіберген';
  }

  @override
  String authInvitedByTeam(Object team) {
    return '$team сізді шақырады';
  }

  @override
  String get authNewPassword => 'Жаңа құпия сөз';

  @override
  String get authNoAccount => 'Аккаунт жоқ па?';

  @override
  String get authPassword => 'Құпия сөз';

  @override
  String get authPasswordHelp => 'Кемінде 8 таңба, бір сан.';

  @override
  String get authPasswordMinLength => 'Кемінде 6 таңба';

  @override
  String get authPasswordMinLength8 => 'Кемінде 8 таңба';

  @override
  String get authPasswordRequired => 'Құпия сөзді енгізіңіз';

  @override
  String get authPasswordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get authPhoneOptional => 'Телефон (міндетті емес)';

  @override
  String get authPrivacyPolicy => 'Құпиялылық саясаты';

  @override
  String get authResendCode => 'Кодты қайта жіберу';

  @override
  String authResendCodeIn(Object seconds) {
    return 'Жаңа код $seconds с ішінде';
  }

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
  String get authRoleAgentBody =>
      'Жетекшінің командасына қосылып, өз клиенттеріңізбен жұмыс істеңіз.';

  @override
  String get authRoleAgentTitle => 'Мен агентпін';

  @override
  String get authRoleManagerBody =>
      'Команда құрып, агенттер қосыңыз және олардың жұмысын көріңіз.';

  @override
  String get authRoleManagerTitle => 'Мен агенттік басқарамын';

  @override
  String get authSendResetLink => 'Сілтеме жіберу';

  @override
  String get authSetPasswordSignIn => 'Құпиясөз қойып, кіру';

  @override
  String get authSignIn => 'Кіру';

  @override
  String get authSignInSubtitle => 'Нысандарыңызды басқару үшін кіріңіз';

  @override
  String get authSignUp => 'Тіркелу';

  @override
  String get authVerify => 'Растау';

  @override
  String authVerifyEmailSubtitle(Object email) {
    return '$email адресіне жіберілген алты таңбалы кодты енгізіңіз.';
  }

  @override
  String get authVerifyEmailTitle => 'Поштаны растаңыз';

  @override
  String get authWaitingCopyEmail => 'Адресті көшіру';

  @override
  String get authWaitingEmailCopied => 'Адрес көшірілді';

  @override
  String get authWaitingNoRequests => 'Шақыру әзірге жоқ';

  @override
  String get authWaitingNoRequestsBody => 'Жаңарту үшін төмен тартыңыз.';

  @override
  String get authWaitingSubtitle =>
      'Осы адресті жетекшіге беріңіз. Ол сізді қосып, сұранысты қабылдағаннан кейін клиенттер мен мәмілелер шығады.';

  @override
  String get authWaitingTitle => 'Команда күтілуде';

  @override
  String get authWelcomeBack => 'Қайта оралуыңызбен!';

  @override
  String get calendarAdd => 'Қосу';

  @override
  String get calendarAddMeeting => 'Кездесу';

  @override
  String get calendarAddMeetingHint => 'Клиентпен, белгіленген уақытта';

  @override
  String get calendarAddTask => 'Тапсырма';

  @override
  String get calendarAddTaskHint => 'Белгілі уақытқа дейін орындалатын іс';

  @override
  String calendarAddTo(String day) {
    return '$day күніне қосу';
  }

  @override
  String get calendarDayEmpty => 'Ештеңе жоспарланбаған';

  @override
  String get calendarDayEmptyHint =>
      'Кездесу не тапсырма қосу үшін + басыңыз немесе күнді басып тұрыңыз';

  @override
  String calendarDayEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count жазба',
      zero: 'ештеңе жоспарланбаған',
    );
    return '$_temp0';
  }

  @override
  String get calendarLegendMeeting => 'Кездесу';

  @override
  String get calendarLegendOpenHouse => 'Ашық есік күні';

  @override
  String get calendarLegendOverdue => 'Мерзімі өткен';

  @override
  String get calendarLegendTask => 'Тапсырма';

  @override
  String get calendarLegendViewing => 'Көрсетілім';

  @override
  String get calendarLoadFailed => 'Күнтізбе жүктелмеді';

  @override
  String get calendarNextMonth => 'Келесі ай';

  @override
  String get calendarNextWeek => 'Келесі апта';

  @override
  String get calendarPreviousMonth => 'Алдыңғы ай';

  @override
  String get calendarPreviousWeek => 'Алдыңғы апта';

  @override
  String get calendarShowMonth => 'Бүкіл айды көрсету';

  @override
  String get calendarShowWeek => 'Бір аптаны көрсету';

  @override
  String get calendarTitle => 'Күнтізбе';

  @override
  String get calendarToday => 'Бүгін';

  @override
  String get calendarViewList => 'Тізім';

  @override
  String get calendarViewMonth => 'Ай';

  @override
  String get clientsActivityCall => 'Қоңырау';

  @override
  String get clientsActivityDate => 'Күні';

  @override
  String get clientsActivityDeleteBody =>
      'Жазба клиент тарихынан бүкіл команда үшін жойылады. Мұны қайтару мүмкін емес.';

  @override
  String get clientsActivityDeleteTitle => 'Жазбаны жою керек пе?';

  @override
  String get clientsActivityEdit => 'Жазбаны өзгерту';

  @override
  String get clientsActivityEmail => 'Хат';

  @override
  String get clientsActivityFormerMember => 'Бұрынғы қызметкер';

  @override
  String get clientsActivityInFuture => 'Бұл уақыт әлі келген жоқ';

  @override
  String get clientsActivityKind => 'Қалай хабарластыңыз';

  @override
  String get clientsActivityLogged => 'Байланыс жазылды';

  @override
  String get clientsActivityMessage => 'Хабарлама';

  @override
  String get clientsActivityNote => 'Жазба';

  @override
  String get clientsActivityNoteHint => 'Не айтылды, әрі қарай не болады…';

  @override
  String get clientsActivityNoteLabel => 'Не талқыланды';

  @override
  String get clientsActivityNoteRequired => 'Жазбаға мәтін керек';

  @override
  String get clientsActivityRemove => 'Жазбаны жою';

  @override
  String get clientsActivitySave => 'Сақтау';

  @override
  String clientsActivitySentListings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нысан жіберілді',
      one: '1 нысан жіберілді',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityTime => 'Уақыты';

  @override
  String clientsActivityToday(String time) {
    return 'Бүгін, $time';
  }

  @override
  String get clientsActivityUpdated => 'Жазба жаңартылды';

  @override
  String get clientsActivityWhen => 'Қашан';

  @override
  String get clientsActivityWhenHourAgo => 'Бір сағат бұрын';

  @override
  String get clientsActivityWhenJustNow => 'Жаңа ғана';

  @override
  String get clientsActivityWhenYesterday => 'Кеше';

  @override
  String clientsActivityYesterday(String time) {
    return 'Кеше, $time';
  }

  @override
  String get clientsAddFirstClient => 'Алғашқы клиентіңізді қосыңыз';

  @override
  String get clientsAgent => 'Агент';

  @override
  String clientsAgentMeta(Object name) {
    return 'агент $name';
  }

  @override
  String get clientsAnyType => 'Кез келген';

  @override
  String get clientsBirthday => 'Туған күн';

  @override
  String clientsBirthdayAge(int age) {
    return '$age жаста';
  }

  @override
  String get clientsBirthdayClear => 'Туған күнді өшіру';

  @override
  String get clientsBirthdayHint =>
      'Жылы белгісіз болса, тек күні мен айы сақталады.';

  @override
  String get clientsBirthdayNoYear => 'Жылы белгісіз';

  @override
  String get clientsBirthdayPick => 'Күнді таңдау';

  @override
  String get clientsBudgetFrom => 'Бюджет бастап';

  @override
  String get clientsBudgetTo => 'Бюджет дейін';

  @override
  String get clientsBuyer => 'Сатып алушы';

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
  String clientsColdDaysOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdEmpty => 'Ешкім суымай жатыр';

  @override
  String clientsColdEmptyHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Хабарласуға тұрарлық әр клиентпен соңғы $count күнде сөйлестіңіз.',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdLoadFailed => 'Суып бара жатқан клиенттер жүктелмеді';

  @override
  String get clientsColdNeverContacted => 'Әлі хабарласпаған';

  @override
  String get clientsColdNextCheckIn => 'Жағдайын сұрау';

  @override
  String get clientsColdNextFirstCall => 'Алғашқы қоңырау шалу';

  @override
  String get clientsColdNextPushDeal => 'Мәмілені алға жылжыту';

  @override
  String get clientsColdNextSendMatches => 'Сәйкес нысандарды жіберу';

  @override
  String get clientsColdReasonLead => 'Нысан бетінен өтінім';

  @override
  String clientsColdReasonMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сәйкес нысан',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdReasonNegotiation => 'Мәміле келіссөзде';

  @override
  String get clientsColdReasonOpenDeal => 'Ашық мәміле';

  @override
  String get clientsColdRemind => 'Еске салу';

  @override
  String clientsColdRemindTask(String name) {
    return 'Қоңырау шалу: $name';
  }

  @override
  String clientsColdReminderSet(String time) {
    return 'Еске салу ертеңге қойылды, $time';
  }

  @override
  String clientsColdSilentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн хабарсыз',
    );
    return '$_temp0';
  }

  @override
  String clientsColdSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн және одан да көп хабарсыз',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdTitle => 'Суып барады';

  @override
  String get clientsColdUndo => 'Болдырмау';

  @override
  String get clientsComposeClearListing => 'Нысанды алып тастау';

  @override
  String get clientsComposeHint =>
      'Жіберу алдында мәтінді түзетуге болады. Жіберілген хабарлама клиент тарихында сақталады.';

  @override
  String get clientsComposeListing => 'Нысан';

  @override
  String get clientsComposeListingHint =>
      'Нысанды, оның бағасын, мекенжайын және сілтемесін қояды';

  @override
  String get clientsComposeListingNone => 'Нысансыз';

  @override
  String get clientsComposeNoListings => 'Нысандар жоқ';

  @override
  String get clientsComposeNoTemplates => 'Агенттікте әзірге үлгілер жоқ';

  @override
  String get clientsComposePickListing => 'Нысанды таңдаңыз';

  @override
  String get clientsComposePickTemplate => 'Үлгіні таңдаңыз';

  @override
  String get clientsComposeSearchListings => 'Нысандарды іздеу';

  @override
  String get clientsComposeSearchTemplates => 'Үлгілерді іздеу';

  @override
  String get clientsComposeSms => 'SMS';

  @override
  String get clientsComposeText => 'Хабарлама';

  @override
  String get clientsComposeTextHint =>
      'Хабарлама жазыңыз немесе үлгіні таңдаңыз';

  @override
  String get clientsComposeTitle => 'Клиентке жазу';

  @override
  String get clientsComposeUseTemplate => 'Үлгіні қолдану';

  @override
  String get clientsContact => 'Байланыс';

  @override
  String get clientsContactInfo => 'Байланыс ақпараты';

  @override
  String clientsContactedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн бұрын хабарласты',
    );
    return '$_temp0';
  }

  @override
  String clientsContactedOn(String date) {
    return 'Соңғы байланыс: $date';
  }

  @override
  String get clientsContactedToday => 'Бүгін хабарласты';

  @override
  String get clientsContactedYesterday => 'Кеше хабарласты';

  @override
  String clientsCounter(Object active, Object total) {
    return 'барлығы $total · жұмыста $active';
  }

  @override
  String get clientsCreateClient => 'Клиент құру';

  @override
  String clientsDatesAnniversary(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Сатып алғанына $years жыл',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesBirthday => 'Туған күн';

  @override
  String get clientsDatesEmpty => 'Алдағы екі аптада күндер жоқ';

  @override
  String get clientsDatesEmptyHint =>
      'Клиент карточкасына туған күнін қосыңыз. Сәтті мәміленің жылдығы мұнда жыл сайын өзі шығады.';

  @override
  String get clientsDatesGreet => 'Құттықтау';

  @override
  String clientsDatesInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күннен кейін',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesLoadFailed => 'Жақын күндерді жүктеу мүмкін болмады';

  @override
  String get clientsDatesTitle => 'Жақын күндер';

  @override
  String get clientsDatesToday => 'Бүгін';

  @override
  String get clientsDatesTomorrow => 'Ертең';

  @override
  String clientsDatesTurns(int years) {
    return 'Туған күні, $years жасқа толады';
  }

  @override
  String clientsDatesWhen(String when, String date) {
    return '$when · $date';
  }

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
  String get clientsDuplicateEyebrow => 'Ықтимал қайталану';

  @override
  String clientsDuplicateHeldBy(String agent, String name) {
    return 'Агенттікте бар: $name (агент $agent)';
  }

  @override
  String get clientsDuplicateHint =>
      'Бәрібір сақтауға болады. Алдымен әріптеспен нақтылаңыз.';

  @override
  String get clientsDuplicateOpen => 'Ашу';

  @override
  String get clientsDuplicateSameBoth => 'Телефоны мен email сәйкес';

  @override
  String get clientsDuplicateSameEmail => 'Email сәйкес';

  @override
  String get clientsDuplicateSamePhone => 'Телефоны сәйкес';

  @override
  String clientsDuplicateUnassigned(String name) {
    return 'Агенттікте бар: $name';
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
  String get clientsFilterNewLeads => 'Жаңа өтінімдер';

  @override
  String get clientsFilterSellers => 'Сатушылар';

  @override
  String clientsFilterTagsCount(Object count) {
    return 'Тегтер · $count';
  }

  @override
  String get clientsFilterSource => 'Дереккөз';

  @override
  String get clientsFilterSourceAll => 'Барлық дереккөздер';

  @override
  String get clientsFollowUpCall => 'Бұл қоңырауды жазып қоясыз ба?';

  @override
  String get clientsFollowUpEmail => 'Бұл хатты жазып қоясыз ба?';

  @override
  String get clientsFollowUpHint =>
      'Бір басқанда тарихқа жазылады. Ескертпе міндетті емес.';

  @override
  String get clientsFullName => 'Толық аты-жөні';

  @override
  String get clientsHistory => 'Тарих';

  @override
  String get clientsHistoryEmpty => 'Әзірге байланыс жазылмаған';

  @override
  String get clientsHistoryEmptyHint =>
      'Әр қоңырауды, хабарламаны және хатты жазып отырыңыз — клиентті кім алса да, қай жерде тоқтағанын бірден біледі.';

  @override
  String get clientsHistoryLoadFailed => 'Тарихты жүктеу мүмкін болмады';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Қате email';

  @override
  String get clientsLogContact => 'Байланысты жазу';

  @override
  String get clientsLogFirstContact => 'Алғашқы байланысты жазу';

  @override
  String get clientsMatches => 'Сәйкес нысандар';

  @override
  String get clientsMerge => 'Басқа карточкамен біріктіру';

  @override
  String get clientsMergeConfirm => 'Біріктіру';

  @override
  String clientsMergeConfirmBody(String source, String target) {
    return '$source клиентінің мәмілелері, көрсетілімдері, байланыс тарихы мен тапсырмалары $target клиентіне ауысады. Бос телефон, email және талаптар толтырылады, жазбалар қосылады. Содан кейін $source карточкасы жойылады. Бұны қайтару мүмкін емес.';
  }

  @override
  String get clientsMergeConfirmTitle => 'Осы карточкаға біріктіру керек пе?';

  @override
  String get clientsMergeNoCandidates => 'Біріктіретін басқа клиент жоқ';

  @override
  String get clientsMergePickTitle => 'Қай карточка — сол адам?';

  @override
  String get clientsMergeSearchHint => 'Клиенттерді іздеу';

  @override
  String get clientsMessage => 'Жазу';

  @override
  String get clientsMinArea => 'Аумағы, кемінде м²';

  @override
  String get clientsMinRooms => 'Бөлме, кемінде';

  @override
  String get clientsNameRequired => 'Атын енгізіңіз';

  @override
  String get clientsNewClient => 'Жаңа клиент';

  @override
  String get clientsNewLeadsEmpty =>
      'Нысанның жария сілтемесі арқылы байланыс қалдырған сатып алушылар мұнда бір апта көрінеді.';

  @override
  String get clientsNoClientsFound => 'Клиенттер табылмады';

  @override
  String get clientsNoEmail => 'Эл. пошта көрсетілмеген';

  @override
  String get clientsNoMatches => 'Әзірге сәйкесі жоқ';

  @override
  String get clientsNoPhone => 'Телефон көрсетілмеген';

  @override
  String get clientsNoRequirements =>
      'Сатып алушы не іздейтінін көрсетіңіз, сәйкес нысандар осында шығады';

  @override
  String get clientsNoWhatsApp =>
      'Карточкада телефон жоқ, сондықтан WhatsApp қолжетімсіз';

  @override
  String get clientsNotes => 'Ескертпелер';

  @override
  String get clientsNotesHint => 'Осы клиент туралы қосымша ескертпелер…';

  @override
  String get clientsOverBudget => 'Бюджеттен қымбат';

  @override
  String get clientsPhone => 'Телефон';

  @override
  String get clientsRequirements => 'Не іздейді';

  @override
  String get clientsRequirementsHint =>
      'Толтырыңыз — қолданба сәйкес нысандарды өзі көрсетеді.';

  @override
  String get clientsSearchHint => 'Аты, телефоны бойынша іздеу…';

  @override
  String get clientsSeller => 'Сатушы';

  @override
  String get clientsSendClosing =>
      'Қайсысын көргіңіз келетінін жазыңыз, көрсетілімді ұйымдастырамын.';

  @override
  String get clientsSendFailed => 'Жіберуді ашу мүмкін болмады';

  @override
  String get clientsSendGreeting =>
      'Сәлеметсіз бе! Сұранысыңызға сай келетін нұсқалар:';

  @override
  String get clientsSendLinks => 'Сілтемелерді қосу';

  @override
  String get clientsSendLinksHint =>
      'Әр нысанның барлық фотосы бар беті. Кез келген браузерде ашылады.';

  @override
  String get clientsSendLogged => 'Клиент тарихына сақталды';

  @override
  String get clientsSendMatches => 'Іріктемені жіберу';

  @override
  String get clientsSendPhotos => 'Фото тіркеу';

  @override
  String get clientsSendPhotosHint =>
      'Фото «Бөлісу» арқылы жіберіледі. WhatsApp чатты тек мәтінмен ашады.';

  @override
  String clientsSendSelected(int count) {
    return 'Таңдалды: $count';
  }

  @override
  String get clientsSendShare => 'Бөлісу';

  @override
  String get clientsSendWhatsApp => 'WhatsApp';

  @override
  String clientsSentOn(String date) {
    return '$date жіберілді';
  }

  @override
  String clientsShownOn(String date) {
    return '$date көрсетілді';
  }

  @override
  String get clientsSourceImport => 'Импорттан';

  @override
  String get clientsSourceOpenHouse => 'Ашық есік күнінен';

  @override
  String get clientsSourcePublicLink => 'Жария сілтемеден';

  @override
  String get clientsTagAdd => 'Тег қосу';

  @override
  String get clientsTagAddHint => 'Тег қосу';

  @override
  String get clientsTagFilterClear => 'Тегтерді тазалау';

  @override
  String get clientsTagFilterDone => 'Клиенттерді көрсету';

  @override
  String get clientsTagFilterEmpty =>
      'Әзірге ешбір клиентте тег жоқ. Тегтер клиент карточкасында қосылады.';

  @override
  String get clientsTagFilterSubtitle =>
      'Таңдалған тегтердің бәрі бар клиенттер';

  @override
  String get clientsTagFilterTitle => 'Тегтер бойынша сүзу';

  @override
  String clientsTagLimit(Object count) {
    return 'Бір клиентке $count тегтен артық емес';
  }

  @override
  String clientsTagRemove(Object tag) {
    return '$tag тегін алып тастау';
  }

  @override
  String get clientsTagSuggestions => 'Агенттікте бұрыннан бар';

  @override
  String clientsTagTooLong(Object count) {
    return 'Тег $count таңбадан аспауы керек';
  }

  @override
  String get clientsTags => 'Тегтер';

  @override
  String get clientsTagsHint =>
      'Клиентті кейін табуға арналған қысқа белгілер: инвестор, шұғыл, VIP.';

  @override
  String clientsTagsMore(Object count) {
    return '+$count';
  }

  @override
  String get clientsLeadSource => 'Қайдан келді';

  @override
  String get clientsLeadSourceNone => 'Көрсетілмеген';

  @override
  String get clientsLeadSourceReferral => 'Ұсыныс';

  @override
  String get clientsLeadSourceWebsite => 'Сайт';

  @override
  String get clientsLeadSourcePortal => 'Хабарландыру порталы';

  @override
  String get clientsLeadSourceSocial => 'Әлеуметтік желілер';

  @override
  String get clientsLeadSourceWalkIn => 'Кеңсеге келді';

  @override
  String get clientsLeadSourceColdCall => 'Суық қоңырау';

  @override
  String get clientsLeadSourceRepeat => 'Тұрақты клиент';

  @override
  String get clientsLeadSourceOther => 'Басқа';

  @override
  String get clientsLeadSourceDetail => 'Толығырақ';

  @override
  String get clientsLeadSourceDetailHint => 'Кім ұсынды, қай портал';

  @override
  String get clientsTitle => 'Клиенттер';

  @override
  String get clientsTryDifferentSearch => 'Басқа сұранысты байқап көріңіз';

  @override
  String get clientsUpdateClient => 'Клиентті жаңарту';

  @override
  String clientsUpdatedAt(Object date) {
    return 'Жаңартылды $date';
  }

  @override
  String get clientsWantedCity => 'Қала';

  @override
  String get clientsWantedType => 'Нысан түрі';

  @override
  String get clientsWrite => 'WhatsApp немесе SMS';

  @override
  String get compareAction => 'Салыстыру';

  @override
  String get compareAdd => 'Салыстыруға қосу';

  @override
  String get compareAdded => 'Салыстыруға қосылды';

  @override
  String compareBarButton(int count) {
    return 'Салыстыру ($count)';
  }

  @override
  String get compareBestLegend => 'Жолдағы ең тиімді мән жасылмен белгіленген';

  @override
  String compareDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн',
      zero: 'Бүгін шықты',
    );
    return '$_temp0';
  }

  @override
  String get compareExit => 'Дайын';

  @override
  String get compareFirstFloor => 'бірінші қабат';

  @override
  String get compareFitMatches => 'Сұранысқа сай';

  @override
  String get compareFitOutside => 'Сұраныстан тыс';

  @override
  String get compareFitOverBudget => 'Бюджеттен қымбат';

  @override
  String get compareLastFloor => 'соңғы қабат';

  @override
  String get compareLimit =>
      'Қатар 4 нысанға дейін салыстыруға болады. Басқасын қосу үшін біреуін алып тастаңыз.';

  @override
  String get compareLinks => 'Сілтемелерді қосу';

  @override
  String get compareLinksHint =>
      'Әр нысанның астында оның барлық фотосы бар бет.';

  @override
  String get compareNeedTwo => 'Салыстыру үшін екі нысан таңдаңыз';

  @override
  String get compareNeedTwoHint =>
      '«Нысандар» қойындысында «Салыстыру» түймесін басыңыз немесе нысанды оның бетінен қосыңыз.';

  @override
  String get comparePickHint => 'Екіден төртке дейін нысан таңдаңыз';

  @override
  String get compareRemove => 'Салыстырудан алып тастау';

  @override
  String get compareRemoved => 'Салыстырудан алынды';

  @override
  String get compareRowAgent => 'Агент';

  @override
  String get compareRowArea => 'Ауданы';

  @override
  String get compareRowDays => 'Сатылымда';

  @override
  String get compareRowFit => 'Сатып алушыға';

  @override
  String get compareRowFloor => 'Қабат';

  @override
  String get compareRowLinkViews => 'Сілтеме қаралымы';

  @override
  String get compareRowPlace => 'Мекенжай';

  @override
  String get compareRowPrice => 'Бағасы';

  @override
  String get compareRowPriceChange => 'Бағаның соңғы өзгерісі';

  @override
  String get compareRowPricePerSqm => '1 м² бағасы';

  @override
  String get compareRowRooms => 'Бөлмелер';

  @override
  String get compareRowType => 'Түрі';

  @override
  String get compareSelected => 'Таңдалғандарды салыстыру';

  @override
  String get compareSend => 'Салыстыруды жіберу';

  @override
  String get compareSendFailed => 'Жіберуді ашу мүмкін болмады';

  @override
  String compareShareBest(String title) {
    return '1 м² ең тиімді бағасы: $title';
  }

  @override
  String get compareShareIntro => 'Нысандарды салыстыру:';

  @override
  String get compareTitle => 'Салыстыру';

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
  String get coreErrorOfflineWrite => 'Желі жоқ — бұл үшін байланыс керек.';

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
  String get coreNavCalendar => 'Күнтізбе';

  @override
  String get coreNavClients => 'Клиенттер';

  @override
  String get coreNavDashboard => 'Басқару тақтасы';

  @override
  String get coreNavDeals => 'Мәмілелер';

  @override
  String get coreNavProperties => 'Нысандар';

  @override
  String get coreNavTeam => 'Команда';

  @override
  String get coreNoResults => 'Ештеңе табылмады';

  @override
  String get coreNotSelected => 'Таңдалмаған';

  @override
  String coreOfflineSince(String time) {
    return 'Желі жоқ — $time кезіндегі деректер';
  }

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
  String get dashboardActiveDealsLabel => 'Белсенді мәмілелер';

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
  String dashboardColdTotal(int count) {
    return 'барлығы $count';
  }

  @override
  String get dashboardConversion => 'Конверсия';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · команда сводкасы';
  }

  @override
  String get dashboardDatesTitle => 'Осы аптадағы күндер';

  @override
  String dashboardDatesTotal(int count) {
    return 'аптада $count';
  }

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
  String dashboardMandatesTotal(int count) {
    return 'барлығы $count';
  }

  @override
  String get dashboardMeetingLoad => 'Алдағы екі апта';

  @override
  String get dashboardMeetingsLabel => 'Кездесулер';

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
  String get dashboardTasksClear => 'Бүгінге тапсырма жоқ';

  @override
  String dashboardTasksOverdueCount(Object count) {
    return 'Мерзімі өткен: $count';
  }

  @override
  String get dashboardTasksToday => 'Бүгін істеу керек';

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
  String get dashboardUpcomingMeetings => 'Алдағы кездесулер';

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
  String dealsBoardColumnMeta(Object count, Object total) {
    return '$count · $total';
  }

  @override
  String get dealsBoardDragHint =>
      'Картаны басып тұрып, оны басқа кезеңге апарыңыз';

  @override
  String get dealsBoardStageEmpty => 'Бұл кезеңде ештеңе жоқ';

  @override
  String get dealsBudget => 'Бюджет';

  @override
  String dealsBudgetValue(Object price) {
    return 'Бюджет: $price';
  }

  @override
  String get dealsChecklistAdd => 'Тармақ қосу';

  @override
  String get dealsChecklistAddTitle => 'Тізімге жаңа тармақ';

  @override
  String get dealsChecklistAttach => 'Құжат тіркеу';

  @override
  String dealsChecklistBadge(int done, int total) {
    return 'Тексеру тізімі: $total ішінен $done орындалды';
  }

  @override
  String get dealsChecklistDelete => 'Тармақты жою';

  @override
  String get dealsChecklistDeleteBody =>
      'Тармақ осы мәміленің тізімінен жойылады.';

  @override
  String get dealsChecklistDeleteTitle => 'Бұл тармақты жою керек пе?';

  @override
  String get dealsChecklistDetach => 'Құжатты ажырату';

  @override
  String dealsChecklistDoneAt(String date) {
    return 'Орындалды: $date';
  }

  @override
  String dealsChecklistDoneBy(String date, String name) {
    return '$name · $date';
  }

  @override
  String get dealsChecklistEmptyStage =>
      'Бұл кезеңде ештеңе жинаудың қажеті жоқ';

  @override
  String dealsChecklistGateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count міндетті тармақ әлі орындалмаған. Мәмілені бәрібір ауыстыру керек пе?',
    );
    return '$_temp0';
  }

  @override
  String get dealsChecklistGateConfirm => 'Бәрібір ауыстыру';

  @override
  String get dealsChecklistGateTitle => 'Міндетті тармақтар орындалмаған';

  @override
  String get dealsChecklistItemHint => 'Мысалы, төлқұжаттың көшірмесі';

  @override
  String get dealsChecklistItemLabel => 'Не қажет';

  @override
  String get dealsChecklistLoadFailed => 'Тізімді жүктеу мүмкін болмады';

  @override
  String get dealsChecklistMore => 'Тармақ әрекеттері';

  @override
  String get dealsChecklistNoDocuments =>
      'Мәміледе әлі құжат жоқ. Алдымен файлды «Құжаттар» бөліміне жүктеңіз.';

  @override
  String get dealsChecklistPickDocument => 'Құжатты таңдаңыз';

  @override
  String dealsChecklistProgress(int done, int total) {
    return '$total ішінен $done орындалды';
  }

  @override
  String get dealsChecklistRequired => 'Міндетті';

  @override
  String get dealsChecklistRequiredHint =>
      'Онсыз мәміле әрі қарай ауысса, қолданба ескертеді';

  @override
  String get dealsChecklistStage => 'Кезең';

  @override
  String get dealsChecklistTitle => 'Тексеру тізімі';

  @override
  String get dealsClient => 'Клиент';

  @override
  String dealsClientRef(Object id) {
    return 'Клиент №$id';
  }

  @override
  String dealsCommentCount(int count) {
    return '$count пікір';
  }

  @override
  String get dealsCommentDelete => 'Пікірді жою';

  @override
  String get dealsCommentDeleteBody =>
      'Ол осы мәмілемен жұмыс істейтін барлық адамнан жойылады.';

  @override
  String get dealsCommentDeleteTitle => 'Бұл пікірді жою керек пе?';

  @override
  String get dealsCommentEdit => 'Пікірді өзгерту';

  @override
  String get dealsCommentEdited => 'өзгертілді';

  @override
  String get dealsCommentHint => 'Пікір жазыңыз…';

  @override
  String get dealsCommentJustNow => 'жаңа ғана';

  @override
  String get dealsCommentLess => 'Жасыру';

  @override
  String get dealsCommentMentionLoadFailed =>
      'Әріптестерді жүктеу мүмкін болмады';

  @override
  String get dealsCommentMentionNone =>
      'Бұл мәмілені сізден басқа ешкім көрмейді';

  @override
  String get dealsCommentMentionNotAllowed =>
      'Тек осы мәмілені көре алатын әріптестерді атауға болады';

  @override
  String get dealsCommentMentionTitle => 'Әріптесті атау';

  @override
  String get dealsCommentMore => 'Толығырақ';

  @override
  String get dealsCommentSend => 'Жіберу';

  @override
  String get dealsCommentSending => 'Жіберілуде…';

  @override
  String get dealsCommission => 'Комиссия';

  @override
  String get dealsCommissionAmount => 'Сомасы';

  @override
  String get dealsCommissionInvalid =>
      '0-ден жоғары, 100-ден аспайтын мөлшерлеме енгізіңіз';

  @override
  String get dealsCommissionNeedsPrice =>
      'Соманы есептеу үшін мәміле бағасын көрсетіңіз';

  @override
  String get dealsCommissionPercent => 'Комиссия, %';

  @override
  String get dealsCommissionRate => 'Мөлшерлеме';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active белсенді · $total';
  }

  @override
  String get dealsCreateDeal => 'Мәміле құру';

  @override
  String get dealsDealPrice => 'Мәміле бағасы';

  @override
  String dealsDeleteCascade(Object title) {
    return '«$title» біржола жойылады. Бұны қайтару мүмкін емес.';
  }

  @override
  String get dealsDeleteTitle => 'Мәмілені жою';

  @override
  String get dealsDiscussion => 'Талқылау';

  @override
  String get dealsDiscussionEmpty => 'Әзірге пікір жоқ';

  @override
  String get dealsDiscussionEmptyHint =>
      'Мәміле туралы әңгімені осында жүргізіңіз. Әріптесті шақыру үшін @ белгісін теріңіз.';

  @override
  String get dealsDiscussionLoadFailed => 'Талқылауды жүктеу мүмкін болмады';

  @override
  String get dealsDiscussionShowEarlier => 'Бұрынғыларын көрсету';

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
  String get dealsLostConfirm => 'Жоғалды деп белгілеу';

  @override
  String get dealsLostNote => 'Түсініктеме';

  @override
  String get dealsLostNoteHint => 'Не болды — келесі жолы пайдасы тиеді';

  @override
  String get dealsLostReason => 'Жоғалту себебі';

  @override
  String get dealsLostReasonChangedMind => 'Ойынан айнып қалды';

  @override
  String get dealsLostReasonChoseAnother => 'Басқа нұсқаны таңдады';

  @override
  String get dealsLostReasonFinancing => 'Қаржыландыру болмады';

  @override
  String get dealsLostReasonNoResponse => 'Байланысқа шықпай кетті';

  @override
  String get dealsLostReasonOther => 'Басқа';

  @override
  String get dealsLostReasonPrice => 'Баға';

  @override
  String get dealsLostReasonUnspecified => 'Көрсетілмеген';

  @override
  String get dealsLostSheetSubtitle =>
      'Себебін таңдаңыз — ол аналитикадағы воронкаға түседі.';

  @override
  String get dealsLostSheetTitle => 'Мәміле неге сәтсіз аяқталды?';

  @override
  String get dealsNewTitle => 'Жаңа мәміле';

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
  String get dealsViewBoard => 'Тақта';

  @override
  String get dealsViewList => 'Тізім';

  @override
  String get depositsAmount => 'Сомасы';

  @override
  String get depositsAmountHint => 'мысалы, 500 000';

  @override
  String get depositsCloseAction => 'Кепілпұлды жабу';

  @override
  String get depositsCloseTitle => 'Кепілпұл немен аяқталды?';

  @override
  String get depositsClosedBeforeReceived =>
      'Кепілпұл алынғанға дейін аяқтала алмайды';

  @override
  String get depositsClosedOn => 'Күні';

  @override
  String get depositsDealClosedHint =>
      'Мәміле жабық, кепілпұл енгізу мүмкін емес.';

  @override
  String get depositsEdit => 'Өзгерту';

  @override
  String get depositsEditTitle => 'Кепілпұлды өзгерту';

  @override
  String get depositsEndingEmpty => 'Мерзімі бітетін кепілпұл жоқ';

  @override
  String get depositsEndingEmptyHint =>
      'Белсенді кепілпұлдар бронь аяқталуына бір апта қалғанда осында шығады.';

  @override
  String get depositsEndingLoadFailed => 'Кепілпұлдарды жүктеу мүмкін болмады';

  @override
  String get depositsEndingTitle => 'Мерзімі бітетін кепілпұлдар';

  @override
  String get depositsHistory => 'Бұрынғы кепілпұлдар';

  @override
  String get depositsHoldBeforeReceived =>
      'Бронь кепілпұл алынғаннан бұрын аяқтала алмайды';

  @override
  String depositsHoldEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бронь $count күн бұрын аяқталды',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndedYesterday => 'Бронь кеше аяқталды';

  @override
  String depositsHoldEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бронь $count күннен кейін аяқталады',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndsToday => 'Бронь бүгін аяқталады';

  @override
  String get depositsHoldEndsTomorrow => 'Бронь ертең аяқталады';

  @override
  String get depositsHoldUntil => 'Бронь мерзімі';

  @override
  String get depositsHolder => 'Сақтаушы';

  @override
  String get depositsHolderAgency => 'Агенттік';

  @override
  String get depositsHolderNotary => 'Нотариус';

  @override
  String get depositsHolderSeller => 'Сатушы';

  @override
  String get depositsLoadFailed => 'Кепілпұлды жүктеу мүмкін болмады';

  @override
  String get depositsNone => 'Кепілпұл енгізілмеген';

  @override
  String get depositsNoneHint =>
      'Сатып алушы ақша енгізгенде жазыңыз, сонда нысан брондалған деп белгіленеді.';

  @override
  String get depositsNote => 'Ескертпе';

  @override
  String get depositsNoteHint => 'Қолхат нөмірі, шарттар';

  @override
  String get depositsOutcomeApplied => 'Сатып алуға есептелді';

  @override
  String get depositsOutcomeForfeited => 'Ұсталды';

  @override
  String get depositsOutcomeRefunded => 'Қайтарылды';

  @override
  String get depositsReceivedOn => 'Алынған күні';

  @override
  String get depositsRecord => 'Кепілпұл енгізу';

  @override
  String get depositsRecordTitle => 'Жаңа кепілпұл';

  @override
  String depositsReservedUntil(String date) {
    return '$date дейін брондалған';
  }

  @override
  String get depositsTitle => 'Кепілпұл';

  @override
  String get documentsAdd => 'Файл тіркеу';

  @override
  String documentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файл',
      one: '1 файл',
      zero: 'Файл жоқ',
    );
    return '$_temp0';
  }

  @override
  String documentsDeleteConfirm(Object name) {
    return '$name осы мәміледен өшіріледі. Мұны қайтару мүмкін емес.';
  }

  @override
  String get documentsDeleteTitle => 'Құжатты өшіру';

  @override
  String get documentsEmpty => 'Бұл мәмілеге әзірге бірде-бір файл тіркелмеген';

  @override
  String get documentsNoApp =>
      'Бұл телефонда мұндай файлды ашатын қолданба жоқ';

  @override
  String get documentsOpenFailed => 'Файлды ашу мүмкін болмады';

  @override
  String documentsSizeBytes(Object size) {
    return '$size Б';
  }

  @override
  String documentsSizeKb(Object size) {
    return '$size КБ';
  }

  @override
  String documentsSizeMb(Object size) {
    return '$size МБ';
  }

  @override
  String get documentsTitle => 'Құжаттар';

  @override
  String documentsTooLarge(Object limit) {
    return '$limit МБ-тан үлкен файлдарды тіркеуге болмайды';
  }

  @override
  String documentsUploadedBy(Object name) {
    return 'Қосқан: $name';
  }

  @override
  String get documentsUploading => 'Жіберілуде…';

  @override
  String get exportAction => 'Экспорт';

  @override
  String get exportAllNote => 'Сізге қолжетімдінің бәрі, сүзгісіз.';

  @override
  String get exportConfirm => 'CSV жүктеп алу';

  @override
  String get exportConsoleSubtitle =>
      'Агенттік деректері кестелерде: иесіне, бухгалтерияға немесе өзіңізге көшірме ретінде.';

  @override
  String get exportConsoleTitle => 'Экспорт';

  @override
  String get exportDelimiter => 'Бөлгіш';

  @override
  String get exportDelimiterComma => 'Үтір';

  @override
  String get exportDelimiterHint =>
      'Орыс және қазақ тіліндегі Excel бағандарды нүктелі үтірмен, ағылшын тіліндегісі үтірмен бөледі.';

  @override
  String get exportDelimiterSemicolon => 'Нүктелі үтір';

  @override
  String get exportFailed => 'Экспорттау сәтсіз аяқталды. Қайталап көріңіз.';

  @override
  String get exportFiltersNote =>
      'Тізімде қазір көрсетілгені ғана, сүзгілерімен бірге.';

  @override
  String get exportFormatNote =>
      'CSV файлы: Excel, Google Sheets және Numbers-та ашылады, CRM-ге өзгеріссіз қайта импортталады.';

  @override
  String get exportKindClients => 'Клиенттер';

  @override
  String get exportKindDeals => 'Мәмілелер';

  @override
  String get exportKindProperties => 'Нысандар';

  @override
  String get exportPersonalData =>
      'Жеке деректер бар: аты-жөні, телефон және пошта. Абайлап қолданыңыз, қажетінен артық ешкімге бермеңіз.';

  @override
  String get exportTitleClients => 'Клиенттерді экспорттау';

  @override
  String get exportTitleDeals => 'Мәмілелерді экспорттау';

  @override
  String get exportTitleProperties => 'Нысандарды экспорттау';

  @override
  String get exportTooMany =>
      'Бір файлға жол тым көп. Сүзгілерді тарылтып, бөліктеп жүктеңіз.';

  @override
  String get goalsAgency => 'Бүкіл агенттік';

  @override
  String get goalsAgentOwn => 'Агенттің өз мақсаты';

  @override
  String get goalsCardTitle => 'Айлық мақсат';

  @override
  String get goalsCommissionLabel => 'Комиссия';

  @override
  String goalsCommissionOf(String achieved, String target) {
    return '$target ішінен $achieved';
  }

  @override
  String goalsCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мақсат көшірілді',
      zero: 'Өткен айдан көшіретін ештеңе жоқ',
    );
    return '$_temp0';
  }

  @override
  String get goalsCopyPrevious => 'Өткен айдың мақсаттарын көшіру';

  @override
  String goalsDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн қалды',
      one: '1 күн қалды',
      zero: 'Ай аяқталды',
    );
    return '$_temp0';
  }

  @override
  String goalsDealEvery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'әр $count күн сайын бір мәміле',
    );
    return '$_temp0';
  }

  @override
  String get goalsDealsLabel => 'Жеңіске жеткен мәмілелер';

  @override
  String goalsDealsOf(int won, int target) {
    return 'Жеңіске жеткен мәмілелер: $target ішінен $won';
  }

  @override
  String goalsDealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'күніне $count мәміле',
    );
    return '$_temp0';
  }

  @override
  String goalsDealsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мәміле жеңіске жетті',
      zero: 'Әзірге жеңіске жеткен мәміле жоқ',
    );
    return '$_temp0';
  }

  @override
  String get goalsEyebrow => 'МАҚСАТ';

  @override
  String get goalsFieldHint => 'Қажет болмаса, бос қалдырыңыз';

  @override
  String get goalsInvalidCommission => 'Нөлден үлкен соманы енгізіңіз';

  @override
  String get goalsInvalidDeals => '1-ден 1000-ға дейінгі бүтін санды енгізіңіз';

  @override
  String get goalsLoadFailed => 'Мақсаттарды жүктеу мүмкін болмады';

  @override
  String get goalsManagerSet => 'Басшы қойған';

  @override
  String get goalsMonthOver => 'Бұл ай аяқталды, оның мақсаттары өзгермейді.';

  @override
  String get goalsNeedOne =>
      'Комиссияны, мәміле санын немесе екеуін де көрсетіңіз';

  @override
  String get goalsNextMonth => 'Келесі ай';

  @override
  String get goalsNoTarget => 'Мақсат жоқ';

  @override
  String get goalsNone => 'Бұл айға әзірге мақсат жоқ';

  @override
  String get goalsNoneHint =>
      'Өз мақсатыңызды қою үшін басыңыз. Басшы қойса, соныкі есептеледі.';

  @override
  String get goalsOwn => 'Өз мақсатыңыз';

  @override
  String goalsPerDay(String amount) {
    return 'күніне $amount';
  }

  @override
  String get goalsPreviousMonth => 'Алдыңғы ай';

  @override
  String get goalsReached => 'Мақсатқа жетті. Бұдан әрі бәрі жоспардан тыс.';

  @override
  String get goalsRemove => 'Мақсатты алып тастау';

  @override
  String get goalsRemoved => 'Мақсат алынды';

  @override
  String get goalsSaved => 'Мақсат сақталды';

  @override
  String goalsSheetFor(String name) {
    return 'Мақсат: $name';
  }

  @override
  String get goalsSheetHint =>
      'Осы айда жеңіске жеткен мәмілелер мен олардың комиссиясы есептеледі.';

  @override
  String get goalsSheetOwnHint =>
      'Басшы сізге мақсат қойса, ол сіздікін алмастырады.';

  @override
  String get goalsSheetTitle => 'Айлық мақсат';

  @override
  String get goalsTeamEmpty => 'Агенттікте әзірге ешкім жоқ';

  @override
  String get goalsTeamHint => 'Әр агент пен агенттік үшін мақсаттар';

  @override
  String get goalsTeamIntro =>
      'Әр агентке және бүкіл агенттікке мақсат. Прогресс ай ішінде жеңіске жеткен мәмілелер мен олардың комиссиясы бойынша есептеледі. Сіздің мақсатыңыз агенттің өзі қойғанын алмастырады.';

  @override
  String get goalsTeamOverrideHint =>
      'Сіздің мақсатыңыз агенттің өзі қойғанын алмастырады.';

  @override
  String get goalsTeamTitle => 'Айлық мақсаттар';

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count жолды импорттау',
    );
    return '$_temp0';
  }

  @override
  String get importAnother => 'Басқа файлды импорттау';

  @override
  String get importAssignTo => 'Жауапты';

  @override
  String get importAssignToMe => 'Мен';

  @override
  String get importChooseFile => 'CSV файлын таңдау';

  @override
  String get importColumns => 'Бағандар';

  @override
  String get importColumnsHint =>
      'Әр баған қай өрісті толтыратынын тексеріңіз. «Өткізіп жіберу» белгіленген бағандар импортталмайды.';

  @override
  String get importCreated => 'Құрылды';

  @override
  String get importDoneTitle => 'Импорт аяқталды';

  @override
  String get importDownloadTemplate => 'Үлгіні жүктеу';

  @override
  String importDuplicateOfClient(String name) {
    return 'Агенттікте бар: $name';
  }

  @override
  String importDuplicateOfRow(int row) {
    return '$row-жолмен бірдей';
  }

  @override
  String get importEmptyFile => 'Файл бос';

  @override
  String get importEntrySubtitle =>
      'Excel немесе басқа CRM-нен клиенттер мен нысандар';

  @override
  String get importErrorInvalidDate => 'Күн емес';

  @override
  String get importErrorInvalidEmail => 'Email қате';

  @override
  String get importErrorInvalidNumber => 'Сан емес';

  @override
  String get importErrorInvalidPhone => 'Телефон қате';

  @override
  String get importErrorNegative => 'Нөлден үлкен болуы керек';

  @override
  String get importErrorOutOfRange => 'Рұқсат етілген ауқымнан тыс';

  @override
  String get importErrorRequired => 'Міндетті өріс';

  @override
  String get importErrorTooLong => 'Тым ұзын';

  @override
  String get importErrorUnknownValue => 'Белгісіз мән';

  @override
  String get importFieldAddress => 'Мекенжай';

  @override
  String get importFieldArea => 'Аудан';

  @override
  String get importFieldBirthday => 'Туған күн';

  @override
  String get importFieldBudgetMax => 'Бюджет (дейін)';

  @override
  String get importFieldBudgetMin => 'Бюджет (бастап)';

  @override
  String get importFieldCity => 'Қала';

  @override
  String get importFieldClientType => 'Клиент түрі';

  @override
  String get importFieldDescription => 'Сипаттама';

  @override
  String get importFieldEmail => 'Email';

  @override
  String get importFieldFloor => 'Қабат';

  @override
  String get importFieldFullName => 'Аты-жөні';

  @override
  String get importFieldMinArea => 'Аудан (кемінде)';

  @override
  String get importFieldMinRooms => 'Бөлме саны (кемінде)';

  @override
  String get importFieldNotes => 'Ескертпе';

  @override
  String get importFieldPhone => 'Телефон';

  @override
  String get importFieldPrice => 'Баға';

  @override
  String get importFieldPropertyType => 'Нысан түрі';

  @override
  String get importFieldRooms => 'Бөлме саны';

  @override
  String get importFieldStatus => 'Мәртебе';

  @override
  String get importFieldTags => 'Тегтер';

  @override
  String get importFieldLeadSource => 'Лид көзі';

  @override
  String get importFieldLeadSourceDetail => 'Лид көзі туралы';

  @override
  String get importFieldTitle => 'Атауы';

  @override
  String get importFieldTotalFloors => 'Қабат саны';

  @override
  String get importFieldWantedCity => 'Қалаған қала';

  @override
  String get importFieldWantedType => 'Қалаған нысан түрі';

  @override
  String get importFileTooLarge =>
      'Файл 5 МБ-тан үлкен. Оны бөліктерге бөліңіз.';

  @override
  String get importHowTo =>
      'Кестені Excel немесе Google Sheets арқылы CSV форматында сақтаңыз. Үтір, нүктелі үтір және табуляция жарайды, орысша Excel-дің кириллица файлдары да оқылады.';

  @override
  String get importInvalid => 'Қателерге байланысты импортталмады';

  @override
  String get importKindClients => 'Клиенттер';

  @override
  String get importKindClientsHint => 'Аттары, телефондары, не іздейді';

  @override
  String get importKindProperties => 'Нысандар';

  @override
  String get importKindPropertiesHint =>
      'Мекенжайлар, бағалар, аудандар, бөлмелер';

  @override
  String importMissingRequired(String field) {
    return '«$field» өрісі үшін баған таңдаңыз';
  }

  @override
  String get importNoAgents => 'Әріптестер табылмады';

  @override
  String get importNoProblems => 'Барлық жол импортқа дайын';

  @override
  String get importNotCsv =>
      '.csv файлын таңдаңыз. Excel-де: Файл, Басқаша сақтау, CSV.';

  @override
  String get importNothingToImport => 'Импорттайтын ештеңе жоқ';

  @override
  String get importOpenClients => 'Клиенттерді ашу';

  @override
  String get importOpenProperties => 'Нысандарды ашу';

  @override
  String get importOptions => 'Параметрлер';

  @override
  String get importPickAgentSearch => 'Аты бойынша іздеу';

  @override
  String get importProblems => 'Назар аударатын жолдар';

  @override
  String get importProblemsTruncated => 'Тек алғашқы 1000 көрсетілген';

  @override
  String importRowLabel(int row) {
    return '$row-жол';
  }

  @override
  String importRowsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Файлда $count жол',
    );
    return '$_temp0';
  }

  @override
  String get importShowMore => 'Тағы көрсету';

  @override
  String get importSkipColumn => 'Өткізіп жіберу';

  @override
  String get importSkipDuplicates => 'Қайталанатындарды өткізіп жіберу';

  @override
  String get importSkipDuplicatesHint =>
      'Email-і агенттікте бар клиент әрқашан өткізіп жіберіледі';

  @override
  String get importSkipped => 'Өткізілген қайталанатындар';

  @override
  String get importSummaryDuplicates => 'Қайталанатындар';

  @override
  String get importSummaryInvalid => 'Қателері бар';

  @override
  String get importSummaryValid => 'Дайын';

  @override
  String get importTemplateFailed => 'Үлгіні дайындау мүмкін болмады';

  @override
  String get importTitle => 'Кестеден импорттау';

  @override
  String get importTooManyRows =>
      'Файлда 5000-нан көп жол бар. Оны бөліктерге бөліңіз.';

  @override
  String get leaderboardDealsLost => 'Жоғалған мәмілелер';

  @override
  String get leaderboardEmptyBody =>
      'Агенттікке қосылған агенттер осында көрсетіледі.';

  @override
  String get leaderboardEmptyTitle => 'Әзірге агенттер жоқ';

  @override
  String get leaderboardHint =>
      'Әр агенттің мәмілелері, комиссиясы мен көрсетілімдері';

  @override
  String get leaderboardInactive => 'Өшірілгендер';

  @override
  String get leaderboardInactiveNote =>
      'Өшірілген қызметкерлер жалпы рейтингке қосылмайды. Агенттіктен шығарылғандар мұнда жоқ: олардың жазбалары әріптесіне өтті.';

  @override
  String get leaderboardLoadFailed => 'Рейтингті жүктеу мүмкін болмады';

  @override
  String get leaderboardNoValue => '—';

  @override
  String get leaderboardPeriodCustom => 'Күндер';

  @override
  String get leaderboardPeriodLastMonth => 'Өткен ай';

  @override
  String get leaderboardPeriodQuarter => 'Тоқсан';

  @override
  String get leaderboardPeriodThisMonth => 'Осы ай';

  @override
  String get leaderboardPickRange => 'Күндерді таңдаңыз';

  @override
  String leaderboardRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get leaderboardSortCommission => 'Комиссия';

  @override
  String get leaderboardSortDealsWon => 'Жабылған мәмілелер';

  @override
  String get leaderboardSortNewClients => 'Жаңа клиенттер';

  @override
  String get leaderboardSortViewings => 'Көрсетілімдер';

  @override
  String get leaderboardSortWinRate => 'Сәттілік үлесі';

  @override
  String leaderboardSummary(int won, int viewings, int clients) {
    return 'Мәмілелер $won · Көрсетілімдер $viewings · Клиенттер $clients';
  }

  @override
  String get leaderboardTeamCommission => 'Агенттік комиссиясы';

  @override
  String get leaderboardTitle => 'Агенттер рейтингі';

  @override
  String get leaderboardWonValue => 'Жабылған сомасы';

  @override
  String get lockAppLock => 'Қолданбаны құлыптау';

  @override
  String get lockAppLockHint => 'Кіру кезінде PIN-код сұрау';

  @override
  String get lockAutoLock => 'Құлыптау уақыты';

  @override
  String get lockAutoLockFifteenMinutes => 'Фонда 15 минуттан кейін';

  @override
  String get lockAutoLockFiveMinutes => 'Фонда 5 минуттан кейін';

  @override
  String get lockAutoLockImmediately => 'Бірден';

  @override
  String get lockAutoLockOneMinute => 'Фонда 1 минуттан кейін';

  @override
  String get lockAutoLockTitle => 'Қолданбаны қашан құлыптау керек';

  @override
  String get lockCancel => 'Бас тарту';

  @override
  String get lockChangePin => 'PIN-кодты өзгерту';

  @override
  String get lockConfirmPinTitle => 'PIN-кодты қайталаңыз';

  @override
  String get lockContinue => 'Жалғастыру';

  @override
  String get lockCurrentPinTitle => 'Қазіргі PIN-кодты енгізіңіз';

  @override
  String get lockDelete => 'Өшіру';

  @override
  String get lockDigitsHint => '4-тен 6-ға дейін сан';

  @override
  String get lockEnterPin => 'PIN-кодты енгізіңіз';

  @override
  String get lockForgotPin => 'PIN-кодты ұмыттыңыз ба?';

  @override
  String get lockForgotPinBody =>
      'Шыққанда PIN-код пен телефонда сақталған клиент деректері жойылады. Содан кейін құпиясөзбен қайта кіріңіз.';

  @override
  String get lockMismatch => 'PIN-кодтар сәйкес келмейді. Қайталап көріңіз.';

  @override
  String get lockNewPinTitle => 'PIN-код ойлап табыңыз';

  @override
  String get lockPinChanged => 'PIN-код өзгертілді';

  @override
  String lockRetryIn(String time) {
    return 'Әрекет тым көп. $time кейін қайталаңыз';
  }

  @override
  String get lockSecurity => 'Қауіпсіздік';

  @override
  String get lockSignOutAgain => 'Шығып, қайта кіру';

  @override
  String get lockTooManyAttempts =>
      'Қате PIN-код тым көп рет енгізілді. Шығып, құпиясөзбен қайта кіріңіз.';

  @override
  String get lockTooShort => 'PIN-код 4-тен 6-ға дейін саннан тұруы керек.';

  @override
  String get lockTurnOn => 'Қосу';

  @override
  String get lockTurnedOff => 'Құлыптау өшірілді';

  @override
  String get lockTurnedOn => 'Құлыптау қосылды';

  @override
  String get lockWrongPin => 'PIN-код қате';

  @override
  String get meetingsAgendaHint => 'Кездесу күн тәртібі, талқылау тақырыптары…';

  @override
  String get meetingsAgent => 'Агент';

  @override
  String meetingsAgentNumber(Object id) {
    return 'Агент №$id';
  }

  @override
  String get meetingsClient => 'Клиент';

  @override
  String meetingsClientNumber(Object id) {
    return 'Клиент №$id';
  }

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
  String get meetingsLocation => 'Орны';

  @override
  String get meetingsMustBeInFuture => 'Болашақтағы уақытты таңдаңыз';

  @override
  String get meetingsNoAgentsToAssign => 'Тағайындайтын адам жоқ';

  @override
  String get meetingsNoLocation => 'Кездесудің орны көрсетілмеген';

  @override
  String get meetingsNoMeetings => 'Кездесулер жоқ';

  @override
  String get meetingsNote => 'Кездесу жазбасы';

  @override
  String get meetingsNothingUpcoming => 'Алдағы кездесулер жоқ';

  @override
  String get meetingsNothingUpcomingSubtitle =>
      'Өткен кездесулер тарихта қалады.';

  @override
  String get meetingsOutcome => 'Қалай өтті';

  @override
  String get meetingsOutcomeInterested => 'Қызықты';

  @override
  String get meetingsOutcomeNoShow => 'Келмеді';

  @override
  String get meetingsOutcomeNote => 'Не айтты';

  @override
  String get meetingsOutcomeNoteHint => 'Қараңғы, жол шулы…';

  @override
  String get meetingsOutcomeRejected => 'Бас тартты';

  @override
  String get meetingsOutcomeRejectedHint =>
      'Бас тартылған нысан бұл сатып алушыға ұсынылмайды';

  @override
  String get meetingsOutcomeSave => 'Сақтау';

  @override
  String get meetingsPleaseSelectAgent => 'Агентті таңдаңыз';

  @override
  String get meetingsPleaseSelectClient => 'Клиентті таңдаңыз';

  @override
  String get meetingsPleaseSelectDateTime => 'Күн мен уақытты таңдаңыз';

  @override
  String get meetingsProperty => 'Нысан';

  @override
  String get meetingsSchedule => 'Жоспарлау';

  @override
  String get meetingsScheduleFirst => 'Алғашқы кездесуіңізді жоспарлаңыз';

  @override
  String get meetingsScheduleMeeting => 'Кездесуді жоспарлау';

  @override
  String get meetingsScheduleViewing => 'Көрсетілім жазу';

  @override
  String get meetingsSearchByNameOrId => 'Аты немесе ID бойынша іздеу…';

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
  String get meetingsViewingOf => 'Көрсетілім';

  @override
  String get meetingsWhen => 'Қашан';

  @override
  String get meetingsWhoAndWhere => 'Кіммен және қайда';

  @override
  String get mortgageAmortisation => 'Төлем кестесі';

  @override
  String get mortgageAnnuity => 'Аннуитетті';

  @override
  String get mortgageDifferentiated => 'Сараланған';

  @override
  String get mortgageDownPayment => 'Бастапқы жарна';

  @override
  String mortgageDownSummary(String percent, String rate, String term) {
    return 'жарна $percent% · $rate% · $term';
  }

  @override
  String get mortgageFees => 'Бір реттік шығындар';

  @override
  String get mortgageFeesHint => 'Бағалау, сақтандыру, банк комиссиясы';

  @override
  String mortgageFromPerMonth(String amount) {
    return 'айына $amount бастап';
  }

  @override
  String mortgageIncomeHint(String percent) {
    return 'Төлем табыстың $percent%-ынан аспауы үшін';
  }

  @override
  String get mortgageIncomeNeeded => 'Қажетті табыс';

  @override
  String get mortgageInterest => 'Пайыздар';

  @override
  String get mortgageLoan => 'Несие сомасы';

  @override
  String mortgageMonthLabel(int number) {
    return '$number-ай';
  }

  @override
  String get mortgageMonthly => 'Ай сайынғы төлем';

  @override
  String get mortgageMonthlyRange => 'Алғашқы ай → соңғы ай';

  @override
  String get mortgageNoLoan => 'Жарна бағаны толық жабады, несие қажет емес.';

  @override
  String get mortgageOpenCalculator => 'Калькуляторды ашу';

  @override
  String get mortgageOverpayment => 'Артық төлем';

  @override
  String get mortgagePresetHousingSavings => 'Тұрғын үй жинақтары';

  @override
  String get mortgagePresetMarket => 'Нарықтық мөлшерлеме';

  @override
  String get mortgagePresetStateProgram => '7-20-25 бағдарламасы';

  @override
  String get mortgagePresetsNote =>
      'Әдеттегі мөлшерлемелер, банк ұсынысы емес. Мөлшерлемелер өзгереді, банктен нақтылаңыз.';

  @override
  String get mortgagePrice => 'Баға';

  @override
  String get mortgagePrincipal => 'Негізгі қарыз';

  @override
  String mortgageRangePerMonth(String first, String last) {
    return 'айына $first → $last';
  }

  @override
  String get mortgageRate => 'Жылдық мөлшерлеме, %';

  @override
  String get mortgageSend => 'Клиентке жіберу';

  @override
  String get mortgageShareDisclaimer => 'Болжамды есеп, оферта емес.';

  @override
  String mortgageShareDown(String amount, String percent) {
    return 'Бастапқы жарна: $amount ($percent%)';
  }

  @override
  String get mortgageShareFailed => 'Есепті бөлісу мүмкін болмады';

  @override
  String get mortgageShareHeading => 'Ипотека есебі';

  @override
  String mortgageShareMonthly(String amount) {
    return 'Ай сайынғы төлем: $amount';
  }

  @override
  String mortgageShareMonthlyRange(String first, String last) {
    return 'Ай сайынғы төлем: алғашқы айда $first, соңғы айда $last';
  }

  @override
  String mortgageShareOverpayment(String amount) {
    return 'Артық төлем: $amount';
  }

  @override
  String mortgageSharePrice(String amount) {
    return 'Бағасы: $amount';
  }

  @override
  String mortgageShareRate(String rate) {
    return 'Мөлшерлеме: жылдық $rate%';
  }

  @override
  String mortgageShareTerm(String term) {
    return 'Мерзімі: $term';
  }

  @override
  String get mortgageTerm => 'Мерзім';

  @override
  String mortgageTermYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count жыл',
    );
    return '$_temp0';
  }

  @override
  String get mortgageTitle => 'Ипотека';

  @override
  String get mortgageTotalRepaid => 'Барлық төлем';

  @override
  String get mortgageType => 'Төлем түрі';

  @override
  String mortgageYearLabel(int number) {
    return '$number-жыл';
  }

  @override
  String get msgAgentInvited => 'Агент шақырылды';

  @override
  String get msgChecklistSaved => 'Тізім сақталды';

  @override
  String get msgClientCreated => 'Клиент құрылды';

  @override
  String get msgClientDeleted => 'Клиент жойылды';

  @override
  String get msgClientUpdated => 'Клиент жаңартылды';

  @override
  String get msgClientsMerged => 'Карточкалар біріктірілді';

  @override
  String get msgCodeSent => 'Код жіберілді';

  @override
  String get msgCommentDeleted => 'Пікір жойылды';

  @override
  String get msgCommentUpdated => 'Пікір өзгертілді';

  @override
  String get msgCurrencyChanged => 'Валюта өзгертілді';

  @override
  String get msgDealCreated => 'Мәміле құрылды';

  @override
  String get msgDealDeleted => 'Мәміле жойылды';

  @override
  String get msgDealUpdated => 'Мәміле жаңартылды';

  @override
  String get msgDocumentDeleted => 'Құжат өшірілді';

  @override
  String get msgDocumentUploaded => 'Құжат тіркелді';

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
  String get msgMemberRemoved => 'Агент командадан шығарылды';

  @override
  String get msgNotificationsAllRead => 'Барлық хабарлама оқылды';

  @override
  String get msgProfileUpdated => 'Профиль жаңартылды';

  @override
  String get msgPropertyCreated => 'Нысан құрылды';

  @override
  String get msgPropertyDeleted => 'Нысан жойылды';

  @override
  String get msgPropertyUpdated => 'Нысан жаңартылды';

  @override
  String get msgRequestCancelled => 'Сұраныс қайтарылды';

  @override
  String get msgRequestDeclined => 'Сұраныс қабылданбады';

  @override
  String get msgRequestSent => 'Сұраныс жіберілді';

  @override
  String get msgRoleUpdated => 'Рөл жаңартылды';

  @override
  String get msgStatusUpdated => 'Мәртебе жаңартылды';

  @override
  String get msgTaskCompleted => 'Тапсырма орындалды';

  @override
  String get msgTaskCreated => 'Тапсырма қосылды';

  @override
  String get msgTaskDeleted => 'Тапсырма жойылды';

  @override
  String get msgTaskReopened => 'Тапсырма қайта ашылды';

  @override
  String get msgTaskUpdated => 'Тапсырма жаңартылды';

  @override
  String get msgTeamAssigned => 'Команда тағайындалды';

  @override
  String get msgTeamCreated => 'Команда құрылды';

  @override
  String get msgTeamJoined => 'Сіз командадасыз';

  @override
  String get msgTeamLeft => 'Сіз командадан шықтыңыз';

  @override
  String get msgTeamUpdated => 'Команда жаңартылды';

  @override
  String get msgTemplateDeleted => 'Үлгі жойылды';

  @override
  String get msgTemplateSaved => 'Үлгі сақталды';

  @override
  String get msgUserActivated => 'Пайдаланушы белсендірілді';

  @override
  String get msgUserDeactivated => 'Пайдаланушы өшірілді';

  @override
  String get msgUserDeleted => 'Пайдаланушы жойылды';

  @override
  String notificationsClientBirthday(String name) {
    return 'Бүгін $name клиенттің туған күні';
  }

  @override
  String notificationsCountClients(int count) {
    return '$count клиент';
  }

  @override
  String notificationsCountDeals(int count) {
    return '$count мәміле';
  }

  @override
  String notificationsCountListings(int count) {
    return '$count нысан';
  }

  @override
  String notificationsCountMeetings(int count) {
    return '$count кездесу';
  }

  @override
  String notificationsCountTasks(int count) {
    return '$count тапсырма';
  }

  @override
  String notificationsDealComment(String author, String title) {
    return '$author $title мәмілесіне пікір қалдырды';
  }

  @override
  String notificationsDealMention(String author, String title) {
    return '$author сізді $title мәмілесінде атап өтті';
  }

  @override
  String notificationsDealStatus(String actor, String status, String title) {
    return '$actor $title мәмілесін «$status» күйіне ауыстырды';
  }

  @override
  String get notificationsEarlier => 'Бұрын';

  @override
  String get notificationsEmptyBody =>
      'Сізге берілген тапсырмалар, сізге өткізілген клиенттер және сатып алушыларыңызға сай нысандар осында шығады.';

  @override
  String get notificationsEmptyTitle => 'Жаңа ештеңе жоқ';

  @override
  String notificationsFitsBuyers(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сатып алушыға сай: $names',
      one: 'Сай келеді: $names',
    );
    return '$_temp0';
  }

  @override
  String notificationsHandedOver(int count, String from) {
    return '$from сізге $count жазба өткізді';
  }

  @override
  String notificationsJoinAccepted(String agent, String team) {
    return '$agent $team агенттігіне қосылды';
  }

  @override
  String notificationsJoinRequest(String actor, String team) {
    return '$actor сізді $team агенттігіне шақырады';
  }

  @override
  String notificationsListingLead(String name, String title) {
    return '$name $title нысанына қызығушылық танытты';
  }

  @override
  String get notificationsMarkAllRead => 'Барлығын оқу';

  @override
  String notificationsMoreNames(int count, String names) {
    return '$names және тағы $count';
  }

  @override
  String notificationsNewMatch(String title) {
    return 'Сатып алушыларыңызға жаңа нысан: $title';
  }

  @override
  String notificationsPriceDrop(String oldPrice, String price, String title) {
    return '$title арзандады: $price, бұрын $oldPrice';
  }

  @override
  String notificationsPurchaseAnniversary(String name, int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Бүгін $name сатып алғанына $years жыл',
    );
    return '$_temp0';
  }

  @override
  String get notificationsSomeone => 'Біреу';

  @override
  String notificationsTaskAssigned(String actor, String title) {
    return '$actor сізге тапсырма берді: $title';
  }

  @override
  String get notificationsTitle => 'Хабарламалар';

  @override
  String get notificationsToday => 'Бүгін';

  @override
  String get notificationsUnknown => 'Жұмысыңызда өзгеріс болды';

  @override
  String notificationsUnreadLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count оқылмаған хабарлама',
      zero: 'Оқылмаған хабарлама жоқ',
    );
    return '$_temp0';
  }

  @override
  String get offersAccept => 'Қабылдау';

  @override
  String offersAcceptConfirm(String amount) {
    return '$amount келісілген баға болады. Нысан бойынша басқа ұсыныстар шешім қабылдағанша қосалқы ретінде ашық қалады.';
  }

  @override
  String get offersAcceptTitle => 'Ұсынысты қабылдау керек пе?';

  @override
  String get offersAgent => 'Агент';

  @override
  String get offersAlreadyAccepted =>
      'Бұл нысан бойынша басқа ұсыныс қабылданған; алдымен оны кері қайтарыңыз';

  @override
  String get offersAlreadyOpen =>
      'Бұл сатып алушының мұнда ашық ұсынысы бар; оған қарсы ұсыныс жасаңыз';

  @override
  String get offersAmount => 'Сома';

  @override
  String get offersAmountHint => 'Ұсынылған сома';

  @override
  String offersAsking(String price) {
    return 'сұралғаны $price';
  }

  @override
  String get offersBackup =>
      'Басқа ұсыныс қабылданды; бұл қосалқы ретінде күтуде';

  @override
  String get offersBuyer => 'Сатып алушы';

  @override
  String get offersCardTitle => 'Ұсыныстар';

  @override
  String get offersClientNone =>
      'Бұл сатып алушыдан әзірге ұсыныс жоқ. Ұсыныс нысан бетінде жазылады.';

  @override
  String get offersClientNotBuyer => 'Ұсынысты тек сатып алушы жасай алады';

  @override
  String get offersClosedHeading => 'Жабылғандар';

  @override
  String offersColleagueBuyer(String agent) {
    return 'Сатып алушы: $agent';
  }

  @override
  String get offersCounter => 'Қарсы ұсыныс';

  @override
  String get offersCounterFrom => 'Кімнің сомасы';

  @override
  String get offersCounterTitle => 'Жаңа сома';

  @override
  String get offersDecidedOn => 'Шешілді';

  @override
  String get offersExpiresOn => 'Жарамды мерзімі';

  @override
  String get offersExpiryPast => 'Мерзім бүгіннен ерте бола алмайды';

  @override
  String get offersFigureBuyer => 'Сатып алушының сомасы';

  @override
  String get offersFigureSeller => 'Сатушының сомасы';

  @override
  String get offersHiddenBuyer => 'Әріптестің сатып алушысы';

  @override
  String get offersHistory => 'Келіссөз барысы';

  @override
  String get offersListLoadFailed => 'Ұсыныстарды жүктеу мүмкін болмады';

  @override
  String get offersLoadFailed => 'Ұсынысты жүктеу мүмкін болмады';

  @override
  String get offersNoBuyers => 'Сатып алушылар табылмады';

  @override
  String get offersNoDeadline => 'Мерзімсіз';

  @override
  String get offersNoLongerOpen => 'Бұл ұсыныс енді ашық емес';

  @override
  String get offersNone =>
      'Әзірге ұсыныс жоқ. Сатып алушы баға атағанда жазып қойыңыз.';

  @override
  String get offersNote => 'Ескертпе';

  @override
  String get offersNoteHint => 'Шарттар, төлем тәсілі, тілектер';

  @override
  String offersOfAsking(int percent) {
    return 'бағаның $percent%';
  }

  @override
  String offersOnTableNow(String amount) {
    return 'Қазіргі сома: $amount';
  }

  @override
  String get offersPartyBuyer => 'Сатып алушы';

  @override
  String get offersPartySeller => 'Сатушы';

  @override
  String get offersPickBuyer => 'Сатып алушыны таңдаңыз';

  @override
  String get offersPropertySold => 'Нысан сатылған, ұсыныс қабылданбайды';

  @override
  String get offersRecord => 'Ұсынысты жазу';

  @override
  String get offersRecordTitle => 'Жаңа ұсыныс';

  @override
  String get offersReject => 'Қабылдамау';

  @override
  String get offersRejectConfirm =>
      'Ұсыныс қабылданбаған ретінде жабылады, оны қайта ашу мүмкін емес.';

  @override
  String get offersRejectTitle => 'Ұсынысты қабылдамау керек пе?';

  @override
  String get offersSave => 'Сақтау';

  @override
  String get offersSearchBuyers => 'Сатып алушыларды іздеу';

  @override
  String get offersShowAll => 'Барлығын көрсету';

  @override
  String get offersStatusAccepted => 'Қабылданды';

  @override
  String get offersStatusCountered => 'Қарсы ұсыныс';

  @override
  String get offersStatusExpired => 'Мерзімі өтті';

  @override
  String get offersStatusNew => 'Жаңа';

  @override
  String get offersStatusRejected => 'Қабылданбады';

  @override
  String get offersStatusWithdrawn => 'Кері қайтарылды';

  @override
  String get offersStepAccepted => 'Қабылданды';

  @override
  String get offersStepCounteredBuyer => 'Сатып алушының қарсы ұсынысы';

  @override
  String get offersStepCounteredSeller => 'Сатушының қарсы ұсынысы';

  @override
  String get offersStepOffered => 'Сатып алушының ұсынысы';

  @override
  String get offersStepOther => 'Өзгеріс';

  @override
  String get offersStepRejected => 'Қабылданбады';

  @override
  String get offersStepWithdrawn => 'Кері қайтарылды';

  @override
  String get offersTitle => 'Ұсыныс';

  @override
  String offersValidUntil(String date) {
    return '$date дейін жарамды';
  }

  @override
  String get offersWithdraw => 'Кері қайтару';

  @override
  String get offersWithdrawConfirm =>
      'Сатып алушы бас тартты. Ұсыныс жабылады, оны қайта ашу мүмкін емес.';

  @override
  String get offersWithdrawTitle => 'Ұсынысты кері қайтару керек пе?';

  @override
  String get openHouseActivity => 'Ашық есік күніне келу';

  @override
  String get openHouseAddVisitor => 'Келушіні қосу';

  @override
  String get openHouseAlreadySignedIn => 'Бұл нөмір әлдеқашан тіркелген';

  @override
  String openHouseColleagueClient(String agent) {
    return 'Клиент: $agent';
  }

  @override
  String get openHouseDate => 'Күні';

  @override
  String get openHouseDelete => 'Ашық есік күнін болдырмау';

  @override
  String get openHouseDeleteConfirm => 'Ол нысаннан және күнтізбеден жойылады.';

  @override
  String get openHouseEdit => 'Ашық есік күнін өзгерту';

  @override
  String get openHouseEnds => 'Аяқталуы';

  @override
  String get openHouseEndsBeforeStart =>
      'Аяқталуы басталуынан кейін болуы керек';

  @override
  String get openHouseHasVisitors =>
      'Келушілер тіркелген, сондықтан болдырмау мүмкін емес';

  @override
  String openHouseHost(String name) {
    return 'Өткізетін: $name';
  }

  @override
  String get openHouseInterestLabel => 'Қызығушылық';

  @override
  String get openHouseInterested => 'Қызықты';

  @override
  String get openHouseJustLooking => 'Жай қарап жүр';

  @override
  String get openHouseKnownClient => 'Бұрыннан клиент';

  @override
  String get openHouseLive => 'Қазір өтуде';

  @override
  String get openHouseLoadFailed => 'Ашық есік күнін жүктеу мүмкін болмады';

  @override
  String get openHouseNewClient => 'Жаңа клиент';

  @override
  String get openHouseNoVisitors => 'Әзірге ешкім тіркелмеген';

  @override
  String get openHouseNoVisitorsHint =>
      'Келушілерді келген сайын қосыңыз. Агенттікке белгісіз нөмір жаңа сатып алушы болады.';

  @override
  String get openHouseNone =>
      'Әзірге жоқ. Ашық есік күнін белгілеп, келушілерді есік алдында тіркеңіз.';

  @override
  String get openHouseNoteHint =>
      'Кілттер, тұрақ, есік алдында кімге қоңырау шалу';

  @override
  String get openHouseNoteLabel => 'Жазба';

  @override
  String get openHousePast => 'Өткен';

  @override
  String get openHouseRemoveVisitor => 'Келушіні алып тастау';

  @override
  String openHouseRemoveVisitorConfirm(String name) {
    return '$name парақтан, ал келу клиент тарихынан алынады. Тіркеу кезінде құрылған клиент қалады.';
  }

  @override
  String get openHouseSave => 'Сақтау';

  @override
  String get openHouseSchedule => 'Ашық есік күнін белгілеу';

  @override
  String get openHouseSeeAll => 'Барлығын көрсету';

  @override
  String get openHouseSignIn => 'Сақтау';

  @override
  String get openHouseSignInNext => 'Сақтап, келесісі';

  @override
  String get openHouseSignInSheet => 'Келушілер парағы';

  @override
  String openHouseSignedIn(String name) {
    return '$name тіркелді';
  }

  @override
  String get openHouseStarts => 'Басталуы';

  @override
  String get openHouseSummary => 'Қорытынды';

  @override
  String get openHouseSummaryInterested => 'Қызығушылық танытты';

  @override
  String get openHouseSummaryNewClients => 'Жаңа клиенттер';

  @override
  String get openHouseSummaryVisitors => 'Келушілер';

  @override
  String get openHouseTitle => 'Ашық есік күні';

  @override
  String get openHouseTooLong => 'Ашық есік күні 12 сағаттан аспайды';

  @override
  String get openHouseUpcoming => 'Алдағы';

  @override
  String get openHouseVisitorName => 'Аты';

  @override
  String get openHouseVisitorNameHint => 'Өзі айтқандай';

  @override
  String get openHouseVisitorNameRequired => 'Атын енгізіңіз';

  @override
  String get openHouseVisitorNoteHint => 'Не туралы сұрады';

  @override
  String get openHouseVisitorPhone => 'Телефон';

  @override
  String get openHouseVisitorPhoneInvalid => 'Телефон нөмірін енгізіңіз';

  @override
  String openHouseVisitorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count келуші',
      zero: 'Келушілер жоқ',
    );
    return '$_temp0';
  }

  @override
  String get openHousesCardTitle => 'Ашық есік күндері';

  @override
  String get profileAgentId => 'Агент ID';

  @override
  String get profileAgentIdCopied => 'Агент ID көшірілді';

  @override
  String get profileApp => 'Қосымша';

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
  String get profileEditProfile => 'Профильді өзгерту';

  @override
  String get profileEmail => 'Электрондық пошта';

  @override
  String get profileEstateCrm => 'Estate CRM';

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
  String get profilePrivacyPolicy => 'Құпиялылық саясаты';

  @override
  String get profileReminders => 'Кездесу еске салғыштары';

  @override
  String get profileRemindersOff => 'Өшірулі';

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
  String get propertiesAddFirstListing => 'Алғашқы нысаныңызды қосыңыз';

  @override
  String get propertiesAddPhotos => 'Фото қосу';

  @override
  String get propertiesAddressLabel => 'Мекенжайы';

  @override
  String get propertiesAll => 'Барлығы';

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
  String get propertiesBrochure => 'Буклет (PDF)';

  @override
  String get propertiesBrochureContact => 'Байланыс';

  @override
  String get propertiesBrochureFailed =>
      'Буклетті жинау мүмкін болмады. Қайталап көріңіз.';

  @override
  String propertiesBrochureGenerated(String date) {
    return 'Дайындалған күні: $date';
  }

  @override
  String propertiesBrochurePage(int page, int total) {
    return '$total беттің $page-беті';
  }

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
  String get propertiesInterested => 'Кімге сәйкес';

  @override
  String get propertiesLink => 'Жария сілтеме';

  @override
  String get propertiesLinkCopied => 'Сілтеме көшірілді';

  @override
  String get propertiesLinkCopy => 'Көшіру';

  @override
  String get propertiesLinkCreate => 'Сілтеме жасау';

  @override
  String propertiesLinkEnquiries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сілтеме арқылы $count өтінім',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLinkHint =>
      'Фотосы, бағасы және сіздің байланыс деректеріңіз бар бет. Кез келген браузерде ашылады, қосымша да, тіркелу де қажет емес.';

  @override
  String propertiesLinkLastViewed(String date) {
    return 'Соңғы рет ашылды: $date';
  }

  @override
  String get propertiesLinkRevoke => 'Өшіру';

  @override
  String get propertiesLinkRevokeConfirm =>
      'Сілтемені алғандар нысанды енді аша алмайды. Жаңа сілтеменің мекенжайы басқа болады.';

  @override
  String get propertiesLinkRevokeTitle => 'Сілтемені өшіру керек пе?';

  @override
  String get propertiesLinkShare => 'Бөлісу';

  @override
  String propertiesLinkViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рет ашылды',
      zero: 'Әлі ашылмаған',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLocation => 'Орналасуы';

  @override
  String get propertiesMandate => 'Сатушымен келісім';

  @override
  String get propertiesMandateClearEndDate => 'Аяқталу күнін алып тастау';

  @override
  String get propertiesMandateEndDate => 'Соңғы күні';

  @override
  String propertiesMandateEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күн бұрын аяқталды',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndedYesterday => 'Кеше аяқталды';

  @override
  String propertiesMandateEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count күннен кейін аяқталады',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndsToday => 'Бүгін аяқталады';

  @override
  String get propertiesMandateEndsTomorrow => 'Ертең аяқталады';

  @override
  String get propertiesMandateExclusive => 'Эксклюзив';

  @override
  String propertiesMandateExclusiveEnded(String date) {
    return 'Эксклюзив $date аяқталды';
  }

  @override
  String propertiesMandateExclusiveUntil(String date) {
    return '$date дейін эксклюзив';
  }

  @override
  String get propertiesMandateNoEndDate => 'Аяқталу күні жоқ';

  @override
  String get propertiesMandateNone => 'Жоқ';

  @override
  String get propertiesMandateOpen => 'Ашық';

  @override
  String get propertiesMandateOpenBadge => 'Ашық келісім';

  @override
  String propertiesMandateOpenEnded(String date) {
    return 'Келісім $date аяқталды';
  }

  @override
  String propertiesMandateOpenUntil(String date) {
    return '$date дейін ашық';
  }

  @override
  String get propertiesMandatesEmpty => 'Аяқталатын келісім жоқ';

  @override
  String get propertiesMandatesEmptyHint =>
      'Сатылымдағы нысандар бойынша ешбір келісім алдағы екі аптада аяқталмайды.';

  @override
  String get propertiesMandatesLoadFailed => 'Аяқталатын келісімдер жүктелмеді';

  @override
  String get propertiesMandatesTitle => 'Келісімдер аяқталып келеді';

  @override
  String propertiesMapCapped(int count) {
    return '$count көрсетілді — қалғанын көру үшін картаны жақындатыңыз';
  }

  @override
  String get propertiesMapEmpty => 'Картаның бұл бөлігінде нысан жоқ';

  @override
  String get propertiesMapLoading => 'Нысандар жүктелуде';

  @override
  String get propertiesMapPin => 'Картадағы нүкте';

  @override
  String get propertiesMapPinClear => 'Нүктені алып тастау';

  @override
  String get propertiesMapPinHint =>
      'Нүкте қою үшін картаны түртіңіз, дәлдеу үшін оны сүйреңіз';

  @override
  String propertiesMapUnpinned(int count) {
    return '$count нысанның картада нүктесі жоқ';
  }

  @override
  String get propertiesMapUnpinnedHint =>
      'Нысанды ашып, «Өңдеу» басып, нүкте қойыңыз — ол картада пайда болады.';

  @override
  String get propertiesMapUnpinnedTitle => 'Картада жоқ';

  @override
  String get propertiesNewProperty => 'Жаңа нысан';

  @override
  String get propertiesNextDetails => 'Әрі қарай — егжей-тегжейі';

  @override
  String get propertiesNoInterested => 'Әзірге мұндайды іздеген жоқ';

  @override
  String get propertiesNoPhotos => 'Әзірге фото жоқ — біріншісі мұқаба болады';

  @override
  String get propertiesNoProperties => 'Нысандар жоқ';

  @override
  String get propertiesNoResultsSubtitle =>
      'Сұранысты немесе сүзгіні өзгертіңіз';

  @override
  String get propertiesNoViewings => 'Бұл нысан әлі көрсетілмеген';

  @override
  String get propertiesOpenInMaps => 'Карталарда ашу';

  @override
  String get propertiesOpenInMapsFailed => 'Карталарды ашу мүмкін болмады';

  @override
  String propertiesPhotoCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPhotoDelete => 'Фотоны өшіру';

  @override
  String get propertiesPhotoDeleteConfirm =>
      'Бұл фотоны нысаннан өшіру керек пе?';

  @override
  String propertiesPhotoFailed(String name) {
    return '$name жүктелмеді';
  }

  @override
  String propertiesPhotoTooLarge(String name) {
    return '$name 12 МБ-тан үлкен';
  }

  @override
  String get propertiesPhotos => 'Фото';

  @override
  String get propertiesPhotosHint =>
      'Фотоны басып тұрып жылжытыңыз — біріншісі мұқаба';

  @override
  String get propertiesPriceCheck => 'Бағаны тексеру';

  @override
  String propertiesPriceCheckAbove(String percent) {
    return '$percent% жоғары';
  }

  @override
  String get propertiesPriceCheckAtMedian => 'медианамен тең';

  @override
  String propertiesPriceCheckBasedOn(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$city қаласындағы $count нысан негізінде',
      one: '$city қаласындағы $count нысан негізінде',
    );
    return '$_temp0';
  }

  @override
  String propertiesPriceCheckBelow(String percent) {
    return '$percent% төмен';
  }

  @override
  String get propertiesPriceCheckComparables => 'Ұқсас нысандар';

  @override
  String propertiesPriceCheckDaysOnMarket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сатылымда $count күн',
      one: 'сатылымда $count күн',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPriceCheckLowConfidence =>
      'Ұқсас нысандар әзірге аз, сондықтан бұл тек бағдар';

  @override
  String get propertiesPriceCheckSeeComparables => 'Ұқсастарын көру';

  @override
  String propertiesPriceCheckSold(String price) {
    return 'Сатылғандар: медиана $price';
  }

  @override
  String propertiesPriceCheckVsMedian(
      String price, String median, String difference) {
    return '$price / м², медиана $median ($difference)';
  }

  @override
  String propertiesPriceHintRange(String low, String high) {
    return 'Ұқсас нысандар: осы ауданға $low–$high';
  }

  @override
  String get propertiesPriceHintUseMedian => 'Медиананы қою';

  @override
  String get propertiesPriceHistory => 'Баға тарихы';

  @override
  String get propertiesPriceLabel => 'Бағасы';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price бір м² үшін';
  }

  @override
  String get propertiesPriceReduced => 'Баға түсті';

  @override
  String propertiesPriceWas(String price) {
    return 'Бұрын $price';
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
  String get propertiesReport => 'Сатушыға есеп';

  @override
  String propertiesReportAsOf(String date) {
    return '$date жағдай бойынша';
  }

  @override
  String get propertiesReportAwaitingOutcome => 'Нәтиже әлі белгіленбеген';

  @override
  String get propertiesReportCurrentPrice => 'Қазір';

  @override
  String get propertiesReportDaysOnMarket => 'Сатылымдағы күндер';

  @override
  String get propertiesReportLinkLeads => 'Сілтеме арқылы өтінімдер';

  @override
  String get propertiesReportLinkViews => 'Сілтемені ашу саны';

  @override
  String propertiesReportListedOn(String date) {
    return '$date бастап сатылымда';
  }

  @override
  String get propertiesReportLoadFailed => 'Есепті жүктеу мүмкін болмады';

  @override
  String get propertiesReportMatchingBuyers => 'Сәйкес сатып алушылар';

  @override
  String propertiesReportNextViewing(String date) {
    return 'Келесі көрсету $date';
  }

  @override
  String get propertiesReportNoViewings => 'Әзірге көрсетулер болған жоқ';

  @override
  String get propertiesReportOriginalPrice => 'Бастапқы баға';

  @override
  String get propertiesReportOutcomes => 'Көрсетуден кейінгі пікір';

  @override
  String get propertiesReportPrice => 'Баға';

  @override
  String get propertiesReportPriceChange => 'Өзгеріс';

  @override
  String get propertiesReportPriceChanges => 'Баға өзгерістері';

  @override
  String get propertiesReportPriceUnchanged =>
      'Баға сатылымға шыққаннан бері өзгерген жоқ';

  @override
  String get propertiesReportShare => 'Сатушыға жіберу';

  @override
  String get propertiesReportShareFailed =>
      'Есепті жіберу мүмкін болмады. Қайталап көріңіз.';

  @override
  String propertiesReportSoldOn(String date) {
    return '$date сатылды';
  }

  @override
  String propertiesReportTextHeading(String title) {
    return 'Сатушыға есеп: $title';
  }

  @override
  String propertiesReportTextLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get propertiesReportViewingsHeld => 'Өткізілген көрсетулер';

  @override
  String get propertiesReportViewingsUpcoming => 'Алдағы көрсетулер';

  @override
  String get propertiesRooms => 'Бөлмелер';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms бөлме';
  }

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
  String get propertiesUpdateProperty => 'Нысанды жаңарту';

  @override
  String get propertiesViewList => 'Тізім';

  @override
  String get propertiesViewMap => 'Карта';

  @override
  String get propertiesViewings => 'Көрсетілімдер';

  @override
  String get quickAddClient => 'Жаңа клиент';

  @override
  String get quickAddDeal => 'Жаңа мәміле';

  @override
  String quickAddFor(String name) {
    return '$name үшін';
  }

  @override
  String get quickAddLastUsed => 'Соңғы рет';

  @override
  String get quickAddListing => 'Жаңа нысан';

  @override
  String get quickAddLogContact => 'Байланысты жазу';

  @override
  String get quickAddMeeting => 'Жаңа кездесу';

  @override
  String get quickAddNoClients => 'Әзірге клиент жоқ — алдымен клиент қосыңыз';

  @override
  String get quickAddOpen => 'Қосу';

  @override
  String get quickAddPickClient => 'Қай клиент?';

  @override
  String get quickAddSearchClients => 'Клиенттерді іздеу';

  @override
  String get quickAddTask => 'Жаңа тапсырма';

  @override
  String get quickAddTitle => 'Қосу';

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
  String get remindersTaskDue => 'Орындау уақыты келді';

  @override
  String remindersTaskDueWithClient(Object client) {
    return 'Орындау уақыты келді · $client';
  }

  @override
  String get routeAddPin => 'Белгі қою';

  @override
  String get routeAppApple => 'Apple Карталар';

  @override
  String get routeAppDgis => '2GIS';

  @override
  String get routeAppGoogle => 'Google Карталар';

  @override
  String get routeAppNextOnly => 'Тек келесі нүкте';

  @override
  String routeAppStops(int from, int to, int total) {
    return '$total нүктенің $from–$to';
  }

  @override
  String get routeAppWhole => 'Бүкіл маршрут ретімен';

  @override
  String get routeAppYandex => 'Яндекс Карталар';

  @override
  String routeChooserNext(String title) {
    return 'Келесі нүкте: $title';
  }

  @override
  String get routeChooserTitle => 'Карталарда ашу';

  @override
  String get routeChooserWhole => 'Алда қалған барлық нүкте кесте ретімен';

  @override
  String get routeDayOver => 'Бұл күнге нүкте қалмады';

  @override
  String get routeDone => 'Өтті';

  @override
  String routeDurationHourMin(int hours, int minutes) {
    return '$hours сағ $minutes мин';
  }

  @override
  String routeDurationHours(int hours) {
    return '$hours сағ';
  }

  @override
  String routeDurationMin(int minutes) {
    return '$minutes мин';
  }

  @override
  String get routeEmpty => 'Бұл күні көрсетілім жоқ';

  @override
  String get routeEmptyHint =>
      'Нысанға байланған кездесу мұнда маршрут нүктесі болып шығады.';

  @override
  String get routeEntryDay => 'Осы күннің маршруты';

  @override
  String get routeEntryToday => 'Бүгінгі маршрут';

  @override
  String routeFromPrevious(String km) {
    return 'Алдыңғы нүктеден $km км';
  }

  @override
  String get routeLoadFailed => 'Маршрутты жүктеу мүмкін болмады';

  @override
  String get routeNavigateNext => 'Келесі нүктеге жол салу';

  @override
  String get routeNext => 'Келесі';

  @override
  String get routeNotOnMap => 'Картада жоқ';

  @override
  String get routeNotOnMapHint =>
      'Бұл нысандарда әлі белгі жоқ, сондықтан олар маршрутқа кірмеді.';

  @override
  String get routeOpenFailed => 'Карталарды ашу мүмкін болмады';

  @override
  String get routeOpenWhole => 'Бүкіл маршрутты ашу';

  @override
  String get routeOverlap => 'Келесі көрсетіліммен қабаттасады';

  @override
  String routeStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нүкте',
      one: '$count нүкте',
    );
    return '$_temp0';
  }

  @override
  String get routeStraightLine =>
      'Нүктелер арасы түзу сызықпен, жол бойынша бағыт емес';

  @override
  String routeSummary(String stops, String km) {
    return '$stops · түзу сызықпен $km км';
  }

  @override
  String get routeTitle => 'Көрсетілімдер маршруты';

  @override
  String routeUntilNext(String duration) {
    return 'Келесісіне дейін $duration';
  }

  @override
  String get searchClear => 'Тазалау';

  @override
  String get searchClearRecent => 'Тазалау';

  @override
  String get searchHint => 'Клиенттер, нысандар, мәмілелер…';

  @override
  String searchMoreCount(Object count) {
    return 'тағы $count';
  }

  @override
  String get searchNoResults => 'Ештеңе табылмады';

  @override
  String get searchNoResultsSubtitle =>
      'Басқа атты, мекенжайды немесе телефон нөмірін көріңіз';

  @override
  String get searchPromptSubtitle =>
      'Клиентті, нысанды немесе мәмілені аты, мекенжайы, телефоны немесе ID бойынша табыңыз';

  @override
  String get searchPromptTitle => 'Бүкіл базадан іздеу';

  @override
  String get searchRecent => 'Соңғылары';

  @override
  String get searchSectionClients => 'Клиенттер';

  @override
  String get searchSectionDeals => 'Мәмілелер';

  @override
  String get searchSectionProperties => 'Нысандар';

  @override
  String get searchTitle => 'Іздеу';

  @override
  String get tasksAbout => 'Неге қатысты';

  @override
  String get tasksAdd => 'Тапсырма қосу';

  @override
  String get tasksAllTasks => 'Барлық тапсырмалар';

  @override
  String tasksAssignedTo(Object name) {
    return '$name үшін';
  }

  @override
  String get tasksAssignee => 'Орындаушы';

  @override
  String get tasksClearLink => 'Байланысты алып тастау';

  @override
  String get tasksClient => 'Клиент';

  @override
  String get tasksComplete => 'Орындалды деп белгілеу';

  @override
  String tasksCounter(Object count) {
    return 'Ашық: $count';
  }

  @override
  String get tasksDate => 'Күні';

  @override
  String get tasksDeal => 'Мәміле';

  @override
  String get tasksDelete => 'Тапсырманы жою';

  @override
  String get tasksDeleteBody =>
      'Тапсырма еске салғышымен бірге барлығынан жойылады.';

  @override
  String get tasksDeleteTitle => 'Тапсырманы жоясыз ба?';

  @override
  String tasksDoneOn(Object date) {
    return 'Орындалды: $date';
  }

  @override
  String get tasksDoneTab => 'Орындалған';

  @override
  String get tasksDue => 'Мерзімі';

  @override
  String tasksDueToday(Object time) {
    return 'Бүгін, $time';
  }

  @override
  String tasksDueTomorrow(Object time) {
    return 'Ертең, $time';
  }

  @override
  String get tasksEdit => 'Тапсырманы өзгерту';

  @override
  String get tasksEmptyDone => 'Әзірге орындалғаны жоқ';

  @override
  String get tasksEmptyOpen => 'Барлығы орындалды';

  @override
  String get tasksEmptyOpenHint =>
      'Клиенттер мен мәмілелерге қосылған тапсырмалар осында көрінеді.';

  @override
  String get tasksEmptyRecordHint => 'Ұмытпау үшін келесі қадамды қосыңыз.';

  @override
  String get tasksFieldTitle => 'Не істеу керек';

  @override
  String get tasksLoadFailed => 'Тапсырмаларды жүктеу мүмкін болмады';

  @override
  String get tasksNew => 'Жаңа тапсырма';

  @override
  String get tasksNoAgents => 'Тапсыратын адам жоқ';

  @override
  String get tasksNote => 'Ескертпе';

  @override
  String get tasksNoteHint => 'Мәліметтер, нөмірлер, не дайындау керек…';

  @override
  String get tasksOpenTab => 'Ашық';

  @override
  String get tasksOverdue => 'Мерзімі өтті';

  @override
  String get tasksQuickInThreeDays => '3 күннен кейін';

  @override
  String get tasksQuickTodayEvening => 'Бүгін кешке';

  @override
  String get tasksQuickTomorrowMorning => 'Ертең таңертең';

  @override
  String get tasksReopen => 'Қайта ашу';

  @override
  String get tasksSave => 'Тапсырманы сақтау';

  @override
  String get tasksSearchHint => 'Аты немесе ID бойынша іздеу';

  @override
  String get tasksTime => 'Уақыты';

  @override
  String get tasksTitle => 'Тапсырмалар';

  @override
  String get tasksTitleHint => 'Иринаға қайта қоңырау шалу';

  @override
  String get tasksTitleRequired => 'Не істеу керегін жазыңыз';

  @override
  String get tasksTitleTooLong => '200 таңбадан аспасын';

  @override
  String get teamsActive => 'Белсенді';

  @override
  String get teamsAddAgent => 'Агент қосу';

  @override
  String get teamsAddAgentAction => 'Жіберу';

  @override
  String get teamsAddAgentHint =>
      'Агенттің аккаунты болса, сұраныс алады. Болмаса, поштаға шақыру жібереміз.';

  @override
  String get teamsAgents => 'Агенттер';

  @override
  String get teamsCancelRequest => 'Қайтару';

  @override
  String get teamsChecklist => 'Мәміле тізімі';

  @override
  String get teamsChecklistAdd => 'Тармақ қосу';

  @override
  String get teamsChecklistDelete => 'Тармақты жою';

  @override
  String get teamsChecklistDiscard => 'Сақтамау';

  @override
  String get teamsChecklistDiscardBody =>
      'Тізімдегі өзгерістер әлі сақталмады.';

  @override
  String get teamsChecklistDiscardTitle => 'Сақтамай шығасыз ба?';

  @override
  String get teamsChecklistEmptyStage => 'Бұл кезеңде әзірге тармақ жоқ';

  @override
  String get teamsChecklistHint => 'Әр кезеңде мәміле бойынша не жинау керек';

  @override
  String get teamsChecklistNewDealsOnly =>
      'Өзгерістер жаңа мәмілелерге қолданылады. Ағымдағы мәмілелерде өз тізімі сақталады.';

  @override
  String get teamsChecklistRename => 'Атауын өзгерту';

  @override
  String get teamsChecklistReorder => 'Ретін өзгерту үшін сүйреңіз';

  @override
  String get teamsClients => 'Клиенттер';

  @override
  String get teamsCouldNotLoadStats => 'Статистиканы жүктеу мүмкін болмады';

  @override
  String get teamsCreate => 'Құру';

  @override
  String get teamsCreateTeam => 'Команда құру';

  @override
  String get teamsCurrency => 'Агенттік валютасы';

  @override
  String get teamsCurrencyConfirm => 'Валютаны ауыстыру';

  @override
  String teamsCurrencyConfirmBody(
      String currency, String before, String after) {
    return 'Агенттіктегі барлығы бағаларды «$currency» валютасында көреді. Сомалар қайта есептелмейді: $before тұратын нысан $after болып көрсетіледі.';
  }

  @override
  String get teamsCurrencyConfirmTitle =>
      'Агенттік валютасын ауыстыру керек пе?';

  @override
  String get teamsCurrencyEur => 'Еуро (€)';

  @override
  String get teamsCurrencyHint =>
      'Қосымшадағы бағалар қай валютада көрсетіледі';

  @override
  String get teamsCurrencyKgs => 'Қырғыз сомы (KGS)';

  @override
  String get teamsCurrencyKzt => 'Теңге (₸)';

  @override
  String get teamsCurrencyRub => 'Рубль (₽)';

  @override
  String get teamsCurrencyUsd => 'АҚШ доллары (\$)';

  @override
  String get teamsCurrencyUzs => 'Өзбек сумы (UZS)';

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
  String teamsInviteSentBody(Object email) {
    return '$email адресіне шақыру жіберілді.';
  }

  @override
  String get teamsLeaveTeam => 'Командадан шығу';

  @override
  String get teamsLeaveTeamBody =>
      'Клиенттер, мәмілелер мен кездесулер командада қалады. Қайту үшін жаңа шақыру керек.';

  @override
  String teamsLeaveTeamTitle(Object team) {
    return '$team командасынан шығасыз ба?';
  }

  @override
  String get teamsManagerChip => 'Жетекші';

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
  String get teamsMembers => 'Қатысушылар';

  @override
  String get teamsMyTeam => 'Менің командам';

  @override
  String get teamsNoManager => 'Менеджерсіз';

  @override
  String get teamsNoMembers => 'Әзірге ешкім жоқ';

  @override
  String get teamsNoMembersBody => 'Бірінші агентті пошта арқылы қосыңыз.';

  @override
  String get teamsNoPending => 'Күтушілер жоқ';

  @override
  String get teamsNoPendingBody => 'Жауап күткен сұраныстар осында шығады.';

  @override
  String get teamsNoTeamLabel => 'Командасыз';

  @override
  String get teamsPending => 'Күтілуде';

  @override
  String get teamsPhoneOptional => 'Телефон (міндетті емес)';

  @override
  String teamsRemoveInviteBody(Object name) {
    return '$name үшін шақыру қайтарылады.';
  }

  @override
  String get teamsRemoveMember => 'Командадан шығару';

  @override
  String teamsRemoveMemberBody(Object successor) {
    return 'Клиенттер, мәмілелер мен кездесулер командада қалып, $successor қарауына өтеді.';
  }

  @override
  String teamsRemoveMemberTitle(Object name) {
    return '$name шығарылсын ба?';
  }

  @override
  String teamsRequestSentBody(Object name) {
    return 'Командаға кіру үшін $name сұранысты қабылдауы керек.';
  }

  @override
  String get teamsRequired => 'Міндетті';

  @override
  String get teamsSave => 'Сақтау';

  @override
  String get teamsStatusPendingInvite => 'Шақырылған';

  @override
  String get teamsStatusPendingVerification => 'Пошта расталмаған';

  @override
  String get teamsSuccessor => 'Жазбалар кімге өтеді';

  @override
  String get teamsSuccessorMe => 'Маған';

  @override
  String get teamsTeamLabel => 'Команда';

  @override
  String get teamsTeamName => 'Команда атауы';

  @override
  String get teamsUpcoming => 'Алдағы';

  @override
  String get templatesAdd => 'Үлгі қосу';

  @override
  String get templatesBodyHint => 'Агент не жібереді';

  @override
  String get templatesBodyLabel => 'Мәтін';

  @override
  String get templatesDelete => 'Үлгіні жою';

  @override
  String templatesDeleteBody(String title) {
    return '«$title» агенттерге енді ұсынылмайды.';
  }

  @override
  String get templatesDeleteTitle => 'Үлгіні жою керек пе?';

  @override
  String get templatesEdit => 'Үлгіні өңдеу';

  @override
  String get templatesEmpty => 'Әзірге үлгілер жоқ';

  @override
  String get templatesEmptyBody =>
      'Агенттер жиі жіберетін хабарламаларды қосыңыз.';

  @override
  String get templatesHint => 'WhatsApp пен SMS үшін дайын мәтіндер';

  @override
  String get templatesInsert => 'Орын толтырғыш қою';

  @override
  String get templatesIntro =>
      'Агенттер клиентке жазғанда үлгіні таңдайды. Орын толтырғыштар клиент, агент және таңдалған нысан деректерімен толтырылады.';

  @override
  String get templatesLoadFailed => 'Үлгілерді жүктеу мүмкін болмады';

  @override
  String get templatesNew => 'Жаңа үлгі';

  @override
  String get templatesPlaceholderAddress => 'Мекенжайы';

  @override
  String get templatesPlaceholderAgent => 'Агенттің аты';

  @override
  String get templatesPlaceholderClient => 'Клиенттің аты';

  @override
  String get templatesPlaceholderLink => 'Нысан сілтемесі';

  @override
  String get templatesPlaceholderListing => 'Нысан';

  @override
  String get templatesPlaceholderPrice => 'Бағасы';

  @override
  String get templatesTitle => 'Хабарлама үлгілері';

  @override
  String get templatesTitleHint => 'Мысалы, Көрсетілімге шақыру';

  @override
  String get templatesTitleLabel => 'Атауы';

  @override
  String templatesUnknownPlaceholder(String names) {
    return 'Белгісіз орын толтырғыш: $names. Төмендегілерді пайдаланыңыз.';
  }

  @override
  String get dealsKind => 'Сату немесе жалға беру';

  @override
  String get dealsKindSale => 'Сату';

  @override
  String get dealsKindRent => 'Жалға беру';

  @override
  String get leasesTitle => 'Жалдау';

  @override
  String get leasesMonthlyRent => 'Айлық жалдау ақысы';

  @override
  String leasesPerMonth(String amount) {
    return 'айына $amount';
  }

  @override
  String get leasesStart => 'Жалдаудың басталуы';

  @override
  String get leasesEnd => 'Жалдаудың аяқталуы';

  @override
  String get leasesPickDate => 'Күнді таңдаңыз';

  @override
  String get leasesReminderDays => 'Аяқталуына дейін неше күн бұрын еске салу';

  @override
  String leasesReminderValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Аяқталуына $count күн қалғанда',
    );
    return '$_temp0';
  }

  @override
  String get leasesReminder => 'Еске салу';

  @override
  String get leasesLandlord => 'Жалға беруші';

  @override
  String get leasesTenant => 'Жалға алушы';

  @override
  String leasesTenantValue(String name) {
    return 'Жалға алушы: $name';
  }

  @override
  String leasesLandlordValue(String name) {
    return 'Жалға беруші: $name';
  }

  @override
  String get leasesRentRequired => 'Айлық жалдау ақысын енгізіңіз';

  @override
  String get leasesDatesRequired =>
      'Жалдаудың бірінші және соңғы күнін таңдаңыз';

  @override
  String get leasesEndBeforeStart => 'Жалдау басталғаннан кейін аяқталуы керек';

  @override
  String get leasesReminderInvalid => '1-ден 365 күнге дейін';

  @override
  String get leasesEndsToday => 'Жалдау бүгін аяқталады';

  @override
  String get leasesEndsTomorrow => 'Жалдау ертең аяқталады';

  @override
  String leasesEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Жалдау $count күннен кейін аяқталады',
    );
    return '$_temp0';
  }

  @override
  String get leasesEndedYesterday => 'Жалдау кеше аяқталды';

  @override
  String leasesEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Жалдау $count күн бұрын аяқталды',
    );
    return '$_temp0';
  }

  @override
  String get leasesRenew => 'Жалдауды ұзарту';

  @override
  String get leasesRenewTitle => 'Жалдауды ұзарту';

  @override
  String get leasesRenewNewEnd => 'Жаңа соңғы күн';

  @override
  String get leasesRenewHint =>
      'Мәміле сол күйінде қалады: жалдау жаңа күнге дейін ұзартылады, ал талқылауда белгі қалады.';

  @override
  String get leasesRenewEndNotLater =>
      'Қазіргі аяқталу күнінен кейінгі күнді таңдаңыз';

  @override
  String get leasesRenewed => 'Жалдау ұзартылды';

  @override
  String get leasesRenewFailed => 'Жалдауды ұзарту мүмкін болмады';

  @override
  String get leasesRenewWhenWon =>
      'Мәміле жеңіспен жабылғанда жалдауды ұзартуға болады.';

  @override
  String get leasesEndingTitle => 'Жалдауы аяқталатындар';

  @override
  String get leasesEndingLoadFailed => 'Жалдауларды жүктеу мүмкін болмады';

  @override
  String get leasesEndingEmpty => 'Алдағы 30 күнде жалдау аяқталмайды';

  @override
  String get leasesEndingEmptyHint =>
      'Жеңіспен жабылған жалдау мәмілелері шарт аяқталуына бір ай қалғанда осында шығады.';

  @override
  String notificationsLeaseEnding(String dealTitle, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          '«$dealTitle» мәмілесі бойынша жалдау $days күннен кейін аяқталады',
      one: '«$dealTitle» мәмілесі бойынша жалдау ертең аяқталады',
      zero: '«$dealTitle» мәмілесі бойынша жалдау бүгін аяқталады',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityHandover => 'Әріптеске берілді';

  @override
  String clientsActivityHandoverDetail(String from, String to) {
    return '$from әріптесінен $to әріптесіне';
  }

  @override
  String clientsActivityHandoverTo(String to) {
    return '$to әріптесіне';
  }

  @override
  String get handoverAction => 'Жұмысты беру';

  @override
  String handoverIntro(String name) {
    return '$name агенттікте қалады. Кімге және не беретінін таңдаңыз; әр клиенттің тарихында белгі қалады.';
  }

  @override
  String get handoverFrom => 'Кімнен';

  @override
  String get handoverTo => 'Кімге';

  @override
  String get handoverChooseColleague => 'Әріптесті таңдаңыз';

  @override
  String get handoverNoColleagues => 'Әзірге беретін ешкім жоқ';

  @override
  String get handoverWhat => 'Не беріледі';

  @override
  String get handoverPartClients => 'Клиенттер';

  @override
  String get handoverPartClientsHint =>
      'Ашық мәмілелерімен, кездесулерімен және тапсырмаларымен';

  @override
  String get handoverPartListings => 'Нысандар';

  @override
  String get handoverPartListingsHint => 'Алдағы ашық есік күндерімен';

  @override
  String get handoverPartDeals => 'Ашық мәмілелер';

  @override
  String get handoverPartDealsHint => 'Әлі жабылмаған барлық мәмілелер';

  @override
  String get handoverPartUpcoming => 'Кездесулер мен тапсырмалар';

  @override
  String get handoverPartUpcomingHint =>
      'Алдағы кездесулер мен орындалмаған тапсырмалар';

  @override
  String get handoverAllClients => 'Барлық клиенттер';

  @override
  String handoverSomeClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count клиент таңдалды',
    );
    return '$_temp0';
  }

  @override
  String get handoverPickClients => 'Клиенттерді таңдау';

  @override
  String get handoverPickAll => 'Барлығын таңдау';

  @override
  String get handoverPickNone => 'Тазалау';

  @override
  String get handoverPickDone => 'Дайын';

  @override
  String get handoverNoClients => 'Таңдайтын клиент жоқ';

  @override
  String get handoverPreview => 'Берілетіндер';

  @override
  String get handoverCountDeals => 'Мәмілелер';

  @override
  String get handoverCountMeetings => 'Кездесулер';

  @override
  String get handoverCountTasks => 'Тапсырмалар';

  @override
  String get handoverCountOpenHouses => 'Ашық есік күндері';

  @override
  String get handoverPickTarget =>
      'Не өтетінін көру үшін кімге беретінін таңдаңыз';

  @override
  String get handoverNothingSelected => 'Кем дегенде бір нәрсені белгілеңіз';

  @override
  String get handoverNothingToMove => 'Беретін ештеңе жоқ';

  @override
  String get handoverPreviewFailed => 'Не өтетінін есептеу мүмкін болмады';

  @override
  String get handoverConfirm => 'Беру';

  @override
  String handoverConfirmTitle(String name) {
    return '$name әріптесіне беру керек пе?';
  }

  @override
  String handoverConfirmBody(String from, String to) {
    return 'Жұмыс $from әріптесінен $to әріптесіне өтеді. Ешкім агенттіктен кетпейді, әр клиенттің тарихында белгі қалады.';
  }

  @override
  String handoverDoneTitle(String name) {
    return 'Берілді: $name';
  }

  @override
  String handoverDoneBody(String name) {
    return '$name берілген жұмыс туралы хабарлама алады.';
  }

  @override
  String get handoverDoneAction => 'Командаға оралу';

  @override
  String get handoverLoadFailed => 'Команданы жүктеу мүмкін болмады';
}
