// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get adminActivate => 'Активировать';

  @override
  String get adminAssignTeam => 'Назначить команду';

  @override
  String get adminAssignToTeam => 'Назначить в команду';

  @override
  String get adminAuditEmptyBody =>
      'Здесь появятся действия команды: создание сделок, смена статусов, приглашения.';

  @override
  String get adminChangeRole => 'Изменить роль';

  @override
  String get adminConsoleTitle => 'Администрирование';

  @override
  String get adminCopyCode => 'Копировать код';

  @override
  String get adminCouldNotLoadStats => 'Не удалось загрузить статистику';

  @override
  String get adminCreateInvite => 'Создать приглашение';

  @override
  String get adminDataScope => 'Область данных';

  @override
  String get adminDeactivate => 'Деактивировать';

  @override
  String adminDeleteCascade(Object name, Object successor) {
    return 'Клиенты, объекты, сделки и встречи ($name) перейдут к $successor. Аккаунт будет удалён навсегда, отменить это нельзя.';
  }

  @override
  String get adminDeleteHandoverEmpty => 'Передать некому';

  @override
  String get adminDeleteHandoverSearch => 'Поиск по сотрудникам';

  @override
  String get adminDeleteHandoverTitle => 'Кому передать записи';

  @override
  String get adminDeleteUser => 'Удалить пользователя';

  @override
  String get adminDone => 'Готово';

  @override
  String get adminEmail => 'Электронная почта';

  @override
  String get adminEnterValidEmail => 'Введите корректный email';

  @override
  String get adminFullName => 'Полное имя';

  @override
  String get adminInactive => 'НЕАКТИВЕН';

  @override
  String get adminInviteCodeCopied => 'Код приглашения скопирован';

  @override
  String get adminInviteCreated => 'Приглашение создано';

  @override
  String get adminInviteHelper => 'Код придёт на почту и будет активен 7 дней.';

  @override
  String get adminInviteInstructions =>
      'Они открывают приложение, нажимают «Есть приглашение?» на экране входа, вставляют этот код и выбирают собственный пароль.';

  @override
  String get adminInviteUser => 'Пригласить пользователя';

  @override
  String adminInvitedAs(Object email, Object name, Object role) {
    return '$name ($email) приглашён(а) как $role.';
  }

  @override
  String get adminNewTeam => 'Новая команда';

  @override
  String get adminNoAuditEntries => 'Нет записей аудита';

  @override
  String get adminNoInviteToken =>
      'Токен приглашения не получен. Пользователь не сможет задать пароль, пока это не будет решено.';

  @override
  String get adminNoTeams => 'Нет команд';

  @override
  String get adminNoTeamsYet => 'Команд пока нет';

  @override
  String get adminNoUsers => 'Нет пользователей';

  @override
  String get adminPhoneOptional => 'Телефон (необязательно)';

  @override
  String get adminRequired => 'Обязательное поле';

  @override
  String get adminResendInvite => 'Отправить приглашение повторно';

  @override
  String get adminRole => 'Роль';

  @override
  String get adminShareInviteCode =>
      'Поделитесь с ними этим кодом приглашения:';

  @override
  String get adminStatActive => 'Активные';

  @override
  String get adminStatClients => 'Клиенты';

  @override
  String get adminStatClosed => 'Закрытые';

  @override
  String get adminStatDeals => 'Сделки';

  @override
  String get adminStatUpcoming => 'Предстоящие';

  @override
  String get adminTabAudit => 'Аудит';

  @override
  String get adminTabTeams => 'Команды';

  @override
  String get adminTabUsers => 'Пользователи';

  @override
  String get adminViewStats => 'Просмотр статистики';

  @override
  String analyticsAgent(Object name) {
    return 'Агент: $name';
  }

  @override
  String get analyticsAllAgents => 'Все агенты';

  @override
  String get analyticsAvgDaysToWin => 'Дней до закрытия';

  @override
  String get analyticsCreated => 'Создано';

  @override
  String analyticsDays(Object days) {
    return '$days дн.';
  }

  @override
  String get analyticsEmptyBody =>
      'Здесь появятся сделки, созданные за этот период.';

  @override
  String get analyticsEmptyTitle => 'За этот период сделок нет';

  @override
  String get analyticsFunnel => 'Воронка';

  @override
  String get analyticsLeadToWon => 'От лида до победы';

  @override
  String get analyticsLoadFailed => 'Не удалось загрузить аналитику';

  @override
  String get analyticsLostReasons => 'Почему сделки срываются';

  @override
  String get analyticsMonthly => 'Последние полгода';

  @override
  String get analyticsNoLost => 'За этот период проигранных сделок нет.';

  @override
  String get analyticsLeadSources => 'Откуда приходят клиенты';

  @override
  String get analyticsLeadSourcesHint =>
      'Клиенты, добавленные за период, и сколько из них со сделкой.';

  @override
  String analyticsLeadSourceWon(Object count, Object rate) {
    return '$count со сделкой · $rate';
  }

  @override
  String get analyticsNoClients => 'За этот период клиентов не добавлено.';

  @override
  String get analyticsNoValue => '—';

  @override
  String analyticsOfPrevious(Object percent) {
    return '$percent от предыдущего этапа';
  }

  @override
  String get analyticsOpen => 'Воронка и аналитика';

  @override
  String get analyticsPeriodMonth => 'Этот месяц';

  @override
  String get analyticsPeriodQuarter => 'Квартал';

  @override
  String get analyticsPeriodYear => 'Год';

  @override
  String get analyticsSelectAgent => 'Выберите агента';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String analyticsWonLost(Object lost, Object won) {
    return 'Выиграно: $won · проиграно: $lost';
  }

  @override
  String get analyticsWonValue => 'Сумма выигранных';

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Введите выданный вам код приглашения и придумайте пароль.';

  @override
  String get authAcceptRequest => 'Принять';

  @override
  String get authAcceptTerms => 'Я согласен с политикой конфиденциальности';

  @override
  String get authAcceptTermsRequired => 'Примите политику конфиденциальности';

  @override
  String get authAcceptYourInvite => 'Примите приглашение';

  @override
  String get authActivate => 'Активировать';

  @override
  String get authBackToSignIn => 'Назад ко входу';

  @override
  String get authChangeEmail => 'Другой адрес';

  @override
  String get authChooseRoleSubtitle =>
      'От этого зависит, что вы увидите. Позже руководитель сможет изменить это.';

  @override
  String get authChooseRoleTitle => 'Как вы будете работать?';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authContinue => 'Продолжить';

  @override
  String get authCreateAccountSubtitle =>
      'Мы отправим на почту шестизначный код для подтверждения адреса.';

  @override
  String get authCreateAccountTitle => 'Создайте аккаунт';

  @override
  String get authCreateTeamAction => 'Создать и продолжить';

  @override
  String get authCreateTeamName => 'Название агентства';

  @override
  String get authCreateTeamNameRequired => 'Введите название';

  @override
  String get authCreateTeamSubtitle =>
      'Название увидят ваши агенты. Его можно изменить позже.';

  @override
  String get authCreateTeamTitle => 'Создайте агентство';

  @override
  String get authDeclineRequest => 'Отклонить';

  @override
  String authDeclineRequestBody(Object team) {
    return '$team не увидит ваших клиентов и сделок. Позже вас смогут пригласить снова.';
  }

  @override
  String get authDeclineRequestTitle => 'Отклонить приглашение?';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authEmailInvalid => 'Введите корректную эл. почту';

  @override
  String get authEmailRequired => 'Укажите эл. почту';

  @override
  String get authEmailTaken => 'На этот адрес уже есть аккаунт. Войдите.';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authForgotPasswordSubtitle =>
      'Укажите адрес, под которым вы входите, и мы пришлём ссылку для смены пароля.';

  @override
  String get authForgotPasswordTitle => 'Сброс пароля';

  @override
  String get authFullName => 'Имя и фамилия';

  @override
  String get authFullNameRequired => 'Введите имя';

  @override
  String get authHaveAnInvite => 'Есть приглашение?';

  @override
  String get authInviteCode => 'Код приглашения';

  @override
  String get authInviteCodeRequired => 'Укажите код приглашения';

  @override
  String get authInvitePendingBody =>
      'На этот адрес отправлено приглашение. Откройте его или введите код, чтобы задать пароль.';

  @override
  String get authInvitePendingTitle => 'Вас уже приглашали';

  @override
  String authInviteSignOutBody(Object email) {
    return 'Сейчас вы вошли как $email. Чтобы принять приглашение, нужно сначала выйти из этого аккаунта.';
  }

  @override
  String get authInviteSignOutConfirm => 'Выйти и продолжить';

  @override
  String get authInviteSignOutTitle => 'Принять приглашение?';

  @override
  String authInvitedBy(Object name) {
    return 'От $name';
  }

  @override
  String authInvitedByTeam(Object team) {
    return '$team приглашает вас';
  }

  @override
  String get authNewPassword => 'Новый пароль';

  @override
  String get authNoAccount => 'Нет аккаунта?';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordHelp => 'Минимум 8 символов, одна цифра.';

  @override
  String get authPasswordMinLength => 'Не менее 6 символов';

  @override
  String get authPasswordMinLength8 => 'Минимум 8 символов';

  @override
  String get authPasswordRequired => 'Укажите пароль';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authPhoneOptional => 'Телефон (необязательно)';

  @override
  String get authPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get authResendCode => 'Отправить код снова';

  @override
  String authResendCodeIn(Object seconds) {
    return 'Новый код через $seconds с';
  }

  @override
  String get authResetCode => 'Код сброса';

  @override
  String get authResetCodeRequired => 'Введите код сброса';

  @override
  String authResetLinkSentBody(Object email) {
    return 'Если аккаунт с адресом $email существует, ссылка для смены пароля уже в пути. Она действует 24 часа.';
  }

  @override
  String get authResetLinkSentTitle => 'Проверьте почту';

  @override
  String get authResetPasswordSubtitle =>
      'Вставьте код из письма и придумайте пароль.';

  @override
  String get authResetPasswordTitle => 'Новый пароль';

  @override
  String get authRoleAgentBody =>
      'Присоединитесь к команде руководителя и ведите своих клиентов и сделки.';

  @override
  String get authRoleAgentTitle => 'Я агент';

  @override
  String get authRoleManagerBody =>
      'Создайте команду, добавляйте агентов и видьте всю их работу.';

  @override
  String get authRoleManagerTitle => 'Я руковожу агентством';

  @override
  String get authSendResetLink => 'Отправить ссылку';

  @override
  String get authSetPasswordSignIn => 'Задать пароль и войти';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInSubtitle => 'Войдите, чтобы управлять своими объектами';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authVerify => 'Подтвердить';

  @override
  String authVerifyEmailSubtitle(Object email) {
    return 'Введите шестизначный код, отправленный на $email.';
  }

  @override
  String get authVerifyEmailTitle => 'Подтвердите почту';

  @override
  String get authWaitingCopyEmail => 'Скопировать адрес';

  @override
  String get authWaitingEmailCopied => 'Адрес скопирован';

  @override
  String get authWaitingNoRequests => 'Приглашений пока нет';

  @override
  String get authWaitingNoRequestsBody => 'Потяните вниз, чтобы обновить.';

  @override
  String get authWaitingSubtitle =>
      'Передайте этот адрес руководителю. Как только он добавит вас и вы примете запрос, здесь появятся клиенты и сделки.';

  @override
  String get authWaitingTitle => 'Ожидание команды';

  @override
  String get authWelcomeBack => 'С возвращением!';

  @override
  String get calendarAdd => 'Добавить';

  @override
  String get calendarAddMeeting => 'Встреча';

  @override
  String get calendarAddMeetingHint => 'С клиентом, в назначенное время';

  @override
  String get calendarAddTask => 'Задача';

  @override
  String get calendarAddTaskHint => 'Дело, которое нужно сделать к сроку';

  @override
  String calendarAddTo(String day) {
    return 'Добавить на $day';
  }

  @override
  String get calendarDayEmpty => 'Ничего не запланировано';

  @override
  String get calendarDayEmptyHint =>
      'Нажмите + или удерживайте день, чтобы добавить встречу или задачу';

  @override
  String calendarDayEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
      zero: 'ничего не запланировано',
    );
    return '$_temp0';
  }

  @override
  String get calendarLegendMeeting => 'Встреча';

  @override
  String get calendarLegendOpenHouse => 'День открытых дверей';

  @override
  String get calendarLegendOverdue => 'Просрочено';

  @override
  String get calendarLegendTask => 'Задача';

  @override
  String get calendarLegendViewing => 'Показ';

  @override
  String get calendarLoadFailed => 'Не удалось загрузить календарь';

  @override
  String get calendarNextMonth => 'Следующий месяц';

  @override
  String get calendarNextWeek => 'Следующая неделя';

  @override
  String get calendarPreviousMonth => 'Предыдущий месяц';

  @override
  String get calendarPreviousWeek => 'Предыдущая неделя';

  @override
  String get calendarShowMonth => 'Показать весь месяц';

  @override
  String get calendarShowWeek => 'Показать одну неделю';

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get calendarToday => 'Сегодня';

  @override
  String get calendarViewList => 'Список';

  @override
  String get calendarViewMonth => 'Месяц';

  @override
  String get changeLogAnyTime => 'За всё время';

  @override
  String get changeLogAnyone => 'Все сотрудники';

  @override
  String get changeLogAutomatic => 'Автоматически';

  @override
  String changeLogChange(String field, String from, String to) {
    return '$field: $from → $to';
  }

  @override
  String get changeLogClearFilters => 'Сбросить фильтры';

  @override
  String get changeLogCreated => 'Создано';

  @override
  String changeLogDays(String from, String to) {
    return '$from – $to';
  }

  @override
  String get changeLogDeleted => 'Удалено';

  @override
  String changeLogEdited(String field) {
    return '$field: изменено';
  }

  @override
  String get changeLogEmptyBody =>
      'Здесь появится каждое изменение этой записи: кто и когда его внёс.';

  @override
  String get changeLogEmptyTitle => 'Изменений пока нет';

  @override
  String get changeLogEntityClient => 'Клиент';

  @override
  String get changeLogEntityDeal => 'Сделка';

  @override
  String get changeLogEntityOther => 'Запись';

  @override
  String get changeLogEntityProperty => 'Объект';

  @override
  String get changeLogFieldAddress => 'Адрес';

  @override
  String get changeLogFieldAgent => 'Агент';

  @override
  String get changeLogFieldArea => 'Площадь';

  @override
  String get changeLogFieldBirthday => 'День рождения';

  @override
  String get changeLogFieldBudget => 'Бюджет';

  @override
  String get changeLogFieldBudgetMax => 'Бюджет до';

  @override
  String get changeLogFieldBudgetMin => 'Бюджет от';

  @override
  String get changeLogFieldCity => 'Город';

  @override
  String get changeLogFieldClient => 'Клиент';

  @override
  String get changeLogFieldCommission => 'Комиссия';

  @override
  String get changeLogFieldDealPrice => 'Цена сделки';

  @override
  String get changeLogFieldDescription => 'Описание';

  @override
  String get changeLogFieldEmail => 'Email';

  @override
  String get changeLogFieldFloor => 'Этаж';

  @override
  String get changeLogFieldLeadSource => 'Источник';

  @override
  String get changeLogFieldLeadSourceDetail => 'Подробности источника';

  @override
  String get changeLogFieldListing => 'Объект';

  @override
  String get changeLogFieldLocation => 'Точка на карте';

  @override
  String get changeLogFieldLostNote => 'Комментарий к проигрышу';

  @override
  String get changeLogFieldLostReason => 'Причина проигрыша';

  @override
  String get changeLogFieldMandate => 'Договор с продавцом';

  @override
  String get changeLogFieldMandateEnd => 'Договор до';

  @override
  String get changeLogFieldMinArea => 'Площадь от';

  @override
  String get changeLogFieldMinRooms => 'Комнат от';

  @override
  String get changeLogFieldName => 'Имя';

  @override
  String get changeLogFieldNotes => 'Заметки';

  @override
  String get changeLogFieldOther => 'Другие данные';

  @override
  String get changeLogFieldPhone => 'Телефон';

  @override
  String get changeLogFieldPrice => 'Цена';

  @override
  String get changeLogFieldRooms => 'Комнаты';

  @override
  String get changeLogFieldStatus => 'Статус';

  @override
  String get changeLogFieldTags => 'Теги';

  @override
  String get changeLogFieldTitle => 'Название';

  @override
  String get changeLogFieldTotalFloors => 'Этажей в доме';

  @override
  String get changeLogFieldType => 'Тип';

  @override
  String get changeLogFieldWantedCity => 'Желаемый город';

  @override
  String get changeLogFieldWantedType => 'Ищет';

  @override
  String get changeLogFilterAll => 'Все';

  @override
  String get changeLogFilterClients => 'Клиенты';

  @override
  String get changeLogFilterDeals => 'Сделки';

  @override
  String get changeLogFilterListings => 'Объекты';

  @override
  String get changeLogLoadFailed => 'Не удалось загрузить историю';

  @override
  String get changeLogNoValue => '—';

  @override
  String get changeLogPeopleFailed =>
      'Не удалось загрузить сотрудников агентства';

  @override
  String changeLogPercent(String value) {
    return '$value%';
  }

  @override
  String get changeLogPickDays => 'Период';

  @override
  String get changeLogPickPerson => 'Кто внёс изменение';

  @override
  String changeLogRecord(String kind, String label) {
    return '$kind: $label';
  }

  @override
  String get changeLogTeamEmptyBody =>
      'Здесь появятся изменения объектов, сделок и клиентов агентства.';

  @override
  String get changeLogTeamEmptyFiltered => 'По этим фильтрам ничего нет.';

  @override
  String get changeLogTeamHint => 'Кто что менял в агентстве';

  @override
  String get changeLogTeamTitle => 'Журнал изменений';

  @override
  String get changeLogTitle => 'История изменений';

  @override
  String get changeLogUnknownValue => 'другое значение';

  @override
  String get changeLogUntitled => 'Без названия';

  @override
  String get clientsActivityCall => 'Звонок';

  @override
  String get clientsActivityDate => 'Дата';

  @override
  String get clientsActivityDeleteBody =>
      'Запись исчезнет из истории клиента для всей команды. Это нельзя отменить.';

  @override
  String get clientsActivityDeleteTitle => 'Удалить запись?';

  @override
  String get clientsActivityEdit => 'Изменить запись';

  @override
  String get clientsActivityEmail => 'Письмо';

  @override
  String get clientsActivityFormerMember => 'Бывший сотрудник';

  @override
  String get clientsActivityInFuture => 'Это время ещё не наступило';

  @override
  String get clientsActivityKind => 'Как связывались';

  @override
  String get clientsActivityLogged => 'Контакт записан';

  @override
  String get clientsActivityMessage => 'Сообщение';

  @override
  String get clientsActivityNote => 'Заметка';

  @override
  String get clientsActivityNoteHint => 'О чём договорились, что дальше…';

  @override
  String get clientsActivityNoteLabel => 'Что обсудили';

  @override
  String get clientsActivityNoteRequired => 'Заметке нужен текст';

  @override
  String get clientsActivityRemove => 'Удалить запись';

  @override
  String get clientsActivitySave => 'Сохранить';

  @override
  String clientsActivitySentListings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено $count объекта',
      many: 'Отправлено $count объектов',
      few: 'Отправлено $count объекта',
      one: 'Отправлен 1 объект',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityTime => 'Время';

  @override
  String clientsActivityToday(String time) {
    return 'Сегодня, $time';
  }

  @override
  String get clientsActivityUpdated => 'Запись обновлена';

  @override
  String get clientsActivityWhen => 'Когда';

  @override
  String get clientsActivityWhenHourAgo => 'Час назад';

  @override
  String get clientsActivityWhenJustNow => 'Только что';

  @override
  String get clientsActivityWhenYesterday => 'Вчера';

  @override
  String clientsActivityYesterday(String time) {
    return 'Вчера, $time';
  }

  @override
  String get clientsAddFirstClient => 'Добавьте первого клиента';

  @override
  String get clientsAgent => 'Агент';

  @override
  String clientsAgentMeta(Object name) {
    return 'агент $name';
  }

  @override
  String get clientsAnyType => 'Любой';

  @override
  String get clientsBirthday => 'День рождения';

  @override
  String clientsBirthdayAge(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age года',
      many: '$age лет',
      few: '$age года',
      one: '$age год',
    );
    return '$_temp0';
  }

  @override
  String get clientsBirthdayClear => 'Убрать день рождения';

  @override
  String get clientsBirthdayHint =>
      'Если год неизвестен, сохраняются только день и месяц.';

  @override
  String get clientsBirthdayNoYear => 'Год неизвестен';

  @override
  String get clientsBirthdayPick => 'Выбрать дату';

  @override
  String get clientsBudgetFrom => 'Бюджет от';

  @override
  String get clientsBudgetTo => 'Бюджет до';

  @override
  String get clientsBuyer => 'Покупатель';

  @override
  String clientsClientCreatedId(Object id) {
    return 'Клиент создан (ID: $id)';
  }

  @override
  String get clientsClientFallback => 'Клиент';

  @override
  String get clientsClientIdCopied => 'ID клиента скопирован';

  @override
  String get clientsClientNotFound => 'Клиент не найден';

  @override
  String get clientsClientType => 'Тип клиента';

  @override
  String clientsColdDaysOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdEmpty => 'Никто не остывает';

  @override
  String clientsColdEmptyHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Все, кому стоит позвонить, слышали вас за последние $count дня.',
      many: 'Все, кому стоит позвонить, слышали вас за последние $count дней.',
      few: 'Все, кому стоит позвонить, слышали вас за последние $count дня.',
      one: 'Все, кому стоит позвонить, слышали вас за последний $count день.',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdLoadFailed =>
      'Не удалось загрузить остывающих клиентов';

  @override
  String get clientsColdNeverContacted => 'Ещё не связывались';

  @override
  String get clientsColdNextCheckIn => 'Узнать, как дела';

  @override
  String get clientsColdNextFirstCall => 'Сделать первый звонок';

  @override
  String get clientsColdNextPushDeal => 'Продвинуть сделку';

  @override
  String get clientsColdNextSendMatches => 'Отправить подходящие объекты';

  @override
  String get clientsColdReasonLead => 'Заявка со страницы объекта';

  @override
  String clientsColdReasonMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подходящего объекта',
      many: '$count подходящих объектов',
      few: '$count подходящих объекта',
      one: '$count подходящий объект',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdReasonNegotiation => 'Сделка на переговорах';

  @override
  String get clientsColdReasonOpenDeal => 'Открытая сделка';

  @override
  String get clientsColdRemind => 'Напомнить';

  @override
  String clientsColdRemindTask(String name) {
    return 'Позвонить: $name';
  }

  @override
  String clientsColdReminderSet(String time) {
    return 'Напоминание на завтра, $time';
  }

  @override
  String clientsColdSilentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Без связи $count дня',
      many: 'Без связи $count дней',
      few: 'Без связи $count дня',
      one: 'Без связи $count день',
    );
    return '$_temp0';
  }

  @override
  String clientsColdSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Без связи $count дня и дольше',
      many: 'Без связи $count дней и дольше',
      few: 'Без связи $count дня и дольше',
      one: 'Без связи $count день и дольше',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdTitle => 'Остывают';

  @override
  String get clientsColdUndo => 'Отменить';

  @override
  String get clientsComposeClearListing => 'Убрать объект';

  @override
  String get clientsComposeHint =>
      'Текст можно поправить перед отправкой. Отправленное сохранится в истории клиента.';

  @override
  String get clientsComposeListing => 'Объект';

  @override
  String get clientsComposeListingHint =>
      'Подставит объект, его цену, адрес и ссылку';

  @override
  String get clientsComposeListingNone => 'Без объекта';

  @override
  String get clientsComposeNoListings => 'Нет объектов';

  @override
  String get clientsComposeNoTemplates => 'В агентстве пока нет шаблонов';

  @override
  String get clientsComposePickListing => 'Выберите объект';

  @override
  String get clientsComposePickTemplate => 'Выберите шаблон';

  @override
  String get clientsComposeSearchListings => 'Поиск объектов';

  @override
  String get clientsComposeSearchTemplates => 'Поиск шаблонов';

  @override
  String get clientsComposeSms => 'SMS';

  @override
  String get clientsComposeText => 'Сообщение';

  @override
  String get clientsComposeTextHint => 'Напишите сообщение или выберите шаблон';

  @override
  String get clientsComposeTitle => 'Написать клиенту';

  @override
  String get clientsComposeUseTemplate => 'Выбрать шаблон';

  @override
  String get clientsContact => 'Контакт';

  @override
  String get clientsContactInfo => 'Контактная информация';

  @override
  String clientsContactedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Связывались $count дня назад',
      many: 'Связывались $count дней назад',
      few: 'Связывались $count дня назад',
      one: 'Связывались $count день назад',
    );
    return '$_temp0';
  }

  @override
  String clientsContactedOn(String date) {
    return 'Связывались $date';
  }

  @override
  String get clientsContactedToday => 'Связывались сегодня';

  @override
  String get clientsContactedYesterday => 'Связывались вчера';

  @override
  String clientsCounter(Object active, Object total) {
    return '$total всего · $active в работе';
  }

  @override
  String get clientsCreateClient => 'Создать клиента';

  @override
  String clientsDatesAnniversary(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years года с покупки',
      many: '$years лет с покупки',
      few: '$years года с покупки',
      one: '$years год с покупки',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesBirthday => 'День рождения';

  @override
  String get clientsDatesEmpty => 'В ближайшие две недели дат нет';

  @override
  String get clientsDatesEmptyHint =>
      'Добавьте день рождения в карточке клиента. Годовщина выигранной сделки появляется здесь каждый год сама.';

  @override
  String get clientsDatesGreet => 'Поздравить';

  @override
  String clientsDatesInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Через $count дня',
      many: 'Через $count дней',
      few: 'Через $count дня',
      one: 'Через $count день',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesLoadFailed => 'Не удалось загрузить ближайшие даты';

  @override
  String get clientsDatesTitle => 'Ближайшие даты';

  @override
  String get clientsDatesToday => 'Сегодня';

  @override
  String get clientsDatesTomorrow => 'Завтра';

  @override
  String clientsDatesTurns(int years) {
    return 'День рождения, исполняется $years';
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
      other: '$count сделки',
      many: '$count сделок',
      few: '$count сделки',
      one: '1 сделка',
    );
    return '$_temp0';
  }

  @override
  String get clientsDeals => 'Сделки';

  @override
  String get clientsDelete => 'Удалить';

  @override
  String clientsDeleteCascade(num count, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'и $count связанные сделки будут удалены безвозвратно',
      many: 'и $count связанных сделок будут удалены безвозвратно',
      few: 'и $count связанные сделки будут удалены безвозвратно',
      one: 'и 1 связанная сделка будут удалены безвозвратно',
      zero: 'будет удалён безвозвратно',
    );
    return '$name $_temp0. Отменить действие нельзя.';
  }

  @override
  String get clientsDeleteClient => 'Удалить клиента';

  @override
  String get clientsDuplicateEyebrow => 'Возможный дубль';

  @override
  String clientsDuplicateHeldBy(String agent, String name) {
    return 'Уже есть в агентстве: $name (агент $agent)';
  }

  @override
  String get clientsDuplicateHint =>
      'Сохранить всё равно можно. Сначала уточните у коллеги.';

  @override
  String get clientsDuplicateOpen => 'Открыть';

  @override
  String get clientsDuplicateSameBoth => 'Тот же телефон и email';

  @override
  String get clientsDuplicateSameEmail => 'Тот же email';

  @override
  String get clientsDuplicateSamePhone => 'Тот же телефон';

  @override
  String clientsDuplicateUnassigned(String name) {
    return 'Уже есть в агентстве: $name';
  }

  @override
  String get clientsEdit => 'Редактировать';

  @override
  String get clientsEditClient => 'Редактировать клиента';

  @override
  String get clientsEmail => 'Эл. почта';

  @override
  String get clientsFilterAll => 'Все';

  @override
  String get clientsFilterBuyers => 'Покупатели';

  @override
  String get clientsFilterNewLeads => 'Новые заявки';

  @override
  String get clientsFilterSellers => 'Продавцы';

  @override
  String clientsFilterTagsCount(Object count) {
    return 'Теги · $count';
  }

  @override
  String get clientsFilterSource => 'Источник';

  @override
  String get clientsFilterSourceAll => 'Все источники';

  @override
  String get clientsFollowUpCall => 'Записать этот звонок?';

  @override
  String get clientsFollowUpEmail => 'Записать это письмо?';

  @override
  String get clientsFollowUpHint =>
      'Одно нажатие — и запись в истории. Заметку можно не писать.';

  @override
  String get clientsFullName => 'Полное имя';

  @override
  String get clientsHistory => 'История';

  @override
  String get clientsHistoryEmpty => 'Контактов пока нет';

  @override
  String get clientsHistoryEmptyHint =>
      'Записывайте звонки, сообщения и письма — кто бы ни подхватил клиента, сразу поймёт, на чём остановились.';

  @override
  String get clientsHistoryLoadFailed => 'Не удалось загрузить историю';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Неверный email';

  @override
  String get clientsLogContact => 'Записать контакт';

  @override
  String get clientsLogFirstContact => 'Записать первый контакт';

  @override
  String get clientsMatches => 'Подходящие объекты';

  @override
  String get clientsMerge => 'Объединить с другой карточкой';

  @override
  String get clientsMergeConfirm => 'Объединить';

  @override
  String clientsMergeConfirmBody(String source, String target) {
    return 'Сделки, показы, история контактов и задачи клиента $source перейдут к $target. Пустые телефон, email и требования заполнятся, заметки добавятся. Затем карточка $source будет удалена. Отменить действие нельзя.';
  }

  @override
  String get clientsMergeConfirmTitle => 'Объединить в эту карточку?';

  @override
  String get clientsMergeNoCandidates => 'Нет других клиентов для объединения';

  @override
  String get clientsMergePickTitle => 'Какая карточка — тот же человек?';

  @override
  String get clientsMergeSearchHint => 'Поиск клиентов';

  @override
  String get clientsMessage => 'Написать';

  @override
  String get clientsMinArea => 'Площадь, минимум м²';

  @override
  String get clientsMinRooms => 'Комнат, минимум';

  @override
  String get clientsNameRequired => 'Укажите имя';

  @override
  String get clientsNewClient => 'Новый клиент';

  @override
  String get clientsNewLeadsEmpty =>
      'Здесь неделю видны покупатели, оставившие контакты по публичной ссылке на объект.';

  @override
  String get clientsNoClientsFound => 'Клиенты не найдены';

  @override
  String get clientsNoEmail => 'Эл. почта не указана';

  @override
  String get clientsNoMatches => 'Пока ничего подходящего нет';

  @override
  String get clientsNoPhone => 'Телефон не указан';

  @override
  String get clientsNoRequirements =>
      'Укажите, что ищет покупатель, и здесь появятся подходящие объекты';

  @override
  String get clientsNoWhatsApp =>
      'В карточке нет телефона, поэтому WhatsApp недоступен';

  @override
  String get clientsNotes => 'Заметки';

  @override
  String get clientsNotesHint => 'Дополнительные заметки об этом клиенте…';

  @override
  String get clientsOverBudget => 'Дороже бюджета';

  @override
  String get clientsPhone => 'Телефон';

  @override
  String get clientsRequirements => 'Что ищет';

  @override
  String get clientsRequirementsHint =>
      'Заполните — и приложение будет само показывать подходящие объекты.';

  @override
  String get clientsSearchHint => 'Поиск по имени, телефону…';

  @override
  String get clientsSeller => 'Продавец';

  @override
  String get clientsSendClosing =>
      'Напишите, какие хотите посмотреть, и я договорюсь о показе.';

  @override
  String get clientsSendFailed => 'Не удалось открыть отправку';

  @override
  String get clientsSendGreeting =>
      'Здравствуйте! Вот варианты, которые подходят под ваш запрос:';

  @override
  String get clientsSendLinks => 'Добавить ссылки';

  @override
  String get clientsSendLinksHint =>
      'Страница каждого объекта со всеми фото. Откроется в любом браузере.';

  @override
  String get clientsSendLogged => 'Сохранено в истории клиента';

  @override
  String get clientsSendMatches => 'Отправить подборку';

  @override
  String get clientsSendPhotos => 'Приложить фото';

  @override
  String get clientsSendPhotosHint =>
      'Фото уходят через «Поделиться». WhatsApp откроет чат только с текстом.';

  @override
  String clientsSendSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get clientsSendShare => 'Поделиться';

  @override
  String get clientsSendWhatsApp => 'WhatsApp';

  @override
  String clientsSentOn(String date) {
    return 'Отправляли $date';
  }

  @override
  String clientsShownOn(String date) {
    return 'Показывали $date';
  }

  @override
  String get clientsSourceImport => 'Из импорта';

  @override
  String get clientsSourceOpenHouse => 'С дня открытых дверей';

  @override
  String get clientsSourcePublicLink => 'С публичной ссылки';

  @override
  String get clientsTagAdd => 'Добавить тег';

  @override
  String get clientsTagAddHint => 'Добавить тег';

  @override
  String get clientsTagFilterClear => 'Сбросить теги';

  @override
  String get clientsTagFilterDone => 'Показать клиентов';

  @override
  String get clientsTagFilterEmpty =>
      'Пока ни у одного клиента нет тегов. Их добавляют в карточке клиента.';

  @override
  String get clientsTagFilterSubtitle =>
      'Клиенты, у которых есть все выбранные теги';

  @override
  String get clientsTagFilterTitle => 'Фильтр по тегам';

  @override
  String clientsTagLimit(Object count) {
    return 'Не больше $count тегов на клиента';
  }

  @override
  String clientsTagRemove(Object tag) {
    return 'Убрать тег $tag';
  }

  @override
  String get clientsTagSuggestions => 'Уже есть в агентстве';

  @override
  String clientsTagTooLong(Object count) {
    return 'Тег — не длиннее $count символов';
  }

  @override
  String get clientsTags => 'Теги';

  @override
  String get clientsTagsHint =>
      'Короткие метки, чтобы потом найти клиента: инвестор, срочно, VIP.';

  @override
  String clientsTagsMore(Object count) {
    return '+$count';
  }

  @override
  String get clientsLeadSource => 'Откуда пришёл';

  @override
  String get clientsLeadSourceNone => 'Не указано';

  @override
  String get clientsLeadSourceReferral => 'Рекомендация';

  @override
  String get clientsLeadSourceWebsite => 'Сайт';

  @override
  String get clientsLeadSourcePortal => 'Портал объявлений';

  @override
  String get clientsLeadSourceSocial => 'Соцсети';

  @override
  String get clientsLeadSourceWalkIn => 'Пришёл в офис';

  @override
  String get clientsLeadSourceColdCall => 'Холодный звонок';

  @override
  String get clientsLeadSourceRepeat => 'Повторный клиент';

  @override
  String get clientsLeadSourceOther => 'Другое';

  @override
  String get clientsLeadSourceDetail => 'Подробности';

  @override
  String get clientsLeadSourceDetailHint => 'Кто порекомендовал, какой портал';

  @override
  String get clientsTitle => 'Клиенты';

  @override
  String get clientsTryDifferentSearch => 'Попробуйте другой запрос';

  @override
  String get clientsUpdateClient => 'Обновить клиента';

  @override
  String clientsUpdatedAt(Object date) {
    return 'Обновлено $date';
  }

  @override
  String get clientsWantedCity => 'Город';

  @override
  String get clientsWantedType => 'Тип объекта';

  @override
  String get clientsWrite => 'WhatsApp или SMS';

  @override
  String get compareAction => 'Сравнить';

  @override
  String get compareAdd => 'Добавить к сравнению';

  @override
  String get compareAdded => 'Добавлено к сравнению';

  @override
  String compareBarButton(int count) {
    return 'Сравнить ($count)';
  }

  @override
  String get compareBestLegend => 'Зелёным отмечено лучшее значение в строке';

  @override
  String compareDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
      zero: 'Выставлен сегодня',
    );
    return '$_temp0';
  }

  @override
  String get compareExit => 'Готово';

  @override
  String get compareFirstFloor => 'первый этаж';

  @override
  String get compareFitMatches => 'Подходит под запрос';

  @override
  String get compareFitOutside => 'Вне запроса';

  @override
  String get compareFitOverBudget => 'Дороже бюджета';

  @override
  String get compareLastFloor => 'последний этаж';

  @override
  String get compareLimit =>
      'Сравнить можно до 4 объектов. Уберите один, чтобы добавить другой.';

  @override
  String get compareLinks => 'Добавить ссылки';

  @override
  String get compareLinksHint =>
      'Под каждым объектом — страница со всеми его фото.';

  @override
  String get compareNeedTwo => 'Выберите два объекта для сравнения';

  @override
  String get compareNeedTwoHint =>
      'Нажмите «Сравнить» на вкладке «Объекты» или добавьте объекты с их страниц.';

  @override
  String get comparePickHint => 'Выберите от двух до четырёх объектов';

  @override
  String get compareRemove => 'Убрать из сравнения';

  @override
  String get compareRemoved => 'Убрано из сравнения';

  @override
  String get compareRowAgent => 'Агент';

  @override
  String get compareRowArea => 'Площадь';

  @override
  String get compareRowDays => 'В продаже';

  @override
  String get compareRowFit => 'Для покупателя';

  @override
  String get compareRowFloor => 'Этаж';

  @override
  String get compareRowLinkViews => 'Просмотры ссылки';

  @override
  String get compareRowPlace => 'Адрес';

  @override
  String get compareRowPrice => 'Цена';

  @override
  String get compareRowPriceChange => 'Последнее изменение цены';

  @override
  String get compareRowPricePerSqm => 'Цена за м²';

  @override
  String get compareRowRooms => 'Комнаты';

  @override
  String get compareRowType => 'Тип';

  @override
  String get compareSelected => 'Сравнить выбранные';

  @override
  String get compareSend => 'Отправить сравнение';

  @override
  String get compareSendFailed => 'Не удалось открыть отправку';

  @override
  String compareShareBest(String title) {
    return 'Лучшая цена за м²: $title';
  }

  @override
  String get compareShareIntro => 'Сравнение объектов:';

  @override
  String get compareTitle => 'Сравнение';

  @override
  String get coreCall => 'Позвонить';

  @override
  String get coreCancel => 'Отмена';

  @override
  String get coreClientTypeBuyer => 'Покупатель';

  @override
  String get coreClientTypeSeller => 'Продавец';

  @override
  String get coreDataScopeAll => 'Все';

  @override
  String get coreDataScopeOwn => 'Свои';

  @override
  String get coreDataScopeTeam => 'Команда';

  @override
  String get coreDelete => 'Удалить';

  @override
  String get coreErrorBadRequest =>
      'Неверный запрос. Проверьте введённые данные.';

  @override
  String get coreErrorConflict => 'Такая запись уже существует.';

  @override
  String get coreErrorCredentials => 'Неверная почта или пароль.';

  @override
  String get coreErrorForbidden => 'У вас нет прав на это действие.';

  @override
  String get coreErrorNotFound => 'Не найдено.';

  @override
  String get coreErrorOffline => 'Нет связи с сервером. Проверьте интернет.';

  @override
  String get coreErrorOfflineWrite => 'Нет сети — для этого нужно подключение.';

  @override
  String get coreErrorServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get coreErrorTimeout => 'Время ожидания истекло. Проверьте интернет.';

  @override
  String get coreErrorUnknown => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get coreLogout => 'Выйти';

  @override
  String get coreNavAdmin => 'Администрирование';

  @override
  String get coreNavCalendar => 'Календарь';

  @override
  String get coreNavClients => 'Клиенты';

  @override
  String get coreNavDashboard => 'Панель';

  @override
  String get coreNavDeals => 'Сделки';

  @override
  String get coreNavProperties => 'Объекты';

  @override
  String get coreNavTeam => 'Команда';

  @override
  String get coreNoResults => 'Ничего не найдено';

  @override
  String get coreNotSelected => 'Не выбран';

  @override
  String coreOfflineSince(String time) {
    return 'Нет сети — данные на $time';
  }

  @override
  String get coreOpen => 'Открыть';

  @override
  String get corePropertyTypeApartment => 'Квартира';

  @override
  String get corePropertyTypeCommercial => 'Коммерция';

  @override
  String get corePropertyTypeHouse => 'Дом';

  @override
  String get corePropertyTypeLand => 'Участок';

  @override
  String get corePropertyTypeOffice => 'Офис';

  @override
  String get coreRetry => 'Повторить';

  @override
  String get coreRoleAdmin => 'Админ';

  @override
  String get coreRoleAgent => 'Агент';

  @override
  String get coreRoleManager => 'Менеджер';

  @override
  String get coreSave => 'Сохранить';

  @override
  String get coreStatusAvailable => 'Доступен';

  @override
  String get coreStatusLead => 'Лид';

  @override
  String get coreStatusLost => 'Проиграна';

  @override
  String get coreStatusNegotiation => 'Переговоры';

  @override
  String get coreStatusReserved => 'Забронирован';

  @override
  String get coreStatusSold => 'Продан';

  @override
  String get coreStatusWon => 'Выиграна';

  @override
  String get dashboardActiveDealsLabel => 'Активных сделок';

  @override
  String dashboardAgentDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сделок',
      few: '$count сделки',
      one: '1 сделка',
    );
    return '$_temp0';
  }

  @override
  String dashboardAgentMeta(Object name) {
    return 'агент: $name';
  }

  @override
  String get dashboardAttention => 'Требует внимания';

  @override
  String get dashboardClients => 'Клиенты';

  @override
  String get dashboardClosedWon => 'Успешно закрыто';

  @override
  String dashboardColdTotal(int count) {
    return 'всего $count';
  }

  @override
  String get dashboardConversion => 'Конверсия';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · сводка команды';
  }

  @override
  String get dashboardDatesTitle => 'Даты на этой неделе';

  @override
  String dashboardDatesTotal(int count) {
    return '$count на неделе';
  }

  @override
  String dashboardGreeting(Object greeting, Object name) {
    return '$greeting, $name';
  }

  @override
  String get dashboardGreetingAfternoon => 'Добрый день';

  @override
  String get dashboardGreetingEvening => 'Добрый вечер';

  @override
  String get dashboardGreetingFallbackName => 'друг';

  @override
  String get dashboardGreetingMorning => 'Доброе утро';

  @override
  String get dashboardGreetingStillUp => 'Ещё не спите';

  @override
  String dashboardIdleDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'без движения $count дней',
      few: 'без движения $count дня',
      one: 'без движения 1 день',
    );
    return '$_temp0';
  }

  @override
  String get dashboardLeaderboard => 'Лучшие агенты';

  @override
  String dashboardLoadTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count встреч',
      few: '$count встречи',
      one: '1 встреча',
      zero: 'ничего не назначено',
    );
    return '$_temp0';
  }

  @override
  String dashboardMandatesTotal(int count) {
    return 'всего $count';
  }

  @override
  String get dashboardMeetingLoad => 'Ближайшие две недели';

  @override
  String get dashboardMeetingsLabel => 'Встречи';

  @override
  String get dashboardNewDeal => 'Новая сделка';

  @override
  String get dashboardNextMeeting => 'Ближайшая встреча';

  @override
  String get dashboardNoDealsYet => 'Сделок пока нет';

  @override
  String get dashboardNoDealsYetHint =>
      'Здесь появится воронка, как только вы добавите сделку';

  @override
  String get dashboardNoMoreMeetingsToday => 'На сегодня встреч больше нет';

  @override
  String get dashboardNoPhone => 'У клиента не указан телефон';

  @override
  String get dashboardNoUpcomingMeetings => 'Нет предстоящих встреч';

  @override
  String get dashboardNothingScheduled => 'Встреч не запланировано';

  @override
  String get dashboardNothingScheduledHint =>
      'Назначьте встречу — она появится здесь';

  @override
  String dashboardRelativeInHours(Object count) {
    return 'через $count ч';
  }

  @override
  String dashboardRelativeInMinutes(Object count) {
    return 'через $count мин';
  }

  @override
  String get dashboardRelativeNow => 'сейчас';

  @override
  String get dashboardRelativeToday => 'сегодня';

  @override
  String get dashboardRelativeTomorrow => 'завтра';

  @override
  String get dashboardScheduleMeeting => 'Запланировать встречу';

  @override
  String get dashboardSeeAll => 'Все';

  @override
  String get dashboardTasksClear => 'На сегодня задач нет';

  @override
  String dashboardTasksOverdueCount(Object count) {
    return 'Просрочено: $count';
  }

  @override
  String get dashboardTasksToday => 'Сделать сегодня';

  @override
  String get dashboardTeamPipeline => 'Воронка команды';

  @override
  String get dashboardToday => 'Сегодня';

  @override
  String dashboardTodayCount(Object count) {
    return '$count сегодня';
  }

  @override
  String get dashboardTopAgents => 'Лучшие агенты';

  @override
  String get dashboardUpcomingMeetings => 'Предстоящие встречи';

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
      'Удерживайте карточку, чтобы перенести её на другой этап';

  @override
  String get dealsBoardStageEmpty => 'На этом этапе пусто';

  @override
  String get dealsBudget => 'Бюджет';

  @override
  String dealsBudgetValue(Object price) {
    return 'Бюджет: $price';
  }

  @override
  String get dealsChecklistAdd => 'Добавить пункт';

  @override
  String get dealsChecklistAddTitle => 'Новый пункт чек-листа';

  @override
  String get dealsChecklistAttach => 'Прикрепить документ';

  @override
  String dealsChecklistBadge(int done, int total) {
    return 'Чек-лист: выполнено $done из $total';
  }

  @override
  String get dealsChecklistDelete => 'Удалить пункт';

  @override
  String get dealsChecklistDeleteBody =>
      'Пункт исчезнет из чек-листа этой сделки.';

  @override
  String get dealsChecklistDeleteTitle => 'Удалить этот пункт?';

  @override
  String get dealsChecklistDetach => 'Открепить документ';

  @override
  String dealsChecklistDoneAt(String date) {
    return 'Выполнено $date';
  }

  @override
  String dealsChecklistDoneBy(String date, String name) {
    return '$name · $date';
  }

  @override
  String get dealsChecklistEmptyStage =>
      'На этом этапе ничего собирать не нужно';

  @override
  String dealsChecklistGateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count обязательного пункта ещё не выполнены. Всё равно перевести сделку?',
      many:
          '$count обязательных пунктов ещё не выполнены. Всё равно перевести сделку?',
      few:
          '$count обязательных пункта ещё не выполнены. Всё равно перевести сделку?',
      one:
          '$count обязательный пункт ещё не выполнен. Всё равно перевести сделку?',
    );
    return '$_temp0';
  }

  @override
  String get dealsChecklistGateConfirm => 'Всё равно перевести';

  @override
  String get dealsChecklistGateTitle => 'Не всё обязательное собрано';

  @override
  String get dealsChecklistItemHint => 'Например, копия паспорта';

  @override
  String get dealsChecklistItemLabel => 'Что нужно';

  @override
  String get dealsChecklistLoadFailed => 'Не удалось загрузить чек-лист';

  @override
  String get dealsChecklistMore => 'Действия с пунктом';

  @override
  String get dealsChecklistNoDocuments =>
      'У сделки пока нет документов. Сначала загрузите файл в разделе «Документы».';

  @override
  String get dealsChecklistPickDocument => 'Выберите документ';

  @override
  String dealsChecklistProgress(int done, int total) {
    return 'Выполнено $done из $total';
  }

  @override
  String get dealsChecklistRequired => 'Обязательно';

  @override
  String get dealsChecklistRequiredHint =>
      'Приложение предупредит, если сделку переводят дальше без него';

  @override
  String get dealsChecklistStage => 'Этап';

  @override
  String get dealsChecklistTitle => 'Чек-лист';

  @override
  String get dealsClient => 'Клиент';

  @override
  String dealsClientRef(Object id) {
    return 'Клиент №$id';
  }

  @override
  String dealsCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
    );
    return '$_temp0';
  }

  @override
  String get dealsCommentDelete => 'Удалить комментарий';

  @override
  String get dealsCommentDeleteBody =>
      'Он исчезнет у всех, кто работает со сделкой.';

  @override
  String get dealsCommentDeleteTitle => 'Удалить этот комментарий?';

  @override
  String get dealsCommentEdit => 'Изменить комментарий';

  @override
  String get dealsCommentEdited => 'изменено';

  @override
  String get dealsCommentHint => 'Напишите комментарий…';

  @override
  String get dealsCommentJustNow => 'только что';

  @override
  String get dealsCommentLess => 'Свернуть';

  @override
  String get dealsCommentMentionLoadFailed => 'Не удалось загрузить коллег';

  @override
  String get dealsCommentMentionNone => 'Кроме вас, эту сделку никто не видит';

  @override
  String get dealsCommentMentionNotAllowed =>
      'Упомянуть можно только коллег, которые видят эту сделку';

  @override
  String get dealsCommentMentionTitle => 'Упомянуть коллегу';

  @override
  String get dealsCommentMore => 'Показать полностью';

  @override
  String get dealsCommentSend => 'Отправить';

  @override
  String get dealsCommentSending => 'Отправляется…';

  @override
  String get dealsCommission => 'Комиссия';

  @override
  String get dealsCommissionAmount => 'Сумма';

  @override
  String get dealsCommissionInvalid => 'Укажите ставку больше 0 и не выше 100';

  @override
  String get dealsCommissionNeedsPrice =>
      'Укажите цену сделки, и сумма посчитается';

  @override
  String get dealsCommissionPercent => 'Комиссия, %';

  @override
  String get dealsCommissionRate => 'Ставка';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active активных · $total';
  }

  @override
  String get dealsCreateDeal => 'Создать сделку';

  @override
  String get dealsDealPrice => 'Цена сделки';

  @override
  String dealsDeleteCascade(Object title) {
    return '«$title» будет удалена безвозвратно. Отменить действие нельзя.';
  }

  @override
  String get dealsDeleteTitle => 'Удалить сделку';

  @override
  String get dealsDiscussion => 'Обсуждение';

  @override
  String get dealsDiscussionEmpty => 'Комментариев пока нет';

  @override
  String get dealsDiscussionEmptyHint =>
      'Обсуждайте сделку здесь, а не в мессенджере. Наберите @, чтобы позвать коллегу.';

  @override
  String get dealsDiscussionLoadFailed => 'Не удалось загрузить обсуждение';

  @override
  String get dealsDiscussionShowEarlier => 'Показать предыдущие';

  @override
  String get dealsEditTitle => 'Редактировать сделку';

  @override
  String get dealsEmptySubtitle => 'Начните свою воронку продаж';

  @override
  String get dealsEmptyTitle => 'Нет сделок';

  @override
  String get dealsFallbackTitle => 'Сделка';

  @override
  String get dealsFilterAll => 'Все';

  @override
  String dealsFilterWithCount(Object count, Object label) {
    return '$label $count';
  }

  @override
  String get dealsFinancials => 'Финансы';

  @override
  String get dealsIdCopied => 'ID сделки скопирован';

  @override
  String dealsIdLabel(Object id) {
    return 'ID сделки: $id';
  }

  @override
  String get dealsLostConfirm => 'Отметить как проигранную';

  @override
  String get dealsLostNote => 'Комментарий';

  @override
  String get dealsLostNoteHint => 'Что произошло — пригодится в следующий раз';

  @override
  String get dealsLostReason => 'Причина проигрыша';

  @override
  String get dealsLostReasonChangedMind => 'Передумал';

  @override
  String get dealsLostReasonChoseAnother => 'Выбрал другой вариант';

  @override
  String get dealsLostReasonFinancing => 'Не получилось с финансированием';

  @override
  String get dealsLostReasonNoResponse => 'Перестал выходить на связь';

  @override
  String get dealsLostReasonOther => 'Другое';

  @override
  String get dealsLostReasonPrice => 'Цена';

  @override
  String get dealsLostReasonUnspecified => 'Не указана';

  @override
  String get dealsLostSheetSubtitle =>
      'Выберите причину — она попадёт в воронку в аналитике.';

  @override
  String get dealsLostSheetTitle => 'Почему сделка сорвалась?';

  @override
  String get dealsNewTitle => 'Новая сделка';

  @override
  String get dealsNoResults => 'Ничего не найдено';

  @override
  String get dealsNoResultsSubtitle => 'Измените фильтр этапа';

  @override
  String get dealsNotFound => 'Сделка не найдена';

  @override
  String get dealsNotes => 'Заметки';

  @override
  String get dealsNotesHint => 'Заметки об этой сделке…';

  @override
  String get dealsPeopleProperty => 'Люди и объект';

  @override
  String get dealsPipelineStage => 'Этап воронки';

  @override
  String get dealsProperty => 'Объект';

  @override
  String dealsPropertyRef(Object id) {
    return 'Объект №$id';
  }

  @override
  String get dealsSearchHint => 'Поиск по имени или ID…';

  @override
  String get dealsSelectAgentError => 'Пожалуйста, выберите агента';

  @override
  String get dealsSelectClientError => 'Пожалуйста, выберите клиента';

  @override
  String dealsSelectLabel(Object label) {
    return 'Выберите $label';
  }

  @override
  String dealsStaleWarning(Object days) {
    return 'нет активности $days дней';
  }

  @override
  String get dealsTimeline => 'Хронология';

  @override
  String get dealsTimelineClosed => 'Сделка закрыта';

  @override
  String get dealsTimelineCreated => 'Создана';

  @override
  String get dealsTimelineUpdated => 'Обновлена';

  @override
  String get dealsTitle => 'Сделки';

  @override
  String get dealsTitleLabel => 'Название';

  @override
  String get dealsTitleRequired => 'Название обязательно';

  @override
  String get dealsUpdateDeal => 'Обновить сделку';

  @override
  String get dealsViewBoard => 'Доска';

  @override
  String get dealsViewList => 'Список';

  @override
  String get depositsAmount => 'Сумма';

  @override
  String get depositsAmountHint => 'например, 500 000';

  @override
  String get depositsCloseAction => 'Закрыть задаток';

  @override
  String get depositsCloseTitle => 'Чем закончился задаток?';

  @override
  String get depositsClosedBeforeReceived =>
      'Задаток не может закончиться раньше, чем получен';

  @override
  String get depositsClosedOn => 'Дата';

  @override
  String get depositsDealClosedHint => 'Сделка закрыта, задаток уже не внести.';

  @override
  String get depositsEdit => 'Изменить';

  @override
  String get depositsEditTitle => 'Изменить задаток';

  @override
  String get depositsEndingEmpty => 'Истекающих задатков нет';

  @override
  String get depositsEndingEmptyHint =>
      'Активные задатки появятся здесь за неделю до конца брони.';

  @override
  String get depositsEndingLoadFailed => 'Не удалось загрузить задатки';

  @override
  String get depositsEndingTitle => 'Истекающие задатки';

  @override
  String get depositsHistory => 'Прежние задатки';

  @override
  String get depositsHoldBeforeReceived =>
      'Бронь не может закончиться раньше, чем получен задаток';

  @override
  String depositsHoldEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бронь истекла $count дня назад',
      many: 'Бронь истекла $count дней назад',
      few: 'Бронь истекла $count дня назад',
      one: 'Бронь истекла $count день назад',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndedYesterday => 'Бронь истекла вчера';

  @override
  String depositsHoldEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Бронь истекает через $count дня',
      many: 'Бронь истекает через $count дней',
      few: 'Бронь истекает через $count дня',
      one: 'Бронь истекает через $count день',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndsToday => 'Бронь истекает сегодня';

  @override
  String get depositsHoldEndsTomorrow => 'Бронь истекает завтра';

  @override
  String get depositsHoldUntil => 'Бронь до';

  @override
  String get depositsHolder => 'Хранится у';

  @override
  String get depositsHolderAgency => 'Агентство';

  @override
  String get depositsHolderNotary => 'Нотариус';

  @override
  String get depositsHolderSeller => 'Продавец';

  @override
  String get depositsLoadFailed => 'Не удалось загрузить задаток';

  @override
  String get depositsNone => 'Задаток не внесён';

  @override
  String get depositsNoneHint =>
      'Запишите, когда покупатель внесёт деньги, и объект будет отмечен как забронированный.';

  @override
  String get depositsNote => 'Заметка';

  @override
  String get depositsNoteHint => 'Номер расписки, условия';

  @override
  String get depositsOutcomeApplied => 'Зачтён в счёт покупки';

  @override
  String get depositsOutcomeForfeited => 'Удержан';

  @override
  String get depositsOutcomeRefunded => 'Возвращён';

  @override
  String get depositsReceivedOn => 'Получен';

  @override
  String get depositsRecord => 'Внести задаток';

  @override
  String get depositsRecordTitle => 'Новый задаток';

  @override
  String depositsReservedUntil(String date) {
    return 'Бронь до $date';
  }

  @override
  String get depositsTitle => 'Задаток';

  @override
  String get documentsAdd => 'Прикрепить файл';

  @override
  String documentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов',
      few: '$count файла',
      one: '1 файл',
      zero: 'Нет файлов',
    );
    return '$_temp0';
  }

  @override
  String documentsDeleteConfirm(Object name) {
    return '$name будет удалён из сделки. Это действие необратимо.';
  }

  @override
  String get documentsDeleteTitle => 'Удалить документ';

  @override
  String get documentsEmpty => 'К этой сделке пока не прикреплён ни один файл';

  @override
  String get documentsNoApp =>
      'На этом телефоне нет приложения, которое откроет такой файл';

  @override
  String get documentsOpenFailed => 'Не удалось открыть файл';

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
  String get documentsTitle => 'Документы';

  @override
  String documentsTooLarge(Object limit) {
    return 'Файлы больше $limit МБ прикрепить нельзя';
  }

  @override
  String documentsUploadedBy(Object name) {
    return 'Добавил: $name';
  }

  @override
  String get documentsUploading => 'Отправляем…';

  @override
  String get exportAction => 'Экспорт';

  @override
  String get exportAllNote => 'Всё, что вам доступно, без фильтров.';

  @override
  String get exportConfirm => 'Выгрузить CSV';

  @override
  String get exportConsoleSubtitle =>
      'Данные агентства в таблицах: для владельца, бухгалтерии или просто себе на всякий случай.';

  @override
  String get exportConsoleTitle => 'Экспорт';

  @override
  String get exportDelimiter => 'Разделитель';

  @override
  String get exportDelimiterComma => 'Запятая';

  @override
  String get exportDelimiterHint =>
      'Excel на русском и казахском делит столбцы по точке с запятой, на английском — по запятой.';

  @override
  String get exportDelimiterSemicolon => 'Точка с запятой';

  @override
  String get exportFailed => 'Не удалось выгрузить. Попробуйте ещё раз.';

  @override
  String get exportFiltersNote =>
      'Только то, что сейчас в списке, с учётом фильтров.';

  @override
  String get exportFormatNote =>
      'Файл CSV: открывается в Excel, Google Таблицах и Numbers, а в CRM импортируется обратно без правок.';

  @override
  String get exportKindClients => 'Клиенты';

  @override
  String get exportKindDeals => 'Сделки';

  @override
  String get exportKindProperties => 'Объекты';

  @override
  String get exportPersonalData =>
      'Содержит персональные данные: имена, телефоны и почту. Обращайтесь бережно и не передавайте дальше, чем нужно.';

  @override
  String get exportTitleClients => 'Экспорт клиентов';

  @override
  String get exportTitleDeals => 'Экспорт сделок';

  @override
  String get exportTitleProperties => 'Экспорт объектов';

  @override
  String get exportTooMany =>
      'Слишком много строк для одного файла. Сузьте фильтры и выгрузите частями.';

  @override
  String get goalsAgency => 'Всё агентство';

  @override
  String get goalsAgentOwn => 'Цель агента';

  @override
  String get goalsCardTitle => 'Цель на месяц';

  @override
  String get goalsCommissionLabel => 'Комиссия';

  @override
  String goalsCommissionOf(String achieved, String target) {
    return '$achieved из $target';
  }

  @override
  String goalsCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скопировано $count цели',
      many: 'Скопировано $count целей',
      few: 'Скопировано $count цели',
      one: 'Скопирована $count цель',
      zero: 'Копировать из прошлого месяца нечего',
    );
    return '$_temp0';
  }

  @override
  String get goalsCopyPrevious => 'Скопировать цели прошлого месяца';

  @override
  String goalsDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count дня',
      many: 'Осталось $count дней',
      few: 'Осталось $count дня',
      one: 'Остался $count день',
      zero: 'Месяц закончился',
    );
    return '$_temp0';
  }

  @override
  String goalsDealEvery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'по сделке каждые $count дня',
      many: 'по сделке каждые $count дней',
      few: 'по сделке каждые $count дня',
      one: 'по сделке каждый $count день',
    );
    return '$_temp0';
  }

  @override
  String get goalsDealsLabel => 'Выигранные сделки';

  @override
  String goalsDealsOf(int won, int target) {
    return 'Выиграно сделок: $won из $target';
  }

  @override
  String goalsDealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сделки в день',
      many: '$count сделок в день',
      few: '$count сделки в день',
      one: '$count сделка в день',
    );
    return '$_temp0';
  }

  @override
  String goalsDealsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выиграно $count сделки',
      many: 'Выиграно $count сделок',
      few: 'Выиграно $count сделки',
      one: 'Выиграна $count сделка',
      zero: 'Выигранных сделок пока нет',
    );
    return '$_temp0';
  }

  @override
  String get goalsEyebrow => 'ЦЕЛЬ';

  @override
  String get goalsFieldHint => 'Оставьте пустым, если не нужно';

  @override
  String get goalsInvalidCommission => 'Введите сумму больше нуля';

  @override
  String get goalsInvalidDeals => 'Введите целое число от 1 до 1000';

  @override
  String get goalsLoadFailed => 'Не удалось загрузить цели';

  @override
  String get goalsManagerSet => 'Поставлена руководителем';

  @override
  String get goalsMonthOver =>
      'Этот месяц закончился, его цели остаются как были.';

  @override
  String get goalsNeedOne => 'Укажите комиссию, число сделок или и то и другое';

  @override
  String get goalsNextMonth => 'Следующий месяц';

  @override
  String get goalsNoTarget => 'Без цели';

  @override
  String get goalsNone => 'Цели на этот месяц пока нет';

  @override
  String get goalsNoneHint =>
      'Нажмите, чтобы поставить свою. Если цель поставит руководитель, считается его.';

  @override
  String get goalsOwn => 'Ваша собственная цель';

  @override
  String goalsPerDay(String amount) {
    return '$amount в день';
  }

  @override
  String get goalsPreviousMonth => 'Предыдущий месяц';

  @override
  String get goalsReached => 'Цель достигнута. Всё дальше — сверх плана.';

  @override
  String get goalsRemove => 'Убрать цель';

  @override
  String get goalsRemoved => 'Цель убрана';

  @override
  String get goalsSaved => 'Цель сохранена';

  @override
  String goalsSheetFor(String name) {
    return 'Цель: $name';
  }

  @override
  String get goalsSheetHint =>
      'Считаются сделки, выигранные в этом месяце, и комиссия по ним.';

  @override
  String get goalsSheetOwnHint =>
      'Если руководитель поставит вам цель, она заменит вашу.';

  @override
  String get goalsSheetTitle => 'Цель на месяц';

  @override
  String get goalsTeamEmpty => 'В агентстве пока никого нет';

  @override
  String get goalsTeamHint => 'Цели для каждого агента и агентства';

  @override
  String get goalsTeamIntro =>
      'Цель для каждого агента и для всего агентства. Прогресс считается по сделкам, выигранным за месяц, и комиссии по ним. Ваша цель заменяет ту, что агент поставил себе сам.';

  @override
  String get goalsTeamOverrideHint =>
      'Ваша цель заменит ту, что агент поставил себе сам.';

  @override
  String get goalsTeamTitle => 'Цели на месяц';

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировать $count строки',
      many: 'Импортировать $count строк',
      few: 'Импортировать $count строки',
      one: 'Импортировать $count строку',
    );
    return '$_temp0';
  }

  @override
  String get importAnother => 'Импортировать другой файл';

  @override
  String get importAssignTo => 'Ответственный';

  @override
  String get importAssignToMe => 'Я';

  @override
  String get importChooseFile => 'Выбрать CSV-файл';

  @override
  String get importColumns => 'Столбцы';

  @override
  String get importColumnsHint =>
      'Проверьте, какое поле заполняет каждый столбец. Столбцы с пометкой «Пропустить» не импортируются.';

  @override
  String get importCreated => 'Создано';

  @override
  String get importDoneTitle => 'Импорт завершён';

  @override
  String get importDownloadTemplate => 'Скачать шаблон';

  @override
  String importDuplicateOfClient(String name) {
    return 'Уже есть в агентстве: $name';
  }

  @override
  String importDuplicateOfRow(int row) {
    return 'Совпадает со строкой $row';
  }

  @override
  String get importEmptyFile => 'Файл пустой';

  @override
  String get importEntrySubtitle => 'Клиенты и объекты из Excel или другой CRM';

  @override
  String get importErrorInvalidDate => 'Не дата';

  @override
  String get importErrorInvalidEmail => 'Неверный email';

  @override
  String get importErrorInvalidNumber => 'Не число';

  @override
  String get importErrorInvalidPhone => 'Неверный телефон';

  @override
  String get importErrorNegative => 'Должно быть больше нуля';

  @override
  String get importErrorOutOfRange => 'Вне допустимого диапазона';

  @override
  String get importErrorRequired => 'Обязательное поле';

  @override
  String get importErrorTooLong => 'Слишком длинно';

  @override
  String get importErrorUnknownValue => 'Неизвестное значение';

  @override
  String get importFieldAddress => 'Адрес';

  @override
  String get importFieldArea => 'Площадь';

  @override
  String get importFieldBirthday => 'День рождения';

  @override
  String get importFieldBudgetMax => 'Бюджет до';

  @override
  String get importFieldBudgetMin => 'Бюджет от';

  @override
  String get importFieldCity => 'Город';

  @override
  String get importFieldClientType => 'Тип клиента';

  @override
  String get importFieldDescription => 'Описание';

  @override
  String get importFieldEmail => 'Email';

  @override
  String get importFieldFloor => 'Этаж';

  @override
  String get importFieldFullName => 'ФИО';

  @override
  String get importFieldMinArea => 'Площадь от';

  @override
  String get importFieldMinRooms => 'Комнат от';

  @override
  String get importFieldNotes => 'Примечание';

  @override
  String get importFieldPhone => 'Телефон';

  @override
  String get importFieldPrice => 'Цена';

  @override
  String get importFieldPropertyType => 'Тип объекта';

  @override
  String get importFieldRooms => 'Комнаты';

  @override
  String get importFieldStatus => 'Статус';

  @override
  String get importFieldTags => 'Теги';

  @override
  String get importFieldLeadSource => 'Источник лида';

  @override
  String get importFieldLeadSourceDetail => 'Источник лида: подробности';

  @override
  String get importFieldTitle => 'Название';

  @override
  String get importFieldTotalFloors => 'Этажность';

  @override
  String get importFieldWantedCity => 'Желаемый город';

  @override
  String get importFieldWantedType => 'Желаемый тип объекта';

  @override
  String get importFileTooLarge => 'Файл больше 5 МБ. Разделите его на части.';

  @override
  String get importHowTo =>
      'Сохраните таблицу в CSV в Excel или Google Таблицах. Подойдут запятые, точки с запятой и табуляция, а также файлы на кириллице из русского Excel.';

  @override
  String get importInvalid => 'Не импортировано из-за ошибок';

  @override
  String get importKindClients => 'Клиенты';

  @override
  String get importKindClientsHint => 'Имена, телефоны, что ищут';

  @override
  String get importKindProperties => 'Объекты';

  @override
  String get importKindPropertiesHint => 'Адреса, цены, площади, комнаты';

  @override
  String importMissingRequired(String field) {
    return 'Выберите столбец для поля «$field»';
  }

  @override
  String get importNoAgents => 'Коллеги не найдены';

  @override
  String get importNoProblems => 'Все строки готовы к импорту';

  @override
  String get importNotCsv =>
      'Выберите файл .csv. В Excel: Файл, Сохранить как, CSV.';

  @override
  String get importNothingToImport => 'Нечего импортировать';

  @override
  String get importOpenClients => 'Открыть клиентов';

  @override
  String get importOpenProperties => 'Открыть объекты';

  @override
  String get importOptions => 'Параметры';

  @override
  String get importPickAgentSearch => 'Поиск по имени';

  @override
  String get importProblems => 'Строки, требующие внимания';

  @override
  String get importProblemsTruncated => 'Показаны только первые 1000';

  @override
  String importRowLabel(int row) {
    return 'Строка $row';
  }

  @override
  String importRowsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строки в файле',
      many: '$count строк в файле',
      few: '$count строки в файле',
      one: '$count строка в файле',
    );
    return '$_temp0';
  }

  @override
  String get importShowMore => 'Показать ещё';

  @override
  String get importSkipColumn => 'Пропустить';

  @override
  String get importSkipDuplicates => 'Пропускать дубликаты';

  @override
  String get importSkipDuplicatesHint =>
      'Клиент с email, который уже есть в агентстве, пропускается всегда';

  @override
  String get importSkipped => 'Пропущено дубликатов';

  @override
  String get importSummaryDuplicates => 'Дубликаты';

  @override
  String get importSummaryInvalid => 'С ошибками';

  @override
  String get importSummaryValid => 'Готово';

  @override
  String get importTemplateFailed => 'Не удалось подготовить шаблон';

  @override
  String get importTitle => 'Импорт из таблицы';

  @override
  String get importTooManyRows =>
      'В файле больше 5000 строк. Разделите его на части.';

  @override
  String get leaderboardDealsLost => 'Проиграно сделок';

  @override
  String get leaderboardEmptyBody =>
      'Здесь появятся агенты, которые вступят в агентство.';

  @override
  String get leaderboardEmptyTitle => 'Пока нет агентов';

  @override
  String get leaderboardHint => 'Сделки, комиссия и показы по каждому агенту';

  @override
  String get leaderboardInactive => 'Деактивированы';

  @override
  String get leaderboardInactiveNote =>
      'Деактивированные сотрудники не участвуют в общем рейтинге. Удалённых из агентства здесь нет: их записи перешли к коллеге.';

  @override
  String get leaderboardLoadFailed => 'Не удалось загрузить рейтинг';

  @override
  String get leaderboardNoValue => '—';

  @override
  String get leaderboardPeriodCustom => 'Даты';

  @override
  String get leaderboardPeriodLastMonth => 'Прошлый месяц';

  @override
  String get leaderboardPeriodQuarter => 'Квартал';

  @override
  String get leaderboardPeriodThisMonth => 'Этот месяц';

  @override
  String get leaderboardPickRange => 'Выберите даты';

  @override
  String leaderboardRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get leaderboardSortCommission => 'Комиссия';

  @override
  String get leaderboardSortDealsWon => 'Выиграно сделок';

  @override
  String get leaderboardSortNewClients => 'Новые клиенты';

  @override
  String get leaderboardSortViewings => 'Показы';

  @override
  String get leaderboardSortWinRate => 'Конверсия';

  @override
  String leaderboardSummary(int won, int viewings, int clients) {
    return 'Сделки $won · Показы $viewings · Клиенты $clients';
  }

  @override
  String get leaderboardTeamCommission => 'Комиссия агентства';

  @override
  String get leaderboardTitle => 'Рейтинг агентов';

  @override
  String get leaderboardWonValue => 'Сумма выигранных';

  @override
  String get lockAppLock => 'Блокировка приложения';

  @override
  String get lockAppLockHint => 'Запрашивать PIN-код при входе';

  @override
  String get lockAutoLock => 'Блокировать через';

  @override
  String get lockAutoLockFifteenMinutes => '15 минут в фоне';

  @override
  String get lockAutoLockFiveMinutes => '5 минут в фоне';

  @override
  String get lockAutoLockImmediately => 'Сразу';

  @override
  String get lockAutoLockOneMinute => '1 минуту в фоне';

  @override
  String get lockAutoLockTitle => 'Когда блокировать приложение';

  @override
  String get lockCancel => 'Отмена';

  @override
  String get lockChangePin => 'Сменить PIN-код';

  @override
  String get lockConfirmPinTitle => 'Повторите PIN-код';

  @override
  String get lockContinue => 'Продолжить';

  @override
  String get lockCurrentPinTitle => 'Введите текущий PIN-код';

  @override
  String get lockDelete => 'Стереть';

  @override
  String get lockDigitsHint => 'От 4 до 6 цифр';

  @override
  String get lockEnterPin => 'Введите PIN-код';

  @override
  String get lockForgotPin => 'Забыли PIN-код?';

  @override
  String get lockForgotPinBody =>
      'При выходе PIN-код и сохранённые на телефоне данные клиентов будут удалены. Затем войдите снова с паролем.';

  @override
  String get lockMismatch => 'PIN-коды не совпадают. Попробуйте ещё раз.';

  @override
  String get lockNewPinTitle => 'Придумайте PIN-код';

  @override
  String get lockPinChanged => 'PIN-код изменён';

  @override
  String lockRetryIn(String time) {
    return 'Слишком много попыток. Повторите через $time';
  }

  @override
  String get lockSecurity => 'Безопасность';

  @override
  String get lockSignOutAgain => 'Выйти и войти заново';

  @override
  String get lockTooManyAttempts =>
      'Слишком много неверных PIN-кодов. Выйдите и войдите снова с паролем.';

  @override
  String get lockTooShort => 'PIN-код должен содержать от 4 до 6 цифр.';

  @override
  String get lockTurnOn => 'Включить';

  @override
  String get lockTurnedOff => 'Блокировка выключена';

  @override
  String get lockTurnedOn => 'Блокировка включена';

  @override
  String get lockWrongPin => 'Неверный PIN-код';

  @override
  String get meetingsAgendaHint => 'Повестка встречи, темы для обсуждения…';

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
      other: '$count на этой неделе',
      many: '$count на этой неделе',
      few: '$count на этой неделе',
      one: '1 на этой неделе',
    );
    return '$_temp0';
  }

  @override
  String get meetingsDate => 'Дата';

  @override
  String get meetingsDeal => 'Сделка';

  @override
  String meetingsDealNumber(Object id) {
    return 'Сделка №$id';
  }

  @override
  String get meetingsDelete => 'Удалить';

  @override
  String meetingsDeleteCascade(Object title) {
    return '«$title» будет удалена безвозвратно. Отменить действие нельзя.';
  }

  @override
  String get meetingsDeleteMeeting => 'Удалить встречу';

  @override
  String get meetingsDescription => 'Описание';

  @override
  String get meetingsDetails => 'Детали';

  @override
  String get meetingsDirections => 'Маршрут';

  @override
  String get meetingsEdit => 'Редактировать';

  @override
  String get meetingsEditMeeting => 'Редактировать встречу';

  @override
  String get meetingsGroupToday => 'Сегодня';

  @override
  String get meetingsGroupTomorrow => 'Завтра';

  @override
  String get meetingsLocation => 'Место';

  @override
  String get meetingsMustBeInFuture => 'Выберите время в будущем';

  @override
  String get meetingsNoAgentsToAssign => 'Некого назначить';

  @override
  String get meetingsNoLocation => 'У встречи не указано место';

  @override
  String get meetingsNoMeetings => 'Нет встреч';

  @override
  String get meetingsNote => 'Заметка к встрече';

  @override
  String get meetingsNothingUpcoming => 'Предстоящих встреч нет';

  @override
  String get meetingsNothingUpcomingSubtitle =>
      'Прошедшие встречи остаются в истории.';

  @override
  String get meetingsOutcome => 'Как прошло';

  @override
  String get meetingsOutcomeInterested => 'Заинтересовался';

  @override
  String get meetingsOutcomeNoShow => 'Не пришёл';

  @override
  String get meetingsOutcomeNote => 'Что сказал';

  @override
  String get meetingsOutcomeNoteHint => 'Тёмная, шумная дорога…';

  @override
  String get meetingsOutcomeRejected => 'Отказался';

  @override
  String get meetingsOutcomeRejectedHint =>
      'Забракованный объект больше не предлагается этому покупателю';

  @override
  String get meetingsOutcomeSave => 'Сохранить';

  @override
  String get meetingsPleaseSelectAgent => 'Пожалуйста, выберите агента';

  @override
  String get meetingsPleaseSelectClient => 'Пожалуйста, выберите клиента';

  @override
  String get meetingsPleaseSelectDateTime =>
      'Пожалуйста, выберите дату и время';

  @override
  String get meetingsProperty => 'Объект';

  @override
  String get meetingsSchedule => 'Запланировать';

  @override
  String get meetingsScheduleFirst => 'Запланируйте свою первую встречу';

  @override
  String get meetingsScheduleMeeting => 'Запланировать встречу';

  @override
  String get meetingsScheduleViewing => 'Записать показ';

  @override
  String get meetingsSearchByNameOrId => 'Поиск по имени или ID…';

  @override
  String meetingsSelectEntity(Object label) {
    return 'Выберите $label';
  }

  @override
  String get meetingsStatus => 'Статус';

  @override
  String get meetingsStatusHeld => 'Прошла';

  @override
  String get meetingsStatusScheduled => 'Запланирована';

  @override
  String get meetingsTime => 'Время';

  @override
  String get meetingsTitle => 'Встречи';

  @override
  String get meetingsTitleFieldLabel => 'Название';

  @override
  String get meetingsTitleRequired => 'Название обязательно';

  @override
  String get meetingsUpcomingEyebrow => 'Сейчас ближайшая';

  @override
  String get meetingsUpdateMeeting => 'Обновить встречу';

  @override
  String get meetingsViewingOf => 'Показ';

  @override
  String get meetingsWhen => 'Когда';

  @override
  String get meetingsWhoAndWhere => 'С кем и где';

  @override
  String get mortgageAmortisation => 'График платежей';

  @override
  String get mortgageAnnuity => 'Аннуитетный';

  @override
  String get mortgageDifferentiated => 'Дифференцированный';

  @override
  String get mortgageDownPayment => 'Первоначальный взнос';

  @override
  String mortgageDownSummary(String percent, String rate, String term) {
    return 'взнос $percent% · $rate% · $term';
  }

  @override
  String get mortgageFees => 'Разовые расходы';

  @override
  String get mortgageFeesHint => 'Оценка, страховка, комиссия банка';

  @override
  String mortgageFromPerMonth(String amount) {
    return 'от $amount в месяц';
  }

  @override
  String mortgageIncomeHint(String percent) {
    return 'Чтобы платёж был не больше $percent% дохода';
  }

  @override
  String get mortgageIncomeNeeded => 'Нужный доход';

  @override
  String get mortgageInterest => 'Проценты';

  @override
  String get mortgageLoan => 'Сумма кредита';

  @override
  String mortgageMonthLabel(int number) {
    return 'Месяц $number';
  }

  @override
  String get mortgageMonthly => 'Ежемесячный платёж';

  @override
  String get mortgageMonthlyRange => 'Первый месяц → последний';

  @override
  String get mortgageNoLoan => 'Взнос покрывает всю цену, кредит не нужен.';

  @override
  String get mortgageOpenCalculator => 'Открыть калькулятор';

  @override
  String get mortgageOverpayment => 'Переплата';

  @override
  String get mortgagePresetHousingSavings => 'Жилстройсбережения';

  @override
  String get mortgagePresetMarket => 'Рыночная ставка';

  @override
  String get mortgagePresetStateProgram => 'Программа 7-20-25';

  @override
  String get mortgagePresetsNote =>
      'Типичные ставки, а не предложения банков. Ставки меняются, уточняйте в банке.';

  @override
  String get mortgagePrice => 'Цена';

  @override
  String get mortgagePrincipal => 'Основной долг';

  @override
  String mortgageRangePerMonth(String first, String last) {
    return '$first → $last в месяц';
  }

  @override
  String get mortgageRate => 'Ставка годовых, %';

  @override
  String get mortgageSend => 'Отправить клиенту';

  @override
  String get mortgageShareDisclaimer =>
      'Ориентировочный расчёт, не является офертой.';

  @override
  String mortgageShareDown(String amount, String percent) {
    return 'Первоначальный взнос: $amount ($percent%)';
  }

  @override
  String get mortgageShareFailed => 'Не удалось поделиться расчётом';

  @override
  String get mortgageShareHeading => 'Расчёт ипотеки';

  @override
  String mortgageShareMonthly(String amount) {
    return 'Ежемесячный платёж: $amount';
  }

  @override
  String mortgageShareMonthlyRange(String first, String last) {
    return 'Ежемесячный платёж: $first в первый месяц, $last в последний';
  }

  @override
  String mortgageShareOverpayment(String amount) {
    return 'Переплата: $amount';
  }

  @override
  String mortgageSharePrice(String amount) {
    return 'Цена: $amount';
  }

  @override
  String mortgageShareRate(String rate) {
    return 'Ставка: $rate% годовых';
  }

  @override
  String mortgageShareTerm(String term) {
    return 'Срок: $term';
  }

  @override
  String get mortgageTerm => 'Срок';

  @override
  String mortgageTermYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String get mortgageTitle => 'Ипотека';

  @override
  String get mortgageTotalRepaid => 'Всего выплат';

  @override
  String get mortgageType => 'Тип платежа';

  @override
  String mortgageYearLabel(int number) {
    return 'Год $number';
  }

  @override
  String get msgAgentInvited => 'Агент приглашён';

  @override
  String get msgChecklistSaved => 'Чек-лист сохранён';

  @override
  String get msgClientCreated => 'Клиент создан';

  @override
  String get msgClientDeleted => 'Клиент удалён';

  @override
  String get msgClientUpdated => 'Клиент обновлён';

  @override
  String get msgClientsMerged => 'Карточки объединены';

  @override
  String get msgCodeSent => 'Код отправлен';

  @override
  String get msgCommentDeleted => 'Комментарий удалён';

  @override
  String get msgCommentUpdated => 'Комментарий изменён';

  @override
  String get msgCurrencyChanged => 'Валюта изменена';

  @override
  String get msgDealCreated => 'Сделка создана';

  @override
  String get msgDealDeleted => 'Сделка удалена';

  @override
  String get msgDealUpdated => 'Сделка обновлена';

  @override
  String get msgDocumentDeleted => 'Документ удалён';

  @override
  String get msgDocumentUploaded => 'Документ прикреплён';

  @override
  String get msgInviteResent => 'Приглашение отправлено повторно';

  @override
  String get msgMeetingCompleted => 'Встреча завершена';

  @override
  String get msgMeetingCreated => 'Встреча создана';

  @override
  String get msgMeetingDeleted => 'Встреча удалена';

  @override
  String get msgMeetingUpdated => 'Встреча обновлена';

  @override
  String get msgMemberRemoved => 'Агент удалён из команды';

  @override
  String get msgNotificationsAllRead => 'Все уведомления прочитаны';

  @override
  String get msgProfileUpdated => 'Профиль обновлён';

  @override
  String get msgPropertyCreated => 'Объект создан';

  @override
  String get msgPropertyDeleted => 'Объект удалён';

  @override
  String get msgPropertyUpdated => 'Объект обновлён';

  @override
  String get msgRequestCancelled => 'Запрос отозван';

  @override
  String get msgRequestDeclined => 'Запрос отклонён';

  @override
  String get msgRequestSent => 'Запрос отправлен';

  @override
  String get msgRoleUpdated => 'Роль обновлена';

  @override
  String get msgStatusUpdated => 'Статус обновлён';

  @override
  String get msgTaskCompleted => 'Задача выполнена';

  @override
  String get msgTaskCreated => 'Задача добавлена';

  @override
  String get msgTaskDeleted => 'Задача удалена';

  @override
  String get msgTaskReopened => 'Задача снова в работе';

  @override
  String get msgTaskUpdated => 'Задача обновлена';

  @override
  String get msgTeamAssigned => 'Команда назначена';

  @override
  String get msgTeamCreated => 'Команда создана';

  @override
  String get msgTeamJoined => 'Вы в команде';

  @override
  String get msgTeamLeft => 'Вы вышли из команды';

  @override
  String get msgTeamUpdated => 'Команда обновлена';

  @override
  String get msgTemplateDeleted => 'Шаблон удалён';

  @override
  String get msgTemplateSaved => 'Шаблон сохранён';

  @override
  String get msgUserActivated => 'Пользователь активирован';

  @override
  String get msgUserDeactivated => 'Пользователь деактивирован';

  @override
  String get msgUserDeleted => 'Пользователь удалён';

  @override
  String notificationsClientBirthday(String name) {
    return 'Сегодня день рождения у клиента $name';
  }

  @override
  String notificationsCountClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count клиента',
      many: '$count клиентов',
      few: '$count клиента',
      one: '$count клиент',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountDeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сделки',
      many: '$count сделок',
      few: '$count сделки',
      one: '$count сделка',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountListings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count объекта',
      many: '$count объектов',
      few: '$count объекта',
      one: '$count объект',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountMeetings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count встречи',
      many: '$count встреч',
      few: '$count встречи',
      one: '$count встреча',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи',
      many: '$count задач',
      few: '$count задачи',
      one: '$count задача',
    );
    return '$_temp0';
  }

  @override
  String notificationsDealComment(String author, String title) {
    return '$author оставляет комментарий к сделке $title';
  }

  @override
  String notificationsDealMention(String author, String title) {
    return '$author упоминает вас в сделке $title';
  }

  @override
  String notificationsDealStatus(String actor, String status, String title) {
    return '$actor перевёл сделку $title в статус «$status»';
  }

  @override
  String get notificationsEarlier => 'Ранее';

  @override
  String get notificationsEmptyBody =>
      'Здесь появятся задачи, которые вам поручили, переданные вам клиенты и объекты, подходящие вашим покупателям.';

  @override
  String get notificationsEmptyTitle => 'Ничего нового';

  @override
  String notificationsFitsBuyers(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подходит $count покупателям: $names',
      many: 'Подходит $count покупателям: $names',
      few: 'Подходит $count покупателям: $names',
      one: 'Подходит $count покупателю: $names',
    );
    return '$_temp0';
  }

  @override
  String notificationsHandedOver(int count, String from) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$from передаёт вам $_temp0';
  }

  @override
  String notificationsJoinAccepted(String agent, String team) {
    return '$agent теперь в агентстве $team';
  }

  @override
  String notificationsJoinRequest(String actor, String team) {
    return '$actor приглашает вас в агентство $team';
  }

  @override
  String notificationsListingLead(String name, String title) {
    return '$name интересуется объектом $title';
  }

  @override
  String get notificationsMarkAllRead => 'Прочитать все';

  @override
  String notificationsMoreNames(int count, String names) {
    return '$names и ещё $count';
  }

  @override
  String notificationsNewMatch(String title) {
    return 'Новый объект для ваших покупателей: $title';
  }

  @override
  String notificationsPriceDrop(String oldPrice, String price, String title) {
    return '$title подешевел до $price, было $oldPrice';
  }

  @override
  String notificationsPurchaseAnniversary(String name, int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Сегодня $years года с покупки клиента $name',
      many: 'Сегодня $years лет с покупки клиента $name',
      few: 'Сегодня $years года с покупки клиента $name',
      one: 'Сегодня $years год с покупки клиента $name',
    );
    return '$_temp0';
  }

  @override
  String get notificationsSomeone => 'Кто-то';

  @override
  String notificationsTaskAssigned(String actor, String title) {
    return '$actor поручает вам задачу: $title';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsToday => 'Сегодня';

  @override
  String get notificationsUnknown => 'В вашей работе что-то изменилось';

  @override
  String notificationsUnreadLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанного уведомления',
      many: '$count непрочитанных уведомлений',
      few: '$count непрочитанных уведомления',
      one: '$count непрочитанное уведомление',
      zero: 'Нет непрочитанных уведомлений',
    );
    return '$_temp0';
  }

  @override
  String get offersAccept => 'Принять';

  @override
  String offersAcceptConfirm(String amount) {
    return '$amount станет согласованной ценой. Остальные предложения по объекту останутся открытыми как запасные, пока вы их не решите.';
  }

  @override
  String get offersAcceptTitle => 'Принять предложение?';

  @override
  String get offersAgent => 'Агент';

  @override
  String get offersAlreadyAccepted =>
      'Другое предложение по объекту уже принято; сначала отзовите его';

  @override
  String get offersAlreadyOpen =>
      'У этого покупателя уже есть открытое предложение; ответьте на него встречным';

  @override
  String get offersAmount => 'Сумма';

  @override
  String get offersAmountHint => 'Сколько предлагают';

  @override
  String offersAsking(String price) {
    return 'запрошено $price';
  }

  @override
  String get offersBackup =>
      'Принято другое предложение; это ждёт как запасное';

  @override
  String get offersBuyer => 'Покупатель';

  @override
  String get offersCardTitle => 'Предложения';

  @override
  String get offersClientNone =>
      'Предложений от этого покупателя пока нет. Их записывают на странице объекта.';

  @override
  String get offersClientNotBuyer =>
      'Предложение может сделать только покупатель';

  @override
  String get offersClosedHeading => 'Закрытые';

  @override
  String offersColleagueBuyer(String agent) {
    return 'Покупатель: $agent';
  }

  @override
  String get offersCounter => 'Встречное';

  @override
  String get offersCounterFrom => 'Чья сумма';

  @override
  String get offersCounterTitle => 'Новая сумма';

  @override
  String get offersDecidedOn => 'Решено';

  @override
  String get offersExpiresOn => 'Действует до';

  @override
  String get offersExpiryPast => 'Срок не может быть раньше сегодняшнего дня';

  @override
  String get offersFigureBuyer => 'Сумма покупателя';

  @override
  String get offersFigureSeller => 'Сумма продавца';

  @override
  String get offersHiddenBuyer => 'Покупатель коллеги';

  @override
  String get offersHistory => 'Ход переговоров';

  @override
  String get offersListLoadFailed => 'Не удалось загрузить предложения';

  @override
  String get offersLoadFailed => 'Не удалось загрузить предложение';

  @override
  String get offersNoBuyers => 'Покупатели не найдены';

  @override
  String get offersNoDeadline => 'Без срока';

  @override
  String get offersNoLongerOpen => 'Это предложение уже закрыто';

  @override
  String get offersNone =>
      'Предложений пока нет. Запишите, когда покупатель назовёт цену.';

  @override
  String get offersNote => 'Заметка';

  @override
  String get offersNoteHint => 'Условия, способ оплаты, пожелания';

  @override
  String offersOfAsking(int percent) {
    return '$percent% от цены';
  }

  @override
  String offersOnTableNow(String amount) {
    return 'Сейчас на столе: $amount';
  }

  @override
  String get offersPartyBuyer => 'Покупатель';

  @override
  String get offersPartySeller => 'Продавец';

  @override
  String get offersPickBuyer => 'Выберите покупателя';

  @override
  String get offersPropertySold =>
      'Объект продан и больше не принимает предложений';

  @override
  String get offersRecord => 'Записать предложение';

  @override
  String get offersRecordTitle => 'Новое предложение';

  @override
  String get offersReject => 'Отклонить';

  @override
  String get offersRejectConfirm =>
      'Предложение закроется как отклонённое, вернуть его нельзя.';

  @override
  String get offersRejectTitle => 'Отклонить предложение?';

  @override
  String get offersSave => 'Сохранить';

  @override
  String get offersSearchBuyers => 'Поиск покупателей';

  @override
  String get offersShowAll => 'Показать все';

  @override
  String get offersStatusAccepted => 'Принято';

  @override
  String get offersStatusCountered => 'Встречное';

  @override
  String get offersStatusExpired => 'Истекло';

  @override
  String get offersStatusNew => 'Новое';

  @override
  String get offersStatusRejected => 'Отклонено';

  @override
  String get offersStatusWithdrawn => 'Отозвано';

  @override
  String get offersStepAccepted => 'Принято';

  @override
  String get offersStepCounteredBuyer => 'Встречное от покупателя';

  @override
  String get offersStepCounteredSeller => 'Встречное от продавца';

  @override
  String get offersStepOffered => 'Предложение покупателя';

  @override
  String get offersStepOther => 'Изменение';

  @override
  String get offersStepRejected => 'Отклонено';

  @override
  String get offersStepWithdrawn => 'Отозвано';

  @override
  String get offersTitle => 'Предложение';

  @override
  String offersValidUntil(String date) {
    return 'Действует до $date';
  }

  @override
  String get offersWithdraw => 'Отозвать';

  @override
  String get offersWithdrawConfirm =>
      'Покупатель отказался. Предложение закроется, вернуть его нельзя.';

  @override
  String get offersWithdrawTitle => 'Отозвать предложение?';

  @override
  String get openHouseActivity => 'Визит на день открытых дверей';

  @override
  String get openHouseAddVisitor => 'Добавить гостя';

  @override
  String get openHouseAlreadySignedIn => 'Этот номер уже записан';

  @override
  String openHouseColleagueClient(String agent) {
    return 'Клиент: $agent';
  }

  @override
  String get openHouseDate => 'Дата';

  @override
  String get openHouseDelete => 'Отменить день открытых дверей';

  @override
  String get openHouseDeleteConfirm => 'Он исчезнет из объекта и календаря.';

  @override
  String get openHouseEdit => 'Изменить день открытых дверей';

  @override
  String get openHouseEnds => 'Конец';

  @override
  String get openHouseEndsBeforeStart => 'Конец должен быть позже начала';

  @override
  String get openHouseHasVisitors =>
      'Гости уже записаны, поэтому отменить нельзя';

  @override
  String openHouseHost(String name) {
    return 'Проводит $name';
  }

  @override
  String get openHouseInterestLabel => 'Интерес';

  @override
  String get openHouseInterested => 'Интересно';

  @override
  String get openHouseJustLooking => 'Просто смотрит';

  @override
  String get openHouseKnownClient => 'Уже клиент';

  @override
  String get openHouseLive => 'Идёт сейчас';

  @override
  String get openHouseLoadFailed => 'Не удалось загрузить день открытых дверей';

  @override
  String get openHouseNewClient => 'Новый клиент';

  @override
  String get openHouseNoVisitors => 'Пока никто не записан';

  @override
  String get openHouseNoVisitorsHint =>
      'Добавляйте гостей по мере прихода. Незнакомый агентству номер станет новым покупателем.';

  @override
  String get openHouseNone =>
      'Пока нет. Назначьте день открытых дверей и записывайте гостей у входа.';

  @override
  String get openHouseNoteHint => 'Ключи, парковка, кому звонить у двери';

  @override
  String get openHouseNoteLabel => 'Заметка';

  @override
  String get openHousePast => 'Прошедшие';

  @override
  String get openHouseRemoveVisitor => 'Убрать гостя';

  @override
  String openHouseRemoveVisitorConfirm(String name) {
    return '$name будет убран(а) из листа, а визит из истории клиента. Клиент, созданный при записи, останется.';
  }

  @override
  String get openHouseSave => 'Сохранить';

  @override
  String get openHouseSchedule => 'Назначить день открытых дверей';

  @override
  String get openHouseSeeAll => 'Показать все';

  @override
  String get openHouseSignIn => 'Сохранить';

  @override
  String get openHouseSignInNext => 'Сохранить и следующий';

  @override
  String get openHouseSignInSheet => 'Лист гостей';

  @override
  String openHouseSignedIn(String name) {
    return '$name записан(а)';
  }

  @override
  String get openHouseStarts => 'Начало';

  @override
  String get openHouseSummary => 'Итоги';

  @override
  String get openHouseSummaryInterested => 'Заинтересованы';

  @override
  String get openHouseSummaryNewClients => 'Новые клиенты';

  @override
  String get openHouseSummaryVisitors => 'Гости';

  @override
  String get openHouseTitle => 'День открытых дверей';

  @override
  String get openHouseTooLong =>
      'День открытых дверей длится не больше 12 часов';

  @override
  String get openHouseUpcoming => 'Предстоящие';

  @override
  String get openHouseVisitorName => 'Имя';

  @override
  String get openHouseVisitorNameHint => 'Как представился';

  @override
  String get openHouseVisitorNameRequired => 'Введите имя';

  @override
  String get openHouseVisitorNoteHint => 'О чём спрашивал';

  @override
  String get openHouseVisitorPhone => 'Телефон';

  @override
  String get openHouseVisitorPhoneInvalid => 'Введите номер телефона';

  @override
  String openHouseVisitorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гостя',
      many: '$count гостей',
      few: '$count гостя',
      one: '$count гость',
      zero: 'Нет гостей',
    );
    return '$_temp0';
  }

  @override
  String get openHousesCardTitle => 'Дни открытых дверей';

  @override
  String get profileAgentId => 'ID агента';

  @override
  String get profileAgentIdCopied => 'ID агента скопирован';

  @override
  String get profileApp => 'Приложение';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String profileDeleteAccountConfirm(Object successor) {
    return 'Ваши клиенты, объекты, сделки и встречи перейдут к $successor. Аккаунт будет удалён безвозвратно.';
  }

  @override
  String get profileDeleteHandoverEmpty => 'Записи некому передать';

  @override
  String get profileDeleteHandoverSearch => 'Поиск коллег';

  @override
  String get profileDeleteHandoverTitle => 'Кому передать ваши записи';

  @override
  String get profileEditProfile => 'Изменить профиль';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFullName => 'Полное имя';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLegal => 'Документы';

  @override
  String get profileLinkFailed => 'Не удалось открыть ссылку';

  @override
  String get profileName => 'Имя';

  @override
  String get profilePrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get profileReminders => 'Напоминания о встречах';

  @override
  String get profileRemindersOff => 'Выключены';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileSignOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get profileSupport => 'Поддержка';

  @override
  String get profileSystemDefault => 'Системный';

  @override
  String get profileTheme => 'Оформление';

  @override
  String get profileThemeDark => 'Тёмное';

  @override
  String get profileThemeLight => 'Светлое';

  @override
  String get profileThemeSystem => 'Как в системе';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileVersion => 'Версия';

  @override
  String get propertiesAddFirstListing => 'Добавьте первый объект';

  @override
  String get propertiesAddPhotos => 'Добавить фото';

  @override
  String get propertiesAddressLabel => 'Адрес';

  @override
  String get propertiesAll => 'Все';

  @override
  String get propertiesArea => 'Площадь';

  @override
  String get propertiesAreaLabel => 'Площадь м²';

  @override
  String propertiesAreaValue(Object area) {
    return '$area м²';
  }

  @override
  String get propertiesBack => 'Назад';

  @override
  String get propertiesBasicInfo => 'Основная информация';

  @override
  String get propertiesBrochure => 'Буклет (PDF)';

  @override
  String get propertiesBrochureContact => 'Контакты';

  @override
  String get propertiesBrochureFailed =>
      'Не удалось собрать буклет. Попробуйте ещё раз.';

  @override
  String propertiesBrochureGenerated(String date) {
    return 'Подготовлено $date';
  }

  @override
  String propertiesBrochurePage(int page, int total) {
    return 'Страница $page из $total';
  }

  @override
  String get propertiesCityLabel => 'Город';

  @override
  String propertiesCounter(Object reserved, Object total) {
    return '$total в базе · $reserved в брони';
  }

  @override
  String get propertiesCreateProperty => 'Создать объект';

  @override
  String get propertiesDelete => 'Удалить';

  @override
  String propertiesDeleteCascade(Object title) {
    return '«$title» будет удалён безвозвратно. Отменить действие нельзя.';
  }

  @override
  String get propertiesDeleteProperty => 'Удалить объект';

  @override
  String get propertiesDescribeHint => 'Опишите объект…';

  @override
  String get propertiesDescription => 'Описание';

  @override
  String get propertiesDetails => 'Детали';

  @override
  String get propertiesEdit => 'Редактировать';

  @override
  String get propertiesEditProperty => 'Редактировать объект';

  @override
  String propertiesFieldRequired(Object label) {
    return '$label обязательно';
  }

  @override
  String get propertiesFilters => 'Фильтры';

  @override
  String get propertiesFloor => 'Этаж';

  @override
  String propertiesFloorOf(Object floor, Object total) {
    return '$floor из $total';
  }

  @override
  String get propertiesInterested => 'Кому подходит';

  @override
  String get propertiesLink => 'Публичная ссылка';

  @override
  String get propertiesLinkCopied => 'Ссылка скопирована';

  @override
  String get propertiesLinkCopy => 'Копировать';

  @override
  String get propertiesLinkCreate => 'Создать ссылку';

  @override
  String propertiesLinkEnquiries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заявки по ссылке',
      many: '$count заявок по ссылке',
      few: '$count заявки по ссылке',
      one: '$count заявка по ссылке',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLinkHint =>
      'Страница с фото, ценой и вашими контактами. Открывается в любом браузере, без приложения и регистрации.';

  @override
  String propertiesLinkLastViewed(String date) {
    return 'Последний раз открывали $date';
  }

  @override
  String get propertiesLinkRevoke => 'Отключить';

  @override
  String get propertiesLinkRevokeConfirm =>
      'Те, кому вы её отправили, больше не смогут открыть объект. Новая ссылка будет с другим адресом.';

  @override
  String get propertiesLinkRevokeTitle => 'Отключить ссылку?';

  @override
  String get propertiesLinkShare => 'Поделиться';

  @override
  String propertiesLinkViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыли $count раза',
      many: 'Открыли $count раз',
      few: 'Открыли $count раза',
      one: 'Открыли $count раз',
      zero: 'Ещё не открывали',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLocation => 'Расположение';

  @override
  String get propertiesMandate => 'Договор с продавцом';

  @override
  String get propertiesMandateClearEndDate => 'Убрать дату окончания';

  @override
  String get propertiesMandateEndDate => 'Последний день';

  @override
  String propertiesMandateEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истёк $count дня назад',
      many: 'Истёк $count дней назад',
      few: 'Истёк $count дня назад',
      one: 'Истёк $count день назад',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndedYesterday => 'Истёк вчера';

  @override
  String propertiesMandateEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Истекает через $count дня',
      many: 'Истекает через $count дней',
      few: 'Истекает через $count дня',
      one: 'Истекает через $count день',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndsToday => 'Истекает сегодня';

  @override
  String get propertiesMandateEndsTomorrow => 'Истекает завтра';

  @override
  String get propertiesMandateExclusive => 'Эксклюзив';

  @override
  String propertiesMandateExclusiveEnded(String date) {
    return 'Эксклюзив истёк $date';
  }

  @override
  String propertiesMandateExclusiveUntil(String date) {
    return 'Эксклюзив до $date';
  }

  @override
  String get propertiesMandateNoEndDate => 'Без даты окончания';

  @override
  String get propertiesMandateNone => 'Нет';

  @override
  String get propertiesMandateOpen => 'Открытый';

  @override
  String get propertiesMandateOpenBadge => 'Открытый договор';

  @override
  String propertiesMandateOpenEnded(String date) {
    return 'Договор истёк $date';
  }

  @override
  String propertiesMandateOpenUntil(String date) {
    return 'Открытый до $date';
  }

  @override
  String get propertiesMandatesEmpty => 'Истекающих договоров нет';

  @override
  String get propertiesMandatesEmptyHint =>
      'Ни один договор по объектам в продаже не истекает в ближайшие две недели.';

  @override
  String get propertiesMandatesLoadFailed =>
      'Не удалось загрузить истекающие договоры';

  @override
  String get propertiesMandatesTitle => 'Договоры истекают';

  @override
  String propertiesMapCapped(int count) {
    return 'Показано $count — приблизьте карту, чтобы увидеть остальные';
  }

  @override
  String get propertiesMapEmpty => 'В этой части карты нет объектов';

  @override
  String get propertiesMapLoading => 'Загружаем объекты';

  @override
  String get propertiesMapPin => 'Точка на карте';

  @override
  String get propertiesMapPinClear => 'Убрать точку';

  @override
  String get propertiesMapPinHint =>
      'Нажмите на карту, чтобы поставить точку, и перетащите её для точности';

  @override
  String propertiesMapUnpinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count объектов нет точки на карте',
      one: 'У $count объекта нет точки на карте',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMapUnpinnedHint =>
      'Откройте объект, нажмите «Изменить» и поставьте точку — он появится на карте.';

  @override
  String get propertiesMapUnpinnedTitle => 'Нет на карте';

  @override
  String get propertiesNewProperty => 'Новый объект';

  @override
  String get propertiesNextDetails => 'Далее — детали';

  @override
  String get propertiesNoInterested => 'Пока никто такого не искал';

  @override
  String get propertiesNoPhotos => 'Фото пока нет — первое станет обложкой';

  @override
  String get propertiesNoProperties => 'Нет объектов';

  @override
  String get propertiesNoResultsSubtitle => 'Измените запрос или фильтр';

  @override
  String get propertiesNoViewings => 'Этот объект ещё не показывали';

  @override
  String get propertiesOpenInMaps => 'Открыть в картах';

  @override
  String get propertiesOpenInMapsFailed => 'Не удалось открыть карты';

  @override
  String propertiesPhotoCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото',
      one: '1 фото',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPhotoDelete => 'Удалить фото';

  @override
  String get propertiesPhotoDeleteConfirm => 'Удалить это фото из объекта?';

  @override
  String propertiesPhotoFailed(String name) {
    return 'Не удалось загрузить $name';
  }

  @override
  String propertiesPhotoTooLarge(String name) {
    return '$name больше 12 МБ';
  }

  @override
  String get propertiesPhotos => 'Фото';

  @override
  String get propertiesPhotosHint =>
      'Удерживайте фото, чтобы переставить — первое станет обложкой';

  @override
  String get propertiesPriceCheck => 'Проверка цены';

  @override
  String propertiesPriceCheckAbove(String percent) {
    return 'на $percent% выше';
  }

  @override
  String get propertiesPriceCheckAtMedian => 'ровно по медиане';

  @override
  String propertiesPriceCheckBasedOn(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На основе $count объявления, г. $city',
      many: 'На основе $count объявлений, г. $city',
      few: 'На основе $count объявлений, г. $city',
      one: 'На основе $count объявления, г. $city',
    );
    return '$_temp0';
  }

  @override
  String propertiesPriceCheckBelow(String percent) {
    return 'на $percent% ниже';
  }

  @override
  String get propertiesPriceCheckComparables => 'Похожие объекты';

  @override
  String propertiesPriceCheckDaysOnMarket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня в продаже',
      many: '$count дней в продаже',
      few: '$count дня в продаже',
      one: '$count день в продаже',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPriceCheckLowConfidence =>
      'Похожих объектов пока мало — это лишь ориентир';

  @override
  String get propertiesPriceCheckSeeComparables => 'Показать похожие';

  @override
  String propertiesPriceCheckSold(String price) {
    return 'Продано: медиана $price';
  }

  @override
  String propertiesPriceCheckVsMedian(
      String price, String median, String difference) {
    return '$price / м² против медианы $median ($difference)';
  }

  @override
  String propertiesPriceHintRange(String low, String high) {
    return 'Похожие объекты: $low–$high за такую площадь';
  }

  @override
  String get propertiesPriceHintUseMedian => 'Взять медиану';

  @override
  String get propertiesPriceHistory => 'История цены';

  @override
  String get propertiesPriceLabel => 'Цена';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price за м²';
  }

  @override
  String get propertiesPriceReduced => 'Цена снижена';

  @override
  String propertiesPriceWas(String price) {
    return 'Было $price';
  }

  @override
  String get propertiesProperty => 'Объект';

  @override
  String propertiesPropertyCreated(Object id) {
    return 'Объект создан (ID: $id)';
  }

  @override
  String get propertiesPropertyIdCopied => 'ID объекта скопирован';

  @override
  String propertiesPropertyIdLabel(Object id) {
    return 'ID объекта: $id';
  }

  @override
  String get propertiesPropertyNotFound => 'Объект не найден';

  @override
  String get propertiesReport => 'Отчёт для продавца';

  @override
  String propertiesReportAsOf(String date) {
    return 'На $date';
  }

  @override
  String get propertiesReportAwaitingOutcome => 'Итог ещё не отмечен';

  @override
  String get propertiesReportCurrentPrice => 'Сейчас';

  @override
  String get propertiesReportDaysOnMarket => 'Дней в продаже';

  @override
  String get propertiesReportLinkLeads => 'Заявок по ссылке';

  @override
  String get propertiesReportLinkViews => 'Открытий ссылки';

  @override
  String propertiesReportListedOn(String date) {
    return 'В продаже с $date';
  }

  @override
  String get propertiesReportLoadFailed => 'Не удалось загрузить отчёт';

  @override
  String get propertiesReportMatchingBuyers => 'Подходящих покупателей';

  @override
  String propertiesReportNextViewing(String date) {
    return 'Следующий показ $date';
  }

  @override
  String get propertiesReportNoViewings => 'Показов пока не было';

  @override
  String get propertiesReportOriginalPrice => 'Начальная цена';

  @override
  String get propertiesReportOutcomes => 'Что сказали после показа';

  @override
  String get propertiesReportPrice => 'Цена';

  @override
  String get propertiesReportPriceChange => 'Изменение';

  @override
  String get propertiesReportPriceChanges => 'Изменения цены';

  @override
  String get propertiesReportPriceUnchanged =>
      'Цена не менялась с начала продажи';

  @override
  String get propertiesReportShare => 'Отправить продавцу';

  @override
  String get propertiesReportShareFailed =>
      'Не удалось отправить отчёт. Попробуйте ещё раз.';

  @override
  String propertiesReportSoldOn(String date) {
    return 'Продан $date';
  }

  @override
  String propertiesReportTextHeading(String title) {
    return 'Отчёт для продавца: $title';
  }

  @override
  String propertiesReportTextLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get propertiesReportViewingsHeld => 'Показов проведено';

  @override
  String get propertiesReportViewingsUpcoming => 'Показов впереди';

  @override
  String get propertiesRooms => 'Комнаты';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms комн.';
  }

  @override
  String get propertiesSearchHintFull => 'Адрес, ЖК, ID…';

  @override
  String get propertiesStatus => 'Статус';

  @override
  String propertiesStepOf(Object current, Object total) {
    return 'Шаг $current из $total';
  }

  @override
  String get propertiesTitle => 'Объекты';

  @override
  String get propertiesTitleLabel => 'Название';

  @override
  String get propertiesTotalFloors => 'Всего этажей';

  @override
  String get propertiesType => 'Тип';

  @override
  String get propertiesUpdateProperty => 'Обновить объект';

  @override
  String get propertiesViewList => 'Список';

  @override
  String get propertiesViewMap => 'Карта';

  @override
  String get propertiesViewings => 'Показы';

  @override
  String get quickAddClient => 'Новый клиент';

  @override
  String get quickAddDeal => 'Новая сделка';

  @override
  String quickAddFor(String name) {
    return 'Для: $name';
  }

  @override
  String get quickAddLastUsed => 'В прошлый раз';

  @override
  String get quickAddListing => 'Новый объект';

  @override
  String get quickAddLogContact => 'Записать контакт';

  @override
  String get quickAddMeeting => 'Новая встреча';

  @override
  String get quickAddNoClients =>
      'Клиентов пока нет — сначала добавьте клиента';

  @override
  String get quickAddOpen => 'Создать';

  @override
  String get quickAddPickClient => 'Какой клиент?';

  @override
  String get quickAddSearchClients => 'Поиск клиентов';

  @override
  String get quickAddTask => 'Новая задача';

  @override
  String get quickAddTitle => 'Добавить';

  @override
  String remindersBody(Object time) {
    return 'Начало в $time';
  }

  @override
  String remindersBodyWithClient(Object client, Object time) {
    return 'Начало в $time, клиент $client';
  }

  @override
  String get remindersFallbackTitle => 'Встреча';

  @override
  String get remindersLeadDay => 'За сутки';

  @override
  String get remindersLeadHour => 'За час';

  @override
  String get remindersLeadQuarter => 'За 15 минут';

  @override
  String get remindersPermissionDenied =>
      'Уведомления для EstateCRM отключены. Включите их в настройках телефона.';

  @override
  String get remindersTaskDue => 'Пора сделать';

  @override
  String remindersTaskDueWithClient(Object client) {
    return 'Пора сделать · $client';
  }

  @override
  String get routeAddPin => 'Поставить метку';

  @override
  String get routeAppApple => 'Apple Карты';

  @override
  String get routeAppDgis => '2ГИС';

  @override
  String get routeAppGoogle => 'Google Карты';

  @override
  String get routeAppNextOnly => 'Только следующая точка';

  @override
  String routeAppStops(int from, int to, int total) {
    return 'Точки $from–$to из $total';
  }

  @override
  String get routeAppWhole => 'Весь маршрут по порядку';

  @override
  String get routeAppYandex => 'Яндекс Карты';

  @override
  String routeChooserNext(String title) {
    return 'Следующая точка: $title';
  }

  @override
  String get routeChooserTitle => 'Открыть в картах';

  @override
  String get routeChooserWhole => 'Все оставшиеся точки в порядке расписания';

  @override
  String get routeDayOver => 'На этот день точек не осталось';

  @override
  String get routeDone => 'Проведён';

  @override
  String routeDurationHourMin(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String routeDurationHours(int hours) {
    return '$hours ч';
  }

  @override
  String routeDurationMin(int minutes) {
    return '$minutes мин';
  }

  @override
  String get routeEmpty => 'В этот день показов нет';

  @override
  String get routeEmptyHint =>
      'Встреча, привязанная к объекту, появится здесь точкой маршрута.';

  @override
  String get routeEntryDay => 'Маршрут на этот день';

  @override
  String get routeEntryToday => 'Маршрут на сегодня';

  @override
  String routeFromPrevious(String km) {
    return '$km км от предыдущей точки';
  }

  @override
  String get routeLoadFailed => 'Не удалось загрузить маршрут';

  @override
  String get routeNavigateNext => 'Проложить к следующей точке';

  @override
  String get routeNext => 'Следующий';

  @override
  String get routeNotOnMap => 'Нет на карте';

  @override
  String get routeNotOnMapHint =>
      'У этих объектов ещё нет метки, поэтому их нет в маршруте.';

  @override
  String get routeOpenFailed => 'Не удалось открыть карты';

  @override
  String get routeOpenWhole => 'Открыть весь маршрут';

  @override
  String get routeOverlap => 'Пересекается со следующим показом';

  @override
  String routeStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count точки',
      many: '$count точек',
      few: '$count точки',
      one: '$count точка',
    );
    return '$_temp0';
  }

  @override
  String get routeStraightLine =>
      'Прямые линии между точками, а не маршрут по дорогам';

  @override
  String routeSummary(String stops, String km) {
    return '$stops · $km км по прямой';
  }

  @override
  String get routeTitle => 'Маршрут показов';

  @override
  String routeUntilNext(String duration) {
    return '$duration до следующего';
  }

  @override
  String get searchClear => 'Очистить';

  @override
  String get searchClearRecent => 'Очистить';

  @override
  String get searchHint => 'Клиенты, объекты, сделки…';

  @override
  String searchMoreCount(Object count) {
    return 'и ещё $count';
  }

  @override
  String get searchNoResults => 'Ничего не найдено';

  @override
  String get searchNoResultsSubtitle =>
      'Попробуйте другое имя, адрес или номер телефона';

  @override
  String get searchPromptSubtitle =>
      'Найдите клиента, объект или сделку по имени, адресу, телефону или ID';

  @override
  String get searchPromptTitle => 'Поиск по всей базе';

  @override
  String get searchRecent => 'Недавние';

  @override
  String get searchSectionClients => 'Клиенты';

  @override
  String get searchSectionDeals => 'Сделки';

  @override
  String get searchSectionProperties => 'Объекты';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get tasksAbout => 'К чему относится';

  @override
  String get tasksAdd => 'Добавить задачу';

  @override
  String get tasksAllTasks => 'Все задачи';

  @override
  String tasksAssignedTo(Object name) {
    return 'для: $name';
  }

  @override
  String get tasksAssignee => 'Исполнитель';

  @override
  String get tasksClearLink => 'Убрать связь';

  @override
  String get tasksClient => 'Клиент';

  @override
  String get tasksComplete => 'Отметить выполненной';

  @override
  String tasksCounter(Object count) {
    return 'Открытых: $count';
  }

  @override
  String get tasksDate => 'Дата';

  @override
  String get tasksDeal => 'Сделка';

  @override
  String get tasksDelete => 'Удалить задачу';

  @override
  String get tasksDeleteBody => 'Задача исчезнет у всех вместе с напоминанием.';

  @override
  String get tasksDeleteTitle => 'Удалить задачу?';

  @override
  String tasksDoneOn(Object date) {
    return 'Выполнено $date';
  }

  @override
  String get tasksDoneTab => 'Выполненные';

  @override
  String get tasksDue => 'Срок';

  @override
  String tasksDueToday(Object time) {
    return 'Сегодня, $time';
  }

  @override
  String tasksDueTomorrow(Object time) {
    return 'Завтра, $time';
  }

  @override
  String get tasksEdit => 'Изменить задачу';

  @override
  String get tasksEmptyDone => 'Выполненных пока нет';

  @override
  String get tasksEmptyOpen => 'Всё сделано';

  @override
  String get tasksEmptyOpenHint =>
      'Здесь появятся задачи, добавленные к клиентам и сделкам.';

  @override
  String get tasksEmptyRecordHint =>
      'Добавьте следующий шаг, чтобы о нём не забыть.';

  @override
  String get tasksFieldTitle => 'Что сделать';

  @override
  String get tasksLoadFailed => 'Не удалось загрузить задачи';

  @override
  String get tasksNew => 'Новая задача';

  @override
  String get tasksNoAgents => 'Некому поручить';

  @override
  String get tasksNote => 'Заметка';

  @override
  String get tasksNoteHint => 'Детали, номера, что подготовить…';

  @override
  String get tasksOpenTab => 'Открытые';

  @override
  String get tasksOverdue => 'Просрочено';

  @override
  String get tasksQuickInThreeDays => 'Через 3 дня';

  @override
  String get tasksQuickTodayEvening => 'Сегодня вечером';

  @override
  String get tasksQuickTomorrowMorning => 'Завтра утром';

  @override
  String get tasksReopen => 'Вернуть в работу';

  @override
  String get tasksSave => 'Сохранить задачу';

  @override
  String get tasksSearchHint => 'Поиск по имени или ID';

  @override
  String get tasksTime => 'Время';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get tasksTitleHint => 'Перезвонить Ирине';

  @override
  String get tasksTitleRequired => 'Напишите, что нужно сделать';

  @override
  String get tasksTitleTooLong => 'Не длиннее 200 символов';

  @override
  String get teamsActive => 'Активные';

  @override
  String get teamsAddAgent => 'Добавить агента';

  @override
  String get teamsAddAgentAction => 'Отправить';

  @override
  String get teamsAddAgentHint =>
      'Если у агента уже есть аккаунт, он получит запрос. Если нет — мы отправим приглашение на почту.';

  @override
  String get teamsAgents => 'Агенты';

  @override
  String get teamsCancelRequest => 'Отозвать';

  @override
  String get teamsChecklist => 'Чек-лист сделки';

  @override
  String get teamsChecklistAdd => 'Добавить пункт';

  @override
  String get teamsChecklistDelete => 'Удалить пункт';

  @override
  String get teamsChecklistDiscard => 'Не сохранять';

  @override
  String get teamsChecklistDiscardBody =>
      'Изменения в чек-листе ещё не сохранены.';

  @override
  String get teamsChecklistDiscardTitle => 'Выйти без сохранения?';

  @override
  String get teamsChecklistEmptyStage => 'На этом этапе пока нет пунктов';

  @override
  String get teamsChecklistHint => 'Что собрать по сделке на каждом этапе';

  @override
  String get teamsChecklistNewDealsOnly =>
      'Изменения касаются новых сделок. У текущих сделок остаётся свой список.';

  @override
  String get teamsChecklistRename => 'Переименовать';

  @override
  String get teamsChecklistReorder => 'Перетащите, чтобы изменить порядок';

  @override
  String get teamsClients => 'Клиенты';

  @override
  String get teamsCouldNotLoadStats => 'Не удалось загрузить статистику';

  @override
  String get teamsCreate => 'Создать';

  @override
  String get teamsCreateTeam => 'Создать команду';

  @override
  String get teamsCurrency => 'Валюта агентства';

  @override
  String get teamsCurrencyConfirm => 'Сменить валюту';

  @override
  String teamsCurrencyConfirmBody(
      String currency, String before, String after) {
    return 'Все в агентстве увидят цены в валюте «$currency». Суммы не пересчитываются: объект за $before будет стоить $after.';
  }

  @override
  String get teamsCurrencyConfirmTitle => 'Сменить валюту агентства?';

  @override
  String get teamsCurrencyEur => 'Евро (€)';

  @override
  String get teamsCurrencyHint => 'В чём показываются цены в приложении';

  @override
  String get teamsCurrencyKgs => 'Кыргызский сом (KGS)';

  @override
  String get teamsCurrencyKzt => 'Тенге (₸)';

  @override
  String get teamsCurrencyRub => 'Рубль (₽)';

  @override
  String get teamsCurrencyUsd => 'Доллар США (\$)';

  @override
  String get teamsCurrencyUzs => 'Узбекский сум (UZS)';

  @override
  String get teamsDeals => 'Сделки';

  @override
  String get teamsEditTeam => 'Редактировать команду';

  @override
  String get teamsEmail => 'Эл. почта';

  @override
  String get teamsEnterValidEmail => 'Введите корректный email';

  @override
  String get teamsFullName => 'Полное имя';

  @override
  String teamsInviteSentBody(Object email) {
    return 'Приглашение отправлено на $email.';
  }

  @override
  String get teamsLeaveTeam => 'Покинуть команду';

  @override
  String get teamsLeaveTeamBody =>
      'Клиенты, сделки и встречи останутся в команде. Чтобы вернуться, понадобится новое приглашение.';

  @override
  String teamsLeaveTeamTitle(Object team) {
    return 'Покинуть $team?';
  }

  @override
  String get teamsManagerChip => 'Руководитель';

  @override
  String teamsManagerLabel(Object name) {
    return 'Менеджер: $name';
  }

  @override
  String get teamsManagerOptional => 'Менеджер (необязательно)';

  @override
  String teamsMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get teamsMembers => 'Участники';

  @override
  String get teamsMyTeam => 'Моя команда';

  @override
  String get teamsNoManager => 'Без менеджера';

  @override
  String get teamsNoMembers => 'Пока никого';

  @override
  String get teamsNoMembersBody => 'Добавьте первого агента по адресу почты.';

  @override
  String get teamsNoPending => 'Ожидающих нет';

  @override
  String get teamsNoPendingBody => 'Здесь появятся запросы, ожидающие ответа.';

  @override
  String get teamsNoTeamLabel => 'Без команды';

  @override
  String get teamsPending => 'Ожидают';

  @override
  String get teamsPhoneOptional => 'Телефон (необязательно)';

  @override
  String teamsRemoveInviteBody(Object name) {
    return 'Приглашение для $name будет отозвано.';
  }

  @override
  String get teamsRemoveMember => 'Удалить из команды';

  @override
  String teamsRemoveMemberBody(Object successor) {
    return 'Клиенты, сделки и встречи останутся в команде и перейдут к $successor.';
  }

  @override
  String teamsRemoveMemberTitle(Object name) {
    return 'Удалить $name?';
  }

  @override
  String teamsRequestSentBody(Object name) {
    return '$name должен принять запрос, чтобы войти в команду.';
  }

  @override
  String get teamsRequired => 'Обязательно';

  @override
  String get teamsSave => 'Сохранить';

  @override
  String get teamsStatusPendingInvite => 'Приглашён';

  @override
  String get teamsStatusPendingVerification => 'Не подтвердил почту';

  @override
  String get teamsSuccessor => 'Записи перейдут';

  @override
  String get teamsSuccessorMe => 'Мне';

  @override
  String get teamsTeamLabel => 'Команда';

  @override
  String get teamsTeamName => 'Название команды';

  @override
  String get teamsUpcoming => 'Предстоящие';

  @override
  String get templatesAdd => 'Добавить шаблон';

  @override
  String get templatesBodyHint => 'Что отправит агент';

  @override
  String get templatesBodyLabel => 'Текст';

  @override
  String get templatesDelete => 'Удалить шаблон';

  @override
  String templatesDeleteBody(String title) {
    return '«$title» больше не будет предлагаться агентам.';
  }

  @override
  String get templatesDeleteTitle => 'Удалить шаблон?';

  @override
  String get templatesEdit => 'Редактировать шаблон';

  @override
  String get templatesEmpty => 'Шаблонов пока нет';

  @override
  String get templatesEmptyBody =>
      'Добавьте сообщения, которые агенты отправляют чаще всего.';

  @override
  String get templatesHint => 'Готовые тексты для WhatsApp и SMS';

  @override
  String get templatesInsert => 'Вставить подстановку';

  @override
  String get templatesIntro =>
      'Агенты выбирают шаблон, когда пишут клиенту. Подстановки заполняются данными клиента, агента и выбранного объекта.';

  @override
  String get templatesLoadFailed => 'Не удалось загрузить шаблоны';

  @override
  String get templatesNew => 'Новый шаблон';

  @override
  String get templatesPlaceholderAddress => 'Адрес';

  @override
  String get templatesPlaceholderAgent => 'Имя агента';

  @override
  String get templatesPlaceholderClient => 'Имя клиента';

  @override
  String get templatesPlaceholderLink => 'Ссылка на объект';

  @override
  String get templatesPlaceholderListing => 'Объект';

  @override
  String get templatesPlaceholderPrice => 'Цена';

  @override
  String get templatesTitle => 'Шаблоны сообщений';

  @override
  String get templatesTitleHint => 'Например, Приглашение на просмотр';

  @override
  String get templatesTitleLabel => 'Название';

  @override
  String templatesUnknownPlaceholder(String names) {
    return 'Неизвестная подстановка: $names. Используйте те, что ниже.';
  }

  @override
  String get dealsKind => 'Продажа или аренда';

  @override
  String get dealsKindSale => 'Продажа';

  @override
  String get dealsKindRent => 'Аренда';

  @override
  String get leasesTitle => 'Аренда';

  @override
  String get leasesMonthlyRent => 'Аренда в месяц';

  @override
  String leasesPerMonth(String amount) {
    return '$amount в месяц';
  }

  @override
  String get leasesStart => 'Начало аренды';

  @override
  String get leasesEnd => 'Конец аренды';

  @override
  String get leasesPickDate => 'Выберите дату';

  @override
  String get leasesReminderDays => 'Напомнить за столько дней до конца';

  @override
  String leasesReminderValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'За $count дня до конца',
      many: 'За $count дней до конца',
      few: 'За $count дня до конца',
      one: 'За $count день до конца',
    );
    return '$_temp0';
  }

  @override
  String get leasesReminder => 'Напоминание';

  @override
  String get leasesLandlord => 'Арендодатель';

  @override
  String get leasesTenant => 'Арендатор';

  @override
  String leasesTenantValue(String name) {
    return 'Арендатор: $name';
  }

  @override
  String leasesLandlordValue(String name) {
    return 'Арендодатель: $name';
  }

  @override
  String get leasesRentRequired => 'Укажите аренду в месяц';

  @override
  String get leasesDatesRequired => 'Выберите первый и последний день аренды';

  @override
  String get leasesEndBeforeStart => 'Аренда должна заканчиваться после начала';

  @override
  String get leasesReminderInvalid => 'От 1 до 365 дней';

  @override
  String get leasesEndsToday => 'Аренда заканчивается сегодня';

  @override
  String get leasesEndsTomorrow => 'Аренда заканчивается завтра';

  @override
  String leasesEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Аренда заканчивается через $count дня',
      many: 'Аренда заканчивается через $count дней',
      few: 'Аренда заканчивается через $count дня',
      one: 'Аренда заканчивается через $count день',
    );
    return '$_temp0';
  }

  @override
  String get leasesEndedYesterday => 'Аренда закончилась вчера';

  @override
  String leasesEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Аренда закончилась $count дня назад',
      many: 'Аренда закончилась $count дней назад',
      few: 'Аренда закончилась $count дня назад',
      one: 'Аренда закончилась $count день назад',
    );
    return '$_temp0';
  }

  @override
  String get leasesRenew => 'Продлить аренду';

  @override
  String get leasesRenewTitle => 'Продление аренды';

  @override
  String get leasesRenewNewEnd => 'Новый последний день';

  @override
  String get leasesRenewHint =>
      'Сделка остаётся той же: аренда продлевается до новой даты, а в обсуждении появится отметка.';

  @override
  String get leasesRenewEndNotLater => 'Выберите дату позже текущего конца';

  @override
  String get leasesRenewed => 'Аренда продлена';

  @override
  String get leasesRenewFailed => 'Не удалось продлить аренду';

  @override
  String get leasesRenewWhenWon =>
      'Продлить аренду можно, когда сделка выиграна.';

  @override
  String get leasesEndingTitle => 'Аренда заканчивается';

  @override
  String get leasesEndingLoadFailed => 'Не удалось загрузить аренду';

  @override
  String get leasesEndingEmpty =>
      'В ближайшие 30 дней аренда ни у кого не заканчивается';

  @override
  String get leasesEndingEmptyHint =>
      'Выигранные сделки аренды появятся здесь за месяц до конца договора.';

  @override
  String notificationsLeaseEnding(String dealTitle, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Аренда по сделке «$dealTitle» заканчивается через $days дня',
      many: 'Аренда по сделке «$dealTitle» заканчивается через $days дней',
      few: 'Аренда по сделке «$dealTitle» заканчивается через $days дня',
      one: 'Аренда по сделке «$dealTitle» заканчивается через $days день',
      zero: 'Аренда по сделке «$dealTitle» заканчивается сегодня',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityHandover => 'Передан коллеге';

  @override
  String clientsActivityHandoverDetail(String from, String to) {
    return 'От $from к $to';
  }

  @override
  String clientsActivityHandoverTo(String to) {
    return 'К $to';
  }

  @override
  String get handoverAction => 'Передать работу';

  @override
  String handoverIntro(String name) {
    return '$name остаётся в агентстве. Выберите, кому и что передать; в истории каждого клиента появится отметка.';
  }

  @override
  String get handoverFrom => 'От кого';

  @override
  String get handoverTo => 'Кому';

  @override
  String get handoverChooseColleague => 'Выберите коллегу';

  @override
  String get handoverNoColleagues => 'Пока некому передать';

  @override
  String get handoverWhat => 'Что передать';

  @override
  String get handoverPartClients => 'Клиенты';

  @override
  String get handoverPartClientsHint =>
      'Вместе с открытыми сделками, встречами и задачами';

  @override
  String get handoverPartListings => 'Объекты';

  @override
  String get handoverPartListingsHint =>
      'Вместе с предстоящими днями открытых дверей';

  @override
  String get handoverPartDeals => 'Открытые сделки';

  @override
  String get handoverPartDealsHint => 'Все сделки, которые ещё не закрыты';

  @override
  String get handoverPartUpcoming => 'Встречи и задачи';

  @override
  String get handoverPartUpcomingHint =>
      'Предстоящие встречи и невыполненные задачи';

  @override
  String get handoverAllClients => 'Все клиенты';

  @override
  String handoverSomeClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count клиента',
      many: 'Выбрано $count клиентов',
      few: 'Выбрано $count клиента',
      one: 'Выбран $count клиент',
    );
    return '$_temp0';
  }

  @override
  String get handoverPickClients => 'Выбрать клиентов';

  @override
  String get handoverPickAll => 'Выбрать всех';

  @override
  String get handoverPickNone => 'Снять выбор';

  @override
  String get handoverPickDone => 'Готово';

  @override
  String get handoverNoClients => 'Нет клиентов для выбора';

  @override
  String get handoverPreview => 'Что будет передано';

  @override
  String get handoverCountDeals => 'Сделки';

  @override
  String get handoverCountMeetings => 'Встречи';

  @override
  String get handoverCountTasks => 'Задачи';

  @override
  String get handoverCountOpenHouses => 'Дни открытых дверей';

  @override
  String get handoverPickTarget =>
      'Выберите, кому передать, чтобы увидеть, что перейдёт';

  @override
  String get handoverNothingSelected => 'Отметьте хотя бы что-то одно';

  @override
  String get handoverNothingToMove => 'Передавать нечего';

  @override
  String get handoverPreviewFailed => 'Не удалось посчитать, что перейдёт';

  @override
  String get handoverConfirm => 'Передать';

  @override
  String handoverConfirmTitle(String name) {
    return 'Передать коллеге $name?';
  }

  @override
  String handoverConfirmBody(String from, String to) {
    return 'Работа перейдёт от $from к $to. Никто не покидает агентство, а в истории каждого клиента появится отметка.';
  }

  @override
  String handoverDoneTitle(String name) {
    return 'Передано: $name';
  }

  @override
  String handoverDoneBody(String name) {
    return '$name получит уведомление о переданной работе.';
  }

  @override
  String get handoverDoneAction => 'Вернуться к команде';

  @override
  String get handoverLoadFailed => 'Не удалось загрузить команду';

  @override
  String get splitsTitle => 'Сплит комиссии';

  @override
  String get splitsSheetSubtitle => 'Доли комиссии, в сумме 100%';

  @override
  String get splitsNotSplit => 'Не разделена';

  @override
  String splitsAllToAgent(String name) {
    return 'Вся комиссия достаётся $name.';
  }

  @override
  String get splitsDealAgent => 'Агент сделки';

  @override
  String get splitsColleague => 'Коллега';

  @override
  String get splitsCoBroker => 'Ко-брокер';

  @override
  String splitsCoBrokerFrom(String agency) {
    return 'Ко-брокер, $agency';
  }

  @override
  String get splitsInactive => 'Больше не работает';

  @override
  String splitsPercent(String value) {
    return '$value%';
  }

  @override
  String get splitsAmountUnknown =>
      'Суммы появятся, когда будут указаны цена и ставка';

  @override
  String get splitsAdd => 'Разделить комиссию';

  @override
  String get splitsEdit => 'Изменить сплит';

  @override
  String get splitsClear => 'Вернуть всё агенту';

  @override
  String get splitsLoadFailed => 'Не удалось загрузить сплит комиссии';

  @override
  String get splitsAddColleague => 'Добавить коллегу';

  @override
  String get splitsAddCoBroker => 'Добавить ко-брокера';

  @override
  String get splitsCoBrokerName => 'Имя ко-брокера';

  @override
  String get splitsCoBrokerNameHint => 'Иван Петров';

  @override
  String get splitsCoBrokerAgency => 'Их агентство';

  @override
  String get splitsCoBrokerAgencyHint => 'Необязательно';

  @override
  String get splitsCoBrokerNameMissing => 'Укажите имя ко-брокера';

  @override
  String get splitsShare => 'Доля, %';

  @override
  String get splitsRemove => 'Убрать';

  @override
  String splitsTotal(String value) {
    return 'Итого $value%';
  }

  @override
  String get splitsTotalMustBe100 => 'Доли должны в сумме давать 100%';

  @override
  String get splitsPercentInvalid =>
      'Доля больше 0 и не больше 100, до двух знаков после запятой';

  @override
  String get splitsBalance => 'Остаток — агенту сделки';

  @override
  String get splitsPickColleague => 'Выберите коллегу';

  @override
  String get splitsSearchColleague => 'Поиск по имени';

  @override
  String get splitsNoColleagues => 'Больше некого добавить';

  @override
  String get splitsTooMany => 'Комиссию делят не больше 10 человек';

  @override
  String get splitsColleagueInactive =>
      'Долю можно дать только действующему сотруднику агентства';

  @override
  String get splitsShareNote =>
      'Комиссия по разделённой сделке засчитывается каждому по его доле; доля ко-брокера в сумму агентства не входит.';
}
