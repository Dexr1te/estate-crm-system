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
  String get adminInvite => 'Пригласить';

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
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Введите выданный вам код приглашения и придумайте пароль.';

  @override
  String get authAcceptYourInvite => 'Примите приглашение';

  @override
  String get authActivate => 'Активировать';

  @override
  String get authBackToSignIn => 'Назад ко входу';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authEmailInvalid => 'Введите корректную эл. почту';

  @override
  String get authEmailRequired => 'Укажите эл. почту';

  @override
  String get authHaveAnInvite => 'Есть приглашение?';

  @override
  String get authInviteCode => 'Код приглашения';

  @override
  String get authInviteCodeRequired => 'Укажите код приглашения';

  @override
  String get authNewPassword => 'Новый пароль';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordHelp => 'Минимум 8 символов, одна цифра.';

  @override
  String get authPasswordMinLength => 'Не менее 6 символов';

  @override
  String get authPasswordRequired => 'Укажите пароль';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authSetPasswordContinue => 'Задать пароль и продолжить';

  @override
  String get authSetPasswordSignIn => 'Задать пароль и войти';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInSubtitle => 'Войдите, чтобы управлять своими объектами';

  @override
  String get authWelcomeBack => 'С возвращением!';

  @override
  String get clientsAddClient => 'Добавить клиента';

  @override
  String get clientsAddFirstClient => 'Добавьте первого клиента';

  @override
  String get clientsAddShort => 'Клиент';

  @override
  String get clientsAgent => 'Агент';

  @override
  String clientsAgentMeta(Object name) {
    return 'агент $name';
  }

  @override
  String get clientsBuyer => 'Покупатель';

  @override
  String get clientsCancel => 'Отмена';

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
  String get clientsContact => 'Контакт';

  @override
  String get clientsContactInfo => 'Контактная информация';

  @override
  String clientsCounter(Object active, Object total) {
    return '$total всего · $active в работе';
  }

  @override
  String get clientsCreateClient => 'Создать клиента';

  @override
  String get clientsCreated => 'Создано';

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
  String clientsDeleteConfirm(Object name) {
    return 'Удалить «$name»?';
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
  String get clientsFilterSellers => 'Продавцы';

  @override
  String get clientsFullName => 'Полное имя';

  @override
  String get clientsFullNameLabel => 'Полное имя *';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Неверный email';

  @override
  String get clientsMessage => 'Написать';

  @override
  String get clientsNameRequired => 'Укажите имя';

  @override
  String get clientsNewClient => 'Новый клиент';

  @override
  String get clientsNoClientsFound => 'Клиенты не найдены';

  @override
  String get clientsNoEmail => 'Эл. почта не указана';

  @override
  String get clientsNoPhone => 'Телефон не указан';

  @override
  String get clientsNotes => 'Заметки';

  @override
  String get clientsNotesHint => 'Дополнительные заметки об этом клиенте…';

  @override
  String get clientsPhone => 'Телефон';

  @override
  String get clientsSearchHint => 'Поиск по имени, телефону…';

  @override
  String get clientsSeller => 'Продавец';

  @override
  String get clientsTimestamps => 'Отметки времени';

  @override
  String get clientsTitle => 'Клиенты';

  @override
  String get clientsTryDifferentSearch => 'Попробуйте другой запрос';

  @override
  String get clientsUpdateClient => 'Обновить клиента';

  @override
  String get clientsUpdated => 'Обновлено';

  @override
  String clientsUpdatedAt(Object date) {
    return 'Обновлено $date';
  }

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
  String get coreLogout => 'Выйти';

  @override
  String get coreNavAdmin => 'Администрирование';

  @override
  String get coreNavClients => 'Клиенты';

  @override
  String get coreNavDashboard => 'Панель';

  @override
  String get coreNavDeals => 'Сделки';

  @override
  String get coreNavMeetings => 'Встречи';

  @override
  String get coreNavProperties => 'Объекты';

  @override
  String get coreNavTeam => 'Команда';

  @override
  String get coreNoResults => 'Ничего не найдено';

  @override
  String get coreNotSelected => 'Не выбран';

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
  String dashboardActiveDeals(Object count) {
    return '$count активных';
  }

  @override
  String get dashboardActiveDealsLabel => 'Активных сделок';

  @override
  String get dashboardAddClient => 'Добавить клиента';

  @override
  String get dashboardAddProperty => 'Добавить объект';

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
  String get dashboardConversion => 'Конверсия';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · сводка команды';
  }

  @override
  String dashboardDecidedDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сделок завершено',
      few: '$count сделки завершены',
      one: '1 сделка завершена',
      zero: 'Пока ничего не закрыто',
    );
    return '$_temp0';
  }

  @override
  String get dashboardGoalClear => 'Убрать цель';

  @override
  String get dashboardGoalEyebrow => 'ЦЕЛЬ';

  @override
  String get dashboardGoalReached =>
      'Цель достигнута. Всё дальше — сверх плана.';

  @override
  String dashboardGoalRemaining(Object amount) {
    return 'До цели осталось $amount';
  }

  @override
  String get dashboardGoalSheetField => 'Сумма';

  @override
  String get dashboardGoalSheetHint =>
      'Засчитываются выигранные сделки. Хранится только на этом устройстве.';

  @override
  String get dashboardGoalSheetTitle => 'Цель на месяц';

  @override
  String get dashboardGoalTitle => 'Закрыто за месяц';

  @override
  String get dashboardGoalUnset =>
      'Нажмите, чтобы задать цель на месяц и следить за ней здесь';

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
  String get dashboardMeetingLoad => 'Ближайшие две недели';

  @override
  String get dashboardMeetingsLabel => 'Встречи';

  @override
  String get dashboardMeetingsSubtitle => 'встречи';

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
  String get dashboardOverviewSubtitle => 'Ваша сводка на сегодня';

  @override
  String get dashboardOverviewTitle => 'Обзор';

  @override
  String get dashboardQuickActions => 'Быстрые действия';

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
  String get dashboardTotalDeals => 'Всего сделок';

  @override
  String get dashboardUpcoming => 'Предстоящие';

  @override
  String get dashboardUpcomingMeetings => 'Предстоящие встречи';

  @override
  String get dashboardValueByStage => 'Суммы по стадиям';

  @override
  String get dealsAddDeal => 'Добавить сделку';

  @override
  String get dealsAddShort => 'Сделка';

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
  String get dealsCancel => 'Отмена';

  @override
  String get dealsClient => 'Клиент';

  @override
  String dealsClientRef(Object id) {
    return 'Клиент №$id';
  }

  @override
  String get dealsClosed => 'Закрыта';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active активных · $total';
  }

  @override
  String get dealsCreateDeal => 'Создать сделку';

  @override
  String get dealsCreated => 'Создана';

  @override
  String get dealsDealPrice => 'Цена сделки';

  @override
  String dealsDeleteCascade(Object title) {
    return '«$title» будет удалена безвозвратно. Отменить действие нельзя.';
  }

  @override
  String dealsDeleteConfirm(Object title) {
    return 'Удалить «$title»?';
  }

  @override
  String get dealsDeleteTitle => 'Удалить сделку';

  @override
  String get dealsDetails => 'Детали';

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
  String get dealsLoading => 'Загрузка…';

  @override
  String get dealsNewTitle => 'Новая сделка';

  @override
  String dealsNextCall(Object when) {
    return 'звонок $when';
  }

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
  String get dealsStatusClosedLost => 'Закрыта с потерей';

  @override
  String get dealsStatusClosedWon => 'Успешно закрыта';

  @override
  String get dealsStatusLead => 'Лид';

  @override
  String get dealsStatusNegotiation => 'Переговоры';

  @override
  String get dealsStatusNotes => 'Статус и заметки';

  @override
  String dealsTapToSelect(Object label) {
    return 'Нажмите, чтобы выбрать $label';
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
  String get dealsTitleLabel => 'Название *';

  @override
  String get dealsTitleRequired => 'Название обязательно';

  @override
  String get dealsUpdateDeal => 'Обновить сделку';

  @override
  String get meetingsAddShort => 'Встреча';

  @override
  String get meetingsAgendaHint => 'Повестка встречи, темы для обсуждения…';

  @override
  String get meetingsAgent => 'Агент';

  @override
  String meetingsAgentNumber(Object id) {
    return 'Агент №$id';
  }

  @override
  String get meetingsCancel => 'Отмена';

  @override
  String get meetingsClient => 'Клиент';

  @override
  String meetingsClientNumber(Object id) {
    return 'Клиент №$id';
  }

  @override
  String get meetingsCompleted => 'Выполнено';

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
  String get meetingsDeleteConfirm => 'Удалить эту встречу?';

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
  String get meetingsLoading => 'Загрузка…';

  @override
  String get meetingsLocation => 'Место';

  @override
  String get meetingsMarkComplete => 'Отметить выполненной';

  @override
  String get meetingsNoLocation => 'У встречи не указано место';

  @override
  String get meetingsNoMeetings => 'Нет встреч';

  @override
  String get meetingsNoResults => 'Ничего не найдено';

  @override
  String get meetingsNoResultsSubtitle =>
      'В этом диапазоне ничего не запланировано';

  @override
  String get meetingsNote => 'Заметка к встрече';

  @override
  String get meetingsPeopleAndDeal => 'Участники и сделка';

  @override
  String get meetingsPleaseSelectAgent => 'Пожалуйста, выберите агента';

  @override
  String get meetingsPleaseSelectClient => 'Пожалуйста, выберите клиента';

  @override
  String get meetingsPleaseSelectDateTime =>
      'Пожалуйста, выберите дату и время';

  @override
  String get meetingsSchedule => 'Запланировать';

  @override
  String get meetingsScheduleFirst => 'Запланируйте свою первую встречу';

  @override
  String get meetingsScheduleMeeting => 'Запланировать встречу';

  @override
  String get meetingsSearchByNameOrId => 'Поиск по имени или ID…';

  @override
  String get meetingsSelectDateTime => 'Выберите дату и время *';

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
  String meetingsTapToSelect(Object label) {
    return 'Нажмите, чтобы выбрать: $label';
  }

  @override
  String get meetingsTime => 'Время';

  @override
  String get meetingsTitle => 'Встречи';

  @override
  String get meetingsTitleFieldLabel => 'Название *';

  @override
  String get meetingsTitleRequired => 'Название обязательно';

  @override
  String get meetingsUpcomingEyebrow => 'Сейчас ближайшая';

  @override
  String get meetingsUpdateMeeting => 'Обновить встречу';

  @override
  String get meetingsWhen => 'Когда';

  @override
  String get meetingsWhoAndWhere => 'С кем и где';

  @override
  String get profileAbout => 'О приложении';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileAgentId => 'ID агента';

  @override
  String get profileAgentIdCopied => 'ID агента скопирован';

  @override
  String get profileApp => 'Приложение';

  @override
  String get profileBuiltForTeams => 'Создано для команд по недвижимости';

  @override
  String get profileCancel => 'Отмена';

  @override
  String get profileDarkMode => 'Тёмная тема';

  @override
  String get profileEditName => 'Изменить имя';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFollowSystem => 'По системе';

  @override
  String get profileFullName => 'Полное имя';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileName => 'Имя';

  @override
  String get profileNameUpdated => 'Имя обновлено локально';

  @override
  String get profilePreferences => 'Настройки';

  @override
  String get profileRole => 'Роль';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileSignOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get profileSystemDefault => 'Системный';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileVersion => 'Версия';

  @override
  String get propertiesAdd => 'Добавить';

  @override
  String get propertiesAddFirstListing => 'Добавьте первый объект';

  @override
  String get propertiesAddShort => 'Объект';

  @override
  String get propertiesAddressLabel => 'Адрес *';

  @override
  String get propertiesAgent => 'Агент';

  @override
  String get propertiesAll => 'Все';

  @override
  String get propertiesApply => 'Применить';

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
  String get propertiesCancel => 'Отмена';

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
  String propertiesDeleteConfirm(Object title) {
    return 'Удалить «$title»?';
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
  String get propertiesLocation => 'Расположение';

  @override
  String get propertiesNewProperty => 'Новый объект';

  @override
  String get propertiesNextDetails => 'Далее — детали';

  @override
  String get propertiesNoProperties => 'Нет объектов';

  @override
  String get propertiesNoResultsSubtitle => 'Измените запрос или фильтр';

  @override
  String get propertiesPriceLabel => 'Цена *';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price за м²';
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
  String get propertiesRooms => 'Комнаты';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms комн.';
  }

  @override
  String get propertiesSearchHint => 'Поиск...';

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
  String get propertiesTitleLabel => 'Название *';

  @override
  String get propertiesTotalFloors => 'Всего этажей';

  @override
  String get propertiesType => 'Тип';

  @override
  String get propertiesTypeAndStatus => 'Тип и статус';

  @override
  String get propertiesUpdateProperty => 'Обновить объект';

  @override
  String get propertiesUpdateStatus => 'Обновить статус';

  @override
  String get teamsActive => 'Активные';

  @override
  String get teamsAgents => 'Агенты';

  @override
  String get teamsClients => 'Клиенты';

  @override
  String get teamsCouldNotLoadStats => 'Не удалось загрузить статистику';

  @override
  String get teamsCreate => 'Создать';

  @override
  String get teamsCreateTeam => 'Создать команду';

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
  String get teamsInviteAgent => 'Пригласить агента';

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
  String get teamsMyTeam => 'Моя команда';

  @override
  String get teamsNoManager => 'Без менеджера';

  @override
  String get teamsNoTeamSubtitle => 'Вы не управляете командой';

  @override
  String get teamsNoTeamYet => 'Пока нет команды';

  @override
  String get teamsPhoneOptional => 'Телефон (необязательно)';

  @override
  String get teamsRequired => 'Обязательно';

  @override
  String get teamsSave => 'Сохранить';

  @override
  String get teamsSendInvite => 'Отправить приглашение';

  @override
  String get teamsTeamName => 'Название команды';

  @override
  String get teamsUpcoming => 'Предстоящие';
}
