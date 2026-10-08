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

  /// No description provided for @adminAuditEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Team activity shows up here: deals created, status changes, invitations.'**
  String get adminAuditEmptyBody;

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

  /// No description provided for @adminDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s clients, properties, deals and meetings move to {successor}. The account is removed permanently and this cannot be undone.'**
  String adminDeleteCascade(Object name, Object successor);

  /// No description provided for @adminDeleteHandoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one else to hand them to'**
  String get adminDeleteHandoverEmpty;

  /// No description provided for @adminDeleteHandoverSearch.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get adminDeleteHandoverSearch;

  /// No description provided for @adminDeleteHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand the records over to'**
  String get adminDeleteHandoverTitle;

  /// No description provided for @adminDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminDeleteUser;

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

  /// No description provided for @adminInviteHelper.
  ///
  /// In en, this message translates to:
  /// **'The code is emailed to them and stays valid for 7 days.'**
  String get adminInviteHelper;

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
  String adminInvitedAs(Object email, Object name, Object role);

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

  /// No description provided for @analyticsAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent: {name}'**
  String analyticsAgent(Object name);

  /// No description provided for @analyticsAllAgents.
  ///
  /// In en, this message translates to:
  /// **'All agents'**
  String get analyticsAllAgents;

  /// No description provided for @analyticsAvgDaysToWin.
  ///
  /// In en, this message translates to:
  /// **'Days to close'**
  String get analyticsAvgDaysToWin;

  /// No description provided for @analyticsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get analyticsCreated;

  /// No description provided for @analyticsDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String analyticsDays(Object days);

  /// No description provided for @analyticsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deals created in this period will show up here.'**
  String get analyticsEmptyBody;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deals in this period'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsFunnel.
  ///
  /// In en, this message translates to:
  /// **'Funnel'**
  String get analyticsFunnel;

  /// No description provided for @analyticsLeadToWon.
  ///
  /// In en, this message translates to:
  /// **'Lead to won'**
  String get analyticsLeadToWon;

  /// No description provided for @analyticsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics'**
  String get analyticsLoadFailed;

  /// No description provided for @analyticsLostReasons.
  ///
  /// In en, this message translates to:
  /// **'Why deals are lost'**
  String get analyticsLostReasons;

  /// No description provided for @analyticsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Last six months'**
  String get analyticsMonthly;

  /// No description provided for @analyticsNoLost.
  ///
  /// In en, this message translates to:
  /// **'No deals lost in this period.'**
  String get analyticsNoLost;

  /// No description provided for @analyticsLeadSources.
  ///
  /// In en, this message translates to:
  /// **'Where clients come from'**
  String get analyticsLeadSources;

  /// No description provided for @analyticsLeadSourcesHint.
  ///
  /// In en, this message translates to:
  /// **'Clients added in the period, and how many of them have a won deal.'**
  String get analyticsLeadSourcesHint;

  /// No description provided for @analyticsLeadSourceWon.
  ///
  /// In en, this message translates to:
  /// **'{count} with a won deal · {rate}'**
  String analyticsLeadSourceWon(Object count, Object rate);

  /// No description provided for @analyticsNoClients.
  ///
  /// In en, this message translates to:
  /// **'No clients added in this period.'**
  String get analyticsNoClients;

  /// No description provided for @analyticsNoValue.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get analyticsNoValue;

  /// No description provided for @analyticsOfPrevious.
  ///
  /// In en, this message translates to:
  /// **'{percent} of the previous stage'**
  String analyticsOfPrevious(Object percent);

  /// No description provided for @analyticsOpen.
  ///
  /// In en, this message translates to:
  /// **'Funnel and analytics'**
  String get analyticsOpen;

  /// No description provided for @analyticsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get analyticsPeriodMonth;

  /// No description provided for @analyticsPeriodQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get analyticsPeriodQuarter;

  /// No description provided for @analyticsPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get analyticsPeriodYear;

  /// No description provided for @analyticsSelectAgent.
  ///
  /// In en, this message translates to:
  /// **'Choose an agent'**
  String get analyticsSelectAgent;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsWonLost.
  ///
  /// In en, this message translates to:
  /// **'{won} won · {lost} lost'**
  String analyticsWonLost(Object lost, Object won);

  /// No description provided for @analyticsWonValue.
  ///
  /// In en, this message translates to:
  /// **'Won value'**
  String get analyticsWonValue;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Estate CRM'**
  String get appTitle;

  /// No description provided for @authAcceptInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code you were given and choose a password.'**
  String get authAcceptInviteSubtitle;

  /// No description provided for @authAcceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get authAcceptRequest;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the privacy policy'**
  String get authAcceptTerms;

  /// No description provided for @authAcceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the privacy policy'**
  String get authAcceptTermsRequired;

  /// No description provided for @authAcceptYourInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept your invite'**
  String get authAcceptYourInvite;

  /// No description provided for @authActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get authActivate;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get authChangeEmail;

  /// No description provided for @authChooseRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This decides what you see. You can be moved later by your manager.'**
  String get authChooseRoleSubtitle;

  /// No description provided for @authChooseRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you work?'**
  String get authChooseRoleTitle;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will email you a six-digit code to confirm the address.'**
  String get authCreateAccountSubtitle;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateTeamAction.
  ///
  /// In en, this message translates to:
  /// **'Create and continue'**
  String get authCreateTeamAction;

  /// No description provided for @authCreateTeamName.
  ///
  /// In en, this message translates to:
  /// **'Agency name'**
  String get authCreateTeamName;

  /// No description provided for @authCreateTeamNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get authCreateTeamNameRequired;

  /// No description provided for @authCreateTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Its name is what your agents will see. You can change it later.'**
  String get authCreateTeamSubtitle;

  /// No description provided for @authCreateTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your agency'**
  String get authCreateTeamTitle;

  /// No description provided for @authDeclineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get authDeclineRequest;

  /// No description provided for @authDeclineRequestBody.
  ///
  /// In en, this message translates to:
  /// **'{team} will not see your clients or deals. They can invite you again later.'**
  String authDeclineRequestBody(Object team);

  /// No description provided for @authDeclineRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this invitation?'**
  String get authDeclineRequestTitle;

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

  /// No description provided for @authEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Sign in instead.'**
  String get authEmailTaken;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the address you sign in with and we’ll email you a link to choose a new password.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authFullNameRequired;

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

  /// No description provided for @authInvitePendingBody.
  ///
  /// In en, this message translates to:
  /// **'An invite was emailed to this address. Open it, or enter its code to set your password.'**
  String get authInvitePendingBody;

  /// No description provided for @authInvitePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'You already have an invite'**
  String get authInvitePendingTitle;

  /// No description provided for @authInviteSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You are signed in as {email}. Accepting the invite means signing out of that account first.'**
  String authInviteSignOutBody(Object email);

  /// No description provided for @authInviteSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out & continue'**
  String get authInviteSignOutConfirm;

  /// No description provided for @authInviteSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this invite?'**
  String get authInviteSignOutTitle;

  /// No description provided for @authInvitedBy.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String authInvitedBy(Object name);

  /// No description provided for @authInvitedByTeam.
  ///
  /// In en, this message translates to:
  /// **'{team} invited you'**
  String authInvitedByTeam(Object team);

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get authNoAccount;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, including a digit.'**
  String get authPasswordHelp;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordMinLength8;

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

  /// No description provided for @authPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get authPhoneOptional;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get authResendCode;

  /// No description provided for @authResendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Send a new code in {seconds}s'**
  String authResendCodeIn(Object seconds);

  /// No description provided for @authResetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get authResetCode;

  /// No description provided for @authResetCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Reset code is required'**
  String get authResetCodeRequired;

  /// No description provided for @authResetLinkSentBody.
  ///
  /// In en, this message translates to:
  /// **'If {email} has an account, a link to choose a new password is on its way. It expires in 24 hours.'**
  String authResetLinkSentBody(Object email);

  /// No description provided for @authResetLinkSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authResetLinkSentTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste the code from the email, then choose a password.'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authResetPasswordTitle;

  /// No description provided for @authRoleAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Join your manager\'s team and work on your own clients and deals.'**
  String get authRoleAgentBody;

  /// No description provided for @authRoleAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'I am an agent'**
  String get authRoleAgentTitle;

  /// No description provided for @authRoleManagerBody.
  ///
  /// In en, this message translates to:
  /// **'Create a team, add agents and see everything they work on.'**
  String get authRoleManagerBody;

  /// No description provided for @authRoleManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'I run an agency'**
  String get authRoleManagerTitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authSetPasswordSignIn.
  ///
  /// In en, this message translates to:
  /// **'Set password & sign in'**
  String get authSetPasswordSignIn;

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

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authVerify;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code we sent to {email}.'**
  String authVerifyEmailSubtitle(Object email);

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authWaitingCopyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get authWaitingCopyEmail;

  /// No description provided for @authWaitingEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get authWaitingEmailCopied;

  /// No description provided for @authWaitingNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet'**
  String get authWaitingNoRequests;

  /// No description provided for @authWaitingNoRequestsBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get authWaitingNoRequestsBody;

  /// No description provided for @authWaitingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give this email to your manager. Once they add you and you accept, your clients and deals appear here.'**
  String get authWaitingSubtitle;

  /// No description provided for @authWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a team'**
  String get authWaitingTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get authWelcomeBack;

  /// No description provided for @calendarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendarAdd;

  /// No description provided for @calendarAddMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get calendarAddMeeting;

  /// No description provided for @calendarAddMeetingHint.
  ///
  /// In en, this message translates to:
  /// **'With a client, at a set time'**
  String get calendarAddMeetingHint;

  /// No description provided for @calendarAddTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get calendarAddTask;

  /// No description provided for @calendarAddTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Something to get done by a time'**
  String get calendarAddTaskHint;

  /// No description provided for @calendarAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {day}'**
  String calendarAddTo(String day);

  /// No description provided for @calendarDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get calendarDayEmpty;

  /// No description provided for @calendarDayEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + or press and hold a day to add a meeting or a task'**
  String get calendarDayEmptyHint;

  /// No description provided for @calendarDayEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{nothing planned} =1{1 entry} other{{count} entries}}'**
  String calendarDayEntries(int count);

  /// No description provided for @calendarLegendMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get calendarLegendMeeting;

  /// No description provided for @calendarLegendOpenHouse.
  ///
  /// In en, this message translates to:
  /// **'Open house'**
  String get calendarLegendOpenHouse;

  /// No description provided for @calendarLegendOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get calendarLegendOverdue;

  /// No description provided for @calendarLegendTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get calendarLegendTask;

  /// No description provided for @calendarLegendViewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get calendarLegendViewing;

  /// No description provided for @calendarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the calendar'**
  String get calendarLoadFailed;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get calendarNextWeek;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get calendarPreviousWeek;

  /// No description provided for @calendarShowMonth.
  ///
  /// In en, this message translates to:
  /// **'Show the whole month'**
  String get calendarShowMonth;

  /// No description provided for @calendarShowWeek.
  ///
  /// In en, this message translates to:
  /// **'Show one week'**
  String get calendarShowWeek;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get calendarViewList;

  /// No description provided for @calendarViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// No description provided for @changeLogAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get changeLogAnyTime;

  /// No description provided for @changeLogAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get changeLogAnyone;

  /// No description provided for @changeLogAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatically'**
  String get changeLogAutomatic;

  /// No description provided for @changeLogChange.
  ///
  /// In en, this message translates to:
  /// **'{field}: {from} → {to}'**
  String changeLogChange(String field, String from, String to);

  /// No description provided for @changeLogClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get changeLogClearFilters;

  /// No description provided for @changeLogCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get changeLogCreated;

  /// No description provided for @changeLogDays.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String changeLogDays(String from, String to);

  /// No description provided for @changeLogDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get changeLogDeleted;

  /// No description provided for @changeLogEdited.
  ///
  /// In en, this message translates to:
  /// **'{field} edited'**
  String changeLogEdited(String field);

  /// No description provided for @changeLogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every edit to this record will show up here, with who made it and when.'**
  String get changeLogEmptyBody;

  /// No description provided for @changeLogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No changes yet'**
  String get changeLogEmptyTitle;

  /// No description provided for @changeLogEntityClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get changeLogEntityClient;

  /// No description provided for @changeLogEntityDeal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get changeLogEntityDeal;

  /// No description provided for @changeLogEntityOther.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get changeLogEntityOther;

  /// No description provided for @changeLogEntityProperty.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get changeLogEntityProperty;

  /// No description provided for @changeLogFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get changeLogFieldAddress;

  /// No description provided for @changeLogFieldAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get changeLogFieldAgent;

  /// No description provided for @changeLogFieldArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get changeLogFieldArea;

  /// No description provided for @changeLogFieldBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get changeLogFieldBirthday;

  /// No description provided for @changeLogFieldBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get changeLogFieldBudget;

  /// No description provided for @changeLogFieldBudgetMax.
  ///
  /// In en, this message translates to:
  /// **'Budget up to'**
  String get changeLogFieldBudgetMax;

  /// No description provided for @changeLogFieldBudgetMin.
  ///
  /// In en, this message translates to:
  /// **'Budget from'**
  String get changeLogFieldBudgetMin;

  /// No description provided for @changeLogFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get changeLogFieldCity;

  /// No description provided for @changeLogFieldClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get changeLogFieldClient;

  /// No description provided for @changeLogFieldCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get changeLogFieldCommission;

  /// No description provided for @changeLogFieldDealPrice.
  ///
  /// In en, this message translates to:
  /// **'Deal price'**
  String get changeLogFieldDealPrice;

  /// No description provided for @changeLogFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get changeLogFieldDescription;

  /// No description provided for @changeLogFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get changeLogFieldEmail;

  /// No description provided for @changeLogFieldFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get changeLogFieldFloor;

  /// No description provided for @changeLogFieldLeadSource.
  ///
  /// In en, this message translates to:
  /// **'Lead source'**
  String get changeLogFieldLeadSource;

  /// No description provided for @changeLogFieldLeadSourceDetail.
  ///
  /// In en, this message translates to:
  /// **'Lead source details'**
  String get changeLogFieldLeadSourceDetail;

  /// No description provided for @changeLogFieldListing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get changeLogFieldListing;

  /// No description provided for @changeLogFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location on the map'**
  String get changeLogFieldLocation;

  /// No description provided for @changeLogFieldLostNote.
  ///
  /// In en, this message translates to:
  /// **'Note on the loss'**
  String get changeLogFieldLostNote;

  /// No description provided for @changeLogFieldLostReason.
  ///
  /// In en, this message translates to:
  /// **'Why it was lost'**
  String get changeLogFieldLostReason;

  /// No description provided for @changeLogFieldMandate.
  ///
  /// In en, this message translates to:
  /// **'Agreement with the seller'**
  String get changeLogFieldMandate;

  /// No description provided for @changeLogFieldMandateEnd.
  ///
  /// In en, this message translates to:
  /// **'Agreement ends'**
  String get changeLogFieldMandateEnd;

  /// No description provided for @changeLogFieldMinArea.
  ///
  /// In en, this message translates to:
  /// **'Area, at least'**
  String get changeLogFieldMinArea;

  /// No description provided for @changeLogFieldMinRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms, at least'**
  String get changeLogFieldMinRooms;

  /// No description provided for @changeLogFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get changeLogFieldName;

  /// No description provided for @changeLogFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get changeLogFieldNotes;

  /// No description provided for @changeLogFieldOther.
  ///
  /// In en, this message translates to:
  /// **'Other details'**
  String get changeLogFieldOther;

  /// No description provided for @changeLogFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get changeLogFieldPhone;

  /// No description provided for @changeLogFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get changeLogFieldPrice;

  /// No description provided for @changeLogFieldRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get changeLogFieldRooms;

  /// No description provided for @changeLogFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get changeLogFieldStatus;

  /// No description provided for @changeLogFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get changeLogFieldTags;

  /// No description provided for @changeLogFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get changeLogFieldTitle;

  /// No description provided for @changeLogFieldTotalFloors.
  ///
  /// In en, this message translates to:
  /// **'Floors in the building'**
  String get changeLogFieldTotalFloors;

  /// No description provided for @changeLogFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get changeLogFieldType;

  /// No description provided for @changeLogFieldWantedCity.
  ///
  /// In en, this message translates to:
  /// **'City wanted'**
  String get changeLogFieldWantedCity;

  /// No description provided for @changeLogFieldWantedType.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get changeLogFieldWantedType;

  /// No description provided for @changeLogFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get changeLogFilterAll;

  /// No description provided for @changeLogFilterClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get changeLogFilterClients;

  /// No description provided for @changeLogFilterDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get changeLogFilterDeals;

  /// No description provided for @changeLogFilterListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get changeLogFilterListings;

  /// No description provided for @changeLogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the history'**
  String get changeLogLoadFailed;

  /// No description provided for @changeLogNoValue.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get changeLogNoValue;

  /// No description provided for @changeLogPeopleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the agency\'s people'**
  String get changeLogPeopleFailed;

  /// No description provided for @changeLogPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String changeLogPercent(String value);

  /// No description provided for @changeLogPickDays.
  ///
  /// In en, this message translates to:
  /// **'Days to show'**
  String get changeLogPickDays;

  /// No description provided for @changeLogPickPerson.
  ///
  /// In en, this message translates to:
  /// **'Who made the change'**
  String get changeLogPickPerson;

  /// No description provided for @changeLogRecord.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {label}'**
  String changeLogRecord(String kind, String label);

  /// No description provided for @changeLogTeamEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Edits to the agency\'s listings, deals and clients will show up here.'**
  String get changeLogTeamEmptyBody;

  /// No description provided for @changeLogTeamEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get changeLogTeamEmptyFiltered;

  /// No description provided for @changeLogTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Who changed what across the agency'**
  String get changeLogTeamHint;

  /// No description provided for @changeLogTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Change log'**
  String get changeLogTeamTitle;

  /// No description provided for @changeLogTitle.
  ///
  /// In en, this message translates to:
  /// **'History of changes'**
  String get changeLogTitle;

  /// No description provided for @changeLogUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'another value'**
  String get changeLogUnknownValue;

  /// No description provided for @changeLogUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get changeLogUntitled;

  /// No description provided for @clientsActivityCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get clientsActivityCall;

  /// No description provided for @clientsActivityDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get clientsActivityDate;

  /// No description provided for @clientsActivityDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears from this client\'s history for the whole team. This cannot be undone.'**
  String get clientsActivityDeleteBody;

  /// No description provided for @clientsActivityDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this entry?'**
  String get clientsActivityDeleteTitle;

  /// No description provided for @clientsActivityEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get clientsActivityEdit;

  /// No description provided for @clientsActivityEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clientsActivityEmail;

  /// No description provided for @clientsActivityFormerMember.
  ///
  /// In en, this message translates to:
  /// **'Former member'**
  String get clientsActivityFormerMember;

  /// No description provided for @clientsActivityInFuture.
  ///
  /// In en, this message translates to:
  /// **'That time has not come yet'**
  String get clientsActivityInFuture;

  /// No description provided for @clientsActivityKind.
  ///
  /// In en, this message translates to:
  /// **'How you were in touch'**
  String get clientsActivityKind;

  /// No description provided for @clientsActivityLogged.
  ///
  /// In en, this message translates to:
  /// **'Contact logged'**
  String get clientsActivityLogged;

  /// No description provided for @clientsActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get clientsActivityMessage;

  /// No description provided for @clientsActivityNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get clientsActivityNote;

  /// No description provided for @clientsActivityNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What was said, what happens next…'**
  String get clientsActivityNoteHint;

  /// No description provided for @clientsActivityNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'What was said'**
  String get clientsActivityNoteLabel;

  /// No description provided for @clientsActivityNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'A note needs some text'**
  String get clientsActivityNoteRequired;

  /// No description provided for @clientsActivityRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove entry'**
  String get clientsActivityRemove;

  /// No description provided for @clientsActivitySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get clientsActivitySave;

  /// No description provided for @clientsActivitySentListings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent 1 listing} other{Sent {count} listings}}'**
  String clientsActivitySentListings(int count);

  /// No description provided for @clientsActivityTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get clientsActivityTime;

  /// No description provided for @clientsActivityToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String clientsActivityToday(String time);

  /// No description provided for @clientsActivityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get clientsActivityUpdated;

  /// No description provided for @clientsActivityWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get clientsActivityWhen;

  /// No description provided for @clientsActivityWhenHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get clientsActivityWhenHourAgo;

  /// No description provided for @clientsActivityWhenJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get clientsActivityWhenJustNow;

  /// No description provided for @clientsActivityWhenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get clientsActivityWhenYesterday;

  /// No description provided for @clientsActivityYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String clientsActivityYesterday(String time);

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

  /// No description provided for @clientsAgentMeta.
  ///
  /// In en, this message translates to:
  /// **'agent {name}'**
  String clientsAgentMeta(Object name);

  /// No description provided for @clientsAnyType.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get clientsAnyType;

  /// No description provided for @clientsBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get clientsBirthday;

  /// No description provided for @clientsBirthdayAge.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String clientsBirthdayAge(int age);

  /// No description provided for @clientsBirthdayClear.
  ///
  /// In en, this message translates to:
  /// **'Remove birthday'**
  String get clientsBirthdayClear;

  /// No description provided for @clientsBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'With the year unknown, only the day and month are kept.'**
  String get clientsBirthdayHint;

  /// No description provided for @clientsBirthdayNoYear.
  ///
  /// In en, this message translates to:
  /// **'Year unknown'**
  String get clientsBirthdayNoYear;

  /// No description provided for @clientsBirthdayPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get clientsBirthdayPick;

  /// No description provided for @clientsBudgetFrom.
  ///
  /// In en, this message translates to:
  /// **'Budget from'**
  String get clientsBudgetFrom;

  /// No description provided for @clientsBudgetTo.
  ///
  /// In en, this message translates to:
  /// **'Budget to'**
  String get clientsBudgetTo;

  /// No description provided for @clientsBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get clientsBuyer;

  /// No description provided for @clientsClientCreatedId.
  ///
  /// In en, this message translates to:
  /// **'Client created (ID: {id})'**
  String clientsClientCreatedId(Object id);

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

  /// No description provided for @clientsColdDaysOption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String clientsColdDaysOption(int count);

  /// No description provided for @clientsColdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody is going cold'**
  String get clientsColdEmpty;

  /// No description provided for @clientsColdEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Everyone worth a call has heard from you in the last day.} other{Everyone worth a call has heard from you in the last {count} days.}}'**
  String clientsColdEmptyHint(int count);

  /// No description provided for @clientsColdLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load who is going cold'**
  String get clientsColdLoadFailed;

  /// No description provided for @clientsColdNeverContacted.
  ///
  /// In en, this message translates to:
  /// **'Never contacted'**
  String get clientsColdNeverContacted;

  /// No description provided for @clientsColdNextCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get clientsColdNextCheckIn;

  /// No description provided for @clientsColdNextFirstCall.
  ///
  /// In en, this message translates to:
  /// **'Make the first call'**
  String get clientsColdNextFirstCall;

  /// No description provided for @clientsColdNextPushDeal.
  ///
  /// In en, this message translates to:
  /// **'Move the deal forward'**
  String get clientsColdNextPushDeal;

  /// No description provided for @clientsColdNextSendMatches.
  ///
  /// In en, this message translates to:
  /// **'Send the listings that fit'**
  String get clientsColdNextSendMatches;

  /// No description provided for @clientsColdReasonLead.
  ///
  /// In en, this message translates to:
  /// **'Lead from a listing page'**
  String get clientsColdReasonLead;

  /// No description provided for @clientsColdReasonMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String clientsColdReasonMatches(int count);

  /// No description provided for @clientsColdReasonNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Deal in negotiation'**
  String get clientsColdReasonNegotiation;

  /// No description provided for @clientsColdReasonOpenDeal.
  ///
  /// In en, this message translates to:
  /// **'Open deal'**
  String get clientsColdReasonOpenDeal;

  /// No description provided for @clientsColdRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get clientsColdRemind;

  /// No description provided for @clientsColdRemindTask.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String clientsColdRemindTask(String name);

  /// No description provided for @clientsColdReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for tomorrow, {time}'**
  String clientsColdReminderSet(String time);

  /// No description provided for @clientsColdSilentDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Silent 1 day} other{Silent {count} days}}'**
  String clientsColdSilentDays(int count);

  /// No description provided for @clientsColdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{No contact for a day or more} other{No contact for {count} days or more}}'**
  String clientsColdSubtitle(int count);

  /// No description provided for @clientsColdTitle.
  ///
  /// In en, this message translates to:
  /// **'Going cold'**
  String get clientsColdTitle;

  /// No description provided for @clientsColdUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get clientsColdUndo;

  /// No description provided for @clientsComposeClearListing.
  ///
  /// In en, this message translates to:
  /// **'Remove listing'**
  String get clientsComposeClearListing;

  /// No description provided for @clientsComposeHint.
  ///
  /// In en, this message translates to:
  /// **'You can edit the text before sending. What you send is saved to the client\'s history.'**
  String get clientsComposeHint;

  /// No description provided for @clientsComposeListing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get clientsComposeListing;

  /// No description provided for @clientsComposeListingHint.
  ///
  /// In en, this message translates to:
  /// **'Fills in the listing, its price, address and link'**
  String get clientsComposeListingHint;

  /// No description provided for @clientsComposeListingNone.
  ///
  /// In en, this message translates to:
  /// **'No listing'**
  String get clientsComposeListingNone;

  /// No description provided for @clientsComposeNoListings.
  ///
  /// In en, this message translates to:
  /// **'No listings'**
  String get clientsComposeNoListings;

  /// No description provided for @clientsComposeNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'Your agency has no templates yet'**
  String get clientsComposeNoTemplates;

  /// No description provided for @clientsComposePickListing.
  ///
  /// In en, this message translates to:
  /// **'Choose a listing'**
  String get clientsComposePickListing;

  /// No description provided for @clientsComposePickTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get clientsComposePickTemplate;

  /// No description provided for @clientsComposeSearchListings.
  ///
  /// In en, this message translates to:
  /// **'Search listings'**
  String get clientsComposeSearchListings;

  /// No description provided for @clientsComposeSearchTemplates.
  ///
  /// In en, this message translates to:
  /// **'Search templates'**
  String get clientsComposeSearchTemplates;

  /// No description provided for @clientsComposeSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get clientsComposeSms;

  /// No description provided for @clientsComposeText.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get clientsComposeText;

  /// No description provided for @clientsComposeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message or use a template'**
  String get clientsComposeTextHint;

  /// No description provided for @clientsComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Write to the client'**
  String get clientsComposeTitle;

  /// No description provided for @clientsComposeUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use template'**
  String get clientsComposeUseTemplate;

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

  /// No description provided for @clientsContactedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Contacted 1 day ago} other{Contacted {count} days ago}}'**
  String clientsContactedDaysAgo(int count);

  /// No description provided for @clientsContactedOn.
  ///
  /// In en, this message translates to:
  /// **'Contacted {date}'**
  String clientsContactedOn(String date);

  /// No description provided for @clientsContactedToday.
  ///
  /// In en, this message translates to:
  /// **'Contacted today'**
  String get clientsContactedToday;

  /// No description provided for @clientsContactedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Contacted yesterday'**
  String get clientsContactedYesterday;

  /// No description provided for @clientsCounter.
  ///
  /// In en, this message translates to:
  /// **'{total} total · {active} in progress'**
  String clientsCounter(Object active, Object total);

  /// No description provided for @clientsCreateClient.
  ///
  /// In en, this message translates to:
  /// **'Create Client'**
  String get clientsCreateClient;

  /// No description provided for @clientsDatesAnniversary.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, one{{years} year since the purchase} other{{years} years since the purchase}}'**
  String clientsDatesAnniversary(int years);

  /// No description provided for @clientsDatesBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get clientsDatesBirthday;

  /// No description provided for @clientsDatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dates in the next two weeks'**
  String get clientsDatesEmpty;

  /// No description provided for @clientsDatesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a client\'s birthday on their card. A won deal\'s anniversary shows up here every year on its own.'**
  String get clientsDatesEmptyHint;

  /// No description provided for @clientsDatesGreet.
  ///
  /// In en, this message translates to:
  /// **'Greet'**
  String get clientsDatesGreet;

  /// No description provided for @clientsDatesInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In {count} day} other{In {count} days}}'**
  String clientsDatesInDays(int count);

  /// No description provided for @clientsDatesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the dates coming up'**
  String get clientsDatesLoadFailed;

  /// No description provided for @clientsDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates coming up'**
  String get clientsDatesTitle;

  /// No description provided for @clientsDatesToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get clientsDatesToday;

  /// No description provided for @clientsDatesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get clientsDatesTomorrow;

  /// No description provided for @clientsDatesTurns.
  ///
  /// In en, this message translates to:
  /// **'Birthday, turns {years}'**
  String clientsDatesTurns(int years);

  /// No description provided for @clientsDatesWhen.
  ///
  /// In en, this message translates to:
  /// **'{when} · {date}'**
  String clientsDatesWhen(String when, String date);

  /// No description provided for @clientsDealCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deal} other{{count} deals}}'**
  String clientsDealCount(num count);

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

  /// No description provided for @clientsDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{name} {count, plural, =0{will be deleted permanently} =1{and 1 linked deal will be deleted permanently} other{and {count} linked deals will be deleted permanently}}. This cannot be undone.'**
  String clientsDeleteCascade(num count, Object name);

  /// No description provided for @clientsDeleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get clientsDeleteClient;

  /// No description provided for @clientsDuplicateEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get clientsDuplicateEyebrow;

  /// No description provided for @clientsDuplicateHeldBy.
  ///
  /// In en, this message translates to:
  /// **'Already in the agency: {name} (agent {agent})'**
  String clientsDuplicateHeldBy(String agent, String name);

  /// No description provided for @clientsDuplicateHint.
  ///
  /// In en, this message translates to:
  /// **'You can still save. Check with the colleague first.'**
  String get clientsDuplicateHint;

  /// No description provided for @clientsDuplicateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get clientsDuplicateOpen;

  /// No description provided for @clientsDuplicateSameBoth.
  ///
  /// In en, this message translates to:
  /// **'Same phone and email'**
  String get clientsDuplicateSameBoth;

  /// No description provided for @clientsDuplicateSameEmail.
  ///
  /// In en, this message translates to:
  /// **'Same email'**
  String get clientsDuplicateSameEmail;

  /// No description provided for @clientsDuplicateSamePhone.
  ///
  /// In en, this message translates to:
  /// **'Same phone'**
  String get clientsDuplicateSamePhone;

  /// No description provided for @clientsDuplicateUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Already in the agency: {name}'**
  String clientsDuplicateUnassigned(String name);

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

  /// No description provided for @clientsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clientsFilterAll;

  /// No description provided for @clientsFilterBuyers.
  ///
  /// In en, this message translates to:
  /// **'Buyers'**
  String get clientsFilterBuyers;

  /// No description provided for @clientsFilterNewLeads.
  ///
  /// In en, this message translates to:
  /// **'New leads'**
  String get clientsFilterNewLeads;

  /// No description provided for @clientsFilterSellers.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get clientsFilterSellers;

  /// No description provided for @clientsFilterTagsCount.
  ///
  /// In en, this message translates to:
  /// **'Tags · {count}'**
  String clientsFilterTagsCount(Object count);

  /// No description provided for @clientsFilterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get clientsFilterSource;

  /// No description provided for @clientsFilterSourceAll.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get clientsFilterSourceAll;

  /// No description provided for @clientsFollowUpCall.
  ///
  /// In en, this message translates to:
  /// **'Log this call?'**
  String get clientsFollowUpCall;

  /// No description provided for @clientsFollowUpEmail.
  ///
  /// In en, this message translates to:
  /// **'Log this email?'**
  String get clientsFollowUpEmail;

  /// No description provided for @clientsFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'One tap puts it in the history. A note is optional.'**
  String get clientsFollowUpHint;

  /// No description provided for @clientsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get clientsFullName;

  /// No description provided for @clientsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get clientsHistory;

  /// No description provided for @clientsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contact logged yet'**
  String get clientsHistoryEmpty;

  /// No description provided for @clientsHistoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Log each call, message and email, and whoever picks up this client knows where things stand.'**
  String get clientsHistoryEmptyHint;

  /// No description provided for @clientsHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the history'**
  String get clientsHistoryLoadFailed;

  /// No description provided for @clientsIdBadge.
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String clientsIdBadge(Object id);

  /// No description provided for @clientsInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get clientsInvalidEmail;

  /// No description provided for @clientsLogContact.
  ///
  /// In en, this message translates to:
  /// **'Log contact'**
  String get clientsLogContact;

  /// No description provided for @clientsLogFirstContact.
  ///
  /// In en, this message translates to:
  /// **'Log the first contact'**
  String get clientsLogFirstContact;

  /// No description provided for @clientsMatches.
  ///
  /// In en, this message translates to:
  /// **'Matching listings'**
  String get clientsMatches;

  /// No description provided for @clientsMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge with another card'**
  String get clientsMerge;

  /// No description provided for @clientsMergeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get clientsMergeConfirm;

  /// No description provided for @clientsMergeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Deals, viewings, contact history and tasks of {source} move to {target}. An empty phone, email and requirements are filled in, and the notes are added. The card {source} is then deleted. This cannot be undone.'**
  String clientsMergeConfirmBody(String source, String target);

  /// No description provided for @clientsMergeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge into this card?'**
  String get clientsMergeConfirmTitle;

  /// No description provided for @clientsMergeNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'No other clients to merge with'**
  String get clientsMergeNoCandidates;

  /// No description provided for @clientsMergePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Which card is the same person?'**
  String get clientsMergePickTitle;

  /// No description provided for @clientsMergeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search clients'**
  String get clientsMergeSearchHint;

  /// No description provided for @clientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get clientsMessage;

  /// No description provided for @clientsMinArea.
  ///
  /// In en, this message translates to:
  /// **'Area, min m²'**
  String get clientsMinArea;

  /// No description provided for @clientsMinRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms, min'**
  String get clientsMinRooms;

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

  /// No description provided for @clientsNewLeadsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Buyers who leave their details on a listing\'s public link show up here for a week.'**
  String get clientsNewLeadsEmpty;

  /// No description provided for @clientsNoClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get clientsNoClientsFound;

  /// No description provided for @clientsNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address on file'**
  String get clientsNoEmail;

  /// No description provided for @clientsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the books fits yet'**
  String get clientsNoMatches;

  /// No description provided for @clientsNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file'**
  String get clientsNoPhone;

  /// No description provided for @clientsNoRequirements.
  ///
  /// In en, this message translates to:
  /// **'Say what this buyer is looking for and matching listings appear here'**
  String get clientsNoRequirements;

  /// No description provided for @clientsNoWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'No phone number on the card, so WhatsApp is unavailable'**
  String get clientsNoWhatsApp;

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

  /// No description provided for @clientsOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get clientsOverBudget;

  /// No description provided for @clientsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientsPhone;

  /// No description provided for @clientsRequirements.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get clientsRequirements;

  /// No description provided for @clientsRequirementsHint.
  ///
  /// In en, this message translates to:
  /// **'Fill this in and the app will keep showing which listings fit.'**
  String get clientsRequirementsHint;

  /// No description provided for @clientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone…'**
  String get clientsSearchHint;

  /// No description provided for @clientsSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get clientsSeller;

  /// No description provided for @clientsSendClosing.
  ///
  /// In en, this message translates to:
  /// **'Tell me which ones you would like to see and I will arrange a viewing.'**
  String get clientsSendClosing;

  /// No description provided for @clientsSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open sending'**
  String get clientsSendFailed;

  /// No description provided for @clientsSendGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! Here are listings that fit what you are looking for:'**
  String get clientsSendGreeting;

  /// No description provided for @clientsSendLinks.
  ///
  /// In en, this message translates to:
  /// **'Include links'**
  String get clientsSendLinks;

  /// No description provided for @clientsSendLinksHint.
  ///
  /// In en, this message translates to:
  /// **'A page per listing with all its photos. Opens in any browser.'**
  String get clientsSendLinksHint;

  /// No description provided for @clientsSendLogged.
  ///
  /// In en, this message translates to:
  /// **'Saved to the client\'s history'**
  String get clientsSendLogged;

  /// No description provided for @clientsSendMatches.
  ///
  /// In en, this message translates to:
  /// **'Send listings'**
  String get clientsSendMatches;

  /// No description provided for @clientsSendPhotos.
  ///
  /// In en, this message translates to:
  /// **'Attach cover photos'**
  String get clientsSendPhotos;

  /// No description provided for @clientsSendPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Photos go through Share. WhatsApp opens the chat with the text only.'**
  String get clientsSendPhotosHint;

  /// No description provided for @clientsSendSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String clientsSendSelected(int count);

  /// No description provided for @clientsSendShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get clientsSendShare;

  /// No description provided for @clientsSendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get clientsSendWhatsApp;

  /// No description provided for @clientsSentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String clientsSentOn(String date);

  /// No description provided for @clientsShownOn.
  ///
  /// In en, this message translates to:
  /// **'Shown {date}'**
  String clientsShownOn(String date);

  /// No description provided for @clientsSourceImport.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get clientsSourceImport;

  /// No description provided for @clientsSourceOpenHouse.
  ///
  /// In en, this message translates to:
  /// **'From an open house'**
  String get clientsSourceOpenHouse;

  /// No description provided for @clientsSourcePublicLink.
  ///
  /// In en, this message translates to:
  /// **'From the public link'**
  String get clientsSourcePublicLink;

  /// No description provided for @clientsTagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get clientsTagAdd;

  /// No description provided for @clientsTagAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get clientsTagAddHint;

  /// No description provided for @clientsTagFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear tags'**
  String get clientsTagFilterClear;

  /// No description provided for @clientsTagFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Show clients'**
  String get clientsTagFilterDone;

  /// No description provided for @clientsTagFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No client has a tag yet. Add tags on the client form.'**
  String get clientsTagFilterEmpty;

  /// No description provided for @clientsTagFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clients carrying every tag you pick'**
  String get clientsTagFilterSubtitle;

  /// No description provided for @clientsTagFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by tags'**
  String get clientsTagFilterTitle;

  /// No description provided for @clientsTagLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} tags per client'**
  String clientsTagLimit(Object count);

  /// No description provided for @clientsTagRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove tag {tag}'**
  String clientsTagRemove(Object tag);

  /// No description provided for @clientsTagSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Already used in the agency'**
  String get clientsTagSuggestions;

  /// No description provided for @clientsTagTooLong.
  ///
  /// In en, this message translates to:
  /// **'A tag can be at most {count} characters'**
  String clientsTagTooLong(Object count);

  /// No description provided for @clientsTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get clientsTags;

  /// No description provided for @clientsTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Short labels to find a client by later: investor, urgent, VIP.'**
  String get clientsTagsHint;

  /// No description provided for @clientsTagsMore.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String clientsTagsMore(Object count);

  /// No description provided for @clientsLeadSource.
  ///
  /// In en, this message translates to:
  /// **'Where they came from'**
  String get clientsLeadSource;

  /// No description provided for @clientsLeadSourceNone.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get clientsLeadSourceNone;

  /// No description provided for @clientsLeadSourceReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get clientsLeadSourceReferral;

  /// No description provided for @clientsLeadSourceWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get clientsLeadSourceWebsite;

  /// No description provided for @clientsLeadSourcePortal.
  ///
  /// In en, this message translates to:
  /// **'Listings portal'**
  String get clientsLeadSourcePortal;

  /// No description provided for @clientsLeadSourceSocial.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get clientsLeadSourceSocial;

  /// No description provided for @clientsLeadSourceWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get clientsLeadSourceWalkIn;

  /// No description provided for @clientsLeadSourceColdCall.
  ///
  /// In en, this message translates to:
  /// **'Cold call'**
  String get clientsLeadSourceColdCall;

  /// No description provided for @clientsLeadSourceRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat client'**
  String get clientsLeadSourceRepeat;

  /// No description provided for @clientsLeadSourceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get clientsLeadSourceOther;

  /// No description provided for @clientsLeadSourceDetail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get clientsLeadSourceDetail;

  /// No description provided for @clientsLeadSourceDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Who referred them, which portal'**
  String get clientsLeadSourceDetailHint;

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

  /// No description provided for @clientsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String clientsUpdatedAt(Object date);

  /// No description provided for @clientsWantedCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get clientsWantedCity;

  /// No description provided for @clientsWantedType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get clientsWantedType;

  /// No description provided for @clientsWrite.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp or SMS'**
  String get clientsWrite;

  /// No description provided for @compareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareAction;

  /// No description provided for @compareAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to comparison'**
  String get compareAdd;

  /// No description provided for @compareAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to comparison'**
  String get compareAdded;

  /// No description provided for @compareBarButton.
  ///
  /// In en, this message translates to:
  /// **'Compare ({count})'**
  String compareBarButton(int count);

  /// No description provided for @compareBestLegend.
  ///
  /// In en, this message translates to:
  /// **'Green marks the best value in a row'**
  String get compareBestLegend;

  /// No description provided for @compareDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Listed today} =1{1 day} other{{count} days}}'**
  String compareDays(int count);

  /// No description provided for @compareExit.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get compareExit;

  /// No description provided for @compareFirstFloor.
  ///
  /// In en, this message translates to:
  /// **'first floor'**
  String get compareFirstFloor;

  /// No description provided for @compareFitMatches.
  ///
  /// In en, this message translates to:
  /// **'Fits requirements'**
  String get compareFitMatches;

  /// No description provided for @compareFitOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside requirements'**
  String get compareFitOutside;

  /// No description provided for @compareFitOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get compareFitOverBudget;

  /// No description provided for @compareLastFloor.
  ///
  /// In en, this message translates to:
  /// **'last floor'**
  String get compareLastFloor;

  /// No description provided for @compareLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 listings side by side. Remove one to add another.'**
  String get compareLimit;

  /// No description provided for @compareLinks.
  ///
  /// In en, this message translates to:
  /// **'Include links'**
  String get compareLinks;

  /// No description provided for @compareLinksHint.
  ///
  /// In en, this message translates to:
  /// **'A page per listing with all its photos, added under each one.'**
  String get compareLinksHint;

  /// No description provided for @compareNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Pick two listings to compare'**
  String get compareNeedTwo;

  /// No description provided for @compareNeedTwoHint.
  ///
  /// In en, this message translates to:
  /// **'Choose Compare on the Properties tab, or add listings from their pages.'**
  String get compareNeedTwoHint;

  /// No description provided for @comparePickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick two to four listings'**
  String get comparePickHint;

  /// No description provided for @compareRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from comparison'**
  String get compareRemove;

  /// No description provided for @compareRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from comparison'**
  String get compareRemoved;

  /// No description provided for @compareRowAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get compareRowAgent;

  /// No description provided for @compareRowArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get compareRowArea;

  /// No description provided for @compareRowDays.
  ///
  /// In en, this message translates to:
  /// **'On the market'**
  String get compareRowDays;

  /// No description provided for @compareRowFit.
  ///
  /// In en, this message translates to:
  /// **'For this buyer'**
  String get compareRowFit;

  /// No description provided for @compareRowFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get compareRowFloor;

  /// No description provided for @compareRowLinkViews.
  ///
  /// In en, this message translates to:
  /// **'Link views'**
  String get compareRowLinkViews;

  /// No description provided for @compareRowPlace.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get compareRowPlace;

  /// No description provided for @compareRowPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get compareRowPrice;

  /// No description provided for @compareRowPriceChange.
  ///
  /// In en, this message translates to:
  /// **'Last price change'**
  String get compareRowPriceChange;

  /// No description provided for @compareRowPricePerSqm.
  ///
  /// In en, this message translates to:
  /// **'Price per m²'**
  String get compareRowPricePerSqm;

  /// No description provided for @compareRowRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get compareRowRooms;

  /// No description provided for @compareRowType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get compareRowType;

  /// No description provided for @compareSelected.
  ///
  /// In en, this message translates to:
  /// **'Compare selected'**
  String get compareSelected;

  /// No description provided for @compareSend.
  ///
  /// In en, this message translates to:
  /// **'Send comparison'**
  String get compareSend;

  /// No description provided for @compareSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open sending'**
  String get compareSendFailed;

  /// No description provided for @compareShareBest.
  ///
  /// In en, this message translates to:
  /// **'Best price per m²: {title}'**
  String compareShareBest(String title);

  /// No description provided for @compareShareIntro.
  ///
  /// In en, this message translates to:
  /// **'Here is how the listings compare:'**
  String get compareShareIntro;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get compareTitle;

  /// No description provided for @coreCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get coreCall;

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

  /// No description provided for @coreDataScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get coreDataScopeAll;

  /// No description provided for @coreDataScopeOwn.
  ///
  /// In en, this message translates to:
  /// **'Own'**
  String get coreDataScopeOwn;

  /// No description provided for @coreDataScopeTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get coreDataScopeTeam;

  /// No description provided for @coreDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get coreDelete;

  /// No description provided for @coreErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get coreErrorBadRequest;

  /// No description provided for @coreErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'This already exists.'**
  String get coreErrorConflict;

  /// No description provided for @coreErrorCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get coreErrorCredentials;

  /// No description provided for @coreErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don’t have permission to do that.'**
  String get coreErrorForbidden;

  /// No description provided for @coreErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get coreErrorNotFound;

  /// No description provided for @coreErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Check your internet.'**
  String get coreErrorOffline;

  /// No description provided for @coreErrorOfflineWrite.
  ///
  /// In en, this message translates to:
  /// **'You’re offline — this needs a connection.'**
  String get coreErrorOfflineWrite;

  /// No description provided for @coreErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get coreErrorServer;

  /// No description provided for @coreErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your internet.'**
  String get coreErrorTimeout;

  /// No description provided for @coreErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get coreErrorUnknown;

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

  /// No description provided for @coreNavCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get coreNavCalendar;

  /// No description provided for @coreNavClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get coreNavClients;

  /// No description provided for @coreNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get coreNavDashboard;

  /// No description provided for @coreNavDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get coreNavDeals;

  /// No description provided for @coreNavProperties.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get coreNavProperties;

  /// No description provided for @coreNavTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get coreNavTeam;

  /// No description provided for @coreNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get coreNoResults;

  /// No description provided for @coreNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get coreNotSelected;

  /// No description provided for @coreOfflineSince.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing data from {time}'**
  String coreOfflineSince(String time);

  /// No description provided for @coreOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get coreOpen;

  /// No description provided for @corePropertyTypeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get corePropertyTypeApartment;

  /// No description provided for @corePropertyTypeCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get corePropertyTypeCommercial;

  /// No description provided for @corePropertyTypeHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get corePropertyTypeHouse;

  /// No description provided for @corePropertyTypeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get corePropertyTypeLand;

  /// No description provided for @corePropertyTypeOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get corePropertyTypeOffice;

  /// No description provided for @coreRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get coreRetry;

  /// No description provided for @coreRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get coreRoleAdmin;

  /// No description provided for @coreRoleAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get coreRoleAgent;

  /// No description provided for @coreRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get coreRoleManager;

  /// No description provided for @coreSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get coreSave;

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

  /// No description provided for @dashboardActiveDealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active deals'**
  String get dashboardActiveDealsLabel;

  /// No description provided for @dashboardAgentDeals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deal} other{{count} deals}}'**
  String dashboardAgentDeals(num count);

  /// No description provided for @dashboardAgentMeta.
  ///
  /// In en, this message translates to:
  /// **'agent: {name}'**
  String dashboardAgentMeta(Object name);

  /// No description provided for @dashboardAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get dashboardAttention;

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

  /// No description provided for @dashboardColdTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} in all'**
  String dashboardColdTotal(int count);

  /// No description provided for @dashboardConversion.
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get dashboardConversion;

  /// No description provided for @dashboardDateSummary.
  ///
  /// In en, this message translates to:
  /// **'{date} · team overview'**
  String dashboardDateSummary(Object date);

  /// No description provided for @dashboardDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates this week'**
  String get dashboardDatesTitle;

  /// No description provided for @dashboardDatesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} this week'**
  String dashboardDatesTotal(int count);

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String dashboardGreeting(Object greeting, Object name);

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

  /// No description provided for @dashboardIdleDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{no movement for 1 day} other{no movement for {count} days}}'**
  String dashboardIdleDays(num count);

  /// No description provided for @dashboardLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Top agents'**
  String get dashboardLeaderboard;

  /// No description provided for @dashboardLoadTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{nothing booked} =1{1 meeting} other{{count} meetings}}'**
  String dashboardLoadTotal(num count);

  /// No description provided for @dashboardMandatesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} in all'**
  String dashboardMandatesTotal(int count);

  /// No description provided for @dashboardMeetingLoad.
  ///
  /// In en, this message translates to:
  /// **'Next two weeks'**
  String get dashboardMeetingLoad;

  /// No description provided for @dashboardMeetingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get dashboardMeetingsLabel;

  /// No description provided for @dashboardNewDeal.
  ///
  /// In en, this message translates to:
  /// **'New Deal'**
  String get dashboardNewDeal;

  /// No description provided for @dashboardNextMeeting.
  ///
  /// In en, this message translates to:
  /// **'Next meeting'**
  String get dashboardNextMeeting;

  /// No description provided for @dashboardNoDealsYet.
  ///
  /// In en, this message translates to:
  /// **'No deals yet'**
  String get dashboardNoDealsYet;

  /// No description provided for @dashboardNoDealsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Your pipeline will appear here once you add one'**
  String get dashboardNoDealsYetHint;

  /// No description provided for @dashboardNoMoreMeetingsToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing else scheduled today'**
  String get dashboardNoMoreMeetingsToday;

  /// No description provided for @dashboardNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file for this client'**
  String get dashboardNoPhone;

  /// No description provided for @dashboardNoUpcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'No upcoming meetings'**
  String get dashboardNoUpcomingMeetings;

  /// No description provided for @dashboardNothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get dashboardNothingScheduled;

  /// No description provided for @dashboardNothingScheduledHint.
  ///
  /// In en, this message translates to:
  /// **'Book a meeting and it will show up here'**
  String get dashboardNothingScheduledHint;

  /// No description provided for @dashboardRelativeInHours.
  ///
  /// In en, this message translates to:
  /// **'in {count} h'**
  String dashboardRelativeInHours(Object count);

  /// No description provided for @dashboardRelativeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {count} min'**
  String dashboardRelativeInMinutes(Object count);

  /// No description provided for @dashboardRelativeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get dashboardRelativeNow;

  /// No description provided for @dashboardRelativeToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get dashboardRelativeToday;

  /// No description provided for @dashboardRelativeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get dashboardRelativeTomorrow;

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

  /// No description provided for @dashboardTasksClear.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get dashboardTasksClear;

  /// No description provided for @dashboardTasksOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String dashboardTasksOverdueCount(Object count);

  /// No description provided for @dashboardTasksToday.
  ///
  /// In en, this message translates to:
  /// **'To do today'**
  String get dashboardTasksToday;

  /// No description provided for @dashboardTeamPipeline.
  ///
  /// In en, this message translates to:
  /// **'Team pipeline'**
  String get dashboardTeamPipeline;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @dashboardTodayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String dashboardTodayCount(Object count);

  /// No description provided for @dashboardTopAgents.
  ///
  /// In en, this message translates to:
  /// **'Top agents'**
  String get dashboardTopAgents;

  /// No description provided for @dashboardUpcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Meetings'**
  String get dashboardUpcomingMeetings;

  /// No description provided for @dealsAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get dealsAgent;

  /// No description provided for @dealsAgentRef.
  ///
  /// In en, this message translates to:
  /// **'Agent #{id}'**
  String dealsAgentRef(Object id);

  /// No description provided for @dealsAgentValue.
  ///
  /// In en, this message translates to:
  /// **'Agent: {name}'**
  String dealsAgentValue(Object name);

  /// No description provided for @dealsBoardColumnMeta.
  ///
  /// In en, this message translates to:
  /// **'{count} · {total}'**
  String dealsBoardColumnMeta(Object count, Object total);

  /// No description provided for @dealsBoardDragHint.
  ///
  /// In en, this message translates to:
  /// **'Hold a card to move it to another stage'**
  String get dealsBoardDragHint;

  /// No description provided for @dealsBoardStageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing at this stage'**
  String get dealsBoardStageEmpty;

  /// No description provided for @dealsBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get dealsBudget;

  /// No description provided for @dealsBudgetValue.
  ///
  /// In en, this message translates to:
  /// **'Budget: {price}'**
  String dealsBudgetValue(Object price);

  /// No description provided for @dealsChecklistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get dealsChecklistAdd;

  /// No description provided for @dealsChecklistAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New checklist item'**
  String get dealsChecklistAddTitle;

  /// No description provided for @dealsChecklistAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach document'**
  String get dealsChecklistAttach;

  /// No description provided for @dealsChecklistBadge.
  ///
  /// In en, this message translates to:
  /// **'Checklist: {done} of {total} done'**
  String dealsChecklistBadge(int done, int total);

  /// No description provided for @dealsChecklistDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get dealsChecklistDelete;

  /// No description provided for @dealsChecklistDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears from this deal\'s checklist.'**
  String get dealsChecklistDeleteBody;

  /// No description provided for @dealsChecklistDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get dealsChecklistDeleteTitle;

  /// No description provided for @dealsChecklistDetach.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get dealsChecklistDetach;

  /// No description provided for @dealsChecklistDoneAt.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String dealsChecklistDoneAt(String date);

  /// No description provided for @dealsChecklistDoneBy.
  ///
  /// In en, this message translates to:
  /// **'{name} · {date}'**
  String dealsChecklistDoneBy(String date, String name);

  /// No description provided for @dealsChecklistEmptyStage.
  ///
  /// In en, this message translates to:
  /// **'Nothing to collect at this stage'**
  String get dealsChecklistEmptyStage;

  /// No description provided for @dealsChecklistGateBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 required item is not done yet. Move the deal anyway?} other{{count} required items are not done yet. Move the deal anyway?}}'**
  String dealsChecklistGateBody(int count);

  /// No description provided for @dealsChecklistGateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move anyway'**
  String get dealsChecklistGateConfirm;

  /// No description provided for @dealsChecklistGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Required items are open'**
  String get dealsChecklistGateTitle;

  /// No description provided for @dealsChecklistItemHint.
  ///
  /// In en, this message translates to:
  /// **'For example, a copy of the passport'**
  String get dealsChecklistItemHint;

  /// No description provided for @dealsChecklistItemLabel.
  ///
  /// In en, this message translates to:
  /// **'What is needed'**
  String get dealsChecklistItemLabel;

  /// No description provided for @dealsChecklistLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the checklist'**
  String get dealsChecklistLoadFailed;

  /// No description provided for @dealsChecklistMore.
  ///
  /// In en, this message translates to:
  /// **'Item actions'**
  String get dealsChecklistMore;

  /// No description provided for @dealsChecklistNoDocuments.
  ///
  /// In en, this message translates to:
  /// **'This deal has no documents yet. Upload the file under Documents first.'**
  String get dealsChecklistNoDocuments;

  /// No description provided for @dealsChecklistPickDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose a document'**
  String get dealsChecklistPickDocument;

  /// No description provided for @dealsChecklistProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String dealsChecklistProgress(int done, int total);

  /// No description provided for @dealsChecklistRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get dealsChecklistRequired;

  /// No description provided for @dealsChecklistRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'The app warns before a deal moves on without it'**
  String get dealsChecklistRequiredHint;

  /// No description provided for @dealsChecklistStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get dealsChecklistStage;

  /// No description provided for @dealsChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get dealsChecklistTitle;

  /// No description provided for @dealsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get dealsClient;

  /// No description provided for @dealsClientRef.
  ///
  /// In en, this message translates to:
  /// **'Client #{id}'**
  String dealsClientRef(Object id);

  /// No description provided for @dealsCommentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 comment} other{{count} comments}}'**
  String dealsCommentCount(int count);

  /// No description provided for @dealsCommentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get dealsCommentDelete;

  /// No description provided for @dealsCommentDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears for everyone on this deal.'**
  String get dealsCommentDeleteBody;

  /// No description provided for @dealsCommentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get dealsCommentDeleteTitle;

  /// No description provided for @dealsCommentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit comment'**
  String get dealsCommentEdit;

  /// No description provided for @dealsCommentEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get dealsCommentEdited;

  /// No description provided for @dealsCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get dealsCommentHint;

  /// No description provided for @dealsCommentJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get dealsCommentJustNow;

  /// No description provided for @dealsCommentLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get dealsCommentLess;

  /// No description provided for @dealsCommentMentionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load colleagues'**
  String get dealsCommentMentionLoadFailed;

  /// No description provided for @dealsCommentMentionNone.
  ///
  /// In en, this message translates to:
  /// **'Nobody else can see this deal'**
  String get dealsCommentMentionNone;

  /// No description provided for @dealsCommentMentionNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only colleagues who can see this deal can be mentioned'**
  String get dealsCommentMentionNotAllowed;

  /// No description provided for @dealsCommentMentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mention a colleague'**
  String get dealsCommentMentionTitle;

  /// No description provided for @dealsCommentMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get dealsCommentMore;

  /// No description provided for @dealsCommentSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get dealsCommentSend;

  /// No description provided for @dealsCommentSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get dealsCommentSending;

  /// No description provided for @dealsCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get dealsCommission;

  /// No description provided for @dealsCommissionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dealsCommissionAmount;

  /// No description provided for @dealsCommissionInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a rate above 0 and no more than 100'**
  String get dealsCommissionInvalid;

  /// No description provided for @dealsCommissionNeedsPrice.
  ///
  /// In en, this message translates to:
  /// **'Set a deal price to work it out'**
  String get dealsCommissionNeedsPrice;

  /// No description provided for @dealsCommissionPercent.
  ///
  /// In en, this message translates to:
  /// **'Commission, %'**
  String get dealsCommissionPercent;

  /// No description provided for @dealsCommissionRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get dealsCommissionRate;

  /// No description provided for @dealsCounter.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {total}'**
  String dealsCounter(Object active, Object total);

  /// No description provided for @dealsCreateDeal.
  ///
  /// In en, this message translates to:
  /// **'Create Deal'**
  String get dealsCreateDeal;

  /// No description provided for @dealsDealPrice.
  ///
  /// In en, this message translates to:
  /// **'Deal Price'**
  String get dealsDealPrice;

  /// No description provided for @dealsDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{title} will be deleted permanently. This cannot be undone.'**
  String dealsDeleteCascade(Object title);

  /// No description provided for @dealsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Deal'**
  String get dealsDeleteTitle;

  /// No description provided for @dealsDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get dealsDiscussion;

  /// No description provided for @dealsDiscussionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get dealsDiscussionEmpty;

  /// No description provided for @dealsDiscussionEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the conversation about this deal here. Type @ to bring in a colleague.'**
  String get dealsDiscussionEmptyHint;

  /// No description provided for @dealsDiscussionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the discussion'**
  String get dealsDiscussionLoadFailed;

  /// No description provided for @dealsDiscussionShowEarlier.
  ///
  /// In en, this message translates to:
  /// **'Show earlier'**
  String get dealsDiscussionShowEarlier;

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

  /// No description provided for @dealsFilterWithCount.
  ///
  /// In en, this message translates to:
  /// **'{label} {count}'**
  String dealsFilterWithCount(Object count, Object label);

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
  String dealsIdLabel(Object id);

  /// No description provided for @dealsLostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark as lost'**
  String get dealsLostConfirm;

  /// No description provided for @dealsLostNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get dealsLostNote;

  /// No description provided for @dealsLostNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What happened, if it helps next time'**
  String get dealsLostNoteHint;

  /// No description provided for @dealsLostReason.
  ///
  /// In en, this message translates to:
  /// **'Why it was lost'**
  String get dealsLostReason;

  /// No description provided for @dealsLostReasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed their mind'**
  String get dealsLostReasonChangedMind;

  /// No description provided for @dealsLostReasonChoseAnother.
  ///
  /// In en, this message translates to:
  /// **'Chose another option'**
  String get dealsLostReasonChoseAnother;

  /// No description provided for @dealsLostReasonFinancing.
  ///
  /// In en, this message translates to:
  /// **'Financing fell through'**
  String get dealsLostReasonFinancing;

  /// No description provided for @dealsLostReasonNoResponse.
  ///
  /// In en, this message translates to:
  /// **'Stopped responding'**
  String get dealsLostReasonNoResponse;

  /// No description provided for @dealsLostReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dealsLostReasonOther;

  /// No description provided for @dealsLostReasonPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get dealsLostReasonPrice;

  /// No description provided for @dealsLostReasonUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get dealsLostReasonUnspecified;

  /// No description provided for @dealsLostSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a reason. It feeds the funnel in Analytics.'**
  String get dealsLostSheetSubtitle;

  /// No description provided for @dealsLostSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Why was the deal lost?'**
  String get dealsLostSheetTitle;

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

  /// No description provided for @dealsNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different stage filter'**
  String get dealsNoResultsSubtitle;

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

  /// No description provided for @dealsPropertyRef.
  ///
  /// In en, this message translates to:
  /// **'Property #{id}'**
  String dealsPropertyRef(Object id);

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
  String dealsSelectLabel(Object label);

  /// No description provided for @dealsStaleWarning.
  ///
  /// In en, this message translates to:
  /// **'no activity for {days} days'**
  String dealsStaleWarning(Object days);

  /// No description provided for @dealsTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get dealsTimeline;

  /// No description provided for @dealsTimelineClosed.
  ///
  /// In en, this message translates to:
  /// **'Deal closed'**
  String get dealsTimelineClosed;

  /// No description provided for @dealsTimelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get dealsTimelineCreated;

  /// No description provided for @dealsTimelineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get dealsTimelineUpdated;

  /// No description provided for @dealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get dealsTitle;

  /// No description provided for @dealsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
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

  /// No description provided for @dealsViewBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get dealsViewBoard;

  /// No description provided for @dealsViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get dealsViewList;

  /// No description provided for @depositsAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get depositsAmount;

  /// No description provided for @depositsAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500,000'**
  String get depositsAmountHint;

  /// No description provided for @depositsCloseAction.
  ///
  /// In en, this message translates to:
  /// **'End deposit'**
  String get depositsCloseAction;

  /// No description provided for @depositsCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'How did the deposit end?'**
  String get depositsCloseTitle;

  /// No description provided for @depositsClosedBeforeReceived.
  ///
  /// In en, this message translates to:
  /// **'It cannot end before the money came in'**
  String get depositsClosedBeforeReceived;

  /// No description provided for @depositsClosedOn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get depositsClosedOn;

  /// No description provided for @depositsDealClosedHint.
  ///
  /// In en, this message translates to:
  /// **'The deal is closed; a deposit can no longer be recorded.'**
  String get depositsDealClosedHint;

  /// No description provided for @depositsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get depositsEdit;

  /// No description provided for @depositsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit the deposit'**
  String get depositsEditTitle;

  /// No description provided for @depositsEndingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deposits running out'**
  String get depositsEndingEmpty;

  /// No description provided for @depositsEndingEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Active deposits show here a week before their hold ends.'**
  String get depositsEndingEmptyHint;

  /// No description provided for @depositsEndingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the deposits'**
  String get depositsEndingLoadFailed;

  /// No description provided for @depositsEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposits ending'**
  String get depositsEndingTitle;

  /// No description provided for @depositsHistory.
  ///
  /// In en, this message translates to:
  /// **'Earlier deposits'**
  String get depositsHistory;

  /// No description provided for @depositsHoldBeforeReceived.
  ///
  /// In en, this message translates to:
  /// **'The hold cannot end before the money came in'**
  String get depositsHoldBeforeReceived;

  /// No description provided for @depositsHoldEndedAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hold ended 1 day ago} other{Hold ended {count} days ago}}'**
  String depositsHoldEndedAgo(int count);

  /// No description provided for @depositsHoldEndedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Hold ended yesterday'**
  String get depositsHoldEndedYesterday;

  /// No description provided for @depositsHoldEndsIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hold ends in 1 day} other{Hold ends in {count} days}}'**
  String depositsHoldEndsIn(int count);

  /// No description provided for @depositsHoldEndsToday.
  ///
  /// In en, this message translates to:
  /// **'Hold ends today'**
  String get depositsHoldEndsToday;

  /// No description provided for @depositsHoldEndsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Hold ends tomorrow'**
  String get depositsHoldEndsTomorrow;

  /// No description provided for @depositsHoldUntil.
  ///
  /// In en, this message translates to:
  /// **'Held until'**
  String get depositsHoldUntil;

  /// No description provided for @depositsHolder.
  ///
  /// In en, this message translates to:
  /// **'Held by'**
  String get depositsHolder;

  /// No description provided for @depositsHolderAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get depositsHolderAgency;

  /// No description provided for @depositsHolderNotary.
  ///
  /// In en, this message translates to:
  /// **'Notary'**
  String get depositsHolderNotary;

  /// No description provided for @depositsHolderSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get depositsHolderSeller;

  /// No description provided for @depositsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the deposit'**
  String get depositsLoadFailed;

  /// No description provided for @depositsNone.
  ///
  /// In en, this message translates to:
  /// **'No deposit recorded'**
  String get depositsNone;

  /// No description provided for @depositsNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Record it when the buyer puts money down; the listing then shows as reserved.'**
  String get depositsNoneHint;

  /// No description provided for @depositsNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get depositsNote;

  /// No description provided for @depositsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Receipt number, terms'**
  String get depositsNoteHint;

  /// No description provided for @depositsOutcomeApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied to the purchase'**
  String get depositsOutcomeApplied;

  /// No description provided for @depositsOutcomeForfeited.
  ///
  /// In en, this message translates to:
  /// **'Forfeited'**
  String get depositsOutcomeForfeited;

  /// No description provided for @depositsOutcomeRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get depositsOutcomeRefunded;

  /// No description provided for @depositsReceivedOn.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get depositsReceivedOn;

  /// No description provided for @depositsRecord.
  ///
  /// In en, this message translates to:
  /// **'Record deposit'**
  String get depositsRecord;

  /// No description provided for @depositsRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a deposit'**
  String get depositsRecordTitle;

  /// No description provided for @depositsReservedUntil.
  ///
  /// In en, this message translates to:
  /// **'Reserved until {date}'**
  String depositsReservedUntil(String date);

  /// No description provided for @depositsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositsTitle;

  /// No description provided for @documentsAdd.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get documentsAdd;

  /// No description provided for @documentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No files} =1{1 file} other{{count} files}}'**
  String documentsCount(num count);

  /// No description provided for @documentsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this deal. This cannot be undone.'**
  String documentsDeleteConfirm(Object name);

  /// No description provided for @documentsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get documentsDeleteTitle;

  /// No description provided for @documentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No files attached to this deal yet'**
  String get documentsEmpty;

  /// No description provided for @documentsNoApp.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this file'**
  String get documentsNoApp;

  /// No description provided for @documentsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This file could not be opened'**
  String get documentsOpenFailed;

  /// No description provided for @documentsSizeBytes.
  ///
  /// In en, this message translates to:
  /// **'{size} B'**
  String documentsSizeBytes(Object size);

  /// No description provided for @documentsSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String documentsSizeKb(Object size);

  /// No description provided for @documentsSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String documentsSizeMb(Object size);

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @documentsTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Files larger than {limit} MB cannot be attached'**
  String documentsTooLarge(Object limit);

  /// No description provided for @documentsUploadedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String documentsUploadedBy(Object name);

  /// No description provided for @documentsUploading.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get documentsUploading;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @exportAllNote.
  ///
  /// In en, this message translates to:
  /// **'Everything you can see, without filters.'**
  String get exportAllNote;

  /// No description provided for @exportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportConfirm;

  /// No description provided for @exportConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your agency\'s book as spreadsheets: for the owner, the accountant, or a copy of your own.'**
  String get exportConsoleSubtitle;

  /// No description provided for @exportConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportConsoleTitle;

  /// No description provided for @exportDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get exportDelimiter;

  /// No description provided for @exportDelimiterComma.
  ///
  /// In en, this message translates to:
  /// **'Comma'**
  String get exportDelimiterComma;

  /// No description provided for @exportDelimiterHint.
  ///
  /// In en, this message translates to:
  /// **'Excel in Russian or Kazakh splits columns on semicolons; in English, on commas.'**
  String get exportDelimiterHint;

  /// No description provided for @exportDelimiterSemicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon'**
  String get exportDelimiterSemicolon;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export. Try again.'**
  String get exportFailed;

  /// No description provided for @exportFiltersNote.
  ///
  /// In en, this message translates to:
  /// **'Only what the list shows now, with its filters.'**
  String get exportFiltersNote;

  /// No description provided for @exportFormatNote.
  ///
  /// In en, this message translates to:
  /// **'A CSV file that opens in Excel, Google Sheets and Numbers, and imports back into the CRM as it is.'**
  String get exportFormatNote;

  /// No description provided for @exportKindClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get exportKindClients;

  /// No description provided for @exportKindDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get exportKindDeals;

  /// No description provided for @exportKindProperties.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get exportKindProperties;

  /// No description provided for @exportPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Includes personal data: names, phones and emails. Handle with care and share it no further than needed.'**
  String get exportPersonalData;

  /// No description provided for @exportTitleClients.
  ///
  /// In en, this message translates to:
  /// **'Export clients'**
  String get exportTitleClients;

  /// No description provided for @exportTitleDeals.
  ///
  /// In en, this message translates to:
  /// **'Export deals'**
  String get exportTitleDeals;

  /// No description provided for @exportTitleProperties.
  ///
  /// In en, this message translates to:
  /// **'Export listings'**
  String get exportTitleProperties;

  /// No description provided for @exportTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many rows for one file. Narrow the filters and export in parts.'**
  String get exportTooMany;

  /// No description provided for @goalsAgency.
  ///
  /// In en, this message translates to:
  /// **'Whole agency'**
  String get goalsAgency;

  /// No description provided for @goalsAgentOwn.
  ///
  /// In en, this message translates to:
  /// **'Agent\'s own target'**
  String get goalsAgentOwn;

  /// No description provided for @goalsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'This month\'s target'**
  String get goalsCardTitle;

  /// No description provided for @goalsCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get goalsCommissionLabel;

  /// No description provided for @goalsCommissionOf.
  ///
  /// In en, this message translates to:
  /// **'{achieved} of {target}'**
  String goalsCommissionOf(String achieved, String target);

  /// No description provided for @goalsCopied.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to copy from last month} =1{1 target copied} other{{count} targets copied}}'**
  String goalsCopied(int count);

  /// No description provided for @goalsCopyPrevious.
  ///
  /// In en, this message translates to:
  /// **'Copy last month\'s targets'**
  String get goalsCopyPrevious;

  /// No description provided for @goalsDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The month is over} =1{1 day left} other{{count} days left}}'**
  String goalsDaysLeft(int count);

  /// No description provided for @goalsDealEvery.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{a deal every {count} days}}'**
  String goalsDealEvery(int count);

  /// No description provided for @goalsDealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Deals won'**
  String get goalsDealsLabel;

  /// No description provided for @goalsDealsOf.
  ///
  /// In en, this message translates to:
  /// **'{won} of {target} deals won'**
  String goalsDealsOf(int won, int target);

  /// No description provided for @goalsDealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deal a day} other{{count} deals a day}}'**
  String goalsDealsPerDay(int count);

  /// No description provided for @goalsDealsWon.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No deals won yet} =1{1 deal won} other{{count} deals won}}'**
  String goalsDealsWon(int count);

  /// No description provided for @goalsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get goalsEyebrow;

  /// No description provided for @goalsFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for none'**
  String get goalsFieldHint;

  /// No description provided for @goalsInvalidCommission.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get goalsInvalidCommission;

  /// No description provided for @goalsInvalidDeals.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1 to 1000'**
  String get goalsInvalidDeals;

  /// No description provided for @goalsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the targets'**
  String get goalsLoadFailed;

  /// No description provided for @goalsManagerSet.
  ///
  /// In en, this message translates to:
  /// **'Set by your manager'**
  String get goalsManagerSet;

  /// No description provided for @goalsMonthOver.
  ///
  /// In en, this message translates to:
  /// **'This month is over. Its targets stay as they were.'**
  String get goalsMonthOver;

  /// No description provided for @goalsNeedOne.
  ///
  /// In en, this message translates to:
  /// **'Enter a commission, a number of deals, or both'**
  String get goalsNeedOne;

  /// No description provided for @goalsNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get goalsNextMonth;

  /// No description provided for @goalsNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get goalsNoTarget;

  /// No description provided for @goalsNone.
  ///
  /// In en, this message translates to:
  /// **'No target for this month yet'**
  String get goalsNone;

  /// No description provided for @goalsNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to set your own. If your manager sets one, theirs counts.'**
  String get goalsNoneHint;

  /// No description provided for @goalsOwn.
  ///
  /// In en, this message translates to:
  /// **'Your own target'**
  String get goalsOwn;

  /// No description provided for @goalsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} a day'**
  String goalsPerDay(String amount);

  /// No description provided for @goalsPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get goalsPreviousMonth;

  /// No description provided for @goalsReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached. Everything from here is ahead of plan.'**
  String get goalsReached;

  /// No description provided for @goalsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove target'**
  String get goalsRemove;

  /// No description provided for @goalsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Target removed'**
  String get goalsRemoved;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Target saved'**
  String get goalsSaved;

  /// No description provided for @goalsSheetFor.
  ///
  /// In en, this message translates to:
  /// **'Target for {name}'**
  String goalsSheetFor(String name);

  /// No description provided for @goalsSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Deals won this month count, with the commission on each.'**
  String get goalsSheetHint;

  /// No description provided for @goalsSheetOwnHint.
  ///
  /// In en, this message translates to:
  /// **'If your manager sets a target for you, theirs takes the place of yours.'**
  String get goalsSheetOwnHint;

  /// No description provided for @goalsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly target'**
  String get goalsSheetTitle;

  /// No description provided for @goalsTeamEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one in the agency yet'**
  String get goalsTeamEmpty;

  /// No description provided for @goalsTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Targets for each agent and the agency'**
  String get goalsTeamHint;

  /// No description provided for @goalsTeamIntro.
  ///
  /// In en, this message translates to:
  /// **'A target for each agent and for the whole agency. Progress counts the deals won in the month and the commission on them. Your target replaces one an agent set for themselves.'**
  String get goalsTeamIntro;

  /// No description provided for @goalsTeamOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Your target replaces one the agent set for themselves.'**
  String get goalsTeamOverrideHint;

  /// No description provided for @goalsTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly goals'**
  String get goalsTeamTitle;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 row} other{Import {count} rows}}'**
  String importAction(int count);

  /// No description provided for @importAnother.
  ///
  /// In en, this message translates to:
  /// **'Import another file'**
  String get importAnother;

  /// No description provided for @importAssignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get importAssignTo;

  /// No description provided for @importAssignToMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get importAssignToMe;

  /// No description provided for @importChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV file'**
  String get importChooseFile;

  /// No description provided for @importColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get importColumns;

  /// No description provided for @importColumnsHint.
  ///
  /// In en, this message translates to:
  /// **'Check which field each column fills. Columns set to Skip are left out.'**
  String get importColumnsHint;

  /// No description provided for @importCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get importCreated;

  /// No description provided for @importDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get importDoneTitle;

  /// No description provided for @importDownloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download template'**
  String get importDownloadTemplate;

  /// No description provided for @importDuplicateOfClient.
  ///
  /// In en, this message translates to:
  /// **'Already in the agency: {name}'**
  String importDuplicateOfClient(String name);

  /// No description provided for @importDuplicateOfRow.
  ///
  /// In en, this message translates to:
  /// **'Same as row {row}'**
  String importDuplicateOfRow(int row);

  /// No description provided for @importEmptyFile.
  ///
  /// In en, this message translates to:
  /// **'The file is empty'**
  String get importEmptyFile;

  /// No description provided for @importEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clients and listings from Excel or another CRM'**
  String get importEntrySubtitle;

  /// No description provided for @importErrorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Not a date'**
  String get importErrorInvalidDate;

  /// No description provided for @importErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Not an email address'**
  String get importErrorInvalidEmail;

  /// No description provided for @importErrorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Not a number'**
  String get importErrorInvalidNumber;

  /// No description provided for @importErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Not a phone number'**
  String get importErrorInvalidPhone;

  /// No description provided for @importErrorNegative.
  ///
  /// In en, this message translates to:
  /// **'Must be above zero'**
  String get importErrorNegative;

  /// No description provided for @importErrorOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of range'**
  String get importErrorOutOfRange;

  /// No description provided for @importErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get importErrorRequired;

  /// No description provided for @importErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get importErrorTooLong;

  /// No description provided for @importErrorUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown value'**
  String get importErrorUnknownValue;

  /// No description provided for @importFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get importFieldAddress;

  /// No description provided for @importFieldArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get importFieldArea;

  /// No description provided for @importFieldBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get importFieldBirthday;

  /// No description provided for @importFieldBudgetMax.
  ///
  /// In en, this message translates to:
  /// **'Budget to'**
  String get importFieldBudgetMax;

  /// No description provided for @importFieldBudgetMin.
  ///
  /// In en, this message translates to:
  /// **'Budget from'**
  String get importFieldBudgetMin;

  /// No description provided for @importFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get importFieldCity;

  /// No description provided for @importFieldClientType.
  ///
  /// In en, this message translates to:
  /// **'Client type'**
  String get importFieldClientType;

  /// No description provided for @importFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get importFieldDescription;

  /// No description provided for @importFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get importFieldEmail;

  /// No description provided for @importFieldFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get importFieldFloor;

  /// No description provided for @importFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get importFieldFullName;

  /// No description provided for @importFieldMinArea.
  ///
  /// In en, this message translates to:
  /// **'Area from'**
  String get importFieldMinArea;

  /// No description provided for @importFieldMinRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms from'**
  String get importFieldMinRooms;

  /// No description provided for @importFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get importFieldNotes;

  /// No description provided for @importFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get importFieldPhone;

  /// No description provided for @importFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get importFieldPrice;

  /// No description provided for @importFieldPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get importFieldPropertyType;

  /// No description provided for @importFieldRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get importFieldRooms;

  /// No description provided for @importFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get importFieldStatus;

  /// No description provided for @importFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get importFieldTags;

  /// No description provided for @importFieldLeadSource.
  ///
  /// In en, this message translates to:
  /// **'Lead source'**
  String get importFieldLeadSource;

  /// No description provided for @importFieldLeadSourceDetail.
  ///
  /// In en, this message translates to:
  /// **'Lead source detail'**
  String get importFieldLeadSourceDetail;

  /// No description provided for @importFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get importFieldTitle;

  /// No description provided for @importFieldTotalFloors.
  ///
  /// In en, this message translates to:
  /// **'Total floors'**
  String get importFieldTotalFloors;

  /// No description provided for @importFieldWantedCity.
  ///
  /// In en, this message translates to:
  /// **'Wanted city'**
  String get importFieldWantedCity;

  /// No description provided for @importFieldWantedType.
  ///
  /// In en, this message translates to:
  /// **'Wanted property type'**
  String get importFieldWantedType;

  /// No description provided for @importFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 5 MB. Split it into parts.'**
  String get importFileTooLarge;

  /// No description provided for @importHowTo.
  ///
  /// In en, this message translates to:
  /// **'Save the sheet as CSV in Excel or Google Sheets. Commas, semicolons and tabs all work, and so do Cyrillic files from a Russian Excel.'**
  String get importHowTo;

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not imported, errors'**
  String get importInvalid;

  /// No description provided for @importKindClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get importKindClients;

  /// No description provided for @importKindClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Names, phones, what they are looking for'**
  String get importKindClientsHint;

  /// No description provided for @importKindProperties.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get importKindProperties;

  /// No description provided for @importKindPropertiesHint.
  ///
  /// In en, this message translates to:
  /// **'Addresses, prices, areas, rooms'**
  String get importKindPropertiesHint;

  /// No description provided for @importMissingRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a column for {field}'**
  String importMissingRequired(String field);

  /// No description provided for @importNoAgents.
  ///
  /// In en, this message translates to:
  /// **'No colleagues found'**
  String get importNoAgents;

  /// No description provided for @importNoProblems.
  ///
  /// In en, this message translates to:
  /// **'Every row is ready to import'**
  String get importNoProblems;

  /// No description provided for @importNotCsv.
  ///
  /// In en, this message translates to:
  /// **'Choose a .csv file. In Excel: File, Save as, CSV.'**
  String get importNotCsv;

  /// No description provided for @importNothingToImport.
  ///
  /// In en, this message translates to:
  /// **'Nothing to import'**
  String get importNothingToImport;

  /// No description provided for @importOpenClients.
  ///
  /// In en, this message translates to:
  /// **'Open clients'**
  String get importOpenClients;

  /// No description provided for @importOpenProperties.
  ///
  /// In en, this message translates to:
  /// **'Open listings'**
  String get importOpenProperties;

  /// No description provided for @importOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get importOptions;

  /// No description provided for @importPickAgentSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get importPickAgentSearch;

  /// No description provided for @importProblems.
  ///
  /// In en, this message translates to:
  /// **'Rows that need attention'**
  String get importProblems;

  /// No description provided for @importProblemsTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first 1000 are listed'**
  String get importProblemsTruncated;

  /// No description provided for @importRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {row}'**
  String importRowLabel(int row);

  /// No description provided for @importRowsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row in the file} other{{count} rows in the file}}'**
  String importRowsTotal(int count);

  /// No description provided for @importShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get importShowMore;

  /// No description provided for @importSkipColumn.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get importSkipColumn;

  /// No description provided for @importSkipDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Skip duplicates'**
  String get importSkipDuplicates;

  /// No description provided for @importSkipDuplicatesHint.
  ///
  /// In en, this message translates to:
  /// **'A client whose email is already in the agency is always skipped'**
  String get importSkipDuplicatesHint;

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped duplicates'**
  String get importSkipped;

  /// No description provided for @importSummaryDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get importSummaryDuplicates;

  /// No description provided for @importSummaryInvalid.
  ///
  /// In en, this message translates to:
  /// **'With errors'**
  String get importSummaryInvalid;

  /// No description provided for @importSummaryValid.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get importSummaryValid;

  /// No description provided for @importTemplateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the template'**
  String get importTemplateFailed;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from a spreadsheet'**
  String get importTitle;

  /// No description provided for @importTooManyRows.
  ///
  /// In en, this message translates to:
  /// **'The file has more than 5000 rows. Split it into parts.'**
  String get importTooManyRows;

  /// No description provided for @leaderboardDealsLost.
  ///
  /// In en, this message translates to:
  /// **'Deals lost'**
  String get leaderboardDealsLost;

  /// No description provided for @leaderboardEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Agents who join the agency will be ranked here.'**
  String get leaderboardEmptyBody;

  /// No description provided for @leaderboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No agents yet'**
  String get leaderboardEmptyTitle;

  /// No description provided for @leaderboardHint.
  ///
  /// In en, this message translates to:
  /// **'Deals, commission and viewings, agent by agent'**
  String get leaderboardHint;

  /// No description provided for @leaderboardInactive.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get leaderboardInactive;

  /// No description provided for @leaderboardInactiveNote.
  ///
  /// In en, this message translates to:
  /// **'Deactivated members are not ranked with the team. Anyone removed from the agency is not listed: their records moved to a colleague.'**
  String get leaderboardInactiveNote;

  /// No description provided for @leaderboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the leaderboard'**
  String get leaderboardLoadFailed;

  /// No description provided for @leaderboardNoValue.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get leaderboardNoValue;

  /// No description provided for @leaderboardPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get leaderboardPeriodCustom;

  /// No description provided for @leaderboardPeriodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get leaderboardPeriodLastMonth;

  /// No description provided for @leaderboardPeriodQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get leaderboardPeriodQuarter;

  /// No description provided for @leaderboardPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get leaderboardPeriodThisMonth;

  /// No description provided for @leaderboardPickRange.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get leaderboardPickRange;

  /// No description provided for @leaderboardRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String leaderboardRange(String from, String to);

  /// No description provided for @leaderboardSortCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get leaderboardSortCommission;

  /// No description provided for @leaderboardSortDealsWon.
  ///
  /// In en, this message translates to:
  /// **'Deals won'**
  String get leaderboardSortDealsWon;

  /// No description provided for @leaderboardSortNewClients.
  ///
  /// In en, this message translates to:
  /// **'New clients'**
  String get leaderboardSortNewClients;

  /// No description provided for @leaderboardSortViewings.
  ///
  /// In en, this message translates to:
  /// **'Viewings'**
  String get leaderboardSortViewings;

  /// No description provided for @leaderboardSortWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get leaderboardSortWinRate;

  /// No description provided for @leaderboardSummary.
  ///
  /// In en, this message translates to:
  /// **'Won {won} · Viewings {viewings} · Clients {clients}'**
  String leaderboardSummary(int won, int viewings, int clients);

  /// No description provided for @leaderboardTeamCommission.
  ///
  /// In en, this message translates to:
  /// **'Agency commission'**
  String get leaderboardTeamCommission;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardWonValue.
  ///
  /// In en, this message translates to:
  /// **'Won value'**
  String get leaderboardWonValue;

  /// No description provided for @lockAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get lockAppLock;

  /// No description provided for @lockAppLockHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN to open the app'**
  String get lockAppLockHint;

  /// No description provided for @lockAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockAutoLock;

  /// No description provided for @lockAutoLockFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes in the background'**
  String get lockAutoLockFifteenMinutes;

  /// No description provided for @lockAutoLockFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes in the background'**
  String get lockAutoLockFiveMinutes;

  /// No description provided for @lockAutoLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockAutoLockImmediately;

  /// No description provided for @lockAutoLockOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute in the background'**
  String get lockAutoLockOneMinute;

  /// No description provided for @lockAutoLockTitle.
  ///
  /// In en, this message translates to:
  /// **'When to lock the app'**
  String get lockAutoLockTitle;

  /// No description provided for @lockCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get lockCancel;

  /// No description provided for @lockChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get lockChangePin;

  /// No description provided for @lockConfirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get lockConfirmPinTitle;

  /// No description provided for @lockContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lockContinue;

  /// No description provided for @lockCurrentPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get lockCurrentPinTitle;

  /// No description provided for @lockDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get lockDelete;

  /// No description provided for @lockDigitsHint.
  ///
  /// In en, this message translates to:
  /// **'4 to 6 digits'**
  String get lockDigitsHint;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockEnterPin;

  /// No description provided for @lockForgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get lockForgotPin;

  /// No description provided for @lockForgotPinBody.
  ///
  /// In en, this message translates to:
  /// **'Signing out removes the PIN and the client data saved on this phone. Then sign in again with your password.'**
  String get lockForgotPinBody;

  /// No description provided for @lockMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs do not match. Try again.'**
  String get lockMismatch;

  /// No description provided for @lockNewPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get lockNewPinTitle;

  /// No description provided for @lockPinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get lockPinChanged;

  /// No description provided for @lockRetryIn.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {time}'**
  String lockRetryIn(String time);

  /// No description provided for @lockSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get lockSecurity;

  /// No description provided for @lockSignOutAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign out and sign in again'**
  String get lockSignOutAgain;

  /// No description provided for @lockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Sign out and sign in again with your password.'**
  String get lockTooManyAttempts;

  /// No description provided for @lockTooShort.
  ///
  /// In en, this message translates to:
  /// **'The PIN needs 4 to 6 digits.'**
  String get lockTooShort;

  /// No description provided for @lockTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get lockTurnOn;

  /// No description provided for @lockTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get lockTurnedOff;

  /// No description provided for @lockTurnedOn.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get lockTurnedOn;

  /// No description provided for @lockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get lockWrongPin;

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
  String meetingsAgentNumber(Object id);

  /// No description provided for @meetingsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get meetingsClient;

  /// No description provided for @meetingsClientNumber.
  ///
  /// In en, this message translates to:
  /// **'Client #{id}'**
  String meetingsClientNumber(Object id);

  /// No description provided for @meetingsCounter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 this week} other{{count} this week}}'**
  String meetingsCounter(num count);

  /// No description provided for @meetingsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get meetingsDate;

  /// No description provided for @meetingsDeal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get meetingsDeal;

  /// No description provided for @meetingsDealNumber.
  ///
  /// In en, this message translates to:
  /// **'Deal #{id}'**
  String meetingsDealNumber(Object id);

  /// No description provided for @meetingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get meetingsDelete;

  /// No description provided for @meetingsDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{title} will be deleted permanently. This cannot be undone.'**
  String meetingsDeleteCascade(Object title);

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

  /// No description provided for @meetingsDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get meetingsDirections;

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

  /// No description provided for @meetingsGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get meetingsGroupToday;

  /// No description provided for @meetingsGroupTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get meetingsGroupTomorrow;

  /// No description provided for @meetingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get meetingsLocation;

  /// No description provided for @meetingsMustBeInFuture.
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future'**
  String get meetingsMustBeInFuture;

  /// No description provided for @meetingsNoAgentsToAssign.
  ///
  /// In en, this message translates to:
  /// **'No agents to assign'**
  String get meetingsNoAgentsToAssign;

  /// No description provided for @meetingsNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location on this meeting'**
  String get meetingsNoLocation;

  /// No description provided for @meetingsNoMeetings.
  ///
  /// In en, this message translates to:
  /// **'No meetings'**
  String get meetingsNoMeetings;

  /// No description provided for @meetingsNote.
  ///
  /// In en, this message translates to:
  /// **'Meeting note'**
  String get meetingsNote;

  /// No description provided for @meetingsNothingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing upcoming'**
  String get meetingsNothingUpcoming;

  /// No description provided for @meetingsNothingUpcomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past meetings stay in your history.'**
  String get meetingsNothingUpcomingSubtitle;

  /// No description provided for @meetingsOutcome.
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get meetingsOutcome;

  /// No description provided for @meetingsOutcomeInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get meetingsOutcomeInterested;

  /// No description provided for @meetingsOutcomeNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get meetingsOutcomeNoShow;

  /// No description provided for @meetingsOutcomeNote.
  ///
  /// In en, this message translates to:
  /// **'What they said'**
  String get meetingsOutcomeNote;

  /// No description provided for @meetingsOutcomeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Too dark, the road is loud…'**
  String get meetingsOutcomeNoteHint;

  /// No description provided for @meetingsOutcomeRejected.
  ///
  /// In en, this message translates to:
  /// **'Turned it down'**
  String get meetingsOutcomeRejected;

  /// No description provided for @meetingsOutcomeRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'A listing turned down stops being offered to this buyer'**
  String get meetingsOutcomeRejectedHint;

  /// No description provided for @meetingsOutcomeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get meetingsOutcomeSave;

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

  /// No description provided for @meetingsProperty.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get meetingsProperty;

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

  /// No description provided for @meetingsScheduleViewing.
  ///
  /// In en, this message translates to:
  /// **'Schedule a viewing'**
  String get meetingsScheduleViewing;

  /// No description provided for @meetingsSearchByNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by name or ID…'**
  String get meetingsSearchByNameOrId;

  /// No description provided for @meetingsSelectEntity.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String meetingsSelectEntity(Object label);

  /// No description provided for @meetingsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get meetingsStatus;

  /// No description provided for @meetingsStatusHeld.
  ///
  /// In en, this message translates to:
  /// **'Held'**
  String get meetingsStatusHeld;

  /// No description provided for @meetingsStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get meetingsStatusScheduled;

  /// No description provided for @meetingsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get meetingsTime;

  /// No description provided for @meetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetingsTitle;

  /// No description provided for @meetingsTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get meetingsTitleFieldLabel;

  /// No description provided for @meetingsTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get meetingsTitleRequired;

  /// No description provided for @meetingsUpcomingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get meetingsUpcomingEyebrow;

  /// No description provided for @meetingsUpdateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Update Meeting'**
  String get meetingsUpdateMeeting;

  /// No description provided for @meetingsViewingOf.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get meetingsViewingOf;

  /// No description provided for @meetingsWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get meetingsWhen;

  /// No description provided for @meetingsWhoAndWhere.
  ///
  /// In en, this message translates to:
  /// **'Who & where'**
  String get meetingsWhoAndWhere;

  /// No description provided for @mortgageAmortisation.
  ///
  /// In en, this message translates to:
  /// **'Payment schedule'**
  String get mortgageAmortisation;

  /// No description provided for @mortgageAnnuity.
  ///
  /// In en, this message translates to:
  /// **'Annuity'**
  String get mortgageAnnuity;

  /// No description provided for @mortgageDifferentiated.
  ///
  /// In en, this message translates to:
  /// **'Differentiated'**
  String get mortgageDifferentiated;

  /// No description provided for @mortgageDownPayment.
  ///
  /// In en, this message translates to:
  /// **'Down payment'**
  String get mortgageDownPayment;

  /// No description provided for @mortgageDownSummary.
  ///
  /// In en, this message translates to:
  /// **'{percent}% down · {rate}% · {term}'**
  String mortgageDownSummary(String percent, String rate, String term);

  /// No description provided for @mortgageFees.
  ///
  /// In en, this message translates to:
  /// **'One-off fees'**
  String get mortgageFees;

  /// No description provided for @mortgageFeesHint.
  ///
  /// In en, this message translates to:
  /// **'Appraisal, insurance, bank fee'**
  String get mortgageFeesHint;

  /// No description provided for @mortgageFromPerMonth.
  ///
  /// In en, this message translates to:
  /// **'from {amount} / month'**
  String mortgageFromPerMonth(String amount);

  /// No description provided for @mortgageIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps the payment within {percent}% of income'**
  String mortgageIncomeHint(String percent);

  /// No description provided for @mortgageIncomeNeeded.
  ///
  /// In en, this message translates to:
  /// **'Income needed'**
  String get mortgageIncomeNeeded;

  /// No description provided for @mortgageInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get mortgageInterest;

  /// No description provided for @mortgageLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get mortgageLoan;

  /// No description provided for @mortgageMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month {number}'**
  String mortgageMonthLabel(int number);

  /// No description provided for @mortgageMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get mortgageMonthly;

  /// No description provided for @mortgageMonthlyRange.
  ///
  /// In en, this message translates to:
  /// **'First month → last month'**
  String get mortgageMonthlyRange;

  /// No description provided for @mortgageNoLoan.
  ///
  /// In en, this message translates to:
  /// **'The down payment covers the price, so there is nothing to borrow.'**
  String get mortgageNoLoan;

  /// No description provided for @mortgageOpenCalculator.
  ///
  /// In en, this message translates to:
  /// **'Open calculator'**
  String get mortgageOpenCalculator;

  /// No description provided for @mortgageOverpayment.
  ///
  /// In en, this message translates to:
  /// **'Overpayment'**
  String get mortgageOverpayment;

  /// No description provided for @mortgagePresetHousingSavings.
  ///
  /// In en, this message translates to:
  /// **'Housing savings'**
  String get mortgagePresetHousingSavings;

  /// No description provided for @mortgagePresetMarket.
  ///
  /// In en, this message translates to:
  /// **'Market rate'**
  String get mortgagePresetMarket;

  /// No description provided for @mortgagePresetStateProgram.
  ///
  /// In en, this message translates to:
  /// **'7-20-25 programme'**
  String get mortgagePresetStateProgram;

  /// No description provided for @mortgagePresetsNote.
  ///
  /// In en, this message translates to:
  /// **'Typical rates, not bank offers. Rates change, so check with the bank.'**
  String get mortgagePresetsNote;

  /// No description provided for @mortgagePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get mortgagePrice;

  /// No description provided for @mortgagePrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get mortgagePrincipal;

  /// No description provided for @mortgageRangePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{first} → {last} / month'**
  String mortgageRangePerMonth(String first, String last);

  /// No description provided for @mortgageRate.
  ///
  /// In en, this message translates to:
  /// **'Annual rate, %'**
  String get mortgageRate;

  /// No description provided for @mortgageSend.
  ///
  /// In en, this message translates to:
  /// **'Send to client'**
  String get mortgageSend;

  /// No description provided for @mortgageShareDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Indicative estimate, not an offer.'**
  String get mortgageShareDisclaimer;

  /// No description provided for @mortgageShareDown.
  ///
  /// In en, this message translates to:
  /// **'Down payment: {amount} ({percent}%)'**
  String mortgageShareDown(String amount, String percent);

  /// No description provided for @mortgageShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the estimate'**
  String get mortgageShareFailed;

  /// No description provided for @mortgageShareHeading.
  ///
  /// In en, this message translates to:
  /// **'Mortgage estimate'**
  String get mortgageShareHeading;

  /// No description provided for @mortgageShareMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment: {amount}'**
  String mortgageShareMonthly(String amount);

  /// No description provided for @mortgageShareMonthlyRange.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment: {first} in the first month, {last} in the last'**
  String mortgageShareMonthlyRange(String first, String last);

  /// No description provided for @mortgageShareOverpayment.
  ///
  /// In en, this message translates to:
  /// **'Total overpayment: {amount}'**
  String mortgageShareOverpayment(String amount);

  /// No description provided for @mortgageSharePrice.
  ///
  /// In en, this message translates to:
  /// **'Price: {amount}'**
  String mortgageSharePrice(String amount);

  /// No description provided for @mortgageShareRate.
  ///
  /// In en, this message translates to:
  /// **'Rate: {rate}% a year'**
  String mortgageShareRate(String rate);

  /// No description provided for @mortgageShareTerm.
  ///
  /// In en, this message translates to:
  /// **'Term: {term}'**
  String mortgageShareTerm(String term);

  /// No description provided for @mortgageTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get mortgageTerm;

  /// No description provided for @mortgageTermYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year} other{{count} years}}'**
  String mortgageTermYears(int count);

  /// No description provided for @mortgageTitle.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgageTitle;

  /// No description provided for @mortgageTotalRepaid.
  ///
  /// In en, this message translates to:
  /// **'Total repaid'**
  String get mortgageTotalRepaid;

  /// No description provided for @mortgageType.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get mortgageType;

  /// No description provided for @mortgageYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year {number}'**
  String mortgageYearLabel(int number);

  /// No description provided for @msgAgentInvited.
  ///
  /// In en, this message translates to:
  /// **'Agent invited'**
  String get msgAgentInvited;

  /// No description provided for @msgChecklistSaved.
  ///
  /// In en, this message translates to:
  /// **'Checklist saved'**
  String get msgChecklistSaved;

  /// No description provided for @msgClientCreated.
  ///
  /// In en, this message translates to:
  /// **'Client created'**
  String get msgClientCreated;

  /// No description provided for @msgClientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Client deleted'**
  String get msgClientDeleted;

  /// No description provided for @msgClientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Client updated'**
  String get msgClientUpdated;

  /// No description provided for @msgClientsMerged.
  ///
  /// In en, this message translates to:
  /// **'Cards merged'**
  String get msgClientsMerged;

  /// No description provided for @msgCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent'**
  String get msgCodeSent;

  /// No description provided for @msgCommentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted'**
  String get msgCommentDeleted;

  /// No description provided for @msgCommentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment updated'**
  String get msgCommentUpdated;

  /// No description provided for @msgCurrencyChanged.
  ///
  /// In en, this message translates to:
  /// **'Currency changed'**
  String get msgCurrencyChanged;

  /// No description provided for @msgDealCreated.
  ///
  /// In en, this message translates to:
  /// **'Deal created'**
  String get msgDealCreated;

  /// No description provided for @msgDealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deal deleted'**
  String get msgDealDeleted;

  /// No description provided for @msgDealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Deal updated'**
  String get msgDealUpdated;

  /// No description provided for @msgDocumentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document removed'**
  String get msgDocumentDeleted;

  /// No description provided for @msgDocumentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document attached'**
  String get msgDocumentUploaded;

  /// No description provided for @msgInviteResent.
  ///
  /// In en, this message translates to:
  /// **'Invite resent'**
  String get msgInviteResent;

  /// No description provided for @msgMeetingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Meeting completed'**
  String get msgMeetingCompleted;

  /// No description provided for @msgMeetingCreated.
  ///
  /// In en, this message translates to:
  /// **'Meeting created'**
  String get msgMeetingCreated;

  /// No description provided for @msgMeetingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meeting deleted'**
  String get msgMeetingDeleted;

  /// No description provided for @msgMeetingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meeting updated'**
  String get msgMeetingUpdated;

  /// No description provided for @msgMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Agent removed from the team'**
  String get msgMemberRemoved;

  /// No description provided for @msgNotificationsAllRead.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get msgNotificationsAllRead;

  /// No description provided for @msgProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get msgProfileUpdated;

  /// No description provided for @msgPropertyCreated.
  ///
  /// In en, this message translates to:
  /// **'Property created'**
  String get msgPropertyCreated;

  /// No description provided for @msgPropertyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Property deleted'**
  String get msgPropertyDeleted;

  /// No description provided for @msgPropertyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Property updated'**
  String get msgPropertyUpdated;

  /// No description provided for @msgRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request withdrawn'**
  String get msgRequestCancelled;

  /// No description provided for @msgRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get msgRequestDeclined;

  /// No description provided for @msgRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get msgRequestSent;

  /// No description provided for @msgRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Role updated'**
  String get msgRoleUpdated;

  /// No description provided for @msgStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get msgStatusUpdated;

  /// No description provided for @msgTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task done'**
  String get msgTaskCompleted;

  /// No description provided for @msgTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task added'**
  String get msgTaskCreated;

  /// No description provided for @msgTaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get msgTaskDeleted;

  /// No description provided for @msgTaskReopened.
  ///
  /// In en, this message translates to:
  /// **'Task reopened'**
  String get msgTaskReopened;

  /// No description provided for @msgTaskRepeatStopped.
  ///
  /// In en, this message translates to:
  /// **'The task no longer repeats'**
  String get msgTaskRepeatStopped;

  /// No description provided for @msgTaskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get msgTaskUpdated;

  /// No description provided for @msgTeamAssigned.
  ///
  /// In en, this message translates to:
  /// **'Team assigned'**
  String get msgTeamAssigned;

  /// No description provided for @msgTeamCreated.
  ///
  /// In en, this message translates to:
  /// **'Team created'**
  String get msgTeamCreated;

  /// No description provided for @msgTeamJoined.
  ///
  /// In en, this message translates to:
  /// **'You have joined the team'**
  String get msgTeamJoined;

  /// No description provided for @msgTeamLeft.
  ///
  /// In en, this message translates to:
  /// **'You have left the team'**
  String get msgTeamLeft;

  /// No description provided for @msgTeamUpdated.
  ///
  /// In en, this message translates to:
  /// **'Team updated'**
  String get msgTeamUpdated;

  /// No description provided for @msgTemplateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get msgTemplateDeleted;

  /// No description provided for @msgTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get msgTemplateSaved;

  /// No description provided for @msgUserActivated.
  ///
  /// In en, this message translates to:
  /// **'User activated'**
  String get msgUserActivated;

  /// No description provided for @msgUserDeactivated.
  ///
  /// In en, this message translates to:
  /// **'User deactivated'**
  String get msgUserDeactivated;

  /// No description provided for @msgUserDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get msgUserDeleted;

  /// No description provided for @notificationsClientBirthday.
  ///
  /// In en, this message translates to:
  /// **'It\'s {name}\'s birthday today'**
  String notificationsClientBirthday(String name);

  /// No description provided for @notificationsCountClients.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 client} other{{count} clients}}'**
  String notificationsCountClients(int count);

  /// No description provided for @notificationsCountDeals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deal} other{{count} deals}}'**
  String notificationsCountDeals(int count);

  /// No description provided for @notificationsCountListings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 listing} other{{count} listings}}'**
  String notificationsCountListings(int count);

  /// No description provided for @notificationsCountMeetings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meeting} other{{count} meetings}}'**
  String notificationsCountMeetings(int count);

  /// No description provided for @notificationsCountTasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String notificationsCountTasks(int count);

  /// No description provided for @notificationsDealComment.
  ///
  /// In en, this message translates to:
  /// **'{author} commented on {title}'**
  String notificationsDealComment(String author, String title);

  /// No description provided for @notificationsDealMention.
  ///
  /// In en, this message translates to:
  /// **'{author} mentioned you in {title}'**
  String notificationsDealMention(String author, String title);

  /// No description provided for @notificationsDealStatus.
  ///
  /// In en, this message translates to:
  /// **'{actor} moved {title} to {status}'**
  String notificationsDealStatus(String actor, String status, String title);

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlier;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A task someone gives you, clients handed to you or a listing that fits your buyers will show up here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing new'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsFitsBuyers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Fits {names}} other{Fits {count} buyers: {names}}}'**
  String notificationsFitsBuyers(int count, String names);

  /// No description provided for @notificationsHandedOver.
  ///
  /// In en, this message translates to:
  /// **'{from} handed you {count, plural, =1{1 record} other{{count} records}}'**
  String notificationsHandedOver(int count, String from);

  /// No description provided for @notificationsJoinAccepted.
  ///
  /// In en, this message translates to:
  /// **'{agent} joined {team}'**
  String notificationsJoinAccepted(String agent, String team);

  /// No description provided for @notificationsJoinRequest.
  ///
  /// In en, this message translates to:
  /// **'{actor} invites you to join {team}'**
  String notificationsJoinRequest(String actor, String team);

  /// No description provided for @notificationsListingLead.
  ///
  /// In en, this message translates to:
  /// **'{name} is interested in {title}'**
  String notificationsListingLead(String name, String title);

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMoreNames.
  ///
  /// In en, this message translates to:
  /// **'{names} and {count} more'**
  String notificationsMoreNames(int count, String names);

  /// No description provided for @notificationsNewMatch.
  ///
  /// In en, this message translates to:
  /// **'New listing for your buyers: {title}'**
  String notificationsNewMatch(String title);

  /// No description provided for @notificationsPriceDrop.
  ///
  /// In en, this message translates to:
  /// **'{title} is now {price}, down from {oldPrice}'**
  String notificationsPriceDrop(String oldPrice, String price, String title);

  /// No description provided for @notificationsPurchaseAnniversary.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, one{A year today since {name}\'s purchase} other{{years} years today since {name}\'s purchase}}'**
  String notificationsPurchaseAnniversary(String name, int years);

  /// No description provided for @notificationsSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get notificationsSomeone;

  /// No description provided for @notificationsTaskAssigned.
  ///
  /// In en, this message translates to:
  /// **'{actor} gave you a task: {title}'**
  String notificationsTaskAssigned(String actor, String title);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something changed in your work'**
  String get notificationsUnknown;

  /// No description provided for @notificationsUnreadLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unread notifications} =1{1 unread notification} other{{count} unread notifications}}'**
  String notificationsUnreadLabel(int count);

  /// No description provided for @offersAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get offersAccept;

  /// No description provided for @offersAcceptConfirm.
  ///
  /// In en, this message translates to:
  /// **'{amount} becomes the agreed price. Other offers on this listing stay open as backups until you decide on them.'**
  String offersAcceptConfirm(String amount);

  /// No description provided for @offersAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this offer?'**
  String get offersAcceptTitle;

  /// No description provided for @offersAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get offersAgent;

  /// No description provided for @offersAlreadyAccepted.
  ///
  /// In en, this message translates to:
  /// **'Another offer on this listing is already accepted; withdraw it first'**
  String get offersAlreadyAccepted;

  /// No description provided for @offersAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'This buyer already has an open offer here; counter it instead'**
  String get offersAlreadyOpen;

  /// No description provided for @offersAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get offersAmount;

  /// No description provided for @offersAmountHint.
  ///
  /// In en, this message translates to:
  /// **'What they offer'**
  String get offersAmountHint;

  /// No description provided for @offersAsking.
  ///
  /// In en, this message translates to:
  /// **'asking {price}'**
  String offersAsking(String price);

  /// No description provided for @offersBackup.
  ///
  /// In en, this message translates to:
  /// **'Another offer is accepted; this one waits as a backup'**
  String get offersBackup;

  /// No description provided for @offersBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get offersBuyer;

  /// No description provided for @offersCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersCardTitle;

  /// No description provided for @offersClientNone.
  ///
  /// In en, this message translates to:
  /// **'No offers from this buyer yet. Record one from a listing.'**
  String get offersClientNone;

  /// No description provided for @offersClientNotBuyer.
  ///
  /// In en, this message translates to:
  /// **'Only a buyer can make an offer'**
  String get offersClientNotBuyer;

  /// No description provided for @offersClosedHeading.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get offersClosedHeading;

  /// No description provided for @offersColleagueBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer of {agent}'**
  String offersColleagueBuyer(String agent);

  /// No description provided for @offersCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get offersCounter;

  /// No description provided for @offersCounterFrom.
  ///
  /// In en, this message translates to:
  /// **'Whose figure'**
  String get offersCounterFrom;

  /// No description provided for @offersCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'New figure'**
  String get offersCounterTitle;

  /// No description provided for @offersDecidedOn.
  ///
  /// In en, this message translates to:
  /// **'Decided'**
  String get offersDecidedOn;

  /// No description provided for @offersExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get offersExpiresOn;

  /// No description provided for @offersExpiryPast.
  ///
  /// In en, this message translates to:
  /// **'The deadline cannot be before today'**
  String get offersExpiryPast;

  /// No description provided for @offersFigureBuyer.
  ///
  /// In en, this message translates to:
  /// **'The buyer\'s figure'**
  String get offersFigureBuyer;

  /// No description provided for @offersFigureSeller.
  ///
  /// In en, this message translates to:
  /// **'The seller\'s figure'**
  String get offersFigureSeller;

  /// No description provided for @offersHiddenBuyer.
  ///
  /// In en, this message translates to:
  /// **'A colleague\'s buyer'**
  String get offersHiddenBuyer;

  /// No description provided for @offersHistory.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get offersHistory;

  /// No description provided for @offersListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the offers'**
  String get offersListLoadFailed;

  /// No description provided for @offersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the offer'**
  String get offersLoadFailed;

  /// No description provided for @offersNoBuyers.
  ///
  /// In en, this message translates to:
  /// **'No buyers found'**
  String get offersNoBuyers;

  /// No description provided for @offersNoDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get offersNoDeadline;

  /// No description provided for @offersNoLongerOpen.
  ///
  /// In en, this message translates to:
  /// **'This offer is no longer open'**
  String get offersNoLongerOpen;

  /// No description provided for @offersNone.
  ///
  /// In en, this message translates to:
  /// **'No offers yet. Record one when a buyer names a price.'**
  String get offersNone;

  /// No description provided for @offersNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get offersNote;

  /// No description provided for @offersNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Terms, how they pay, what they asked for'**
  String get offersNoteHint;

  /// No description provided for @offersOfAsking.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of asking'**
  String offersOfAsking(int percent);

  /// No description provided for @offersOnTableNow.
  ///
  /// In en, this message translates to:
  /// **'On the table now: {amount}'**
  String offersOnTableNow(String amount);

  /// No description provided for @offersPartyBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get offersPartyBuyer;

  /// No description provided for @offersPartySeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get offersPartySeller;

  /// No description provided for @offersPickBuyer.
  ///
  /// In en, this message translates to:
  /// **'Choose a buyer'**
  String get offersPickBuyer;

  /// No description provided for @offersPropertySold.
  ///
  /// In en, this message translates to:
  /// **'This listing is sold and takes no more offers'**
  String get offersPropertySold;

  /// No description provided for @offersRecord.
  ///
  /// In en, this message translates to:
  /// **'Record an offer'**
  String get offersRecord;

  /// No description provided for @offersRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record an offer'**
  String get offersRecordTitle;

  /// No description provided for @offersReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get offersReject;

  /// No description provided for @offersRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'The offer is closed as rejected and cannot be reopened.'**
  String get offersRejectConfirm;

  /// No description provided for @offersRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this offer?'**
  String get offersRejectTitle;

  /// No description provided for @offersSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get offersSave;

  /// No description provided for @offersSearchBuyers.
  ///
  /// In en, this message translates to:
  /// **'Search buyers'**
  String get offersSearchBuyers;

  /// No description provided for @offersShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get offersShowAll;

  /// No description provided for @offersStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get offersStatusAccepted;

  /// No description provided for @offersStatusCountered.
  ///
  /// In en, this message translates to:
  /// **'Countered'**
  String get offersStatusCountered;

  /// No description provided for @offersStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get offersStatusExpired;

  /// No description provided for @offersStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get offersStatusNew;

  /// No description provided for @offersStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get offersStatusRejected;

  /// No description provided for @offersStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get offersStatusWithdrawn;

  /// No description provided for @offersStepAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get offersStepAccepted;

  /// No description provided for @offersStepCounteredBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer\'s counter'**
  String get offersStepCounteredBuyer;

  /// No description provided for @offersStepCounteredSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller\'s counter'**
  String get offersStepCounteredSeller;

  /// No description provided for @offersStepOffered.
  ///
  /// In en, this message translates to:
  /// **'Offer from the buyer'**
  String get offersStepOffered;

  /// No description provided for @offersStepOther.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get offersStepOther;

  /// No description provided for @offersStepRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get offersStepRejected;

  /// No description provided for @offersStepWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get offersStepWithdrawn;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offersTitle;

  /// No description provided for @offersValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String offersValidUntil(String date);

  /// No description provided for @offersWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get offersWithdraw;

  /// No description provided for @offersWithdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'The buyer has pulled out. The offer is closed and cannot be reopened.'**
  String get offersWithdrawConfirm;

  /// No description provided for @offersWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this offer?'**
  String get offersWithdrawTitle;

  /// No description provided for @openHouseActivity.
  ///
  /// In en, this message translates to:
  /// **'Open house visit'**
  String get openHouseActivity;

  /// No description provided for @openHouseAddVisitor.
  ///
  /// In en, this message translates to:
  /// **'Add visitor'**
  String get openHouseAddVisitor;

  /// No description provided for @openHouseAlreadySignedIn.
  ///
  /// In en, this message translates to:
  /// **'This number has already signed in'**
  String get openHouseAlreadySignedIn;

  /// No description provided for @openHouseColleagueClient.
  ///
  /// In en, this message translates to:
  /// **'Client of {agent}'**
  String openHouseColleagueClient(String agent);

  /// No description provided for @openHouseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get openHouseDate;

  /// No description provided for @openHouseDelete.
  ///
  /// In en, this message translates to:
  /// **'Cancel open house'**
  String get openHouseDelete;

  /// No description provided for @openHouseDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'It is removed from the listing and the calendar.'**
  String get openHouseDeleteConfirm;

  /// No description provided for @openHouseEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit open house'**
  String get openHouseEdit;

  /// No description provided for @openHouseEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get openHouseEnds;

  /// No description provided for @openHouseEndsBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'It has to end after it starts'**
  String get openHouseEndsBeforeStart;

  /// No description provided for @openHouseHasVisitors.
  ///
  /// In en, this message translates to:
  /// **'People have signed in, so it cannot be cancelled'**
  String get openHouseHasVisitors;

  /// No description provided for @openHouseHost.
  ///
  /// In en, this message translates to:
  /// **'Held by {name}'**
  String openHouseHost(String name);

  /// No description provided for @openHouseInterestLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get openHouseInterestLabel;

  /// No description provided for @openHouseInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get openHouseInterested;

  /// No description provided for @openHouseJustLooking.
  ///
  /// In en, this message translates to:
  /// **'Just looking'**
  String get openHouseJustLooking;

  /// No description provided for @openHouseKnownClient.
  ///
  /// In en, this message translates to:
  /// **'Already a client'**
  String get openHouseKnownClient;

  /// No description provided for @openHouseLive.
  ///
  /// In en, this message translates to:
  /// **'On now'**
  String get openHouseLive;

  /// No description provided for @openHouseLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the open house'**
  String get openHouseLoadFailed;

  /// No description provided for @openHouseNewClient.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get openHouseNewClient;

  /// No description provided for @openHouseNoVisitors.
  ///
  /// In en, this message translates to:
  /// **'Nobody has signed in yet'**
  String get openHouseNoVisitors;

  /// No description provided for @openHouseNoVisitorsHint.
  ///
  /// In en, this message translates to:
  /// **'Add each visitor as they arrive. A number the agency does not know becomes a new buyer.'**
  String get openHouseNoVisitorsHint;

  /// No description provided for @openHouseNone.
  ///
  /// In en, this message translates to:
  /// **'No open houses yet. Schedule one and sign visitors in at the door.'**
  String get openHouseNone;

  /// No description provided for @openHouseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Keys, parking, who to call at the door'**
  String get openHouseNoteHint;

  /// No description provided for @openHouseNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get openHouseNoteLabel;

  /// No description provided for @openHousePast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get openHousePast;

  /// No description provided for @openHouseRemoveVisitor.
  ///
  /// In en, this message translates to:
  /// **'Remove visitor'**
  String get openHouseRemoveVisitor;

  /// No description provided for @openHouseRemoveVisitorConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} comes off the sheet and the visit leaves the client\'s history. A client this sign-in created stays.'**
  String openHouseRemoveVisitorConfirm(String name);

  /// No description provided for @openHouseSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get openHouseSave;

  /// No description provided for @openHouseSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule an open house'**
  String get openHouseSchedule;

  /// No description provided for @openHouseSeeAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get openHouseSeeAll;

  /// No description provided for @openHouseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get openHouseSignIn;

  /// No description provided for @openHouseSignInNext.
  ///
  /// In en, this message translates to:
  /// **'Save and next'**
  String get openHouseSignInNext;

  /// No description provided for @openHouseSignInSheet.
  ///
  /// In en, this message translates to:
  /// **'Sign-in sheet'**
  String get openHouseSignInSheet;

  /// No description provided for @openHouseSignedIn.
  ///
  /// In en, this message translates to:
  /// **'{name} signed in'**
  String openHouseSignedIn(String name);

  /// No description provided for @openHouseStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get openHouseStarts;

  /// No description provided for @openHouseSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get openHouseSummary;

  /// No description provided for @openHouseSummaryInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get openHouseSummaryInterested;

  /// No description provided for @openHouseSummaryNewClients.
  ///
  /// In en, this message translates to:
  /// **'New clients'**
  String get openHouseSummaryNewClients;

  /// No description provided for @openHouseSummaryVisitors.
  ///
  /// In en, this message translates to:
  /// **'Visitors'**
  String get openHouseSummaryVisitors;

  /// No description provided for @openHouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Open house'**
  String get openHouseTitle;

  /// No description provided for @openHouseTooLong.
  ///
  /// In en, this message translates to:
  /// **'An open house lasts at most 12 hours'**
  String get openHouseTooLong;

  /// No description provided for @openHouseUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get openHouseUpcoming;

  /// No description provided for @openHouseVisitorName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get openHouseVisitorName;

  /// No description provided for @openHouseVisitorNameHint.
  ///
  /// In en, this message translates to:
  /// **'As they give it'**
  String get openHouseVisitorNameHint;

  /// No description provided for @openHouseVisitorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get openHouseVisitorNameRequired;

  /// No description provided for @openHouseVisitorNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What they asked about'**
  String get openHouseVisitorNoteHint;

  /// No description provided for @openHouseVisitorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get openHouseVisitorPhone;

  /// No description provided for @openHouseVisitorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number'**
  String get openHouseVisitorPhoneInvalid;

  /// No description provided for @openHouseVisitorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No visitors} =1{1 visitor} other{{count} visitors}}'**
  String openHouseVisitorsCount(int count);

  /// No description provided for @openHousesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Open houses'**
  String get openHousesCardTitle;

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

  /// No description provided for @profileApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileApp;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Your clients, properties, deals and meetings move to {successor}. The account is removed permanently and this cannot be undone.'**
  String profileDeleteAccountConfirm(Object successor);

  /// No description provided for @profileDeleteHandoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one else to hand them to'**
  String get profileDeleteHandoverEmpty;

  /// No description provided for @profileDeleteHandoverSearch.
  ///
  /// In en, this message translates to:
  /// **'Search colleagues'**
  String get profileDeleteHandoverSearch;

  /// No description provided for @profileDeleteHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand your records over to'**
  String get profileDeleteHandoverTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

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

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegal;

  /// No description provided for @profileLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get profileLinkFailed;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileReminders.
  ///
  /// In en, this message translates to:
  /// **'Meeting reminders'**
  String get profileReminders;

  /// No description provided for @profileRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get profileRemindersOff;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

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

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileSystemDefault;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileTheme;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get profileThemeSystem;

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

  /// No description provided for @propertiesAddFirstListing.
  ///
  /// In en, this message translates to:
  /// **'Add your first listing'**
  String get propertiesAddFirstListing;

  /// No description provided for @propertiesAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get propertiesAddPhotos;

  /// No description provided for @propertiesAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get propertiesAddressLabel;

  /// No description provided for @propertiesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get propertiesAll;

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
  String propertiesAreaValue(Object area);

  /// No description provided for @propertiesBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get propertiesBack;

  /// No description provided for @propertiesBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get propertiesBasicInfo;

  /// No description provided for @propertiesBrochure.
  ///
  /// In en, this message translates to:
  /// **'Brochure (PDF)'**
  String get propertiesBrochure;

  /// No description provided for @propertiesBrochureContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get propertiesBrochureContact;

  /// No description provided for @propertiesBrochureFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t put the brochure together. Try again.'**
  String get propertiesBrochureFailed;

  /// No description provided for @propertiesBrochureGenerated.
  ///
  /// In en, this message translates to:
  /// **'Prepared {date}'**
  String propertiesBrochureGenerated(String date);

  /// No description provided for @propertiesBrochurePage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String propertiesBrochurePage(int page, int total);

  /// No description provided for @propertiesCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get propertiesCityLabel;

  /// No description provided for @propertiesCounter.
  ///
  /// In en, this message translates to:
  /// **'{total} listed · {reserved} reserved'**
  String propertiesCounter(Object reserved, Object total);

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

  /// No description provided for @propertiesDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{title} will be deleted permanently. This cannot be undone.'**
  String propertiesDeleteCascade(Object title);

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
  String propertiesFieldRequired(Object label);

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

  /// No description provided for @propertiesFloorOf.
  ///
  /// In en, this message translates to:
  /// **'{floor} of {total}'**
  String propertiesFloorOf(Object floor, Object total);

  /// No description provided for @propertiesInterested.
  ///
  /// In en, this message translates to:
  /// **'Buyers looking for this'**
  String get propertiesInterested;

  /// No description provided for @propertiesLink.
  ///
  /// In en, this message translates to:
  /// **'Public link'**
  String get propertiesLink;

  /// No description provided for @propertiesLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get propertiesLinkCopied;

  /// No description provided for @propertiesLinkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get propertiesLinkCopy;

  /// No description provided for @propertiesLinkCreate.
  ///
  /// In en, this message translates to:
  /// **'Create link'**
  String get propertiesLinkCreate;

  /// No description provided for @propertiesLinkEnquiries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 enquiry from this link} other{{count} enquiries from this link}}'**
  String propertiesLinkEnquiries(int count);

  /// No description provided for @propertiesLinkHint.
  ///
  /// In en, this message translates to:
  /// **'A page with the photos, price and your contacts. Opens in any browser, no app or account needed.'**
  String get propertiesLinkHint;

  /// No description provided for @propertiesLinkLastViewed.
  ///
  /// In en, this message translates to:
  /// **'Last opened {date}'**
  String propertiesLinkLastViewed(String date);

  /// No description provided for @propertiesLinkRevoke.
  ///
  /// In en, this message translates to:
  /// **'Switch off'**
  String get propertiesLinkRevoke;

  /// No description provided for @propertiesLinkRevokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Anyone you sent it to will no longer be able to open the listing. A new link will have a different address.'**
  String get propertiesLinkRevokeConfirm;

  /// No description provided for @propertiesLinkRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch off the link?'**
  String get propertiesLinkRevokeTitle;

  /// No description provided for @propertiesLinkShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get propertiesLinkShare;

  /// No description provided for @propertiesLinkViews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not opened yet} =1{Opened once} other{Opened {count} times}}'**
  String propertiesLinkViews(int count);

  /// No description provided for @propertiesLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get propertiesLocation;

  /// No description provided for @propertiesMandate.
  ///
  /// In en, this message translates to:
  /// **'Seller agreement'**
  String get propertiesMandate;

  /// No description provided for @propertiesMandateClearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Remove the end date'**
  String get propertiesMandateClearEndDate;

  /// No description provided for @propertiesMandateEndDate.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get propertiesMandateEndDate;

  /// No description provided for @propertiesMandateEndedAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Ended 1 day ago} other{Ended {count} days ago}}'**
  String propertiesMandateEndedAgo(int count);

  /// No description provided for @propertiesMandateEndedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Ended yesterday'**
  String get propertiesMandateEndedYesterday;

  /// No description provided for @propertiesMandateEndsIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Ends in 1 day} other{Ends in {count} days}}'**
  String propertiesMandateEndsIn(int count);

  /// No description provided for @propertiesMandateEndsToday.
  ///
  /// In en, this message translates to:
  /// **'Ends today'**
  String get propertiesMandateEndsToday;

  /// No description provided for @propertiesMandateEndsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Ends tomorrow'**
  String get propertiesMandateEndsTomorrow;

  /// No description provided for @propertiesMandateExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get propertiesMandateExclusive;

  /// No description provided for @propertiesMandateExclusiveEnded.
  ///
  /// In en, this message translates to:
  /// **'Exclusive ended {date}'**
  String propertiesMandateExclusiveEnded(String date);

  /// No description provided for @propertiesMandateExclusiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Exclusive until {date}'**
  String propertiesMandateExclusiveUntil(String date);

  /// No description provided for @propertiesMandateNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get propertiesMandateNoEndDate;

  /// No description provided for @propertiesMandateNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get propertiesMandateNone;

  /// No description provided for @propertiesMandateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get propertiesMandateOpen;

  /// No description provided for @propertiesMandateOpenBadge.
  ///
  /// In en, this message translates to:
  /// **'Open agreement'**
  String get propertiesMandateOpenBadge;

  /// No description provided for @propertiesMandateOpenEnded.
  ///
  /// In en, this message translates to:
  /// **'Agreement ended {date}'**
  String propertiesMandateOpenEnded(String date);

  /// No description provided for @propertiesMandateOpenUntil.
  ///
  /// In en, this message translates to:
  /// **'Open until {date}'**
  String propertiesMandateOpenUntil(String date);

  /// No description provided for @propertiesMandatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No agreements running out'**
  String get propertiesMandatesEmpty;

  /// No description provided for @propertiesMandatesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No seller agreement on a listing still for sale ends in the next two weeks.'**
  String get propertiesMandatesEmptyHint;

  /// No description provided for @propertiesMandatesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the agreements running out'**
  String get propertiesMandatesLoadFailed;

  /// No description provided for @propertiesMandatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Agreements running out'**
  String get propertiesMandatesTitle;

  /// No description provided for @propertiesMapCapped.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} — zoom in to see the rest'**
  String propertiesMapCapped(int count);

  /// No description provided for @propertiesMapEmpty.
  ///
  /// In en, this message translates to:
  /// **'No listings in this area'**
  String get propertiesMapEmpty;

  /// No description provided for @propertiesMapLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading listings'**
  String get propertiesMapLoading;

  /// No description provided for @propertiesMapPin.
  ///
  /// In en, this message translates to:
  /// **'Pin on the map'**
  String get propertiesMapPin;

  /// No description provided for @propertiesMapPinClear.
  ///
  /// In en, this message translates to:
  /// **'Remove pin'**
  String get propertiesMapPinClear;

  /// No description provided for @propertiesMapPinHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin, drag it to adjust'**
  String get propertiesMapPinHint;

  /// No description provided for @propertiesMapUnpinned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 listing has no location} other{{count} listings have no location}}'**
  String propertiesMapUnpinned(int count);

  /// No description provided for @propertiesMapUnpinnedHint.
  ///
  /// In en, this message translates to:
  /// **'Open a listing, choose Edit and drop a pin to show it on the map.'**
  String get propertiesMapUnpinnedHint;

  /// No description provided for @propertiesMapUnpinnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not on the map'**
  String get propertiesMapUnpinnedTitle;

  /// No description provided for @propertiesNewProperty.
  ///
  /// In en, this message translates to:
  /// **'New Property'**
  String get propertiesNewProperty;

  /// No description provided for @propertiesNextDetails.
  ///
  /// In en, this message translates to:
  /// **'Next — details'**
  String get propertiesNextDetails;

  /// No description provided for @propertiesNoInterested.
  ///
  /// In en, this message translates to:
  /// **'No buyer has asked for anything like this yet'**
  String get propertiesNoInterested;

  /// No description provided for @propertiesNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet — the first one becomes the cover'**
  String get propertiesNoPhotos;

  /// No description provided for @propertiesNoProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties'**
  String get propertiesNoProperties;

  /// No description provided for @propertiesNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter'**
  String get propertiesNoResultsSubtitle;

  /// No description provided for @propertiesNoViewings.
  ///
  /// In en, this message translates to:
  /// **'This listing has not been shown yet'**
  String get propertiesNoViewings;

  /// No description provided for @propertiesOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get propertiesOpenInMaps;

  /// No description provided for @propertiesOpenInMapsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open a maps app'**
  String get propertiesOpenInMapsFailed;

  /// No description provided for @propertiesPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String propertiesPhotoCount(num count);

  /// No description provided for @propertiesPhotoDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get propertiesPhotoDelete;

  /// No description provided for @propertiesPhotoDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this photo from the listing?'**
  String get propertiesPhotoDeleteConfirm;

  /// No description provided for @propertiesPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload {name}'**
  String propertiesPhotoFailed(String name);

  /// No description provided for @propertiesPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'{name} is larger than 12 MB'**
  String propertiesPhotoTooLarge(String name);

  /// No description provided for @propertiesPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get propertiesPhotos;

  /// No description provided for @propertiesPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Hold a photo to move it — the first one is the cover'**
  String get propertiesPhotosHint;

  /// No description provided for @propertiesPriceCheck.
  ///
  /// In en, this message translates to:
  /// **'Price check'**
  String get propertiesPriceCheck;

  /// No description provided for @propertiesPriceCheckAbove.
  ///
  /// In en, this message translates to:
  /// **'{percent}% above'**
  String propertiesPriceCheckAbove(String percent);

  /// No description provided for @propertiesPriceCheckAtMedian.
  ///
  /// In en, this message translates to:
  /// **'at the median'**
  String get propertiesPriceCheckAtMedian;

  /// No description provided for @propertiesPriceCheckBasedOn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Based on {count} listing in {city}} other{Based on {count} listings in {city}}}'**
  String propertiesPriceCheckBasedOn(int count, String city);

  /// No description provided for @propertiesPriceCheckBelow.
  ///
  /// In en, this message translates to:
  /// **'{percent}% below'**
  String propertiesPriceCheckBelow(String percent);

  /// No description provided for @propertiesPriceCheckComparables.
  ///
  /// In en, this message translates to:
  /// **'Comparable listings'**
  String get propertiesPriceCheckComparables;

  /// No description provided for @propertiesPriceCheckDaysOnMarket.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day on the market} other{{count} days on the market}}'**
  String propertiesPriceCheckDaysOnMarket(int count);

  /// No description provided for @propertiesPriceCheckLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Few similar listings yet, so treat this as a rough guide'**
  String get propertiesPriceCheckLowConfidence;

  /// No description provided for @propertiesPriceCheckSeeComparables.
  ///
  /// In en, this message translates to:
  /// **'See comparables'**
  String get propertiesPriceCheckSeeComparables;

  /// No description provided for @propertiesPriceCheckSold.
  ///
  /// In en, this message translates to:
  /// **'Sold at a median of {price}'**
  String propertiesPriceCheckSold(String price);

  /// No description provided for @propertiesPriceCheckVsMedian.
  ///
  /// In en, this message translates to:
  /// **'{price} / m² vs median {median} ({difference})'**
  String propertiesPriceCheckVsMedian(
      String price, String median, String difference);

  /// No description provided for @propertiesPriceHintRange.
  ///
  /// In en, this message translates to:
  /// **'Similar listings: {low}–{high} for this area'**
  String propertiesPriceHintRange(String low, String high);

  /// No description provided for @propertiesPriceHintUseMedian.
  ///
  /// In en, this message translates to:
  /// **'Use median'**
  String get propertiesPriceHintUseMedian;

  /// No description provided for @propertiesPriceHistory.
  ///
  /// In en, this message translates to:
  /// **'Price history'**
  String get propertiesPriceHistory;

  /// No description provided for @propertiesPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get propertiesPriceLabel;

  /// No description provided for @propertiesPricePerSqm.
  ///
  /// In en, this message translates to:
  /// **'{price} per m²'**
  String propertiesPricePerSqm(Object price);

  /// No description provided for @propertiesPriceReduced.
  ///
  /// In en, this message translates to:
  /// **'Price reduced'**
  String get propertiesPriceReduced;

  /// No description provided for @propertiesPriceWas.
  ///
  /// In en, this message translates to:
  /// **'Was {price}'**
  String propertiesPriceWas(String price);

  /// No description provided for @propertiesProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get propertiesProperty;

  /// No description provided for @propertiesPropertyCreated.
  ///
  /// In en, this message translates to:
  /// **'Property created (ID: {id})'**
  String propertiesPropertyCreated(Object id);

  /// No description provided for @propertiesPropertyIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Property ID copied'**
  String get propertiesPropertyIdCopied;

  /// No description provided for @propertiesPropertyIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Property ID: {id}'**
  String propertiesPropertyIdLabel(Object id);

  /// No description provided for @propertiesPropertyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get propertiesPropertyNotFound;

  /// No description provided for @propertiesReport.
  ///
  /// In en, this message translates to:
  /// **'Report for the seller'**
  String get propertiesReport;

  /// No description provided for @propertiesReportAsOf.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String propertiesReportAsOf(String date);

  /// No description provided for @propertiesReportAwaitingOutcome.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet'**
  String get propertiesReportAwaitingOutcome;

  /// No description provided for @propertiesReportCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get propertiesReportCurrentPrice;

  /// No description provided for @propertiesReportDaysOnMarket.
  ///
  /// In en, this message translates to:
  /// **'Days on the market'**
  String get propertiesReportDaysOnMarket;

  /// No description provided for @propertiesReportLinkLeads.
  ///
  /// In en, this message translates to:
  /// **'Enquiries from the link'**
  String get propertiesReportLinkLeads;

  /// No description provided for @propertiesReportLinkViews.
  ///
  /// In en, this message translates to:
  /// **'Link opens'**
  String get propertiesReportLinkViews;

  /// No description provided for @propertiesReportListedOn.
  ///
  /// In en, this message translates to:
  /// **'Listed on {date}'**
  String propertiesReportListedOn(String date);

  /// No description provided for @propertiesReportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the report'**
  String get propertiesReportLoadFailed;

  /// No description provided for @propertiesReportMatchingBuyers.
  ///
  /// In en, this message translates to:
  /// **'Buyers it fits'**
  String get propertiesReportMatchingBuyers;

  /// No description provided for @propertiesReportNextViewing.
  ///
  /// In en, this message translates to:
  /// **'Next viewing {date}'**
  String propertiesReportNextViewing(String date);

  /// No description provided for @propertiesReportNoViewings.
  ///
  /// In en, this message translates to:
  /// **'No viewings yet'**
  String get propertiesReportNoViewings;

  /// No description provided for @propertiesReportOriginalPrice.
  ///
  /// In en, this message translates to:
  /// **'Listed at'**
  String get propertiesReportOriginalPrice;

  /// No description provided for @propertiesReportOutcomes.
  ///
  /// In en, this message translates to:
  /// **'What viewers said'**
  String get propertiesReportOutcomes;

  /// No description provided for @propertiesReportPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get propertiesReportPrice;

  /// No description provided for @propertiesReportPriceChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get propertiesReportPriceChange;

  /// No description provided for @propertiesReportPriceChanges.
  ///
  /// In en, this message translates to:
  /// **'Price changes'**
  String get propertiesReportPriceChanges;

  /// No description provided for @propertiesReportPriceUnchanged.
  ///
  /// In en, this message translates to:
  /// **'The price has not changed since it was listed'**
  String get propertiesReportPriceUnchanged;

  /// No description provided for @propertiesReportShare.
  ///
  /// In en, this message translates to:
  /// **'Share with the seller'**
  String get propertiesReportShare;

  /// No description provided for @propertiesReportShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the report. Try again.'**
  String get propertiesReportShareFailed;

  /// No description provided for @propertiesReportSoldOn.
  ///
  /// In en, this message translates to:
  /// **'Sold on {date}'**
  String propertiesReportSoldOn(String date);

  /// No description provided for @propertiesReportTextHeading.
  ///
  /// In en, this message translates to:
  /// **'Report for the seller: {title}'**
  String propertiesReportTextHeading(String title);

  /// No description provided for @propertiesReportTextLine.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String propertiesReportTextLine(String label, String value);

  /// No description provided for @propertiesReportViewingsHeld.
  ///
  /// In en, this message translates to:
  /// **'Viewings held'**
  String get propertiesReportViewingsHeld;

  /// No description provided for @propertiesReportViewingsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Viewings to come'**
  String get propertiesReportViewingsUpcoming;

  /// No description provided for @propertiesRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get propertiesRooms;

  /// No description provided for @propertiesRoomsCount.
  ///
  /// In en, this message translates to:
  /// **'{rooms} rooms'**
  String propertiesRoomsCount(Object rooms);

  /// No description provided for @propertiesSearchHintFull.
  ///
  /// In en, this message translates to:
  /// **'Address, complex, ID…'**
  String get propertiesSearchHintFull;

  /// No description provided for @propertiesStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get propertiesStatus;

  /// No description provided for @propertiesStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String propertiesStepOf(Object current, Object total);

  /// No description provided for @propertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesTitle;

  /// No description provided for @propertiesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
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

  /// No description provided for @propertiesUpdateProperty.
  ///
  /// In en, this message translates to:
  /// **'Update Property'**
  String get propertiesUpdateProperty;

  /// No description provided for @propertiesViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get propertiesViewList;

  /// No description provided for @propertiesViewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get propertiesViewMap;

  /// No description provided for @propertiesViewings.
  ///
  /// In en, this message translates to:
  /// **'Viewings'**
  String get propertiesViewings;

  /// No description provided for @quickAddClient.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get quickAddClient;

  /// No description provided for @quickAddDeal.
  ///
  /// In en, this message translates to:
  /// **'New deal'**
  String get quickAddDeal;

  /// No description provided for @quickAddFor.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String quickAddFor(String name);

  /// No description provided for @quickAddLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get quickAddLastUsed;

  /// No description provided for @quickAddListing.
  ///
  /// In en, this message translates to:
  /// **'New property'**
  String get quickAddListing;

  /// No description provided for @quickAddLogContact.
  ///
  /// In en, this message translates to:
  /// **'Log a contact'**
  String get quickAddLogContact;

  /// No description provided for @quickAddMeeting.
  ///
  /// In en, this message translates to:
  /// **'New meeting'**
  String get quickAddMeeting;

  /// No description provided for @quickAddNoClients.
  ///
  /// In en, this message translates to:
  /// **'No clients yet — add one first'**
  String get quickAddNoClients;

  /// No description provided for @quickAddOpen.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get quickAddOpen;

  /// No description provided for @quickAddPickClient.
  ///
  /// In en, this message translates to:
  /// **'Which client?'**
  String get quickAddPickClient;

  /// No description provided for @quickAddSearchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients'**
  String get quickAddSearchClients;

  /// No description provided for @quickAddTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get quickAddTask;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickAddTitle;

  /// No description provided for @remindersBody.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String remindersBody(Object time);

  /// No description provided for @remindersBodyWithClient.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time} with {client}'**
  String remindersBodyWithClient(Object client, Object time);

  /// No description provided for @remindersFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get remindersFallbackTitle;

  /// No description provided for @remindersLeadDay.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get remindersLeadDay;

  /// No description provided for @remindersLeadHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get remindersLeadHour;

  /// No description provided for @remindersLeadQuarter.
  ///
  /// In en, this message translates to:
  /// **'15 minutes before'**
  String get remindersLeadQuarter;

  /// No description provided for @remindersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for EstateCRM. Turn them on in your phone’s settings.'**
  String get remindersPermissionDenied;

  /// No description provided for @remindersTaskDue.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get remindersTaskDue;

  /// No description provided for @remindersTaskDueWithClient.
  ///
  /// In en, this message translates to:
  /// **'Due now · {client}'**
  String remindersTaskDueWithClient(Object client);

  /// No description provided for @routeAddPin.
  ///
  /// In en, this message translates to:
  /// **'Add a pin'**
  String get routeAddPin;

  /// No description provided for @routeAppApple.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get routeAppApple;

  /// No description provided for @routeAppDgis.
  ///
  /// In en, this message translates to:
  /// **'2GIS'**
  String get routeAppDgis;

  /// No description provided for @routeAppGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get routeAppGoogle;

  /// No description provided for @routeAppNextOnly.
  ///
  /// In en, this message translates to:
  /// **'Next stop only'**
  String get routeAppNextOnly;

  /// No description provided for @routeAppStops.
  ///
  /// In en, this message translates to:
  /// **'Stops {from}–{to} of {total}'**
  String routeAppStops(int from, int to, int total);

  /// No description provided for @routeAppWhole.
  ///
  /// In en, this message translates to:
  /// **'Whole route, in order'**
  String get routeAppWhole;

  /// No description provided for @routeAppYandex.
  ///
  /// In en, this message translates to:
  /// **'Yandex Maps'**
  String get routeAppYandex;

  /// No description provided for @routeChooserNext.
  ///
  /// In en, this message translates to:
  /// **'Next stop: {title}'**
  String routeChooserNext(String title);

  /// No description provided for @routeChooserTitle.
  ///
  /// In en, this message translates to:
  /// **'Open in a maps app'**
  String get routeChooserTitle;

  /// No description provided for @routeChooserWhole.
  ///
  /// In en, this message translates to:
  /// **'Every stop still ahead, in the order they are booked'**
  String get routeChooserWhole;

  /// No description provided for @routeDayOver.
  ///
  /// In en, this message translates to:
  /// **'No stops left for this day'**
  String get routeDayOver;

  /// No description provided for @routeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get routeDone;

  /// No description provided for @routeDurationHourMin.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String routeDurationHourMin(int hours, int minutes);

  /// No description provided for @routeDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String routeDurationHours(int hours);

  /// No description provided for @routeDurationMin.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String routeDurationMin(int minutes);

  /// No description provided for @routeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No viewings this day'**
  String get routeEmpty;

  /// No description provided for @routeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'A meeting booked on a listing shows up here as a stop.'**
  String get routeEmptyHint;

  /// No description provided for @routeEntryDay.
  ///
  /// In en, this message translates to:
  /// **'Route for this day'**
  String get routeEntryDay;

  /// No description provided for @routeEntryToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s route'**
  String get routeEntryToday;

  /// No description provided for @routeFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'{km} km from the previous stop'**
  String routeFromPrevious(String km);

  /// No description provided for @routeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the route'**
  String get routeLoadFailed;

  /// No description provided for @routeNavigateNext.
  ///
  /// In en, this message translates to:
  /// **'Navigate to next stop'**
  String get routeNavigateNext;

  /// No description provided for @routeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get routeNext;

  /// No description provided for @routeNotOnMap.
  ///
  /// In en, this message translates to:
  /// **'Not on the map'**
  String get routeNotOnMap;

  /// No description provided for @routeNotOnMapHint.
  ///
  /// In en, this message translates to:
  /// **'These listings have no pin yet, so they are not in the route.'**
  String get routeNotOnMapHint;

  /// No description provided for @routeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open a maps app'**
  String get routeOpenFailed;

  /// No description provided for @routeOpenWhole.
  ///
  /// In en, this message translates to:
  /// **'Open the whole route'**
  String get routeOpenWhole;

  /// No description provided for @routeOverlap.
  ///
  /// In en, this message translates to:
  /// **'Overlaps the next viewing'**
  String get routeOverlap;

  /// No description provided for @routeStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String routeStopsCount(int count);

  /// No description provided for @routeStraightLine.
  ///
  /// In en, this message translates to:
  /// **'Straight lines between stops, not driving directions'**
  String get routeStraightLine;

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'{stops} · {km} km straight-line'**
  String routeSummary(String stops, String km);

  /// No description provided for @routeTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewings route'**
  String get routeTitle;

  /// No description provided for @routeUntilNext.
  ///
  /// In en, this message translates to:
  /// **'{duration} until the next one'**
  String routeUntilNext(String duration);

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// No description provided for @searchClearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearRecent;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Clients, listings, deals…'**
  String get searchHint;

  /// No description provided for @searchMoreCount.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String searchMoreCount(Object count);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, address or phone number'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a client, a listing or a deal by name, address, phone or id'**
  String get searchPromptSubtitle;

  /// No description provided for @searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Search everything'**
  String get searchPromptTitle;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get searchRecent;

  /// No description provided for @searchSectionClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get searchSectionClients;

  /// No description provided for @searchSectionDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get searchSectionDeals;

  /// No description provided for @searchSectionProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get searchSectionProperties;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @tasksAbout.
  ///
  /// In en, this message translates to:
  /// **'What it is about'**
  String get tasksAbout;

  /// No description provided for @tasksAdd.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get tasksAdd;

  /// No description provided for @tasksAllTasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get tasksAllTasks;

  /// No description provided for @tasksAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'for {name}'**
  String tasksAssignedTo(Object name);

  /// No description provided for @tasksAssignee.
  ///
  /// In en, this message translates to:
  /// **'Who does it'**
  String get tasksAssignee;

  /// No description provided for @tasksClearLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get tasksClearLink;

  /// No description provided for @tasksClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get tasksClient;

  /// No description provided for @tasksComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get tasksComplete;

  /// No description provided for @tasksCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String tasksCounter(Object count);

  /// No description provided for @tasksDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tasksDate;

  /// No description provided for @tasksDeal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get tasksDeal;

  /// No description provided for @tasksDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get tasksDelete;

  /// No description provided for @tasksDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears for everyone, together with its reminder.'**
  String get tasksDeleteBody;

  /// No description provided for @tasksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get tasksDeleteTitle;

  /// No description provided for @tasksDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String tasksDoneOn(Object date);

  /// No description provided for @tasksDoneTab.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksDoneTab;

  /// No description provided for @tasksDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get tasksDue;

  /// No description provided for @tasksDueToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String tasksDueToday(Object time);

  /// No description provided for @tasksDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String tasksDueTomorrow(Object time);

  /// No description provided for @tasksEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get tasksEdit;

  /// No description provided for @tasksEmptyDone.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet'**
  String get tasksEmptyDone;

  /// No description provided for @tasksEmptyOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get tasksEmptyOpen;

  /// No description provided for @tasksEmptyOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups you add to clients and deals show up here.'**
  String get tasksEmptyOpenHint;

  /// No description provided for @tasksEmptyRecordHint.
  ///
  /// In en, this message translates to:
  /// **'Add a follow-up so it is not forgotten.'**
  String get tasksEmptyRecordHint;

  /// No description provided for @tasksFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get tasksFieldTitle;

  /// No description provided for @tasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load tasks'**
  String get tasksLoadFailed;

  /// No description provided for @tasksNew.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasksNew;

  /// No description provided for @tasksNoAgents.
  ///
  /// In en, this message translates to:
  /// **'No one to hand it to'**
  String get tasksNoAgents;

  /// No description provided for @tasksNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get tasksNote;

  /// No description provided for @tasksNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Details, numbers, what to prepare…'**
  String get tasksNoteHint;

  /// No description provided for @tasksOpenTab.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tasksOpenTab;

  /// No description provided for @tasksOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasksOverdue;

  /// No description provided for @tasksQuickInThreeDays.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get tasksQuickInThreeDays;

  /// No description provided for @tasksQuickTodayEvening.
  ///
  /// In en, this message translates to:
  /// **'Today evening'**
  String get tasksQuickTodayEvening;

  /// No description provided for @tasksQuickTomorrowMorning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning'**
  String get tasksQuickTomorrowMorning;

  /// No description provided for @tasksReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get tasksReopen;

  /// No description provided for @tasksRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get tasksRepeat;

  /// No description provided for @tasksRepeatCount.
  ///
  /// In en, this message translates to:
  /// **'How many times'**
  String get tasksRepeatCount;

  /// No description provided for @tasksRepeatCountInvalid.
  ///
  /// In en, this message translates to:
  /// **'From 1 to 999'**
  String get tasksRepeatCountInvalid;

  /// No description provided for @tasksRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get tasksRepeatDaily;

  /// No description provided for @tasksRepeatDayOrdinal.
  ///
  /// In en, this message translates to:
  /// **'{day}{suffix, select, st{st} nd{nd} rd{rd} other{th}}'**
  String tasksRepeatDayOrdinal(int day, String suffix);

  /// No description provided for @tasksRepeatDays.
  ///
  /// In en, this message translates to:
  /// **'On these days'**
  String get tasksRepeatDays;

  /// No description provided for @tasksRepeatEndAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get tasksRepeatEndAfter;

  /// No description provided for @tasksRepeatEndNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get tasksRepeatEndNever;

  /// No description provided for @tasksRepeatEndOn.
  ///
  /// In en, this message translates to:
  /// **'On a day'**
  String get tasksRepeatEndOn;

  /// No description provided for @tasksRepeatEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get tasksRepeatEnds;

  /// No description provided for @tasksRepeatLeapYear.
  ///
  /// In en, this message translates to:
  /// **'{rule} (28 February in other years)'**
  String tasksRepeatLeapYear(Object rule);

  /// No description provided for @tasksRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month on the {day}'**
  String tasksRepeatMonthly(Object day);

  /// No description provided for @tasksRepeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get tasksRepeatNone;

  /// No description provided for @tasksRepeatOptionDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get tasksRepeatOptionDaily;

  /// No description provided for @tasksRepeatOptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get tasksRepeatOptionMonthly;

  /// No description provided for @tasksRepeatOptionQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get tasksRepeatOptionQuarterly;

  /// No description provided for @tasksRepeatOptionWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get tasksRepeatOptionWeekly;

  /// No description provided for @tasksRepeatOptionYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get tasksRepeatOptionYearly;

  /// No description provided for @tasksRepeatPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get tasksRepeatPickDay;

  /// No description provided for @tasksRepeatQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months on the {day}'**
  String tasksRepeatQuarterly(Object day);

  /// No description provided for @tasksRepeatShortMonths.
  ///
  /// In en, this message translates to:
  /// **'{rule} (last day in shorter months)'**
  String tasksRepeatShortMonths(Object rule);

  /// No description provided for @tasksRepeatStop.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating'**
  String get tasksRepeatStop;

  /// No description provided for @tasksRepeatStopBody.
  ///
  /// In en, this message translates to:
  /// **'This one stays as it is; no more are added after it.'**
  String get tasksRepeatStopBody;

  /// No description provided for @tasksRepeatStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating this task?'**
  String get tasksRepeatStopTitle;

  /// No description provided for @tasksRepeatTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{rule}, once} other{{rule}, {count} times}}'**
  String tasksRepeatTimes(num count, Object rule);

  /// No description provided for @tasksRepeatUntil.
  ///
  /// In en, this message translates to:
  /// **'{rule}, until {date}'**
  String tasksRepeatUntil(Object date, Object rule);

  /// No description provided for @tasksRepeatUntilBeforeDue.
  ///
  /// In en, this message translates to:
  /// **'The last day cannot be before the task is due'**
  String get tasksRepeatUntilBeforeDue;

  /// No description provided for @tasksRepeatUse.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tasksRepeatUse;

  /// No description provided for @tasksRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week on {days}'**
  String tasksRepeatWeekly(Object days);

  /// No description provided for @tasksRepeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year on {date}'**
  String tasksRepeatYearly(Object date);

  /// No description provided for @tasksSave.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get tasksSave;

  /// No description provided for @tasksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or ID'**
  String get tasksSearchHint;

  /// No description provided for @tasksTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tasksTime;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Call Irina back'**
  String get tasksTitleHint;

  /// No description provided for @tasksTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Say what needs doing'**
  String get tasksTitleRequired;

  /// No description provided for @tasksTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under 200 characters'**
  String get tasksTitleTooLong;

  /// No description provided for @teamsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get teamsActive;

  /// No description provided for @teamsAddAgent.
  ///
  /// In en, this message translates to:
  /// **'Add agent'**
  String get teamsAddAgent;

  /// No description provided for @teamsAddAgentAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get teamsAddAgentAction;

  /// No description provided for @teamsAddAgentHint.
  ///
  /// In en, this message translates to:
  /// **'If the agent already has an account they get a request to accept. If not, we email them an invite.'**
  String get teamsAddAgentHint;

  /// No description provided for @teamsAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get teamsAgents;

  /// No description provided for @teamsCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get teamsCancelRequest;

  /// No description provided for @teamsChecklist.
  ///
  /// In en, this message translates to:
  /// **'Deal checklist'**
  String get teamsChecklist;

  /// No description provided for @teamsChecklistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get teamsChecklistAdd;

  /// No description provided for @teamsChecklistDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get teamsChecklistDelete;

  /// No description provided for @teamsChecklistDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get teamsChecklistDiscard;

  /// No description provided for @teamsChecklistDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to the checklist have not been saved.'**
  String get teamsChecklistDiscardBody;

  /// No description provided for @teamsChecklistDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get teamsChecklistDiscardTitle;

  /// No description provided for @teamsChecklistEmptyStage.
  ///
  /// In en, this message translates to:
  /// **'No items at this stage yet'**
  String get teamsChecklistEmptyStage;

  /// No description provided for @teamsChecklistHint.
  ///
  /// In en, this message translates to:
  /// **'What a deal collects at each stage'**
  String get teamsChecklistHint;

  /// No description provided for @teamsChecklistNewDealsOnly.
  ///
  /// In en, this message translates to:
  /// **'Changes apply to new deals. Deals already under way keep their own list.'**
  String get teamsChecklistNewDealsOnly;

  /// No description provided for @teamsChecklistRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get teamsChecklistRename;

  /// No description provided for @teamsChecklistReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get teamsChecklistReorder;

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

  /// No description provided for @teamsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Agency currency'**
  String get teamsCurrency;

  /// No description provided for @teamsCurrencyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get teamsCurrencyConfirm;

  /// No description provided for @teamsCurrencyConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the agency will see prices in {currency}. Amounts are not converted: a listing priced {before} will read {after}.'**
  String teamsCurrencyConfirmBody(String currency, String before, String after);

  /// No description provided for @teamsCurrencyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Change the agency currency?'**
  String get teamsCurrencyConfirmTitle;

  /// No description provided for @teamsCurrencyEur.
  ///
  /// In en, this message translates to:
  /// **'Euro (€)'**
  String get teamsCurrencyEur;

  /// No description provided for @teamsCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'How prices read across the app'**
  String get teamsCurrencyHint;

  /// No description provided for @teamsCurrencyKgs.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyz som (KGS)'**
  String get teamsCurrencyKgs;

  /// No description provided for @teamsCurrencyKzt.
  ///
  /// In en, this message translates to:
  /// **'Tenge (₸)'**
  String get teamsCurrencyKzt;

  /// No description provided for @teamsCurrencyRub.
  ///
  /// In en, this message translates to:
  /// **'Rouble (₽)'**
  String get teamsCurrencyRub;

  /// No description provided for @teamsCurrencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US dollar (\$)'**
  String get teamsCurrencyUsd;

  /// No description provided for @teamsCurrencyUzs.
  ///
  /// In en, this message translates to:
  /// **'Uzbek som (UZS)'**
  String get teamsCurrencyUzs;

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

  /// No description provided for @teamsInviteSentBody.
  ///
  /// In en, this message translates to:
  /// **'An invite has been emailed to {email}.'**
  String teamsInviteSentBody(Object email);

  /// No description provided for @teamsLeaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave team'**
  String get teamsLeaveTeam;

  /// No description provided for @teamsLeaveTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Your clients, deals and meetings stay with the team. You will need a new invitation to come back.'**
  String get teamsLeaveTeamBody;

  /// No description provided for @teamsLeaveTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {team}?'**
  String teamsLeaveTeamTitle(Object team);

  /// No description provided for @teamsManagerChip.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get teamsManagerChip;

  /// No description provided for @teamsManagerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manager: {name}'**
  String teamsManagerLabel(Object name);

  /// No description provided for @teamsManagerOptional.
  ///
  /// In en, this message translates to:
  /// **'Manager (optional)'**
  String get teamsManagerOptional;

  /// No description provided for @teamsMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String teamsMemberCount(num count);

  /// No description provided for @teamsMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get teamsMembers;

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

  /// No description provided for @teamsNoMembers.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet'**
  String get teamsNoMembers;

  /// No description provided for @teamsNoMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first agent by email.'**
  String get teamsNoMembersBody;

  /// No description provided for @teamsNoPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending'**
  String get teamsNoPending;

  /// No description provided for @teamsNoPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Requests waiting for an answer appear here.'**
  String get teamsNoPendingBody;

  /// No description provided for @teamsNoTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'No team'**
  String get teamsNoTeamLabel;

  /// No description provided for @teamsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get teamsPending;

  /// No description provided for @teamsPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get teamsPhoneOptional;

  /// No description provided for @teamsRemoveInviteBody.
  ///
  /// In en, this message translates to:
  /// **'The invite to {name} will be revoked.'**
  String teamsRemoveInviteBody(Object name);

  /// No description provided for @teamsRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from team'**
  String get teamsRemoveMember;

  /// No description provided for @teamsRemoveMemberBody.
  ///
  /// In en, this message translates to:
  /// **'Their clients, deals and meetings stay in the team and go to {successor}.'**
  String teamsRemoveMemberBody(Object successor);

  /// No description provided for @teamsRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String teamsRemoveMemberTitle(Object name);

  /// No description provided for @teamsRequestSentBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has to accept before joining your team.'**
  String teamsRequestSentBody(Object name);

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

  /// No description provided for @teamsStatusPendingInvite.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get teamsStatusPendingInvite;

  /// No description provided for @teamsStatusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get teamsStatusPendingVerification;

  /// No description provided for @teamsSuccessor.
  ///
  /// In en, this message translates to:
  /// **'Records go to'**
  String get teamsSuccessor;

  /// No description provided for @teamsSuccessorMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get teamsSuccessorMe;

  /// No description provided for @teamsTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamsTeamLabel;

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

  /// No description provided for @templatesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get templatesAdd;

  /// No description provided for @templatesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What the agent will send'**
  String get templatesBodyHint;

  /// No description provided for @templatesBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get templatesBodyLabel;

  /// No description provided for @templatesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get templatesDelete;

  /// No description provided for @templatesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will no longer be offered to agents.'**
  String templatesDeleteBody(String title);

  /// No description provided for @templatesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get templatesDeleteTitle;

  /// No description provided for @templatesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templatesEdit;

  /// No description provided for @templatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmpty;

  /// No description provided for @templatesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the messages your agents send most often.'**
  String get templatesEmptyBody;

  /// No description provided for @templatesHint.
  ///
  /// In en, this message translates to:
  /// **'Ready texts for WhatsApp and SMS'**
  String get templatesHint;

  /// No description provided for @templatesInsert.
  ///
  /// In en, this message translates to:
  /// **'Insert a placeholder'**
  String get templatesInsert;

  /// No description provided for @templatesIntro.
  ///
  /// In en, this message translates to:
  /// **'Agents pick a template when writing to a client. Placeholders fill in with the client, the agent and the chosen listing.'**
  String get templatesIntro;

  /// No description provided for @templatesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load templates'**
  String get templatesLoadFailed;

  /// No description provided for @templatesNew.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templatesNew;

  /// No description provided for @templatesPlaceholderAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get templatesPlaceholderAddress;

  /// No description provided for @templatesPlaceholderAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent\'s name'**
  String get templatesPlaceholderAgent;

  /// No description provided for @templatesPlaceholderClient.
  ///
  /// In en, this message translates to:
  /// **'Client\'s name'**
  String get templatesPlaceholderClient;

  /// No description provided for @templatesPlaceholderLink.
  ///
  /// In en, this message translates to:
  /// **'Listing link'**
  String get templatesPlaceholderLink;

  /// No description provided for @templatesPlaceholderListing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get templatesPlaceholderListing;

  /// No description provided for @templatesPlaceholderPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get templatesPlaceholderPrice;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Message templates'**
  String get templatesTitle;

  /// No description provided for @templatesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Viewing invitation'**
  String get templatesTitleHint;

  /// No description provided for @templatesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get templatesTitleLabel;

  /// No description provided for @templatesUnknownPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Unknown placeholder: {names}. Use the ones below.'**
  String templatesUnknownPlaceholder(String names);

  /// No description provided for @dealsKind.
  ///
  /// In en, this message translates to:
  /// **'Sale or rent'**
  String get dealsKind;

  /// No description provided for @dealsKindSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get dealsKindSale;

  /// No description provided for @dealsKindRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get dealsKindRent;

  /// No description provided for @leasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Lease'**
  String get leasesTitle;

  /// No description provided for @leasesMonthlyRent.
  ///
  /// In en, this message translates to:
  /// **'Rent per month'**
  String get leasesMonthlyRent;

  /// No description provided for @leasesPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month'**
  String leasesPerMonth(String amount);

  /// No description provided for @leasesStart.
  ///
  /// In en, this message translates to:
  /// **'Lease starts'**
  String get leasesStart;

  /// No description provided for @leasesEnd.
  ///
  /// In en, this message translates to:
  /// **'Lease ends'**
  String get leasesEnd;

  /// No description provided for @leasesPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get leasesPickDate;

  /// No description provided for @leasesReminderDays.
  ///
  /// In en, this message translates to:
  /// **'Remind me, days before the end'**
  String get leasesReminderDays;

  /// No description provided for @leasesReminderValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before the end} other{{count} days before the end}}'**
  String leasesReminderValue(int count);

  /// No description provided for @leasesReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get leasesReminder;

  /// No description provided for @leasesLandlord.
  ///
  /// In en, this message translates to:
  /// **'Landlord'**
  String get leasesLandlord;

  /// No description provided for @leasesTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get leasesTenant;

  /// No description provided for @leasesTenantValue.
  ///
  /// In en, this message translates to:
  /// **'Tenant: {name}'**
  String leasesTenantValue(String name);

  /// No description provided for @leasesLandlordValue.
  ///
  /// In en, this message translates to:
  /// **'Landlord: {name}'**
  String leasesLandlordValue(String name);

  /// No description provided for @leasesRentRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the rent per month'**
  String get leasesRentRequired;

  /// No description provided for @leasesDatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick the first and the last day of the lease'**
  String get leasesDatesRequired;

  /// No description provided for @leasesEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The lease has to end after it starts'**
  String get leasesEndBeforeStart;

  /// No description provided for @leasesReminderInvalid.
  ///
  /// In en, this message translates to:
  /// **'From 1 to 365 days'**
  String get leasesReminderInvalid;

  /// No description provided for @leasesEndsToday.
  ///
  /// In en, this message translates to:
  /// **'Lease ends today'**
  String get leasesEndsToday;

  /// No description provided for @leasesEndsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Lease ends tomorrow'**
  String get leasesEndsTomorrow;

  /// No description provided for @leasesEndsIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Lease ends in 1 day} other{Lease ends in {count} days}}'**
  String leasesEndsIn(int count);

  /// No description provided for @leasesEndedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Lease ended yesterday'**
  String get leasesEndedYesterday;

  /// No description provided for @leasesEndedAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Lease ended 1 day ago} other{Lease ended {count} days ago}}'**
  String leasesEndedAgo(int count);

  /// No description provided for @leasesRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew lease'**
  String get leasesRenew;

  /// No description provided for @leasesRenewTitle.
  ///
  /// In en, this message translates to:
  /// **'Renew the lease'**
  String get leasesRenewTitle;

  /// No description provided for @leasesRenewNewEnd.
  ///
  /// In en, this message translates to:
  /// **'New last day'**
  String get leasesRenewNewEnd;

  /// No description provided for @leasesRenewHint.
  ///
  /// In en, this message translates to:
  /// **'The deal stays the same; its lease runs on to the new day, and the discussion notes the change.'**
  String get leasesRenewHint;

  /// No description provided for @leasesRenewEndNotLater.
  ///
  /// In en, this message translates to:
  /// **'Pick a day after the current end'**
  String get leasesRenewEndNotLater;

  /// No description provided for @leasesRenewed.
  ///
  /// In en, this message translates to:
  /// **'Lease renewed'**
  String get leasesRenewed;

  /// No description provided for @leasesRenewFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t renew the lease'**
  String get leasesRenewFailed;

  /// No description provided for @leasesRenewWhenWon.
  ///
  /// In en, this message translates to:
  /// **'A lease can be renewed once the deal is won.'**
  String get leasesRenewWhenWon;

  /// No description provided for @leasesEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Leases ending'**
  String get leasesEndingTitle;

  /// No description provided for @leasesEndingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the leases'**
  String get leasesEndingLoadFailed;

  /// No description provided for @leasesEndingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leases end in the next 30 days'**
  String get leasesEndingEmpty;

  /// No description provided for @leasesEndingEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Won rent deals show here a month before their lease runs out.'**
  String get leasesEndingEmptyHint;

  /// No description provided for @notificationsLeaseEnding.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{The lease on {dealTitle} ends today} =1{The lease on {dealTitle} ends tomorrow} other{The lease on {dealTitle} ends in {days} days}}'**
  String notificationsLeaseEnding(String dealTitle, int days);

  /// No description provided for @clientsActivityHandover.
  ///
  /// In en, this message translates to:
  /// **'Handed over'**
  String get clientsActivityHandover;

  /// No description provided for @clientsActivityHandoverDetail.
  ///
  /// In en, this message translates to:
  /// **'From {from} to {to}'**
  String clientsActivityHandoverDetail(String from, String to);

  /// No description provided for @clientsActivityHandoverTo.
  ///
  /// In en, this message translates to:
  /// **'To {to}'**
  String clientsActivityHandoverTo(String to);

  /// No description provided for @handoverAction.
  ///
  /// In en, this message translates to:
  /// **'Hand over work'**
  String get handoverAction;

  /// No description provided for @handoverIntro.
  ///
  /// In en, this message translates to:
  /// **'{name} stays in the agency. Choose who takes over and what moves; each client\'s history will say so.'**
  String handoverIntro(String name);

  /// No description provided for @handoverFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get handoverFrom;

  /// No description provided for @handoverTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get handoverTo;

  /// No description provided for @handoverChooseColleague.
  ///
  /// In en, this message translates to:
  /// **'Choose a colleague'**
  String get handoverChooseColleague;

  /// No description provided for @handoverNoColleagues.
  ///
  /// In en, this message translates to:
  /// **'Nobody else can take it yet'**
  String get handoverNoColleagues;

  /// No description provided for @handoverWhat.
  ///
  /// In en, this message translates to:
  /// **'What moves'**
  String get handoverWhat;

  /// No description provided for @handoverPartClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get handoverPartClients;

  /// No description provided for @handoverPartClientsHint.
  ///
  /// In en, this message translates to:
  /// **'With their open deals, meetings and tasks'**
  String get handoverPartClientsHint;

  /// No description provided for @handoverPartListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get handoverPartListings;

  /// No description provided for @handoverPartListingsHint.
  ///
  /// In en, this message translates to:
  /// **'With open houses still to come'**
  String get handoverPartListingsHint;

  /// No description provided for @handoverPartDeals.
  ///
  /// In en, this message translates to:
  /// **'Open deals'**
  String get handoverPartDeals;

  /// No description provided for @handoverPartDealsHint.
  ///
  /// In en, this message translates to:
  /// **'Every deal not yet won or lost'**
  String get handoverPartDealsHint;

  /// No description provided for @handoverPartUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Meetings and tasks'**
  String get handoverPartUpcoming;

  /// No description provided for @handoverPartUpcomingHint.
  ///
  /// In en, this message translates to:
  /// **'Meetings to come and tasks not done'**
  String get handoverPartUpcomingHint;

  /// No description provided for @handoverAllClients.
  ///
  /// In en, this message translates to:
  /// **'All clients'**
  String get handoverAllClients;

  /// No description provided for @handoverSomeClients.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 client picked} other{{count} clients picked}}'**
  String handoverSomeClients(int count);

  /// No description provided for @handoverPickClients.
  ///
  /// In en, this message translates to:
  /// **'Choose clients'**
  String get handoverPickClients;

  /// No description provided for @handoverPickAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get handoverPickAll;

  /// No description provided for @handoverPickNone.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get handoverPickNone;

  /// No description provided for @handoverPickDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get handoverPickDone;

  /// No description provided for @handoverNoClients.
  ///
  /// In en, this message translates to:
  /// **'No clients to pick'**
  String get handoverNoClients;

  /// No description provided for @handoverPreview.
  ///
  /// In en, this message translates to:
  /// **'What will move'**
  String get handoverPreview;

  /// No description provided for @handoverCountDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get handoverCountDeals;

  /// No description provided for @handoverCountMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get handoverCountMeetings;

  /// No description provided for @handoverCountTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get handoverCountTasks;

  /// No description provided for @handoverCountOpenHouses.
  ///
  /// In en, this message translates to:
  /// **'Open houses'**
  String get handoverCountOpenHouses;

  /// No description provided for @handoverPickTarget.
  ///
  /// In en, this message translates to:
  /// **'Choose who takes over to see what moves'**
  String get handoverPickTarget;

  /// No description provided for @handoverNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one thing to hand over'**
  String get handoverNothingSelected;

  /// No description provided for @handoverNothingToMove.
  ///
  /// In en, this message translates to:
  /// **'Nothing to hand over'**
  String get handoverNothingToMove;

  /// No description provided for @handoverPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not count what moves'**
  String get handoverPreviewFailed;

  /// No description provided for @handoverConfirm.
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get handoverConfirm;

  /// No description provided for @handoverConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand over to {name}?'**
  String handoverConfirmTitle(String name);

  /// No description provided for @handoverConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Work moves from {from} to {to}. Nobody leaves the agency, and each client\'s history will note it.'**
  String handoverConfirmBody(String from, String to);

  /// No description provided for @handoverDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Handed over to {name}'**
  String handoverDoneTitle(String name);

  /// No description provided for @handoverDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has been told what is now theirs.'**
  String handoverDoneBody(String name);

  /// No description provided for @handoverDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Back to the team'**
  String get handoverDoneAction;

  /// No description provided for @handoverLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the team'**
  String get handoverLoadFailed;

  /// No description provided for @clientsLeadSourcePartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get clientsLeadSourcePartner;

  /// No description provided for @partnersTitle.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get partnersTitle;

  /// No description provided for @partnersHint.
  ///
  /// In en, this message translates to:
  /// **'Brokers, notaries and others who send clients'**
  String get partnersHint;

  /// No description provided for @partnersIntro.
  ///
  /// In en, this message translates to:
  /// **'The agency\'s brokers, notaries, appraisers and other partners, the clients they sent and the fees owed on won deals.'**
  String get partnersIntro;

  /// No description provided for @partnersAdd.
  ///
  /// In en, this message translates to:
  /// **'Add partner'**
  String get partnersAdd;

  /// No description provided for @partnersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No partners yet'**
  String get partnersEmpty;

  /// No description provided for @partnersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the brokers, notaries and agencies you work with.'**
  String get partnersEmptyBody;

  /// No description provided for @partnersNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No partners match'**
  String get partnersNoMatches;

  /// No description provided for @partnersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load partners'**
  String get partnersLoadFailed;

  /// No description provided for @partnersLoadFailedOne.
  ///
  /// In en, this message translates to:
  /// **'Could not load the partner'**
  String get partnersLoadFailedOne;

  /// No description provided for @partnersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, company or phone'**
  String get partnersSearchHint;

  /// No description provided for @partnersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get partnersFilterAll;

  /// No description provided for @partnersKindMortgageBroker.
  ///
  /// In en, this message translates to:
  /// **'Mortgage broker'**
  String get partnersKindMortgageBroker;

  /// No description provided for @partnersKindLawyer.
  ///
  /// In en, this message translates to:
  /// **'Lawyer or notary'**
  String get partnersKindLawyer;

  /// No description provided for @partnersKindAppraiser.
  ///
  /// In en, this message translates to:
  /// **'Appraiser'**
  String get partnersKindAppraiser;

  /// No description provided for @partnersKindDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get partnersKindDeveloper;

  /// No description provided for @partnersKindAgency.
  ///
  /// In en, this message translates to:
  /// **'Other agency'**
  String get partnersKindAgency;

  /// No description provided for @partnersKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get partnersKindOther;

  /// No description provided for @partnersReferredCount.
  ///
  /// In en, this message translates to:
  /// **'Referred: {count}'**
  String partnersReferredCount(int count);

  /// No description provided for @partnersFeePercent.
  ///
  /// In en, this message translates to:
  /// **'{value}% of commission'**
  String partnersFeePercent(String value);

  /// No description provided for @partnersFeeFixed.
  ///
  /// In en, this message translates to:
  /// **'{amount} per deal'**
  String partnersFeeFixed(String amount);

  /// No description provided for @partnersFeeNone.
  ///
  /// In en, this message translates to:
  /// **'No referral fee'**
  String get partnersFeeNone;

  /// No description provided for @partnersStatReferred.
  ///
  /// In en, this message translates to:
  /// **'Referred clients'**
  String get partnersStatReferred;

  /// No description provided for @partnersStatWon.
  ///
  /// In en, this message translates to:
  /// **'Won deals'**
  String get partnersStatWon;

  /// No description provided for @partnersStatFees.
  ///
  /// In en, this message translates to:
  /// **'Fees owed'**
  String get partnersStatFees;

  /// No description provided for @partnersStatHandoffs.
  ///
  /// In en, this message translates to:
  /// **'Clients sent'**
  String get partnersStatHandoffs;

  /// No description provided for @partnersFeesUnknown.
  ///
  /// In en, this message translates to:
  /// **'Won deals without a commission, not counted: {count}'**
  String partnersFeesUnknown(int count);

  /// No description provided for @partnersStatsScope.
  ///
  /// In en, this message translates to:
  /// **'Counted over the clients you see.'**
  String get partnersStatsScope;

  /// No description provided for @partnersContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get partnersContact;

  /// No description provided for @partnersName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get partnersName;

  /// No description provided for @partnersNameHint.
  ///
  /// In en, this message translates to:
  /// **'Who you deal with'**
  String get partnersNameHint;

  /// No description provided for @partnersNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get partnersNameRequired;

  /// No description provided for @partnersCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get partnersCompany;

  /// No description provided for @partnersCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Bank, firm or agency'**
  String get partnersCompanyHint;

  /// No description provided for @partnersKind.
  ///
  /// In en, this message translates to:
  /// **'What they do'**
  String get partnersKind;

  /// No description provided for @partnersPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get partnersPhone;

  /// No description provided for @partnersEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get partnersEmail;

  /// No description provided for @partnersNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get partnersNote;

  /// No description provided for @partnersNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Terms, how to reach them, anything to remember'**
  String get partnersNoteHint;

  /// No description provided for @partnersFee.
  ///
  /// In en, this message translates to:
  /// **'Referral fee'**
  String get partnersFee;

  /// No description provided for @partnersFeeHint.
  ///
  /// In en, this message translates to:
  /// **'Owed on each won deal of a client the partner sent.'**
  String get partnersFeeHint;

  /// No description provided for @partnersFeeTypeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get partnersFeeTypeNone;

  /// No description provided for @partnersFeeTypePercent.
  ///
  /// In en, this message translates to:
  /// **'% of commission'**
  String get partnersFeeTypePercent;

  /// No description provided for @partnersFeeTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get partnersFeeTypeFixed;

  /// No description provided for @partnersFeeValuePercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get partnersFeeValuePercent;

  /// No description provided for @partnersFeeValueAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get partnersFeeValueAmount;

  /// No description provided for @partnersFeeInvalidPercent.
  ///
  /// In en, this message translates to:
  /// **'Enter a percent above 0 and at most 100'**
  String get partnersFeeInvalidPercent;

  /// No description provided for @partnersFeeInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0'**
  String get partnersFeeInvalidAmount;

  /// No description provided for @partnersInvalidFee.
  ///
  /// In en, this message translates to:
  /// **'Check the referral fee'**
  String get partnersInvalidFee;

  /// No description provided for @partnersSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get partnersSave;

  /// No description provided for @partnersNew.
  ///
  /// In en, this message translates to:
  /// **'New partner'**
  String get partnersNew;

  /// No description provided for @partnersEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit partner'**
  String get partnersEdit;

  /// No description provided for @partnersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete partner'**
  String get partnersDelete;

  /// No description provided for @partnersDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String partnersDeleteConfirm(String name);

  /// No description provided for @partnersInUse.
  ///
  /// In en, this message translates to:
  /// **'Clients are linked to this partner, so it cannot be deleted.'**
  String get partnersInUse;

  /// No description provided for @partnersRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the partner who sent this client'**
  String get partnersRequired;

  /// No description provided for @partnersAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String partnersAddedBy(String name);

  /// No description provided for @partnersReferrals.
  ///
  /// In en, this message translates to:
  /// **'Clients they referred'**
  String get partnersReferrals;

  /// No description provided for @partnersNoReferrals.
  ///
  /// In en, this message translates to:
  /// **'No clients from this partner yet'**
  String get partnersNoReferrals;

  /// No description provided for @partnersReferralWon.
  ///
  /// In en, this message translates to:
  /// **'Won deals: {count}'**
  String partnersReferralWon(int count);

  /// No description provided for @partnersReferralFee.
  ///
  /// In en, this message translates to:
  /// **'Fee {amount}'**
  String partnersReferralFee(String amount);

  /// No description provided for @partnersReferralNoDeals.
  ///
  /// In en, this message translates to:
  /// **'No won deals'**
  String get partnersReferralNoDeals;

  /// No description provided for @partnersSentClients.
  ///
  /// In en, this message translates to:
  /// **'Clients sent to them'**
  String get partnersSentClients;

  /// No description provided for @partnersNoSentClients.
  ///
  /// In en, this message translates to:
  /// **'No clients sent yet'**
  String get partnersNoSentClients;

  /// No description provided for @partnersHandoffSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get partnersHandoffSent;

  /// No description provided for @partnersHandoffInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get partnersHandoffInProgress;

  /// No description provided for @partnersHandoffDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get partnersHandoffDone;

  /// No description provided for @partnersClientCard.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get partnersClientCard;

  /// No description provided for @partnersReferredBy.
  ///
  /// In en, this message translates to:
  /// **'Referred by'**
  String get partnersReferredBy;

  /// No description provided for @partnersSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to'**
  String get partnersSentTo;

  /// No description provided for @partnersSendToPartner.
  ///
  /// In en, this message translates to:
  /// **'Send to a partner'**
  String get partnersSendToPartner;

  /// No description provided for @partnersClientNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent to any partner yet'**
  String get partnersClientNotSent;

  /// No description provided for @partnersHandoffEdit.
  ///
  /// In en, this message translates to:
  /// **'Update hand-off'**
  String get partnersHandoffEdit;

  /// No description provided for @partnersHandoffPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnersHandoffPartner;

  /// No description provided for @partnersHandoffDate.
  ///
  /// In en, this message translates to:
  /// **'Sent on'**
  String get partnersHandoffDate;

  /// No description provided for @partnersHandoffStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get partnersHandoffStatus;

  /// No description provided for @partnersHandoffNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What they are helping with'**
  String get partnersHandoffNoteHint;

  /// No description provided for @partnersHandoffRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove hand-off'**
  String get partnersHandoffRemove;

  /// No description provided for @partnersHandoffRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Take this hand-off off the client?'**
  String get partnersHandoffRemoveConfirm;

  /// No description provided for @partnersHandoffBy.
  ///
  /// In en, this message translates to:
  /// **'Sent by {name}'**
  String partnersHandoffBy(String name);

  /// No description provided for @partnersPickPartner.
  ///
  /// In en, this message translates to:
  /// **'Choose a partner'**
  String get partnersPickPartner;

  /// No description provided for @partnersPickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No partners'**
  String get partnersPickerEmpty;

  /// No description provided for @partnersSentOnFuture.
  ///
  /// In en, this message translates to:
  /// **'The day cannot be in the future'**
  String get partnersSentOnFuture;

  /// No description provided for @partnersOpenHandoffs.
  ///
  /// In en, this message translates to:
  /// **'Still open: {count}'**
  String partnersOpenHandoffs(int count);

  /// No description provided for @timeOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Time off'**
  String get timeOffTitle;

  /// No description provided for @timeOffWhosOut.
  ///
  /// In en, this message translates to:
  /// **'Who\'s out'**
  String get timeOffWhosOut;

  /// No description provided for @timeOffAdd.
  ///
  /// In en, this message translates to:
  /// **'Add time off'**
  String get timeOffAdd;

  /// No description provided for @timeOffNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New time off'**
  String get timeOffNewTitle;

  /// No description provided for @timeOffEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Time off'**
  String get timeOffEditTitle;

  /// No description provided for @timeOffKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get timeOffKind;

  /// No description provided for @timeOffKindVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get timeOffKindVacation;

  /// No description provided for @timeOffKindSickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick leave'**
  String get timeOffKindSickLeave;

  /// No description provided for @timeOffKindDayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get timeOffKindDayOff;

  /// No description provided for @timeOffKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get timeOffKindOther;

  /// No description provided for @timeOffPerson.
  ///
  /// In en, this message translates to:
  /// **'Who is away'**
  String get timeOffPerson;

  /// No description provided for @timeOffPickPerson.
  ///
  /// In en, this message translates to:
  /// **'Choose who is away'**
  String get timeOffPickPerson;

  /// No description provided for @timeOffSearchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get timeOffSearchPeople;

  /// No description provided for @timeOffDaysEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get timeOffDaysEyebrow;

  /// No description provided for @timeOffFirstDay.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get timeOffFirstDay;

  /// No description provided for @timeOffLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get timeOffLastDay;

  /// No description provided for @timeOffPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get timeOffPickDate;

  /// No description provided for @timeOffDatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the first and the last day'**
  String get timeOffDatesRequired;

  /// No description provided for @timeOffEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The last day cannot be before the first'**
  String get timeOffEndBeforeStart;

  /// No description provided for @timeOffDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String timeOffDays(int count);

  /// No description provided for @timeOffCover.
  ///
  /// In en, this message translates to:
  /// **'Covering'**
  String get timeOffCover;

  /// No description provided for @timeOffNoCover.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get timeOffNoCover;

  /// No description provided for @timeOffCoverHint.
  ///
  /// In en, this message translates to:
  /// **'While they are away, the cover also gets their notifications. Nothing changes hands.'**
  String get timeOffCoverHint;

  /// No description provided for @timeOffCoveredBy.
  ///
  /// In en, this message translates to:
  /// **'Covered by {name}'**
  String timeOffCoveredBy(String name);

  /// No description provided for @timeOffNobodyCovers.
  ///
  /// In en, this message translates to:
  /// **'Nobody covers'**
  String get timeOffNobodyCovers;

  /// No description provided for @timeOffNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get timeOffNote;

  /// No description provided for @timeOffNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything colleagues should know'**
  String get timeOffNoteHint;

  /// No description provided for @timeOffSaved.
  ///
  /// In en, this message translates to:
  /// **'Time off saved'**
  String get timeOffSaved;

  /// No description provided for @timeOffCancelled.
  ///
  /// In en, this message translates to:
  /// **'Time off cancelled'**
  String get timeOffCancelled;

  /// No description provided for @timeOffCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel time off'**
  String get timeOffCancelAction;

  /// No description provided for @timeOffKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get timeOffKeep;

  /// No description provided for @timeOffCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this time off?'**
  String get timeOffCancelConfirmTitle;

  /// No description provided for @timeOffCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It comes off the team\'s list, and the cover stops getting the notifications.'**
  String get timeOffCancelConfirmBody;

  /// No description provided for @timeOffLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load time off'**
  String get timeOffLoadFailed;

  /// No description provided for @timeOffEmpty.
  ///
  /// In en, this message translates to:
  /// **'No time off yet'**
  String get timeOffEmpty;

  /// No description provided for @timeOffEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a holiday or a day off, so the team knows who covers for you.'**
  String get timeOffEmptyHint;

  /// No description provided for @timeOffTeamEmpty.
  ///
  /// In en, this message translates to:
  /// **'Everyone is in'**
  String get timeOffTeamEmpty;

  /// No description provided for @timeOffTeamEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Nobody has time off in the next three months.'**
  String get timeOffTeamEmptyHint;

  /// No description provided for @timeOffSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Out today'**
  String get timeOffSectionToday;

  /// No description provided for @timeOffSectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Starting this week'**
  String get timeOffSectionThisWeek;

  /// No description provided for @timeOffSectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get timeOffSectionLater;

  /// No description provided for @timeOffSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Now and coming up'**
  String get timeOffSectionUpcoming;

  /// No description provided for @timeOffSectionPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get timeOffSectionPast;

  /// No description provided for @timeOffAwayNow.
  ///
  /// In en, this message translates to:
  /// **'Away now'**
  String get timeOffAwayNow;

  /// No description provided for @timeOffAwayUntil.
  ///
  /// In en, this message translates to:
  /// **'Away until {date}'**
  String timeOffAwayUntil(String date);

  /// No description provided for @timeOffAwayOnDay.
  ///
  /// In en, this message translates to:
  /// **'{name} is away that day: {kind} until {date}'**
  String timeOffAwayOnDay(String name, String kind, String date);

  /// No description provided for @timeOffConflictsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meeting on these days} other{{count} meetings on these days}}'**
  String timeOffConflictsCount(int count);

  /// No description provided for @timeOffConflictsHint.
  ///
  /// In en, this message translates to:
  /// **'They are still on the calendar. Move them, or hand the work to a colleague.'**
  String get timeOffConflictsHint;

  /// No description provided for @timeOffHandOver.
  ///
  /// In en, this message translates to:
  /// **'Hand over work'**
  String get timeOffHandOver;

  /// No description provided for @timeOffErrorOverlaps.
  ///
  /// In en, this message translates to:
  /// **'There is already time off on some of these days'**
  String get timeOffErrorOverlaps;

  /// No description provided for @timeOffErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Time off lasts at most a year'**
  String get timeOffErrorTooLong;

  /// No description provided for @timeOffErrorCoverIsAbsent.
  ///
  /// In en, this message translates to:
  /// **'Somebody else has to cover'**
  String get timeOffErrorCoverIsAbsent;

  /// No description provided for @timeOffErrorNotYours.
  ///
  /// In en, this message translates to:
  /// **'Only the person away or a manager can change this'**
  String get timeOffErrorNotYours;

  /// No description provided for @timeOffOutToday.
  ///
  /// In en, this message translates to:
  /// **'Out today: {count}'**
  String timeOffOutToday(int count);

  /// No description provided for @timeOffCoveringFor.
  ///
  /// In en, this message translates to:
  /// **'Covering for {name}'**
  String timeOffCoveringFor(String name);

  /// No description provided for @notificationsTimeOffCover.
  ///
  /// In en, this message translates to:
  /// **'You are covering for {name}'**
  String notificationsTimeOffCover(String name);

  /// No description provided for @splitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission split'**
  String get splitsTitle;

  /// No description provided for @splitsSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shares of the commission, adding up to 100%'**
  String get splitsSheetSubtitle;

  /// No description provided for @splitsNotSplit.
  ///
  /// In en, this message translates to:
  /// **'Not split'**
  String get splitsNotSplit;

  /// No description provided for @splitsAllToAgent.
  ///
  /// In en, this message translates to:
  /// **'All of it goes to {name}.'**
  String splitsAllToAgent(String name);

  /// No description provided for @splitsDealAgent.
  ///
  /// In en, this message translates to:
  /// **'Deal agent'**
  String get splitsDealAgent;

  /// No description provided for @splitsColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get splitsColleague;

  /// No description provided for @splitsCoBroker.
  ///
  /// In en, this message translates to:
  /// **'Co-broker'**
  String get splitsCoBroker;

  /// No description provided for @splitsCoBrokerFrom.
  ///
  /// In en, this message translates to:
  /// **'Co-broker, {agency}'**
  String splitsCoBrokerFrom(String agency);

  /// No description provided for @splitsInactive.
  ///
  /// In en, this message translates to:
  /// **'No longer active'**
  String get splitsInactive;

  /// No description provided for @splitsPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String splitsPercent(String value);

  /// No description provided for @splitsAmountUnknown.
  ///
  /// In en, this message translates to:
  /// **'Amounts show once the price and the rate are set'**
  String get splitsAmountUnknown;

  /// No description provided for @splitsAdd.
  ///
  /// In en, this message translates to:
  /// **'Split the commission'**
  String get splitsAdd;

  /// No description provided for @splitsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit the split'**
  String get splitsEdit;

  /// No description provided for @splitsClear.
  ///
  /// In en, this message translates to:
  /// **'Give it all to the agent'**
  String get splitsClear;

  /// No description provided for @splitsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the commission split'**
  String get splitsLoadFailed;

  /// No description provided for @splitsAddColleague.
  ///
  /// In en, this message translates to:
  /// **'Add a colleague'**
  String get splitsAddColleague;

  /// No description provided for @splitsAddCoBroker.
  ///
  /// In en, this message translates to:
  /// **'Add a co-broker'**
  String get splitsAddCoBroker;

  /// No description provided for @splitsCoBrokerName.
  ///
  /// In en, this message translates to:
  /// **'Co-broker\'s name'**
  String get splitsCoBrokerName;

  /// No description provided for @splitsCoBrokerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ivan Petrov'**
  String get splitsCoBrokerNameHint;

  /// No description provided for @splitsCoBrokerAgency.
  ///
  /// In en, this message translates to:
  /// **'Their agency'**
  String get splitsCoBrokerAgency;

  /// No description provided for @splitsCoBrokerAgencyHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get splitsCoBrokerAgencyHint;

  /// No description provided for @splitsCoBrokerNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Name the co-broker'**
  String get splitsCoBrokerNameMissing;

  /// No description provided for @splitsShare.
  ///
  /// In en, this message translates to:
  /// **'Share, %'**
  String get splitsShare;

  /// No description provided for @splitsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get splitsRemove;

  /// No description provided for @splitsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {value}%'**
  String splitsTotal(String value);

  /// No description provided for @splitsTotalMustBe100.
  ///
  /// In en, this message translates to:
  /// **'The shares have to add up to 100%'**
  String get splitsTotalMustBe100;

  /// No description provided for @splitsPercentInvalid.
  ///
  /// In en, this message translates to:
  /// **'A share is above 0 and at most 100, with up to two decimals'**
  String get splitsPercentInvalid;

  /// No description provided for @splitsBalance.
  ///
  /// In en, this message translates to:
  /// **'Give the rest to the deal agent'**
  String get splitsBalance;

  /// No description provided for @splitsPickColleague.
  ///
  /// In en, this message translates to:
  /// **'Choose a colleague'**
  String get splitsPickColleague;

  /// No description provided for @splitsSearchColleague.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get splitsSearchColleague;

  /// No description provided for @splitsNoColleagues.
  ///
  /// In en, this message translates to:
  /// **'Nobody else in the agency to add'**
  String get splitsNoColleagues;

  /// No description provided for @splitsTooMany.
  ///
  /// In en, this message translates to:
  /// **'At most 10 people share one commission'**
  String get splitsTooMany;

  /// No description provided for @splitsColleagueInactive.
  ///
  /// In en, this message translates to:
  /// **'Only active members of the agency can be given a share'**
  String get splitsColleagueInactive;

  /// No description provided for @splitsShareNote.
  ///
  /// In en, this message translates to:
  /// **'A split deal\'s commission counts for each person by their share; a co-broker\'s share is not the agency\'s.'**
  String get splitsShareNote;
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
