// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get adminActivate => 'Activate';

  @override
  String get adminAssignTeam => 'Assign team';

  @override
  String get adminAssignToTeam => 'Assign to team';

  @override
  String get adminAuditEmptyBody =>
      'Team activity shows up here: deals created, status changes, invitations.';

  @override
  String get adminChangeRole => 'Change role';

  @override
  String get adminConsoleTitle => 'Admin';

  @override
  String get adminCopyCode => 'Copy code';

  @override
  String get adminCouldNotLoadStats => 'Could not load stats';

  @override
  String get adminCreateInvite => 'Create invite';

  @override
  String get adminDataScope => 'Data scope';

  @override
  String get adminDeactivate => 'Deactivate';

  @override
  String get adminDone => 'Done';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminEnterValidEmail => 'Enter a valid email';

  @override
  String get adminFullName => 'Full name';

  @override
  String get adminInactive => 'INACTIVE';

  @override
  String get adminInvite => 'Invite';

  @override
  String get adminInviteCodeCopied => 'Invite code copied';

  @override
  String get adminInviteCreated => 'Invite created';

  @override
  String get adminInviteHelper =>
      'The code is emailed to them and stays valid for 7 days.';

  @override
  String get adminInviteInstructions =>
      'They open the app, tap “Have an invite?” on the login screen, paste this code and choose their own password.';

  @override
  String get adminInviteUser => 'Invite user';

  @override
  String adminInvitedAs(Object email, Object name, Object role) {
    return '$name ($email) was invited as $role.';
  }

  @override
  String get adminNewTeam => 'New team';

  @override
  String get adminNoAuditEntries => 'No audit entries';

  @override
  String get adminNoInviteToken =>
      'No invite token was returned. The user cannot set a password until this is resolved.';

  @override
  String get adminNoTeams => 'No teams';

  @override
  String get adminNoTeamsYet => 'No teams yet';

  @override
  String get adminNoUsers => 'No users';

  @override
  String get adminPhoneOptional => 'Phone (optional)';

  @override
  String get adminRequired => 'Required';

  @override
  String get adminResendInvite => 'Resend invite';

  @override
  String get adminRole => 'Role';

  @override
  String get adminShareInviteCode => 'Share this invite code with them:';

  @override
  String get adminStatActive => 'Active';

  @override
  String get adminStatClients => 'Clients';

  @override
  String get adminStatClosed => 'Closed';

  @override
  String get adminStatDeals => 'Deals';

  @override
  String get adminStatUpcoming => 'Upcoming';

  @override
  String get adminTabAudit => 'Audit';

  @override
  String get adminTabTeams => 'Teams';

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminViewStats => 'View stats';

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Enter the invite code you were given and choose a password.';

  @override
  String get authAcceptYourInvite => 'Accept your invite';

  @override
  String get authActivate => 'Activate';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authHaveAnInvite => 'Have an invite?';

  @override
  String get authInviteCode => 'Invite code';

  @override
  String get authInviteCodeRequired => 'Invite code is required';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHelp => 'At least 8 characters, including a digit.';

  @override
  String get authPasswordMinLength => 'At least 6 characters';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authSetPasswordContinue => 'Set password & continue';

  @override
  String get authSetPasswordSignIn => 'Set password & sign in';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignInSubtitle => 'Sign in to manage your properties';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get clientsAddClient => 'Add Client';

  @override
  String get clientsAddFirstClient => 'Add your first client';

  @override
  String get clientsAddShort => 'Client';

  @override
  String get clientsAgent => 'Agent';

  @override
  String clientsAgentMeta(Object name) {
    return 'agent $name';
  }

  @override
  String get clientsBuyer => 'Buyer';

  @override
  String get clientsCancel => 'Cancel';

  @override
  String clientsClientCreatedId(Object id) {
    return 'Client created (ID: $id)';
  }

  @override
  String get clientsClientFallback => 'Client';

  @override
  String get clientsClientIdCopied => 'Client ID copied';

  @override
  String get clientsClientNotFound => 'Client not found';

  @override
  String get clientsClientType => 'Client Type';

  @override
  String get clientsContact => 'Contact';

  @override
  String get clientsContactInfo => 'Contact Info';

  @override
  String clientsCounter(Object active, Object total) {
    return '$total total · $active in progress';
  }

  @override
  String get clientsCreateClient => 'Create Client';

  @override
  String get clientsCreated => 'Created';

  @override
  String clientsDealCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals',
      one: '1 deal',
    );
    return '$_temp0';
  }

  @override
  String get clientsDeals => 'Deals';

  @override
  String get clientsDelete => 'Delete';

  @override
  String clientsDeleteCascade(num count, Object name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count linked deals will be deleted permanently',
      one: 'and 1 linked deal will be deleted permanently',
      zero: 'will be deleted permanently',
    );
    return '$name $_temp0. This cannot be undone.';
  }

  @override
  String get clientsDeleteClient => 'Delete Client';

  @override
  String clientsDeleteConfirm(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get clientsEdit => 'Edit';

  @override
  String get clientsEditClient => 'Edit Client';

  @override
  String get clientsEmail => 'Email';

  @override
  String get clientsFilterAll => 'All';

  @override
  String get clientsFilterBuyers => 'Buyers';

  @override
  String get clientsFilterSellers => 'Sellers';

  @override
  String get clientsFullName => 'Full name';

  @override
  String get clientsFullNameLabel => 'Full Name *';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Invalid email';

  @override
  String get clientsMessage => 'Message';

  @override
  String get clientsNameRequired => 'Name is required';

  @override
  String get clientsNewClient => 'New Client';

  @override
  String get clientsNoClientsFound => 'No clients found';

  @override
  String get clientsNoEmail => 'No email address on file';

  @override
  String get clientsNoPhone => 'No phone number on file';

  @override
  String get clientsNotes => 'Notes';

  @override
  String get clientsNotesHint => 'Additional notes about this client…';

  @override
  String get clientsPhone => 'Phone';

  @override
  String get clientsSearchHint => 'Search by name, phone…';

  @override
  String get clientsSeller => 'Seller';

  @override
  String get clientsTimestamps => 'Timestamps';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsTryDifferentSearch => 'Try a different search';

  @override
  String get clientsUpdateClient => 'Update Client';

  @override
  String get clientsUpdated => 'Updated';

  @override
  String clientsUpdatedAt(Object date) {
    return 'Updated $date';
  }

  @override
  String get coreCall => 'Call';

  @override
  String get coreCancel => 'Cancel';

  @override
  String get coreClientTypeBuyer => 'Buyer';

  @override
  String get coreClientTypeSeller => 'Seller';

  @override
  String get coreDataScopeAll => 'All';

  @override
  String get coreDataScopeOwn => 'Own';

  @override
  String get coreDataScopeTeam => 'Team';

  @override
  String get coreDelete => 'Delete';

  @override
  String get coreLogout => 'Logout';

  @override
  String get coreNavAdmin => 'Admin';

  @override
  String get coreNavClients => 'Clients';

  @override
  String get coreNavDashboard => 'Dashboard';

  @override
  String get coreNavDeals => 'Deals';

  @override
  String get coreNavMeetings => 'Meetings';

  @override
  String get coreNavProperties => 'Properties';

  @override
  String get coreNavTeam => 'Team';

  @override
  String get coreNoResults => 'Nothing found';

  @override
  String get coreNotSelected => 'Not selected';

  @override
  String get coreOpen => 'Open';

  @override
  String get corePropertyTypeApartment => 'Apartment';

  @override
  String get corePropertyTypeCommercial => 'Commercial';

  @override
  String get corePropertyTypeHouse => 'House';

  @override
  String get corePropertyTypeLand => 'Land';

  @override
  String get corePropertyTypeOffice => 'Office';

  @override
  String get coreRetry => 'Retry';

  @override
  String get coreRoleAdmin => 'Admin';

  @override
  String get coreRoleAgent => 'Agent';

  @override
  String get coreRoleManager => 'Manager';

  @override
  String get coreSave => 'Save';

  @override
  String get coreStatusAvailable => 'Available';

  @override
  String get coreStatusLead => 'Lead';

  @override
  String get coreStatusLost => 'Lost';

  @override
  String get coreStatusNegotiation => 'Negotiation';

  @override
  String get coreStatusReserved => 'Reserved';

  @override
  String get coreStatusSold => 'Sold';

  @override
  String get coreStatusWon => 'Won';

  @override
  String dashboardActiveDeals(Object count) {
    return '$count active';
  }

  @override
  String get dashboardActiveDealsLabel => 'Active deals';

  @override
  String get dashboardAddClient => 'Add Client';

  @override
  String get dashboardAddProperty => 'Add Property';

  @override
  String dashboardAgentDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals',
      one: '1 deal',
    );
    return '$_temp0';
  }

  @override
  String dashboardAgentMeta(Object name) {
    return 'agent: $name';
  }

  @override
  String get dashboardAttention => 'Needs attention';

  @override
  String get dashboardClients => 'Clients';

  @override
  String get dashboardClosedWon => 'Closed Won';

  @override
  String get dashboardConversion => 'Conversion';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · team overview';
  }

  @override
  String dashboardDecidedDeals(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals decided',
      one: '1 deal decided',
      zero: 'Nothing closed yet',
    );
    return '$_temp0';
  }

  @override
  String get dashboardGoalClear => 'Remove target';

  @override
  String get dashboardGoalEyebrow => 'TARGET';

  @override
  String get dashboardGoalReached =>
      'Target reached. Everything from here is ahead of plan.';

  @override
  String dashboardGoalRemaining(Object amount) {
    return '$amount left to hit the target';
  }

  @override
  String get dashboardGoalSheetField => 'Amount';

  @override
  String get dashboardGoalSheetHint =>
      'Closed-won deals count towards it. Stored on this device only.';

  @override
  String get dashboardGoalSheetTitle => 'Monthly target';

  @override
  String get dashboardGoalTitle => 'Closed this month';

  @override
  String get dashboardGoalUnset =>
      'Tap to set a monthly target and track it here';

  @override
  String dashboardGreeting(Object greeting, Object name) {
    return '$greeting, $name';
  }

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardGreetingFallbackName => 'there';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingStillUp => 'Still up';

  @override
  String dashboardIdleDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'no movement for $count days',
      one: 'no movement for 1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashboardLeaderboard => 'Top agents';

  @override
  String dashboardLoadTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetings',
      one: '1 meeting',
      zero: 'nothing booked',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMeetingLoad => 'Next two weeks';

  @override
  String get dashboardMeetingsLabel => 'Meetings';

  @override
  String get dashboardMeetingsSubtitle => 'meetings';

  @override
  String get dashboardNewDeal => 'New Deal';

  @override
  String get dashboardNextMeeting => 'Next meeting';

  @override
  String get dashboardNoDealsYet => 'No deals yet';

  @override
  String get dashboardNoDealsYetHint =>
      'Your pipeline will appear here once you add one';

  @override
  String get dashboardNoMoreMeetingsToday => 'Nothing else scheduled today';

  @override
  String get dashboardNoPhone => 'No phone number on file for this client';

  @override
  String get dashboardNoUpcomingMeetings => 'No upcoming meetings';

  @override
  String get dashboardNothingScheduled => 'Nothing scheduled';

  @override
  String get dashboardNothingScheduledHint =>
      'Book a meeting and it will show up here';

  @override
  String get dashboardOverviewSubtitle => 'Here\'s your overview for today';

  @override
  String get dashboardOverviewTitle => 'Overview';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String dashboardRelativeInHours(Object count) {
    return 'in $count h';
  }

  @override
  String dashboardRelativeInMinutes(Object count) {
    return 'in $count min';
  }

  @override
  String get dashboardRelativeNow => 'now';

  @override
  String get dashboardRelativeToday => 'today';

  @override
  String get dashboardRelativeTomorrow => 'tomorrow';

  @override
  String get dashboardScheduleMeeting => 'Schedule Meeting';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardTeamPipeline => 'Team pipeline';

  @override
  String get dashboardToday => 'Today';

  @override
  String dashboardTodayCount(Object count) {
    return '$count today';
  }

  @override
  String get dashboardTopAgents => 'Top agents';

  @override
  String get dashboardTotalDeals => 'Total Deals';

  @override
  String get dashboardUpcoming => 'Upcoming';

  @override
  String get dashboardUpcomingMeetings => 'Upcoming Meetings';

  @override
  String get dashboardValueByStage => 'Value by stage';

  @override
  String get dealsAddDeal => 'Add Deal';

  @override
  String get dealsAddShort => 'Deal';

  @override
  String get dealsAgent => 'Agent';

  @override
  String dealsAgentRef(Object id) {
    return 'Agent #$id';
  }

  @override
  String dealsAgentValue(Object name) {
    return 'Agent: $name';
  }

  @override
  String get dealsBudget => 'Budget';

  @override
  String dealsBudgetValue(Object price) {
    return 'Budget: $price';
  }

  @override
  String get dealsCancel => 'Cancel';

  @override
  String get dealsClient => 'Client';

  @override
  String dealsClientRef(Object id) {
    return 'Client #$id';
  }

  @override
  String get dealsClosed => 'Closed';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active active · $total';
  }

  @override
  String get dealsCreateDeal => 'Create Deal';

  @override
  String get dealsCreated => 'Created';

  @override
  String get dealsDealPrice => 'Deal Price';

  @override
  String dealsDeleteCascade(Object title) {
    return '$title will be deleted permanently. This cannot be undone.';
  }

  @override
  String dealsDeleteConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get dealsDeleteTitle => 'Delete Deal';

  @override
  String get dealsDetails => 'Details';

  @override
  String get dealsEditTitle => 'Edit Deal';

  @override
  String get dealsEmptySubtitle => 'Start your pipeline';

  @override
  String get dealsEmptyTitle => 'No deals';

  @override
  String get dealsFallbackTitle => 'Deal';

  @override
  String get dealsFilterAll => 'All';

  @override
  String dealsFilterWithCount(Object count, Object label) {
    return '$label $count';
  }

  @override
  String get dealsFinancials => 'Financials';

  @override
  String get dealsIdCopied => 'Deal ID copied';

  @override
  String dealsIdLabel(Object id) {
    return 'Deal ID: $id';
  }

  @override
  String get dealsLoading => 'Loading…';

  @override
  String get dealsNewTitle => 'New Deal';

  @override
  String dealsNextCall(Object when) {
    return 'call $when';
  }

  @override
  String get dealsNoResults => 'No results';

  @override
  String get dealsNoResultsSubtitle => 'Try a different stage filter';

  @override
  String get dealsNotFound => 'Deal not found';

  @override
  String get dealsNotes => 'Notes';

  @override
  String get dealsNotesHint => 'Notes about this deal…';

  @override
  String get dealsPeopleProperty => 'People & Property';

  @override
  String get dealsPipelineStage => 'Pipeline Stage';

  @override
  String get dealsProperty => 'Property';

  @override
  String dealsPropertyRef(Object id) {
    return 'Property #$id';
  }

  @override
  String get dealsSearchHint => 'Search by name or ID…';

  @override
  String get dealsSelectAgentError => 'Please select an agent';

  @override
  String get dealsSelectClientError => 'Please select a client';

  @override
  String dealsSelectLabel(Object label) {
    return 'Select $label';
  }

  @override
  String dealsStaleWarning(Object days) {
    return 'no activity for $days days';
  }

  @override
  String get dealsStatusClosedLost => 'Closed Lost';

  @override
  String get dealsStatusClosedWon => 'Closed Won';

  @override
  String get dealsStatusLead => 'Lead';

  @override
  String get dealsStatusNegotiation => 'Negotiation';

  @override
  String get dealsStatusNotes => 'Status & Notes';

  @override
  String dealsTapToSelect(Object label) {
    return 'Tap to select $label';
  }

  @override
  String get dealsTimeline => 'Timeline';

  @override
  String get dealsTimelineClosed => 'Deal closed';

  @override
  String get dealsTimelineCreated => 'Created';

  @override
  String get dealsTimelineUpdated => 'Last updated';

  @override
  String get dealsTitle => 'Deals';

  @override
  String get dealsTitleLabel => 'Title *';

  @override
  String get dealsTitleRequired => 'Title is required';

  @override
  String get dealsUpdateDeal => 'Update Deal';

  @override
  String get meetingsAddShort => 'Meeting';

  @override
  String get meetingsAgendaHint => 'Meeting agenda, talking points…';

  @override
  String get meetingsAgent => 'Agent';

  @override
  String meetingsAgentNumber(Object id) {
    return 'Agent #$id';
  }

  @override
  String get meetingsCancel => 'Cancel';

  @override
  String get meetingsClient => 'Client';

  @override
  String meetingsClientNumber(Object id) {
    return 'Client #$id';
  }

  @override
  String get meetingsCompleted => 'Completed';

  @override
  String meetingsCounter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count this week',
      one: '1 this week',
    );
    return '$_temp0';
  }

  @override
  String get meetingsDate => 'Date';

  @override
  String get meetingsDeal => 'Deal';

  @override
  String meetingsDealNumber(Object id) {
    return 'Deal #$id';
  }

  @override
  String get meetingsDelete => 'Delete';

  @override
  String meetingsDeleteCascade(Object title) {
    return '$title will be deleted permanently. This cannot be undone.';
  }

  @override
  String get meetingsDeleteConfirm => 'Delete this meeting?';

  @override
  String get meetingsDeleteMeeting => 'Delete Meeting';

  @override
  String get meetingsDescription => 'Description';

  @override
  String get meetingsDetails => 'Details';

  @override
  String get meetingsDirections => 'Directions';

  @override
  String get meetingsEdit => 'Edit';

  @override
  String get meetingsEditMeeting => 'Edit Meeting';

  @override
  String get meetingsGroupToday => 'Today';

  @override
  String get meetingsGroupTomorrow => 'Tomorrow';

  @override
  String get meetingsLoading => 'Loading…';

  @override
  String get meetingsLocation => 'Location';

  @override
  String get meetingsMarkComplete => 'Mark Complete';

  @override
  String get meetingsNoLocation => 'No location on this meeting';

  @override
  String get meetingsNoMeetings => 'No meetings';

  @override
  String get meetingsNoResults => 'No results';

  @override
  String get meetingsNoResultsSubtitle => 'Nothing scheduled in this range';

  @override
  String get meetingsNote => 'Meeting note';

  @override
  String get meetingsPeopleAndDeal => 'People & Deal';

  @override
  String get meetingsPleaseSelectAgent => 'Please select an agent';

  @override
  String get meetingsPleaseSelectClient => 'Please select a client';

  @override
  String get meetingsPleaseSelectDateTime => 'Please select a date and time';

  @override
  String get meetingsSchedule => 'Schedule';

  @override
  String get meetingsScheduleFirst => 'Schedule your first meeting';

  @override
  String get meetingsScheduleMeeting => 'Schedule Meeting';

  @override
  String get meetingsSearchByNameOrId => 'Search by name or ID…';

  @override
  String get meetingsSelectDateTime => 'Select date & time *';

  @override
  String meetingsSelectEntity(Object label) {
    return 'Select $label';
  }

  @override
  String get meetingsStatus => 'Status';

  @override
  String get meetingsStatusHeld => 'Held';

  @override
  String get meetingsStatusScheduled => 'Scheduled';

  @override
  String meetingsTapToSelect(Object label) {
    return 'Tap to select $label';
  }

  @override
  String get meetingsTime => 'Time';

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get meetingsTitleFieldLabel => 'Title *';

  @override
  String get meetingsTitleRequired => 'Title is required';

  @override
  String get meetingsUpcomingEyebrow => 'Next up';

  @override
  String get meetingsUpdateMeeting => 'Update Meeting';

  @override
  String get meetingsWhen => 'When';

  @override
  String get meetingsWhoAndWhere => 'Who & where';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileAgentId => 'Agent ID';

  @override
  String get profileAgentIdCopied => 'Agent ID copied';

  @override
  String get profileApp => 'App';

  @override
  String get profileBuiltForTeams => 'Built for real estate teams';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileEditName => 'Edit Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFollowSystem => 'Follow system';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameUpdated => 'Name updated locally';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileRole => 'Role';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileSystemDefault => 'System default';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileVersion => 'Version';

  @override
  String get propertiesAdd => 'Add';

  @override
  String get propertiesAddFirstListing => 'Add your first listing';

  @override
  String get propertiesAddShort => 'Property';

  @override
  String get propertiesAddressLabel => 'Address *';

  @override
  String get propertiesAgent => 'Agent';

  @override
  String get propertiesAll => 'All';

  @override
  String get propertiesApply => 'Apply';

  @override
  String get propertiesArea => 'Area';

  @override
  String get propertiesAreaLabel => 'Area m²';

  @override
  String propertiesAreaValue(Object area) {
    return '$area m²';
  }

  @override
  String get propertiesBack => 'Back';

  @override
  String get propertiesBasicInfo => 'Basic Info';

  @override
  String get propertiesCancel => 'Cancel';

  @override
  String get propertiesCityLabel => 'City';

  @override
  String propertiesCounter(Object reserved, Object total) {
    return '$total listed · $reserved reserved';
  }

  @override
  String get propertiesCreateProperty => 'Create Property';

  @override
  String get propertiesDelete => 'Delete';

  @override
  String propertiesDeleteCascade(Object title) {
    return '$title will be deleted permanently. This cannot be undone.';
  }

  @override
  String propertiesDeleteConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get propertiesDeleteProperty => 'Delete Property';

  @override
  String get propertiesDescribeHint => 'Describe the property…';

  @override
  String get propertiesDescription => 'Description';

  @override
  String get propertiesDetails => 'Details';

  @override
  String get propertiesEdit => 'Edit';

  @override
  String get propertiesEditProperty => 'Edit Property';

  @override
  String propertiesFieldRequired(Object label) {
    return '$label is required';
  }

  @override
  String get propertiesFilters => 'Filters';

  @override
  String get propertiesFloor => 'Floor';

  @override
  String propertiesFloorOf(Object floor, Object total) {
    return '$floor of $total';
  }

  @override
  String get propertiesLocation => 'Location';

  @override
  String get propertiesNewProperty => 'New Property';

  @override
  String get propertiesNextDetails => 'Next — details';

  @override
  String get propertiesNoProperties => 'No properties';

  @override
  String get propertiesNoResultsSubtitle => 'Try a different search or filter';

  @override
  String get propertiesPriceLabel => 'Price *';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price per m²';
  }

  @override
  String get propertiesProperty => 'Property';

  @override
  String propertiesPropertyCreated(Object id) {
    return 'Property created (ID: $id)';
  }

  @override
  String get propertiesPropertyIdCopied => 'Property ID copied';

  @override
  String propertiesPropertyIdLabel(Object id) {
    return 'Property ID: $id';
  }

  @override
  String get propertiesPropertyNotFound => 'Property not found';

  @override
  String get propertiesRooms => 'Rooms';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms rooms';
  }

  @override
  String get propertiesSearchHint => 'Search...';

  @override
  String get propertiesSearchHintFull => 'Address, complex, ID…';

  @override
  String get propertiesStatus => 'Status';

  @override
  String propertiesStepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get propertiesTitle => 'Properties';

  @override
  String get propertiesTitleLabel => 'Title *';

  @override
  String get propertiesTotalFloors => 'Total Floors';

  @override
  String get propertiesType => 'Type';

  @override
  String get propertiesTypeAndStatus => 'Type & Status';

  @override
  String get propertiesUpdateProperty => 'Update Property';

  @override
  String get propertiesUpdateStatus => 'Update Status';

  @override
  String get teamsActive => 'Active';

  @override
  String get teamsAgents => 'Agents';

  @override
  String get teamsClients => 'Clients';

  @override
  String get teamsCouldNotLoadStats => 'Could not load stats';

  @override
  String get teamsCreate => 'Create';

  @override
  String get teamsCreateTeam => 'Create team';

  @override
  String get teamsDeals => 'Deals';

  @override
  String get teamsEditTeam => 'Edit team';

  @override
  String get teamsEmail => 'Email';

  @override
  String get teamsEnterValidEmail => 'Enter a valid email';

  @override
  String get teamsFullName => 'Full name';

  @override
  String get teamsInviteAgent => 'Invite agent';

  @override
  String teamsManagerLabel(Object name) {
    return 'Manager: $name';
  }

  @override
  String get teamsManagerOptional => 'Manager (optional)';

  @override
  String teamsMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get teamsMyTeam => 'My Team';

  @override
  String get teamsNoManager => 'No manager';

  @override
  String get teamsNoTeamSubtitle => 'You are not managing a team';

  @override
  String get teamsNoTeamYet => 'No team yet';

  @override
  String get teamsPhoneOptional => 'Phone (optional)';

  @override
  String get teamsRequired => 'Required';

  @override
  String get teamsSave => 'Save';

  @override
  String get teamsSendInvite => 'Send invite';

  @override
  String get teamsTeamName => 'Team name';

  @override
  String get teamsUpcoming => 'Upcoming';
}
