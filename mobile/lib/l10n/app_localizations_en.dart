// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get adminActivate => 'Activate';

  @override
  String get adminAssignTeam => 'Assign team';

  @override
  String get adminAssignToTeam => 'Assign to team';

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
  String get adminInviteInstructions =>
      'They open the app, tap “Have an invite?” on the login screen, paste this code and choose their own password.';

  @override
  String get adminInviteUser => 'Invite user';

  @override
  String adminInvitedAs(String name, String email, String role) {
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
  String get authAcceptInviteSubtitle =>
      'Enter the invite code you were given and choose a password.';

  @override
  String get authAcceptYourInvite => 'Accept your invite';

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
  String get authPasswordMinLength => 'At least 6 characters';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authSetPasswordContinue => 'Set password & continue';

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
  String get clientsAgent => 'Agent';

  @override
  String get clientsBuyer => '🏠 Buyer';

  @override
  String get clientsCancel => 'Cancel';

  @override
  String clientsClientCreatedId(int id) {
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
  String get clientsCreateClient => 'Create Client';

  @override
  String get clientsCreated => 'Created';

  @override
  String clientsDealCount(int count) {
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
  String get clientsDeleteClient => 'Delete Client';

  @override
  String clientsDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get clientsEdit => 'Edit';

  @override
  String get clientsEditClient => 'Edit Client';

  @override
  String get clientsEmail => 'Email';

  @override
  String get clientsFullNameLabel => 'Full Name *';

  @override
  String clientsIdBadge(int id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Invalid email';

  @override
  String get clientsNameRequired => 'Name is required';

  @override
  String get clientsNewClient => 'New Client';

  @override
  String get clientsNoClientsFound => 'No clients found';

  @override
  String get clientsNotes => 'Notes';

  @override
  String get clientsNotesHint => 'Additional notes about this client…';

  @override
  String get clientsPhone => 'Phone';

  @override
  String get clientsSearchHint => 'Search clients...';

  @override
  String get clientsSeller => '💰 Seller';

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
  String get coreCancel => 'Cancel';

  @override
  String get coreClientTypeBuyer => 'Buyer';

  @override
  String get coreClientTypeSeller => 'Seller';

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
  String get coreRetry => 'Retry';

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
  String dashboardActiveDeals(int count) {
    return '$count active';
  }

  @override
  String get dashboardAddClient => 'Add Client';

  @override
  String get dashboardAddProperty => 'Add Property';

  @override
  String get dashboardClients => 'Clients';

  @override
  String get dashboardClosedWon => 'Closed Won';

  @override
  String dashboardGreeting(String greeting, String name) {
    return '$greeting, $name ✨';
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
  String get dashboardMeetingsSubtitle => 'meetings';

  @override
  String get dashboardNewDeal => 'New Deal';

  @override
  String get dashboardNoUpcomingMeetings => 'No upcoming meetings';

  @override
  String get dashboardOverviewSubtitle => 'Here\'s your overview for today';

  @override
  String get dashboardOverviewTitle => 'Overview';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardScheduleMeeting => 'Schedule Meeting';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardTotalDeals => 'Total Deals';

  @override
  String get dashboardUpcoming => 'Upcoming';

  @override
  String get dashboardUpcomingMeetings => 'Upcoming Meetings';

  @override
  String get dealsAddDeal => 'Add Deal';

  @override
  String get dealsAgent => 'Agent';

  @override
  String dealsAgentValue(String name) {
    return 'Agent: $name';
  }

  @override
  String get dealsBudget => 'Budget';

  @override
  String dealsBudgetValue(String price) {
    return 'Budget: $price';
  }

  @override
  String get dealsCancel => 'Cancel';

  @override
  String get dealsClient => 'Client';

  @override
  String get dealsClosed => 'Closed';

  @override
  String get dealsCreateDeal => 'Create Deal';

  @override
  String get dealsCreated => 'Created';

  @override
  String get dealsDealPrice => 'Deal Price';

  @override
  String dealsDeleteConfirm(String title) {
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
  String get dealsFinancials => 'Financials';

  @override
  String get dealsIdCopied => 'Deal ID copied';

  @override
  String dealsIdLabel(int id) {
    return 'Deal ID: $id';
  }

  @override
  String get dealsLoading => 'Loading…';

  @override
  String get dealsNewTitle => 'New Deal';

  @override
  String get dealsNoResults => 'No results';

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
  String get dealsSearchHint => 'Search by name or ID…';

  @override
  String get dealsSelectAgentError => 'Please select an agent';

  @override
  String get dealsSelectClientError => 'Please select a client';

  @override
  String dealsSelectLabel(String label) {
    return 'Select $label';
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
  String dealsTapToSelect(String label) {
    return 'Tap to select $label';
  }

  @override
  String get dealsTitle => 'Deals';

  @override
  String get dealsTitleLabel => 'Title *';

  @override
  String get dealsTitleRequired => 'Title is required';

  @override
  String get dealsUpdateDeal => 'Update Deal';

  @override
  String get meetingsAgendaHint => 'Meeting agenda, talking points…';

  @override
  String get meetingsAgent => 'Agent';

  @override
  String meetingsAgentNumber(int id) {
    return 'Agent #$id';
  }

  @override
  String get meetingsCancel => 'Cancel';

  @override
  String get meetingsClient => 'Client';

  @override
  String meetingsClientNumber(int id) {
    return 'Client #$id';
  }

  @override
  String get meetingsCompleted => 'Completed';

  @override
  String get meetingsDeal => 'Deal';

  @override
  String meetingsDealNumber(int id) {
    return 'Deal #$id';
  }

  @override
  String get meetingsDelete => 'Delete';

  @override
  String get meetingsDeleteConfirm => 'Delete this meeting?';

  @override
  String get meetingsDeleteMeeting => 'Delete Meeting';

  @override
  String get meetingsDescription => 'Description';

  @override
  String get meetingsDetails => 'Details';

  @override
  String get meetingsEdit => 'Edit';

  @override
  String get meetingsEditMeeting => 'Edit Meeting';

  @override
  String get meetingsLoading => 'Loading…';

  @override
  String get meetingsLocation => 'Location';

  @override
  String get meetingsMarkComplete => 'Mark Complete';

  @override
  String get meetingsNoMeetings => 'No meetings';

  @override
  String get meetingsNoResults => 'No results';

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
  String meetingsSelectEntity(String label) {
    return 'Select $label';
  }

  @override
  String meetingsTapToSelect(String label) {
    return 'Tap to select $label';
  }

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get meetingsTitleFieldLabel => 'Title *';

  @override
  String get meetingsTitleRequired => 'Title is required';

  @override
  String get meetingsUpdateMeeting => 'Update Meeting';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileAgentId => 'Agent ID';

  @override
  String get profileAgentIdCopied => 'Agent ID copied';

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
  String get profileFullName => 'Full Name';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNameUpdated => 'Name updated locally';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileRole => 'Role';

  @override
  String get profileSave => 'Save';

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
  String propertiesAreaValue(String area) {
    return '$area m²';
  }

  @override
  String get propertiesBasicInfo => 'Basic Info';

  @override
  String get propertiesCancel => 'Cancel';

  @override
  String get propertiesCityLabel => 'City';

  @override
  String get propertiesCreateProperty => 'Create Property';

  @override
  String get propertiesDelete => 'Delete';

  @override
  String propertiesDeleteConfirm(String title) {
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
  String propertiesFieldRequired(String label) {
    return '$label is required';
  }

  @override
  String get propertiesFilters => 'Filters';

  @override
  String get propertiesFloor => 'Floor';

  @override
  String get propertiesLocation => 'Location';

  @override
  String get propertiesNewProperty => 'New Property';

  @override
  String get propertiesNoProperties => 'No properties';

  @override
  String get propertiesPriceLabel => 'Price *';

  @override
  String get propertiesProperty => 'Property';

  @override
  String propertiesPropertyCreated(int id) {
    return 'Property created (ID: $id)';
  }

  @override
  String get propertiesPropertyIdCopied => 'Property ID copied';

  @override
  String propertiesPropertyIdLabel(int id) {
    return 'Property ID: $id';
  }

  @override
  String get propertiesPropertyNotFound => 'Property not found';

  @override
  String get propertiesRooms => 'Rooms';

  @override
  String propertiesRoomsCount(int rooms) {
    return '$rooms rooms';
  }

  @override
  String get propertiesSearchHint => 'Search...';

  @override
  String get propertiesStatus => 'Status';

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
  String teamsManagerLabel(String name) {
    return 'Manager: $name';
  }

  @override
  String get teamsManagerOptional => 'Manager (optional)';

  @override
  String teamsMemberCount(int count) {
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
