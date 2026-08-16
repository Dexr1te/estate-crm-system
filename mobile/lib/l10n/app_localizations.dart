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

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authSetPasswordContinue.
  ///
  /// In en, this message translates to:
  /// **'Set password & continue'**
  String get authSetPasswordContinue;

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

  /// No description provided for @clientsAddShort.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientsAddShort;

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

  /// No description provided for @clientsBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
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

  /// No description provided for @clientsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get clientsCreated;

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

  /// No description provided for @clientsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String clientsDeleteConfirm(Object name);

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

  /// No description provided for @clientsFilterSellers.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get clientsFilterSellers;

  /// No description provided for @clientsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get clientsFullName;

  /// No description provided for @clientsFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get clientsFullNameLabel;

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

  /// No description provided for @clientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get clientsMessage;

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

  /// No description provided for @clientsNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address on file'**
  String get clientsNoEmail;

  /// No description provided for @clientsNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file'**
  String get clientsNoPhone;

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
  /// **'Search by name, phone…'**
  String get clientsSearchHint;

  /// No description provided for @clientsSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
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

  /// No description provided for @clientsUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String clientsUpdatedAt(Object date);

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

  /// No description provided for @dashboardActiveDeals.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String dashboardActiveDeals(Object count);

  /// No description provided for @dashboardActiveDealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active deals'**
  String get dashboardActiveDealsLabel;

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

  /// No description provided for @dashboardDecidedDeals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing closed yet} =1{1 deal decided} other{{count} deals decided}}'**
  String dashboardDecidedDeals(num count);

  /// No description provided for @dashboardGoalClear.
  ///
  /// In en, this message translates to:
  /// **'Remove target'**
  String get dashboardGoalClear;

  /// No description provided for @dashboardGoalEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get dashboardGoalEyebrow;

  /// No description provided for @dashboardGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached. Everything from here is ahead of plan.'**
  String get dashboardGoalReached;

  /// No description provided for @dashboardGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to hit the target'**
  String dashboardGoalRemaining(Object amount);

  /// No description provided for @dashboardGoalSheetField.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dashboardGoalSheetField;

  /// No description provided for @dashboardGoalSheetHint.
  ///
  /// In en, this message translates to:
  /// **'Closed-won deals count towards it. Stored on this device only.'**
  String get dashboardGoalSheetHint;

  /// No description provided for @dashboardGoalSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly target'**
  String get dashboardGoalSheetTitle;

  /// No description provided for @dashboardGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed this month'**
  String get dashboardGoalTitle;

  /// No description provided for @dashboardGoalUnset.
  ///
  /// In en, this message translates to:
  /// **'Tap to set a monthly target and track it here'**
  String get dashboardGoalUnset;

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

  /// No description provided for @dashboardValueByStage.
  ///
  /// In en, this message translates to:
  /// **'Value by stage'**
  String get dashboardValueByStage;

  /// No description provided for @dealsAddDeal.
  ///
  /// In en, this message translates to:
  /// **'Add Deal'**
  String get dealsAddDeal;

  /// No description provided for @dealsAddShort.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get dealsAddShort;

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

  /// No description provided for @dealsClientRef.
  ///
  /// In en, this message translates to:
  /// **'Client #{id}'**
  String dealsClientRef(Object id);

  /// No description provided for @dealsClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dealsClosed;

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

  /// No description provided for @dealsDeleteCascade.
  ///
  /// In en, this message translates to:
  /// **'{title} will be deleted permanently. This cannot be undone.'**
  String dealsDeleteCascade(Object title);

  /// No description provided for @dealsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String dealsDeleteConfirm(Object title);

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

  /// No description provided for @dealsNextCall.
  ///
  /// In en, this message translates to:
  /// **'call {when}'**
  String dealsNextCall(Object when);

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
  String dealsTapToSelect(Object label);

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

  /// No description provided for @meetingsAddShort.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get meetingsAddShort;

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
  String meetingsClientNumber(Object id);

  /// No description provided for @meetingsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get meetingsCompleted;

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

  /// No description provided for @meetingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get meetingsNoResults;

  /// No description provided for @meetingsNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled in this range'**
  String get meetingsNoResultsSubtitle;

  /// No description provided for @meetingsNote.
  ///
  /// In en, this message translates to:
  /// **'Meeting note'**
  String get meetingsNote;

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

  /// No description provided for @meetingsTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select {label}'**
  String meetingsTapToSelect(Object label);

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
  /// **'Title *'**
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

  /// No description provided for @msgAgentInvited.
  ///
  /// In en, this message translates to:
  /// **'Agent invited'**
  String get msgAgentInvited;

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

  /// No description provided for @msgTeamUpdated.
  ///
  /// In en, this message translates to:
  /// **'Team updated'**
  String get msgTeamUpdated;

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

  /// No description provided for @profileApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileApp;

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

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get profileEditName;

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

  /// No description provided for @profileFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get profileFollowSystem;

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

  /// No description provided for @propertiesAddShort.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get propertiesAddShort;

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

  /// No description provided for @propertiesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String propertiesDeleteConfirm(Object title);

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

  /// No description provided for @propertiesNextDetails.
  ///
  /// In en, this message translates to:
  /// **'Next — details'**
  String get propertiesNextDetails;

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

  /// No description provided for @propertiesPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get propertiesPriceLabel;

  /// No description provided for @propertiesPricePerSqm.
  ///
  /// In en, this message translates to:
  /// **'{price} per m²'**
  String propertiesPricePerSqm(Object price);

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

  /// No description provided for @propertiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get propertiesSearchHint;

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
