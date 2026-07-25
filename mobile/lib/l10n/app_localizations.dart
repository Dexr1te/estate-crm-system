import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Estate CRM'**
  String get appTitle;

  /// No description provided for @adminActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminActivate;

  /// No description provided for @adminAssignTeam.
  ///
  /// In en, this message translates to:
  /// **'Assign team'**
  String get adminAssignTeam;

  /// No description provided for @adminAssignToTeam.
  ///
  /// In en, this message translates to:
  /// **'Assign to team'**
  String get adminAssignToTeam;

  /// No description provided for @adminChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get adminChangeRole;

  /// No description provided for @adminConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminConsoleTitle;

  /// No description provided for @adminCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get adminCopyCode;

  /// No description provided for @adminCouldNotLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Could not load stats'**
  String get adminCouldNotLoadStats;

  /// No description provided for @adminCreateInvite.
  ///
  /// In en, this message translates to:
  /// **'Create invite'**
  String get adminCreateInvite;

  /// No description provided for @adminDataScope.
  ///
  /// In en, this message translates to:
  /// **'Data scope'**
  String get adminDataScope;

  /// No description provided for @adminDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get adminDeactivate;

  /// No description provided for @adminDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adminDone;

  /// No description provided for @adminEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmail;

  /// No description provided for @adminEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get adminEnterValidEmail;

  /// No description provided for @adminFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get adminFullName;

  /// No description provided for @adminInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get adminInactive;

  /// No description provided for @adminInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get adminInvite;

  /// No description provided for @adminInviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get adminInviteCodeCopied;

  /// No description provided for @adminInviteCreated.
  ///
  /// In en, this message translates to:
  /// **'Invite created'**
  String get adminInviteCreated;

  /// No description provided for @adminInviteInstructions.
  ///
  /// In en, this message translates to:
  /// **'They open the app, tap “Have an invite?” on the login screen, paste this code and choose their own password.'**
  String get adminInviteInstructions;

  /// No description provided for @adminInviteUser.
  ///
  /// In en, this message translates to:
  /// **'Invite user'**
  String get adminInviteUser;

  /// No description provided for @adminInvitedAs.
  ///
  /// In en, this message translates to:
  /// **'{name} ({email}) was invited as {role}.'**
  String adminInvitedAs(String name, String email, String role);

  /// No description provided for @adminNewTeam.
  ///
  /// In en, this message translates to:
  /// **'New team'**
  String get adminNewTeam;

  /// No description provided for @adminNoAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No audit entries'**
  String get adminNoAuditEntries;

  /// No description provided for @adminNoInviteToken.
  ///
  /// In en, this message translates to:
  /// **'No invite token was returned. The user cannot set a password until this is resolved.'**
  String get adminNoInviteToken;

  /// No description provided for @adminNoTeams.
  ///
  /// In en, this message translates to:
  /// **'No teams'**
  String get adminNoTeams;

  /// No description provided for @adminNoTeamsYet.
  ///
  /// In en, this message translates to:
  /// **'No teams yet'**
  String get adminNoTeamsYet;

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get adminNoUsers;

  /// No description provided for @adminPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get adminPhoneOptional;

  /// No description provided for @adminRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminRequired;

  /// No description provided for @adminResendInvite.
  ///
  /// In en, this message translates to:
  /// **'Resend invite'**
  String get adminResendInvite;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRole;

  /// No description provided for @adminShareInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Share this invite code with them:'**
  String get adminShareInviteCode;

  /// No description provided for @adminStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatActive;

  /// No description provided for @adminStatClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get adminStatClients;

  /// No description provided for @adminStatClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get adminStatClosed;

  /// No description provided for @adminStatDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get adminStatDeals;

  /// No description provided for @adminStatUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get adminStatUpcoming;

  /// No description provided for @adminTabAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get adminTabAudit;

  /// No description provided for @adminTabTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get adminTabTeams;

  /// No description provided for @adminTabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminTabUsers;

  /// No description provided for @adminViewStats.
  ///
  /// In en, this message translates to:
  /// **'View stats'**
  String get adminViewStats;

  /// No description provided for @authAcceptInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code you were given and choose a password.'**
  String get authAcceptInviteSubtitle;

  /// No description provided for @authAcceptYourInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept your invite'**
  String get authAcceptYourInvite;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// No description provided for @authHaveAnInvite.
  ///
  /// In en, this message translates to:
  /// **'Have an invite?'**
  String get authHaveAnInvite;

  /// No description provided for @authInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get authInviteCode;

  /// No description provided for @authInviteCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Invite code is required'**
  String get authInviteCodeRequired;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authSetPasswordContinue.
  ///
  /// In en, this message translates to:
  /// **'Set password & continue'**
  String get authSetPasswordContinue;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your properties'**
  String get authSignInSubtitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get authWelcomeBack;

  /// No description provided for @clientsAddClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get clientsAddClient;

  /// No description provided for @clientsAddFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add your first client'**
  String get clientsAddFirstClient;

  /// No description provided for @clientsAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get clientsAgent;

  /// No description provided for @clientsBuyer.
  ///
  /// In en, this message translates to:
  /// **'🏠 Buyer'**
  String get clientsBuyer;

  /// No description provided for @clientsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get clientsCancel;

  /// No description provided for @clientsClientCreatedId.
  ///
  /// In en, this message translates to:
  /// **'Client created (ID: {id})'**
  String clientsClientCreatedId(int id);

  /// No description provided for @clientsClientFallback.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientsClientFallback;

  /// No description provided for @clientsClientIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Client ID copied'**
  String get clientsClientIdCopied;

  /// No description provided for @clientsClientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Client not found'**
  String get clientsClientNotFound;

  /// No description provided for @clientsClientType.
  ///
  /// In en, this message translates to:
  /// **'Client Type'**
  String get clientsClientType;

  /// No description provided for @clientsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get clientsContact;

  /// No description provided for @clientsContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get clientsContactInfo;

  /// No description provided for @clientsCreateClient.
  ///
  /// In en, this message translates to:
  /// **'Create Client'**
  String get clientsCreateClient;

  /// No description provided for @clientsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get clientsCreated;

  /// No description provided for @clientsDealCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deal} other{{count} deals}}'**
  String clientsDealCount(int count);

  /// No description provided for @clientsDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get clientsDeals;

  /// No description provided for @clientsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get clientsDelete;

  /// No description provided for @clientsDeleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get clientsDeleteClient;

  /// No description provided for @clientsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String clientsDeleteConfirm(String name);

  /// No description provided for @clientsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get clientsEdit;

  /// No description provided for @clientsEditClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get clientsEditClient;

  /// No description provided for @clientsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clientsEmail;

  /// No description provided for @clientsFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get clientsFullNameLabel;

  /// No description provided for @clientsIdBadge.
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String clientsIdBadge(int id);

  /// No description provided for @clientsInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get clientsInvalidEmail;

  /// No description provided for @clientsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get clientsNameRequired;

  /// No description provided for @clientsNewClient.
  ///
  /// In en, this message translates to:
  /// **'New Client'**
  String get clientsNewClient;

  /// No description provided for @clientsNoClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get clientsNoClientsFound;

  /// No description provided for @clientsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get clientsNotes;

  /// No description provided for @clientsNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes about this client…'**
  String get clientsNotesHint;

  /// No description provided for @clientsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientsPhone;

  /// No description provided for @clientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search clients...'**
  String get clientsSearchHint;

  /// No description provided for @clientsSeller.
  ///
  /// In en, this message translates to:
  /// **'💰 Seller'**
  String get clientsSeller;

  /// No description provided for @clientsTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Timestamps'**
  String get clientsTimestamps;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @clientsTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search'**
  String get clientsTryDifferentSearch;

  /// No description provided for @clientsUpdateClient.
  ///
  /// In en, this message translates to:
  /// **'Update Client'**
  String get clientsUpdateClient;

  /// No description provided for @clientsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get clientsUpdated;

  /// No description provided for @coreCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get coreCancel;

  /// No description provided for @coreClientTypeBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get coreClientTypeBuyer;

  /// No description provided for @coreClientTypeSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get coreClientTypeSeller;

  /// No description provided for @coreDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get coreDelete;

  /// No description provided for @coreLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get coreLogout;

  /// No description provided for @coreNavAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get coreNavAdmin;

  /// No description provided for @coreNavClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get coreNavClients;

  /// No description provided for @coreNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get coreNavDashboard;

  /// No description provided for @coreNavDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get coreNavDeals;

  /// No description provided for @coreNavMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get coreNavMeetings;

  /// No description provided for @coreNavProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get coreNavProperties;

  /// No description provided for @coreNavTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get coreNavTeam;

  /// No description provided for @coreRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get coreRetry;

  /// No description provided for @coreStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get coreStatusAvailable;

  /// No description provided for @coreStatusLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get coreStatusLead;

  /// No description provided for @coreStatusLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get coreStatusLost;

  /// No description provided for @coreStatusNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get coreStatusNegotiation;

  /// No description provided for @coreStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get coreStatusReserved;

  /// No description provided for @coreStatusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get coreStatusSold;

  /// No description provided for @coreStatusWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get coreStatusWon;

  /// No description provided for @dashboardActiveDeals.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String dashboardActiveDeals(int count);

  /// No description provided for @dashboardAddClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get dashboardAddClient;

  /// No description provided for @dashboardAddProperty.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get dashboardAddProperty;

  /// No description provided for @dashboardClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get dashboardClients;

  /// No description provided for @dashboardClosedWon.
  ///
  /// In en, this message translates to:
  /// **'Closed Won'**
  String get dashboardClosedWon;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name} ✨'**
  String dashboardGreeting(String greeting, String name);

  /// No description provided for @dashboardGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get dashboardGreetingAfternoon;

  /// No description provided for @dashboardGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get dashboardGreetingEvening;

  /// No description provided for @dashboardGreetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get dashboardGreetingFallbackName;

  /// No description provided for @dashboardGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashboardGreetingMorning;

  /// No description provided for @dashboardGreetingStillUp.
  ///
  /// In en, this message translates to:
  /// **'Still up'**
  String get dashboardGreetingStillUp;

  /// No description provided for @dashboardMeetingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'meetings'**
  String get dashboardMeetingsSubtitle;

  /// No description provided for @dashboardNewDeal.
  ///
  /// In en, this message translates to:
  /// **'New Deal'**
  String get dashboardNewDeal;

  /// No description provided for @dashboardNoUpcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'No upcoming meetings'**
  String get dashboardNoUpcomingMeetings;

  /// No description provided for @dashboardOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your overview for today'**
  String get dashboardOverviewSubtitle;

  /// No description provided for @dashboardOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverviewTitle;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardScheduleMeeting.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get dashboardScheduleMeeting;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardTotalDeals.
  ///
  /// In en, this message translates to:
  /// **'Total Deals'**
  String get dashboardTotalDeals;

  /// No description provided for @dashboardUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get dashboardUpcoming;

  /// No description provided for @dashboardUpcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Meetings'**
  String get dashboardUpcomingMeetings;

  /// No description provided for @dealsAddDeal.
  ///
  /// In en, this message translates to:
  /// **'Add Deal'**
  String get dealsAddDeal;

  /// No description provided for @dealsAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get dealsAgent;

  /// No description provided for @dealsAgentValue.
  ///
  /// In en, this message translates to:
  /// **'Agent: {name}'**
  String dealsAgentValue(String name);

  /// No description provided for @dealsBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get dealsBudget;

  /// No description provided for @dealsBudgetValue.
  ///
  /// In en, this message translates to:
  /// **'Budget: {price}'**
  String dealsBudgetValue(String price);

  /// No description provided for @dealsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dealsCancel;

  /// No description provided for @dealsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get dealsClient;

  /// No description provided for @dealsClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dealsClosed;

  /// No description provided for @dealsCreateDeal.
  ///
  /// In en, this message translates to:
  /// **'Create Deal'**
  String get dealsCreateDeal;

  /// No description provided for @dealsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get dealsCreated;

  /// No description provided for @dealsDealPrice.
  ///
  /// In en, this message translates to:
  /// **'Deal Price'**
  String get dealsDealPrice;

  /// No description provided for @dealsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String dealsDeleteConfirm(String title);

  /// No description provided for @dealsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Deal'**
  String get dealsDeleteTitle;

  /// No description provided for @dealsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dealsDetails;

  /// No description provided for @dealsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Deal'**
  String get dealsEditTitle;

  /// No description provided for @dealsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your pipeline'**
  String get dealsEmptySubtitle;

  /// No description provided for @dealsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deals'**
  String get dealsEmptyTitle;

  /// No description provided for @dealsFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get dealsFallbackTitle;

  /// No description provided for @dealsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dealsFilterAll;

  /// No description provided for @dealsFinancials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get dealsFinancials;

  /// No description provided for @dealsIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Deal ID copied'**
  String get dealsIdCopied;

  /// No description provided for @dealsIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Deal ID: {id}'**
  String dealsIdLabel(int id);

  /// No description provided for @dealsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get dealsLoading;

  /// No description provided for @dealsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Deal'**
  String get dealsNewTitle;

  /// No description provided for @dealsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get dealsNoResults;

  /// No description provided for @dealsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Deal not found'**
  String get dealsNotFound;

  /// No description provided for @dealsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get dealsNotes;

  /// No description provided for @dealsNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes about this deal…'**
  String get dealsNotesHint;

  /// No description provided for @dealsPeopleProperty.
  ///
  /// In en, this message translates to:
  /// **'People & Property'**
  String get dealsPeopleProperty;

  /// No description provided for @dealsPipelineStage.
  ///
  /// In en, this message translates to:
  /// **'Pipeline Stage'**
  String get dealsPipelineStage;

  /// No description provided for @dealsProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get dealsProperty;

  /// No description provided for @dealsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or ID…'**
  String get dealsSearchHint;

  /// No description provided for @dealsSelectAgentError.
  ///
  /// In en, this message translates to:
  /// **'Please select an agent'**
  String get dealsSelectAgentError;

  /// No description provided for @dealsSelectClientError.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get dealsSelectClientError;

  /// No description provided for @dealsSelectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String dealsSelectLabel(String label);

  /// No description provided for @dealsStatusClosedLost.
  ///
  /// In en, this message translates to:
  /// **'Closed Lost'**
  String get dealsStatusClosedLost;

  /// No description provided for @dealsStatusClosedWon.
  ///
  /// In en, this message translates to:
  /// **'Closed Won'**
  String get dealsStatusClosedWon;

  /// No description provided for @dealsStatusLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get dealsStatusLead;

  /// No description provided for @dealsStatusNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get dealsStatusNegotiation;

  /// No description provided for @dealsStatusNotes.
  ///
  /// In en, this message translates to:
  /// **'Status & Notes'**
  String get dealsStatusNotes;

  /// No description provided for @dealsTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select {label}'**
  String dealsTapToSelect(String label);

  /// No description provided for @dealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTitle;

  /// No description provided for @dealsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get dealsTitleLabel;

  /// No description provided for @dealsTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get dealsTitleRequired;

  /// No description provided for @dealsUpdateDeal.
  ///
  /// In en, this message translates to:
  /// **'Update Deal'**
  String get dealsUpdateDeal;

  /// No description provided for @meetingsAgendaHint.
  ///
  /// In en, this message translates to:
  /// **'Meeting agenda, talking points…'**
  String get meetingsAgendaHint;

  /// No description provided for @meetingsAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get meetingsAgent;

  /// No description provided for @meetingsAgentNumber.
  ///
  /// In en, this message translates to:
  /// **'Agent #{id}'**
  String meetingsAgentNumber(int id);

  /// No description provided for @meetingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get meetingsCancel;

  /// No description provided for @meetingsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get meetingsClient;

  /// No description provided for @meetingsClientNumber.
  ///
  /// In en, this message translates to:
  /// **'Client #{id}'**
  String meetingsClientNumber(int id);

  /// No description provided for @meetingsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get meetingsCompleted;

  /// No description provided for @meetingsDeal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get meetingsDeal;

  /// No description provided for @meetingsDealNumber.
  ///
  /// In en, this message translates to:
  /// **'Deal #{id}'**
  String meetingsDealNumber(int id);

  /// No description provided for @meetingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get meetingsDelete;

  /// No description provided for @meetingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this meeting?'**
  String get meetingsDeleteConfirm;

  /// No description provided for @meetingsDeleteMeeting.
  ///
  /// In en, this message translates to:
  /// **'Delete Meeting'**
  String get meetingsDeleteMeeting;

  /// No description provided for @meetingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get meetingsDescription;

  /// No description provided for @meetingsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get meetingsDetails;

  /// No description provided for @meetingsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get meetingsEdit;

  /// No description provided for @meetingsEditMeeting.
  ///
  /// In en, this message translates to:
  /// **'Edit Meeting'**
  String get meetingsEditMeeting;

  /// No description provided for @meetingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get meetingsLoading;

  /// No description provided for @meetingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get meetingsLocation;

  /// No description provided for @meetingsMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get meetingsMarkComplete;

  /// No description provided for @meetingsNoMeetings.
  ///
  /// In en, this message translates to:
  /// **'No meetings'**
  String get meetingsNoMeetings;

  /// No description provided for @meetingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get meetingsNoResults;

  /// No description provided for @meetingsPeopleAndDeal.
  ///
  /// In en, this message translates to:
  /// **'People & Deal'**
  String get meetingsPeopleAndDeal;

  /// No description provided for @meetingsPleaseSelectAgent.
  ///
  /// In en, this message translates to:
  /// **'Please select an agent'**
  String get meetingsPleaseSelectAgent;

  /// No description provided for @meetingsPleaseSelectClient.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get meetingsPleaseSelectClient;

  /// No description provided for @meetingsPleaseSelectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a date and time'**
  String get meetingsPleaseSelectDateTime;

  /// No description provided for @meetingsSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get meetingsSchedule;

  /// No description provided for @meetingsScheduleFirst.
  ///
  /// In en, this message translates to:
  /// **'Schedule your first meeting'**
  String get meetingsScheduleFirst;

  /// No description provided for @meetingsScheduleMeeting.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get meetingsScheduleMeeting;

  /// No description provided for @meetingsSearchByNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by name or ID…'**
  String get meetingsSearchByNameOrId;

  /// No description provided for @meetingsSelectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date & time *'**
  String get meetingsSelectDateTime;

  /// No description provided for @meetingsSelectEntity.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String meetingsSelectEntity(String label);

  /// No description provided for @meetingsTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select {label}'**
  String meetingsTapToSelect(String label);

  /// No description provided for @meetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetingsTitle;

  /// No description provided for @meetingsTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get meetingsTitleFieldLabel;

  /// No description provided for @meetingsTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get meetingsTitleRequired;

  /// No description provided for @meetingsUpdateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Update Meeting'**
  String get meetingsUpdateMeeting;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileAgentId.
  ///
  /// In en, this message translates to:
  /// **'Agent ID'**
  String get profileAgentId;

  /// No description provided for @profileAgentIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Agent ID copied'**
  String get profileAgentIdCopied;

  /// No description provided for @profileBuiltForTeams.
  ///
  /// In en, this message translates to:
  /// **'Built for real estate teams'**
  String get profileBuiltForTeams;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get profileEditName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileEstateCrm.
  ///
  /// In en, this message translates to:
  /// **'Estate CRM'**
  String get profileEstateCrm;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated locally'**
  String get profileNameUpdated;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileSystemDefault;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @propertiesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get propertiesAdd;

  /// No description provided for @propertiesAddFirstListing.
  ///
  /// In en, this message translates to:
  /// **'Add your first listing'**
  String get propertiesAddFirstListing;

  /// No description provided for @propertiesAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get propertiesAddressLabel;

  /// No description provided for @propertiesAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get propertiesAgent;

  /// No description provided for @propertiesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get propertiesAll;

  /// No description provided for @propertiesApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get propertiesApply;

  /// No description provided for @propertiesArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get propertiesArea;

  /// No description provided for @propertiesAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area m²'**
  String get propertiesAreaLabel;

  /// No description provided for @propertiesAreaValue.
  ///
  /// In en, this message translates to:
  /// **'{area} m²'**
  String propertiesAreaValue(String area);

  /// No description provided for @propertiesBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get propertiesBasicInfo;

  /// No description provided for @propertiesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get propertiesCancel;

  /// No description provided for @propertiesCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get propertiesCityLabel;

  /// No description provided for @propertiesCreateProperty.
  ///
  /// In en, this message translates to:
  /// **'Create Property'**
  String get propertiesCreateProperty;

  /// No description provided for @propertiesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get propertiesDelete;

  /// No description provided for @propertiesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String propertiesDeleteConfirm(String title);

  /// No description provided for @propertiesDeleteProperty.
  ///
  /// In en, this message translates to:
  /// **'Delete Property'**
  String get propertiesDeleteProperty;

  /// No description provided for @propertiesDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the property…'**
  String get propertiesDescribeHint;

  /// No description provided for @propertiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get propertiesDescription;

  /// No description provided for @propertiesDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get propertiesDetails;

  /// No description provided for @propertiesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get propertiesEdit;

  /// No description provided for @propertiesEditProperty.
  ///
  /// In en, this message translates to:
  /// **'Edit Property'**
  String get propertiesEditProperty;

  /// No description provided for @propertiesFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String propertiesFieldRequired(String label);

  /// No description provided for @propertiesFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get propertiesFilters;

  /// No description provided for @propertiesFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get propertiesFloor;

  /// No description provided for @propertiesLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get propertiesLocation;

  /// No description provided for @propertiesNewProperty.
  ///
  /// In en, this message translates to:
  /// **'New Property'**
  String get propertiesNewProperty;

  /// No description provided for @propertiesNoProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties'**
  String get propertiesNoProperties;

  /// No description provided for @propertiesPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get propertiesPriceLabel;

  /// No description provided for @propertiesProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get propertiesProperty;

  /// No description provided for @propertiesPropertyCreated.
  ///
  /// In en, this message translates to:
  /// **'Property created (ID: {id})'**
  String propertiesPropertyCreated(int id);

  /// No description provided for @propertiesPropertyIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Property ID copied'**
  String get propertiesPropertyIdCopied;

  /// No description provided for @propertiesPropertyIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Property ID: {id}'**
  String propertiesPropertyIdLabel(int id);

  /// No description provided for @propertiesPropertyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get propertiesPropertyNotFound;

  /// No description provided for @propertiesRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get propertiesRooms;

  /// No description provided for @propertiesRoomsCount.
  ///
  /// In en, this message translates to:
  /// **'{rooms} rooms'**
  String propertiesRoomsCount(int rooms);

  /// No description provided for @propertiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get propertiesSearchHint;

  /// No description provided for @propertiesStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get propertiesStatus;

  /// No description provided for @propertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesTitle;

  /// No description provided for @propertiesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get propertiesTitleLabel;

  /// No description provided for @propertiesTotalFloors.
  ///
  /// In en, this message translates to:
  /// **'Total Floors'**
  String get propertiesTotalFloors;

  /// No description provided for @propertiesType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get propertiesType;

  /// No description provided for @propertiesTypeAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Type & Status'**
  String get propertiesTypeAndStatus;

  /// No description provided for @propertiesUpdateProperty.
  ///
  /// In en, this message translates to:
  /// **'Update Property'**
  String get propertiesUpdateProperty;

  /// No description provided for @propertiesUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get propertiesUpdateStatus;

  /// No description provided for @teamsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teamsActive;

  /// No description provided for @teamsAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get teamsAgents;

  /// No description provided for @teamsClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get teamsClients;

  /// No description provided for @teamsCouldNotLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Could not load stats'**
  String get teamsCouldNotLoadStats;

  /// No description provided for @teamsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teamsCreate;

  /// No description provided for @teamsCreateTeam.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get teamsCreateTeam;

  /// No description provided for @teamsDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get teamsDeals;

  /// No description provided for @teamsEditTeam.
  ///
  /// In en, this message translates to:
  /// **'Edit team'**
  String get teamsEditTeam;

  /// No description provided for @teamsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get teamsEmail;

  /// No description provided for @teamsEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get teamsEnterValidEmail;

  /// No description provided for @teamsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get teamsFullName;

  /// No description provided for @teamsInviteAgent.
  ///
  /// In en, this message translates to:
  /// **'Invite agent'**
  String get teamsInviteAgent;

  /// No description provided for @teamsManagerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manager: {name}'**
  String teamsManagerLabel(String name);

  /// No description provided for @teamsManagerOptional.
  ///
  /// In en, this message translates to:
  /// **'Manager (optional)'**
  String get teamsManagerOptional;

  /// No description provided for @teamsMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String teamsMemberCount(int count);

  /// No description provided for @teamsMyTeam.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get teamsMyTeam;

  /// No description provided for @teamsNoManager.
  ///
  /// In en, this message translates to:
  /// **'No manager'**
  String get teamsNoManager;

  /// No description provided for @teamsNoTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are not managing a team'**
  String get teamsNoTeamSubtitle;

  /// No description provided for @teamsNoTeamYet.
  ///
  /// In en, this message translates to:
  /// **'No team yet'**
  String get teamsNoTeamYet;

  /// No description provided for @teamsPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get teamsPhoneOptional;

  /// No description provided for @teamsRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get teamsRequired;

  /// No description provided for @teamsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get teamsSave;

  /// No description provided for @teamsSendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get teamsSendInvite;

  /// No description provided for @teamsTeamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get teamsTeamName;

  /// No description provided for @teamsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get teamsUpcoming;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
