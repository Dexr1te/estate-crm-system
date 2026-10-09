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
  String adminDeleteCascade(Object name, Object successor) {
    return '$name\'s clients, properties, deals and meetings move to $successor. The account is removed permanently and this cannot be undone.';
  }

  @override
  String get adminDeleteHandoverEmpty => 'No one else to hand them to';

  @override
  String get adminDeleteHandoverSearch => 'Search people';

  @override
  String get adminDeleteHandoverTitle => 'Hand the records over to';

  @override
  String get adminDeleteUser => 'Delete user';

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
  String analyticsAgent(Object name) {
    return 'Agent: $name';
  }

  @override
  String get analyticsAllAgents => 'All agents';

  @override
  String get analyticsAvgDaysToWin => 'Days to close';

  @override
  String get analyticsCreated => 'Created';

  @override
  String analyticsDays(Object days) {
    return '$days d';
  }

  @override
  String get analyticsEmptyBody =>
      'Deals created in this period will show up here.';

  @override
  String get analyticsEmptyTitle => 'No deals in this period';

  @override
  String get analyticsFunnel => 'Funnel';

  @override
  String get analyticsLeadToWon => 'Lead to won';

  @override
  String get analyticsLoadFailed => 'Could not load analytics';

  @override
  String get analyticsLostReasons => 'Why deals are lost';

  @override
  String get analyticsMonthly => 'Last six months';

  @override
  String get analyticsNoLost => 'No deals lost in this period.';

  @override
  String get analyticsLeadSources => 'Where clients come from';

  @override
  String get analyticsLeadSourcesHint =>
      'Clients added in the period, and how many of them have a won deal.';

  @override
  String analyticsLeadSourceWon(Object count, Object rate) {
    return '$count with a won deal · $rate';
  }

  @override
  String get analyticsNoClients => 'No clients added in this period.';

  @override
  String get analyticsNoValue => '—';

  @override
  String analyticsOfPrevious(Object percent) {
    return '$percent of the previous stage';
  }

  @override
  String get analyticsOpen => 'Funnel and analytics';

  @override
  String get analyticsPeriodMonth => 'This month';

  @override
  String get analyticsPeriodQuarter => 'Quarter';

  @override
  String get analyticsPeriodYear => 'Year';

  @override
  String get analyticsSelectAgent => 'Choose an agent';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String analyticsWonLost(Object lost, Object won) {
    return '$won won · $lost lost';
  }

  @override
  String get analyticsWonValue => 'Won value';

  @override
  String get appTitle => 'Estate CRM';

  @override
  String get authAcceptInviteSubtitle =>
      'Enter the invite code you were given and choose a password.';

  @override
  String get authAcceptRequest => 'Accept';

  @override
  String get authAcceptTerms => 'I agree to the privacy policy';

  @override
  String get authAcceptTermsRequired => 'Please accept the privacy policy';

  @override
  String get authAcceptYourInvite => 'Accept your invite';

  @override
  String get authActivate => 'Activate';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authChangeEmail => 'Use a different email';

  @override
  String get authChooseRoleSubtitle =>
      'This decides what you see. You can be moved later by your manager.';

  @override
  String get authChooseRoleTitle => 'How will you work?';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authContinue => 'Continue';

  @override
  String get authCreateAccountSubtitle =>
      'We will email you a six-digit code to confirm the address.';

  @override
  String get authCreateAccountTitle => 'Create your account';

  @override
  String get authCreateTeamAction => 'Create and continue';

  @override
  String get authCreateTeamName => 'Agency name';

  @override
  String get authCreateTeamNameRequired => 'Enter a name';

  @override
  String get authCreateTeamSubtitle =>
      'Its name is what your agents will see. You can change it later.';

  @override
  String get authCreateTeamTitle => 'Create your agency';

  @override
  String get authDeclineRequest => 'Decline';

  @override
  String authDeclineRequestBody(Object team) {
    return '$team will not see your clients or deals. They can invite you again later.';
  }

  @override
  String get authDeclineRequestTitle => 'Decline this invitation?';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authEmailTaken =>
      'This email already has an account. Sign in instead.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter the address you sign in with and we’ll email you a link to choose a new password.';

  @override
  String get authForgotPasswordTitle => 'Reset your password';

  @override
  String get authFullName => 'Full name';

  @override
  String get authFullNameRequired => 'Enter your name';

  @override
  String get authHaveAnInvite => 'Have an invite?';

  @override
  String get authInviteCode => 'Invite code';

  @override
  String get authInviteCodeRequired => 'Invite code is required';

  @override
  String get authInvitePendingBody =>
      'An invite was emailed to this address. Open it, or enter its code to set your password.';

  @override
  String get authInvitePendingTitle => 'You already have an invite';

  @override
  String authInviteSignOutBody(Object email) {
    return 'You are signed in as $email. Accepting the invite means signing out of that account first.';
  }

  @override
  String get authInviteSignOutConfirm => 'Sign out & continue';

  @override
  String get authInviteSignOutTitle => 'Accept this invite?';

  @override
  String authInvitedBy(Object name) {
    return 'From $name';
  }

  @override
  String authInvitedByTeam(Object team) {
    return '$team invited you';
  }

  @override
  String get authNewPassword => 'New password';

  @override
  String get authNoAccount => 'No account?';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHelp => 'At least 8 characters, including a digit.';

  @override
  String get authPasswordMinLength => 'At least 6 characters';

  @override
  String get authPasswordMinLength8 => 'At least 8 characters';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authPhoneOptional => 'Phone (optional)';

  @override
  String get authPrivacyPolicy => 'Privacy policy';

  @override
  String get authResendCode => 'Send a new code';

  @override
  String authResendCodeIn(Object seconds) {
    return 'Send a new code in ${seconds}s';
  }

  @override
  String get authResetCode => 'Reset code';

  @override
  String get authResetCodeRequired => 'Reset code is required';

  @override
  String authResetLinkSentBody(Object email) {
    return 'If $email has an account, a link to choose a new password is on its way. It expires in 24 hours.';
  }

  @override
  String get authResetLinkSentTitle => 'Check your email';

  @override
  String get authResetPasswordSubtitle =>
      'Paste the code from the email, then choose a password.';

  @override
  String get authResetPasswordTitle => 'Choose a new password';

  @override
  String get authRoleAgentBody =>
      'Join your manager\'s team and work on your own clients and deals.';

  @override
  String get authRoleAgentTitle => 'I am an agent';

  @override
  String get authRoleManagerBody =>
      'Create a team, add agents and see everything they work on.';

  @override
  String get authRoleManagerTitle => 'I run an agency';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authSetPasswordSignIn => 'Set password & sign in';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignInSubtitle => 'Sign in to manage your properties';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authVerify => 'Confirm';

  @override
  String authVerifyEmailSubtitle(Object email) {
    return 'Enter the six-digit code we sent to $email.';
  }

  @override
  String get authVerifyEmailTitle => 'Confirm your email';

  @override
  String get authWaitingCopyEmail => 'Copy email';

  @override
  String get authWaitingEmailCopied => 'Email copied';

  @override
  String get authWaitingNoRequests => 'No invitations yet';

  @override
  String get authWaitingNoRequestsBody => 'Pull down to check again.';

  @override
  String get authWaitingSubtitle =>
      'Give this email to your manager. Once they add you and you accept, your clients and deals appear here.';

  @override
  String get authWaitingTitle => 'Waiting for a team';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get calendarAdd => 'Add';

  @override
  String get calendarAddMeeting => 'Meeting';

  @override
  String get calendarAddMeetingHint => 'With a client, at a set time';

  @override
  String get calendarAddTask => 'Task';

  @override
  String get calendarAddTaskHint => 'Something to get done by a time';

  @override
  String calendarAddTo(String day) {
    return 'Add to $day';
  }

  @override
  String get calendarDayEmpty => 'Nothing planned';

  @override
  String get calendarDayEmptyHint =>
      'Tap + or press and hold a day to add a meeting or a task';

  @override
  String calendarDayEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'nothing planned',
    );
    return '$_temp0';
  }

  @override
  String get calendarLegendMeeting => 'Meeting';

  @override
  String get calendarLegendOpenHouse => 'Open house';

  @override
  String get calendarLegendOverdue => 'Overdue';

  @override
  String get calendarLegendTask => 'Task';

  @override
  String get calendarLegendViewing => 'Viewing';

  @override
  String get calendarLoadFailed => 'Couldn\'t load the calendar';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarNextWeek => 'Next week';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarPreviousWeek => 'Previous week';

  @override
  String get calendarShowMonth => 'Show the whole month';

  @override
  String get calendarShowWeek => 'Show one week';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarViewList => 'List';

  @override
  String get calendarViewMonth => 'Month';

  @override
  String get changeLogAnyTime => 'Any time';

  @override
  String get changeLogAnyone => 'Anyone';

  @override
  String get changeLogAutomatic => 'Automatically';

  @override
  String changeLogChange(String field, String from, String to) {
    return '$field: $from → $to';
  }

  @override
  String get changeLogClearFilters => 'Clear filters';

  @override
  String get changeLogCreated => 'Created';

  @override
  String changeLogDays(String from, String to) {
    return '$from – $to';
  }

  @override
  String get changeLogDeleted => 'Deleted';

  @override
  String changeLogEdited(String field) {
    return '$field edited';
  }

  @override
  String get changeLogEmptyBody =>
      'Every edit to this record will show up here, with who made it and when.';

  @override
  String get changeLogEmptyTitle => 'No changes yet';

  @override
  String get changeLogEntityClient => 'Client';

  @override
  String get changeLogEntityDeal => 'Deal';

  @override
  String get changeLogEntityOther => 'Record';

  @override
  String get changeLogEntityProperty => 'Listing';

  @override
  String get changeLogFieldAddress => 'Address';

  @override
  String get changeLogFieldAgent => 'Agent';

  @override
  String get changeLogFieldArea => 'Area';

  @override
  String get changeLogFieldBirthday => 'Birthday';

  @override
  String get changeLogFieldBudget => 'Budget';

  @override
  String get changeLogFieldBudgetMax => 'Budget up to';

  @override
  String get changeLogFieldBudgetMin => 'Budget from';

  @override
  String get changeLogFieldCity => 'City';

  @override
  String get changeLogFieldClient => 'Client';

  @override
  String get changeLogFieldCommission => 'Commission';

  @override
  String get changeLogFieldDealPrice => 'Deal price';

  @override
  String get changeLogFieldDescription => 'Description';

  @override
  String get changeLogFieldEmail => 'Email';

  @override
  String get changeLogFieldFloor => 'Floor';

  @override
  String get changeLogFieldLeadSource => 'Lead source';

  @override
  String get changeLogFieldLeadSourceDetail => 'Lead source details';

  @override
  String get changeLogFieldListing => 'Listing';

  @override
  String get changeLogFieldLocation => 'Location on the map';

  @override
  String get changeLogFieldLostNote => 'Note on the loss';

  @override
  String get changeLogFieldLostReason => 'Why it was lost';

  @override
  String get changeLogFieldMandate => 'Agreement with the seller';

  @override
  String get changeLogFieldMandateEnd => 'Agreement ends';

  @override
  String get changeLogFieldMinArea => 'Area, at least';

  @override
  String get changeLogFieldMinRooms => 'Rooms, at least';

  @override
  String get changeLogFieldName => 'Name';

  @override
  String get changeLogFieldNotes => 'Notes';

  @override
  String get changeLogFieldOther => 'Other details';

  @override
  String get changeLogFieldPhone => 'Phone';

  @override
  String get changeLogFieldPrice => 'Price';

  @override
  String get changeLogFieldRooms => 'Rooms';

  @override
  String get changeLogFieldStatus => 'Status';

  @override
  String get changeLogFieldTags => 'Tags';

  @override
  String get changeLogFieldTitle => 'Title';

  @override
  String get changeLogFieldTotalFloors => 'Floors in the building';

  @override
  String get changeLogFieldType => 'Type';

  @override
  String get changeLogFieldWantedCity => 'City wanted';

  @override
  String get changeLogFieldWantedType => 'Looking for';

  @override
  String get changeLogFilterAll => 'All';

  @override
  String get changeLogFilterClients => 'Clients';

  @override
  String get changeLogFilterDeals => 'Deals';

  @override
  String get changeLogFilterListings => 'Listings';

  @override
  String get changeLogLoadFailed => 'Could not load the history';

  @override
  String get changeLogNoValue => '—';

  @override
  String get changeLogPeopleFailed => 'Could not load the agency\'s people';

  @override
  String changeLogPercent(String value) {
    return '$value%';
  }

  @override
  String get changeLogPickDays => 'Days to show';

  @override
  String get changeLogPickPerson => 'Who made the change';

  @override
  String changeLogRecord(String kind, String label) {
    return '$kind: $label';
  }

  @override
  String get changeLogTeamEmptyBody =>
      'Edits to the agency\'s listings, deals and clients will show up here.';

  @override
  String get changeLogTeamEmptyFiltered => 'Nothing matches these filters.';

  @override
  String get changeLogTeamHint => 'Who changed what across the agency';

  @override
  String get changeLogTeamTitle => 'Change log';

  @override
  String get changeLogTitle => 'History of changes';

  @override
  String get changeLogUnknownValue => 'another value';

  @override
  String get changeLogUntitled => 'Untitled';

  @override
  String get clientsActivityCall => 'Call';

  @override
  String get clientsActivityDate => 'Date';

  @override
  String get clientsActivityDeleteBody =>
      'It disappears from this client\'s history for the whole team. This cannot be undone.';

  @override
  String get clientsActivityDeleteTitle => 'Remove this entry?';

  @override
  String get clientsActivityEdit => 'Edit entry';

  @override
  String get clientsActivityEmail => 'Email';

  @override
  String get clientsActivityFormerMember => 'Former member';

  @override
  String get clientsActivityInFuture => 'That time has not come yet';

  @override
  String get clientsActivityKind => 'How you were in touch';

  @override
  String get clientsActivityLogged => 'Contact logged';

  @override
  String get clientsActivityMessage => 'Message';

  @override
  String get clientsActivityNote => 'Note';

  @override
  String get clientsActivityNoteHint => 'What was said, what happens next…';

  @override
  String get clientsActivityNoteLabel => 'What was said';

  @override
  String get clientsActivityNoteRequired => 'A note needs some text';

  @override
  String get clientsActivityRemove => 'Remove entry';

  @override
  String get clientsActivitySave => 'Save';

  @override
  String clientsActivitySentListings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent $count listings',
      one: 'Sent 1 listing',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityTime => 'Time';

  @override
  String clientsActivityToday(String time) {
    return 'Today, $time';
  }

  @override
  String get clientsActivityUpdated => 'Entry updated';

  @override
  String get clientsActivityWhen => 'When';

  @override
  String get clientsActivityWhenHourAgo => '1 hour ago';

  @override
  String get clientsActivityWhenJustNow => 'Just now';

  @override
  String get clientsActivityWhenYesterday => 'Yesterday';

  @override
  String clientsActivityYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get clientsAddFirstClient => 'Add your first client';

  @override
  String get clientsAgent => 'Agent';

  @override
  String clientsAgentMeta(Object name) {
    return 'agent $name';
  }

  @override
  String get clientsAnyType => 'Any';

  @override
  String get clientsBirthday => 'Birthday';

  @override
  String clientsBirthdayAge(int age) {
    return '$age years old';
  }

  @override
  String get clientsBirthdayClear => 'Remove birthday';

  @override
  String get clientsBirthdayHint =>
      'With the year unknown, only the day and month are kept.';

  @override
  String get clientsBirthdayNoYear => 'Year unknown';

  @override
  String get clientsBirthdayPick => 'Choose a date';

  @override
  String get clientsBudgetFrom => 'Budget from';

  @override
  String get clientsBudgetTo => 'Budget to';

  @override
  String get clientsBuyer => 'Buyer';

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
  String clientsColdDaysOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdEmpty => 'Nobody is going cold';

  @override
  String clientsColdEmptyHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Everyone worth a call has heard from you in the last $count days.',
      one: 'Everyone worth a call has heard from you in the last day.',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdLoadFailed => 'Could not load who is going cold';

  @override
  String get clientsColdNeverContacted => 'Never contacted';

  @override
  String get clientsColdNextCheckIn => 'Check in';

  @override
  String get clientsColdNextFirstCall => 'Make the first call';

  @override
  String get clientsColdNextPushDeal => 'Move the deal forward';

  @override
  String get clientsColdNextSendMatches => 'Send the listings that fit';

  @override
  String get clientsColdReasonLead => 'Lead from a listing page';

  @override
  String clientsColdReasonMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdReasonNegotiation => 'Deal in negotiation';

  @override
  String get clientsColdReasonOpenDeal => 'Open deal';

  @override
  String get clientsColdRemind => 'Remind me';

  @override
  String clientsColdRemindTask(String name) {
    return 'Call $name';
  }

  @override
  String clientsColdReminderSet(String time) {
    return 'Reminder set for tomorrow, $time';
  }

  @override
  String clientsColdSilentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Silent $count days',
      one: 'Silent 1 day',
    );
    return '$_temp0';
  }

  @override
  String clientsColdSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No contact for $count days or more',
      one: 'No contact for a day or more',
    );
    return '$_temp0';
  }

  @override
  String get clientsColdTitle => 'Going cold';

  @override
  String get clientsColdUndo => 'Undo';

  @override
  String get clientsComposeClearListing => 'Remove listing';

  @override
  String get clientsComposeHint =>
      'You can edit the text before sending. What you send is saved to the client\'s history.';

  @override
  String get clientsComposeListing => 'Listing';

  @override
  String get clientsComposeListingHint =>
      'Fills in the listing, its price, address and link';

  @override
  String get clientsComposeListingNone => 'No listing';

  @override
  String get clientsComposeNoListings => 'No listings';

  @override
  String get clientsComposeNoTemplates => 'Your agency has no templates yet';

  @override
  String get clientsComposePickListing => 'Choose a listing';

  @override
  String get clientsComposePickTemplate => 'Choose a template';

  @override
  String get clientsComposeSearchListings => 'Search listings';

  @override
  String get clientsComposeSearchTemplates => 'Search templates';

  @override
  String get clientsComposeSms => 'SMS';

  @override
  String get clientsComposeText => 'Message';

  @override
  String get clientsComposeTextHint => 'Write a message or use a template';

  @override
  String get clientsComposeTitle => 'Write to the client';

  @override
  String get clientsComposeUseTemplate => 'Use template';

  @override
  String get clientsContact => 'Contact';

  @override
  String get clientsContactInfo => 'Contact Info';

  @override
  String clientsContactedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Contacted $count days ago',
      one: 'Contacted 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String clientsContactedOn(String date) {
    return 'Contacted $date';
  }

  @override
  String get clientsContactedToday => 'Contacted today';

  @override
  String get clientsContactedYesterday => 'Contacted yesterday';

  @override
  String clientsCounter(Object active, Object total) {
    return '$total total · $active in progress';
  }

  @override
  String get clientsCreateClient => 'Create Client';

  @override
  String clientsDatesAnniversary(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years since the purchase',
      one: '$years year since the purchase',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesBirthday => 'Birthday';

  @override
  String get clientsDatesEmpty => 'No dates in the next two weeks';

  @override
  String get clientsDatesEmptyHint =>
      'Add a client\'s birthday on their card. A won deal\'s anniversary shows up here every year on its own.';

  @override
  String get clientsDatesGreet => 'Greet';

  @override
  String clientsDatesInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In $count day',
    );
    return '$_temp0';
  }

  @override
  String get clientsDatesLoadFailed => 'Couldn\'t load the dates coming up';

  @override
  String get clientsDatesTitle => 'Dates coming up';

  @override
  String get clientsDatesToday => 'Today';

  @override
  String get clientsDatesTomorrow => 'Tomorrow';

  @override
  String clientsDatesTurns(int years) {
    return 'Birthday, turns $years';
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
  String get clientsDuplicateEyebrow => 'Possible duplicate';

  @override
  String clientsDuplicateHeldBy(String agent, String name) {
    return 'Already in the agency: $name (agent $agent)';
  }

  @override
  String get clientsDuplicateHint =>
      'You can still save. Check with the colleague first.';

  @override
  String get clientsDuplicateOpen => 'Open';

  @override
  String get clientsDuplicateSameBoth => 'Same phone and email';

  @override
  String get clientsDuplicateSameEmail => 'Same email';

  @override
  String get clientsDuplicateSamePhone => 'Same phone';

  @override
  String clientsDuplicateUnassigned(String name) {
    return 'Already in the agency: $name';
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
  String get clientsFilterNewLeads => 'New leads';

  @override
  String get clientsFilterSellers => 'Sellers';

  @override
  String clientsFilterTagsCount(Object count) {
    return 'Tags · $count';
  }

  @override
  String get clientsFilterSource => 'Source';

  @override
  String get clientsFilterSourceAll => 'All sources';

  @override
  String get clientsFollowUpCall => 'Log this call?';

  @override
  String get clientsFollowUpEmail => 'Log this email?';

  @override
  String get clientsFollowUpHint =>
      'One tap puts it in the history. A note is optional.';

  @override
  String get clientsFullName => 'Full name';

  @override
  String get clientsHistory => 'History';

  @override
  String get clientsHistoryEmpty => 'No contact logged yet';

  @override
  String get clientsHistoryEmptyHint =>
      'Log each call, message and email, and whoever picks up this client knows where things stand.';

  @override
  String get clientsHistoryLoadFailed => 'Couldn\'t load the history';

  @override
  String clientsIdBadge(Object id) {
    return 'ID $id';
  }

  @override
  String get clientsInvalidEmail => 'Invalid email';

  @override
  String get clientsLogContact => 'Log contact';

  @override
  String get clientsLogFirstContact => 'Log the first contact';

  @override
  String get clientsMatches => 'Matching listings';

  @override
  String get clientsMerge => 'Merge with another card';

  @override
  String get clientsMergeConfirm => 'Merge';

  @override
  String clientsMergeConfirmBody(String source, String target) {
    return 'Deals, viewings, contact history and tasks of $source move to $target. An empty phone, email and requirements are filled in, and the notes are added. The card $source is then deleted. This cannot be undone.';
  }

  @override
  String get clientsMergeConfirmTitle => 'Merge into this card?';

  @override
  String get clientsMergeNoCandidates => 'No other clients to merge with';

  @override
  String get clientsMergePickTitle => 'Which card is the same person?';

  @override
  String get clientsMergeSearchHint => 'Search clients';

  @override
  String get clientsMessage => 'Message';

  @override
  String get clientsMinArea => 'Area, min m²';

  @override
  String get clientsMinRooms => 'Rooms, min';

  @override
  String get clientsNameRequired => 'Name is required';

  @override
  String get clientsNewClient => 'New Client';

  @override
  String get clientsNewLeadsEmpty =>
      'Buyers who leave their details on a listing\'s public link show up here for a week.';

  @override
  String get clientsNoClientsFound => 'No clients found';

  @override
  String get clientsNoEmail => 'No email address on file';

  @override
  String get clientsNoMatches => 'Nothing on the books fits yet';

  @override
  String get clientsNoPhone => 'No phone number on file';

  @override
  String get clientsNoRequirements =>
      'Say what this buyer is looking for and matching listings appear here';

  @override
  String get clientsNoWhatsApp =>
      'No phone number on the card, so WhatsApp is unavailable';

  @override
  String get clientsNotes => 'Notes';

  @override
  String get clientsNotesHint => 'Additional notes about this client…';

  @override
  String get clientsOverBudget => 'Over budget';

  @override
  String get clientsPhone => 'Phone';

  @override
  String get clientsRequirements => 'Looking for';

  @override
  String get clientsRequirementsHint =>
      'Fill this in and the app will keep showing which listings fit.';

  @override
  String get clientsSearchHint => 'Search by name, phone…';

  @override
  String get clientsSeller => 'Seller';

  @override
  String get clientsSendClosing =>
      'Tell me which ones you would like to see and I will arrange a viewing.';

  @override
  String get clientsSendFailed => 'Could not open sending';

  @override
  String get clientsSendGreeting =>
      'Hello! Here are listings that fit what you are looking for:';

  @override
  String get clientsSendLinks => 'Include links';

  @override
  String get clientsSendLinksHint =>
      'A page per listing with all its photos. Opens in any browser.';

  @override
  String get clientsSendLogged => 'Saved to the client\'s history';

  @override
  String get clientsSendMatches => 'Send listings';

  @override
  String get clientsSendPhotos => 'Attach cover photos';

  @override
  String get clientsSendPhotosHint =>
      'Photos go through Share. WhatsApp opens the chat with the text only.';

  @override
  String clientsSendSelected(int count) {
    return '$count selected';
  }

  @override
  String get clientsSendShare => 'Share';

  @override
  String get clientsSendWhatsApp => 'WhatsApp';

  @override
  String clientsSentOn(String date) {
    return 'Sent $date';
  }

  @override
  String clientsShownOn(String date) {
    return 'Shown $date';
  }

  @override
  String get clientsSourceImport => 'Imported';

  @override
  String get clientsSourceOpenHouse => 'From an open house';

  @override
  String get clientsSourcePublicLink => 'From the public link';

  @override
  String get clientsTagAdd => 'Add tag';

  @override
  String get clientsTagAddHint => 'Add a tag';

  @override
  String get clientsTagFilterClear => 'Clear tags';

  @override
  String get clientsTagFilterDone => 'Show clients';

  @override
  String get clientsTagFilterEmpty =>
      'No client has a tag yet. Add tags on the client form.';

  @override
  String get clientsTagFilterSubtitle => 'Clients carrying every tag you pick';

  @override
  String get clientsTagFilterTitle => 'Filter by tags';

  @override
  String clientsTagLimit(Object count) {
    return 'Up to $count tags per client';
  }

  @override
  String clientsTagRemove(Object tag) {
    return 'Remove tag $tag';
  }

  @override
  String get clientsTagSuggestions => 'Already used in the agency';

  @override
  String clientsTagTooLong(Object count) {
    return 'A tag can be at most $count characters';
  }

  @override
  String get clientsTags => 'Tags';

  @override
  String get clientsTagsHint =>
      'Short labels to find a client by later: investor, urgent, VIP.';

  @override
  String clientsTagsMore(Object count) {
    return '+$count';
  }

  @override
  String get clientsLeadSource => 'Where they came from';

  @override
  String get clientsLeadSourceNone => 'Not recorded';

  @override
  String get clientsLeadSourceReferral => 'Referral';

  @override
  String get clientsLeadSourceWebsite => 'Website';

  @override
  String get clientsLeadSourcePortal => 'Listings portal';

  @override
  String get clientsLeadSourceSocial => 'Social media';

  @override
  String get clientsLeadSourceWalkIn => 'Walk-in';

  @override
  String get clientsLeadSourceColdCall => 'Cold call';

  @override
  String get clientsLeadSourceRepeat => 'Repeat client';

  @override
  String get clientsLeadSourceOther => 'Other';

  @override
  String get clientsLeadSourceDetail => 'Details';

  @override
  String get clientsLeadSourceDetailHint => 'Who referred them, which portal';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsTryDifferentSearch => 'Try a different search';

  @override
  String get clientsUpdateClient => 'Update Client';

  @override
  String clientsUpdatedAt(Object date) {
    return 'Updated $date';
  }

  @override
  String get clientsWantedCity => 'City';

  @override
  String get clientsWantedType => 'Property type';

  @override
  String get clientsWrite => 'WhatsApp or SMS';

  @override
  String get compareAction => 'Compare';

  @override
  String get compareAdd => 'Add to comparison';

  @override
  String get compareAdded => 'Added to comparison';

  @override
  String compareBarButton(int count) {
    return 'Compare ($count)';
  }

  @override
  String get compareBestLegend => 'Green marks the best value in a row';

  @override
  String compareDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'Listed today',
    );
    return '$_temp0';
  }

  @override
  String get compareExit => 'Done';

  @override
  String get compareFirstFloor => 'first floor';

  @override
  String get compareFitMatches => 'Fits requirements';

  @override
  String get compareFitOutside => 'Outside requirements';

  @override
  String get compareFitOverBudget => 'Over budget';

  @override
  String get compareLastFloor => 'last floor';

  @override
  String get compareLimit =>
      'Up to 4 listings side by side. Remove one to add another.';

  @override
  String get compareLinks => 'Include links';

  @override
  String get compareLinksHint =>
      'A page per listing with all its photos, added under each one.';

  @override
  String get compareNeedTwo => 'Pick two listings to compare';

  @override
  String get compareNeedTwoHint =>
      'Choose Compare on the Properties tab, or add listings from their pages.';

  @override
  String get comparePickHint => 'Pick two to four listings';

  @override
  String get compareRemove => 'Remove from comparison';

  @override
  String get compareRemoved => 'Removed from comparison';

  @override
  String get compareRowAgent => 'Agent';

  @override
  String get compareRowArea => 'Area';

  @override
  String get compareRowDays => 'On the market';

  @override
  String get compareRowFit => 'For this buyer';

  @override
  String get compareRowFloor => 'Floor';

  @override
  String get compareRowLinkViews => 'Link views';

  @override
  String get compareRowPlace => 'Address';

  @override
  String get compareRowPrice => 'Price';

  @override
  String get compareRowPriceChange => 'Last price change';

  @override
  String get compareRowPricePerSqm => 'Price per m²';

  @override
  String get compareRowRooms => 'Rooms';

  @override
  String get compareRowType => 'Type';

  @override
  String get compareSelected => 'Compare selected';

  @override
  String get compareSend => 'Send comparison';

  @override
  String get compareSendFailed => 'Could not open sending';

  @override
  String compareShareBest(String title) {
    return 'Best price per m²: $title';
  }

  @override
  String get compareShareIntro => 'Here is how the listings compare:';

  @override
  String get compareTitle => 'Comparison';

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
  String get coreErrorBadRequest => 'Invalid request. Please check your input.';

  @override
  String get coreErrorConflict => 'This already exists.';

  @override
  String get coreErrorCredentials => 'Invalid email or password.';

  @override
  String get coreErrorForbidden => 'You don’t have permission to do that.';

  @override
  String get coreErrorNotFound => 'Not found.';

  @override
  String get coreErrorOffline =>
      'Cannot connect to server. Check your internet.';

  @override
  String get coreErrorOfflineWrite =>
      'You’re offline — this needs a connection.';

  @override
  String get coreErrorServer => 'Server error. Please try again later.';

  @override
  String get coreErrorTimeout => 'Connection timed out. Check your internet.';

  @override
  String get coreErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get coreLogout => 'Logout';

  @override
  String get coreNavAdmin => 'Admin';

  @override
  String get coreNavCalendar => 'Calendar';

  @override
  String get coreNavClients => 'Clients';

  @override
  String get coreNavDashboard => 'Home';

  @override
  String get coreNavDeals => 'Deals';

  @override
  String get coreNavProperties => 'Listings';

  @override
  String get coreNavTeam => 'Team';

  @override
  String get coreNoResults => 'Nothing found';

  @override
  String get coreNotSelected => 'Not selected';

  @override
  String coreOfflineSince(String time) {
    return 'Offline — showing data from $time';
  }

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
  String get dashboardActiveDealsLabel => 'Active deals';

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
  String dashboardColdTotal(int count) {
    return '$count in all';
  }

  @override
  String get dashboardConversion => 'Conversion';

  @override
  String dashboardDateSummary(Object date) {
    return '$date · team overview';
  }

  @override
  String get dashboardDatesTitle => 'Dates this week';

  @override
  String dashboardDatesTotal(int count) {
    return '$count this week';
  }

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
  String dashboardMandatesTotal(int count) {
    return '$count in all';
  }

  @override
  String get dashboardMeetingLoad => 'Next two weeks';

  @override
  String get dashboardMeetingsLabel => 'Meetings';

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
  String get dashboardTasksClear => 'Nothing due today';

  @override
  String dashboardTasksOverdueCount(Object count) {
    return '$count overdue';
  }

  @override
  String get dashboardTasksToday => 'To do today';

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
  String get dashboardUpcomingMeetings => 'Upcoming Meetings';

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
  String dealsBoardColumnMeta(Object count, Object total) {
    return '$count · $total';
  }

  @override
  String get dealsBoardDragHint => 'Hold a card to move it to another stage';

  @override
  String get dealsBoardStageEmpty => 'Nothing at this stage';

  @override
  String get dealsBudget => 'Budget';

  @override
  String dealsBudgetValue(Object price) {
    return 'Budget: $price';
  }

  @override
  String get dealsChecklistAdd => 'Add item';

  @override
  String get dealsChecklistAddTitle => 'New checklist item';

  @override
  String get dealsChecklistAttach => 'Attach document';

  @override
  String dealsChecklistBadge(int done, int total) {
    return 'Checklist: $done of $total done';
  }

  @override
  String get dealsChecklistDelete => 'Delete item';

  @override
  String get dealsChecklistDeleteBody =>
      'It disappears from this deal\'s checklist.';

  @override
  String get dealsChecklistDeleteTitle => 'Delete this item?';

  @override
  String get dealsChecklistDetach => 'Remove document';

  @override
  String dealsChecklistDoneAt(String date) {
    return 'Done $date';
  }

  @override
  String dealsChecklistDoneBy(String date, String name) {
    return '$name · $date';
  }

  @override
  String get dealsChecklistEmptyStage => 'Nothing to collect at this stage';

  @override
  String dealsChecklistGateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count required items are not done yet. Move the deal anyway?',
      one: '1 required item is not done yet. Move the deal anyway?',
    );
    return '$_temp0';
  }

  @override
  String get dealsChecklistGateConfirm => 'Move anyway';

  @override
  String get dealsChecklistGateTitle => 'Required items are open';

  @override
  String get dealsChecklistItemHint => 'For example, a copy of the passport';

  @override
  String get dealsChecklistItemLabel => 'What is needed';

  @override
  String get dealsChecklistLoadFailed => 'Could not load the checklist';

  @override
  String get dealsChecklistMore => 'Item actions';

  @override
  String get dealsChecklistNoDocuments =>
      'This deal has no documents yet. Upload the file under Documents first.';

  @override
  String get dealsChecklistPickDocument => 'Choose a document';

  @override
  String dealsChecklistProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get dealsChecklistRequired => 'Required';

  @override
  String get dealsChecklistRequiredHint =>
      'The app warns before a deal moves on without it';

  @override
  String get dealsChecklistStage => 'Stage';

  @override
  String get dealsChecklistTitle => 'Checklist';

  @override
  String get dealsClient => 'Client';

  @override
  String dealsClientRef(Object id) {
    return 'Client #$id';
  }

  @override
  String dealsCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get dealsCommentDelete => 'Delete comment';

  @override
  String get dealsCommentDeleteBody =>
      'It disappears for everyone on this deal.';

  @override
  String get dealsCommentDeleteTitle => 'Delete this comment?';

  @override
  String get dealsCommentEdit => 'Edit comment';

  @override
  String get dealsCommentEdited => 'edited';

  @override
  String get dealsCommentHint => 'Write a comment…';

  @override
  String get dealsCommentJustNow => 'just now';

  @override
  String get dealsCommentLess => 'Show less';

  @override
  String get dealsCommentMentionLoadFailed => 'Couldn\'t load colleagues';

  @override
  String get dealsCommentMentionNone => 'Nobody else can see this deal';

  @override
  String get dealsCommentMentionNotAllowed =>
      'Only colleagues who can see this deal can be mentioned';

  @override
  String get dealsCommentMentionTitle => 'Mention a colleague';

  @override
  String get dealsCommentMore => 'Show more';

  @override
  String get dealsCommentSend => 'Send';

  @override
  String get dealsCommentSending => 'Sending…';

  @override
  String get dealsCommission => 'Commission';

  @override
  String get dealsCommissionAmount => 'Amount';

  @override
  String get dealsCommissionInvalid =>
      'Enter a rate above 0 and no more than 100';

  @override
  String get dealsCommissionNeedsPrice => 'Set a deal price to work it out';

  @override
  String get dealsCommissionPercent => 'Commission, %';

  @override
  String get dealsCommissionRate => 'Rate';

  @override
  String dealsCounter(Object active, Object total) {
    return '$active active · $total';
  }

  @override
  String get dealsCreateDeal => 'Create Deal';

  @override
  String get dealsDealPrice => 'Deal Price';

  @override
  String dealsDeleteCascade(Object title) {
    return '$title will be deleted permanently. This cannot be undone.';
  }

  @override
  String get dealsDeleteTitle => 'Delete Deal';

  @override
  String get dealsDiscussion => 'Discussion';

  @override
  String get dealsDiscussionEmpty => 'No comments yet';

  @override
  String get dealsDiscussionEmptyHint =>
      'Keep the conversation about this deal here. Type @ to bring in a colleague.';

  @override
  String get dealsDiscussionLoadFailed => 'Couldn\'t load the discussion';

  @override
  String get dealsDiscussionShowEarlier => 'Show earlier';

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
  String get dealsLostConfirm => 'Mark as lost';

  @override
  String get dealsLostNote => 'Note';

  @override
  String get dealsLostNoteHint => 'What happened, if it helps next time';

  @override
  String get dealsLostReason => 'Why it was lost';

  @override
  String get dealsLostReasonChangedMind => 'Changed their mind';

  @override
  String get dealsLostReasonChoseAnother => 'Chose another option';

  @override
  String get dealsLostReasonFinancing => 'Financing fell through';

  @override
  String get dealsLostReasonNoResponse => 'Stopped responding';

  @override
  String get dealsLostReasonOther => 'Other';

  @override
  String get dealsLostReasonPrice => 'Price';

  @override
  String get dealsLostReasonUnspecified => 'Not specified';

  @override
  String get dealsLostSheetSubtitle =>
      'Pick a reason. It feeds the funnel in Analytics.';

  @override
  String get dealsLostSheetTitle => 'Why was the deal lost?';

  @override
  String get dealsNewTitle => 'New Deal';

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
  String get dealsTitleLabel => 'Title';

  @override
  String get dealsTitleRequired => 'Title is required';

  @override
  String get dealsUpdateDeal => 'Update Deal';

  @override
  String get dealsViewBoard => 'Board';

  @override
  String get dealsViewList => 'List';

  @override
  String get depositsAmount => 'Amount';

  @override
  String get depositsAmountHint => 'e.g. 500,000';

  @override
  String get depositsCloseAction => 'End deposit';

  @override
  String get depositsCloseTitle => 'How did the deposit end?';

  @override
  String get depositsClosedBeforeReceived =>
      'It cannot end before the money came in';

  @override
  String get depositsClosedOn => 'Date';

  @override
  String get depositsDealClosedHint =>
      'The deal is closed; a deposit can no longer be recorded.';

  @override
  String get depositsEdit => 'Edit';

  @override
  String get depositsEditTitle => 'Edit the deposit';

  @override
  String get depositsEndingEmpty => 'No deposits running out';

  @override
  String get depositsEndingEmptyHint =>
      'Active deposits show here a week before their hold ends.';

  @override
  String get depositsEndingLoadFailed => 'Couldn\'t load the deposits';

  @override
  String get depositsEndingTitle => 'Deposits ending';

  @override
  String get depositsHistory => 'Earlier deposits';

  @override
  String get depositsHoldBeforeReceived =>
      'The hold cannot end before the money came in';

  @override
  String depositsHoldEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hold ended $count days ago',
      one: 'Hold ended 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndedYesterday => 'Hold ended yesterday';

  @override
  String depositsHoldEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hold ends in $count days',
      one: 'Hold ends in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get depositsHoldEndsToday => 'Hold ends today';

  @override
  String get depositsHoldEndsTomorrow => 'Hold ends tomorrow';

  @override
  String get depositsHoldUntil => 'Held until';

  @override
  String get depositsHolder => 'Held by';

  @override
  String get depositsHolderAgency => 'Agency';

  @override
  String get depositsHolderNotary => 'Notary';

  @override
  String get depositsHolderSeller => 'Seller';

  @override
  String get depositsLoadFailed => 'Couldn\'t load the deposit';

  @override
  String get depositsNone => 'No deposit recorded';

  @override
  String get depositsNoneHint =>
      'Record it when the buyer puts money down; the listing then shows as reserved.';

  @override
  String get depositsNote => 'Note';

  @override
  String get depositsNoteHint => 'Receipt number, terms';

  @override
  String get depositsOutcomeApplied => 'Applied to the purchase';

  @override
  String get depositsOutcomeForfeited => 'Forfeited';

  @override
  String get depositsOutcomeRefunded => 'Refunded';

  @override
  String get depositsReceivedOn => 'Received';

  @override
  String get depositsRecord => 'Record deposit';

  @override
  String get depositsRecordTitle => 'Record a deposit';

  @override
  String depositsReservedUntil(String date) {
    return 'Reserved until $date';
  }

  @override
  String get depositsTitle => 'Deposit';

  @override
  String get documentsAdd => 'Attach file';

  @override
  String documentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
      zero: 'No files',
    );
    return '$_temp0';
  }

  @override
  String documentsDeleteConfirm(Object name) {
    return '$name will be removed from this deal. This cannot be undone.';
  }

  @override
  String get documentsDeleteTitle => 'Remove document';

  @override
  String get documentsEmpty => 'No files attached to this deal yet';

  @override
  String get documentsNoApp => 'No app on this phone can open this file';

  @override
  String get documentsOpenFailed => 'This file could not be opened';

  @override
  String documentsSizeBytes(Object size) {
    return '$size B';
  }

  @override
  String documentsSizeKb(Object size) {
    return '$size KB';
  }

  @override
  String documentsSizeMb(Object size) {
    return '$size MB';
  }

  @override
  String get documentsTitle => 'Documents';

  @override
  String documentsTooLarge(Object limit) {
    return 'Files larger than $limit MB cannot be attached';
  }

  @override
  String documentsUploadedBy(Object name) {
    return 'Added by $name';
  }

  @override
  String get documentsUploading => 'Sending…';

  @override
  String get exportAction => 'Export';

  @override
  String get exportAllNote => 'Everything you can see, without filters.';

  @override
  String get exportConfirm => 'Export CSV';

  @override
  String get exportConsoleSubtitle =>
      'Your agency\'s book as spreadsheets: for the owner, the accountant, or a copy of your own.';

  @override
  String get exportConsoleTitle => 'Export';

  @override
  String get exportDelimiter => 'Separator';

  @override
  String get exportDelimiterComma => 'Comma';

  @override
  String get exportDelimiterHint =>
      'Excel in Russian or Kazakh splits columns on semicolons; in English, on commas.';

  @override
  String get exportDelimiterSemicolon => 'Semicolon';

  @override
  String get exportFailed => 'Couldn\'t export. Try again.';

  @override
  String get exportFiltersNote =>
      'Only what the list shows now, with its filters.';

  @override
  String get exportFormatNote =>
      'A CSV file that opens in Excel, Google Sheets and Numbers, and imports back into the CRM as it is.';

  @override
  String get exportKindClients => 'Clients';

  @override
  String get exportKindDeals => 'Deals';

  @override
  String get exportKindProperties => 'Listings';

  @override
  String get exportPersonalData =>
      'Includes personal data: names, phones and emails. Handle with care and share it no further than needed.';

  @override
  String get exportTitleClients => 'Export clients';

  @override
  String get exportTitleDeals => 'Export deals';

  @override
  String get exportTitleProperties => 'Export listings';

  @override
  String get exportTooMany =>
      'Too many rows for one file. Narrow the filters and export in parts.';

  @override
  String get goalsAgency => 'Whole agency';

  @override
  String get goalsAgentOwn => 'Agent\'s own target';

  @override
  String get goalsCardTitle => 'This month\'s target';

  @override
  String get goalsCommissionLabel => 'Commission';

  @override
  String goalsCommissionOf(String achieved, String target) {
    return '$achieved of $target';
  }

  @override
  String goalsCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count targets copied',
      one: '1 target copied',
      zero: 'Nothing to copy from last month',
    );
    return '$_temp0';
  }

  @override
  String get goalsCopyPrevious => 'Copy last month\'s targets';

  @override
  String goalsDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'The month is over',
    );
    return '$_temp0';
  }

  @override
  String goalsDealEvery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a deal every $count days',
    );
    return '$_temp0';
  }

  @override
  String get goalsDealsLabel => 'Deals won';

  @override
  String goalsDealsOf(int won, int target) {
    return '$won of $target deals won';
  }

  @override
  String goalsDealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals a day',
      one: '1 deal a day',
    );
    return '$_temp0';
  }

  @override
  String goalsDealsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals won',
      one: '1 deal won',
      zero: 'No deals won yet',
    );
    return '$_temp0';
  }

  @override
  String get goalsEyebrow => 'TARGET';

  @override
  String get goalsFieldHint => 'Leave empty for none';

  @override
  String get goalsInvalidCommission => 'Enter an amount above zero';

  @override
  String get goalsInvalidDeals => 'Enter a whole number from 1 to 1000';

  @override
  String get goalsLoadFailed => 'Could not load the targets';

  @override
  String get goalsManagerSet => 'Set by your manager';

  @override
  String get goalsMonthOver =>
      'This month is over. Its targets stay as they were.';

  @override
  String get goalsNeedOne => 'Enter a commission, a number of deals, or both';

  @override
  String get goalsNextMonth => 'Next month';

  @override
  String get goalsNoTarget => 'No target';

  @override
  String get goalsNone => 'No target for this month yet';

  @override
  String get goalsNoneHint =>
      'Tap to set your own. If your manager sets one, theirs counts.';

  @override
  String get goalsOwn => 'Your own target';

  @override
  String goalsPerDay(String amount) {
    return '$amount a day';
  }

  @override
  String get goalsPreviousMonth => 'Previous month';

  @override
  String get goalsReached =>
      'Target reached. Everything from here is ahead of plan.';

  @override
  String get goalsRemove => 'Remove target';

  @override
  String get goalsRemoved => 'Target removed';

  @override
  String get goalsSaved => 'Target saved';

  @override
  String goalsSheetFor(String name) {
    return 'Target for $name';
  }

  @override
  String get goalsSheetHint =>
      'Deals won this month count, with the commission on each.';

  @override
  String get goalsSheetOwnHint =>
      'If your manager sets a target for you, theirs takes the place of yours.';

  @override
  String get goalsSheetTitle => 'Monthly target';

  @override
  String get goalsTeamEmpty => 'No one in the agency yet';

  @override
  String get goalsTeamHint => 'Targets for each agent and the agency';

  @override
  String get goalsTeamIntro =>
      'A target for each agent and for the whole agency. Progress counts the deals won in the month and the commission on them. Your target replaces one an agent set for themselves.';

  @override
  String get goalsTeamOverrideHint =>
      'Your target replaces one the agent set for themselves.';

  @override
  String get goalsTeamTitle => 'Monthly goals';

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count rows',
      one: 'Import 1 row',
    );
    return '$_temp0';
  }

  @override
  String get importAnother => 'Import another file';

  @override
  String get importAssignTo => 'Assign to';

  @override
  String get importAssignToMe => 'Me';

  @override
  String get importChooseFile => 'Choose a CSV file';

  @override
  String get importColumns => 'Columns';

  @override
  String get importColumnsHint =>
      'Check which field each column fills. Columns set to Skip are left out.';

  @override
  String get importCreated => 'Created';

  @override
  String get importDoneTitle => 'Import finished';

  @override
  String get importDownloadTemplate => 'Download template';

  @override
  String importDuplicateOfClient(String name) {
    return 'Already in the agency: $name';
  }

  @override
  String importDuplicateOfRow(int row) {
    return 'Same as row $row';
  }

  @override
  String get importEmptyFile => 'The file is empty';

  @override
  String get importEntrySubtitle =>
      'Clients and listings from Excel or another CRM';

  @override
  String get importErrorInvalidDate => 'Not a date';

  @override
  String get importErrorInvalidEmail => 'Not an email address';

  @override
  String get importErrorInvalidNumber => 'Not a number';

  @override
  String get importErrorInvalidPhone => 'Not a phone number';

  @override
  String get importErrorNegative => 'Must be above zero';

  @override
  String get importErrorOutOfRange => 'Out of range';

  @override
  String get importErrorRequired => 'Required';

  @override
  String get importErrorTooLong => 'Too long';

  @override
  String get importErrorUnknownValue => 'Unknown value';

  @override
  String get importFieldAddress => 'Address';

  @override
  String get importFieldArea => 'Area';

  @override
  String get importFieldBirthday => 'Birthday';

  @override
  String get importFieldBudgetMax => 'Budget to';

  @override
  String get importFieldBudgetMin => 'Budget from';

  @override
  String get importFieldCity => 'City';

  @override
  String get importFieldClientType => 'Client type';

  @override
  String get importFieldDescription => 'Description';

  @override
  String get importFieldEmail => 'Email';

  @override
  String get importFieldFloor => 'Floor';

  @override
  String get importFieldFullName => 'Full name';

  @override
  String get importFieldMinArea => 'Area from';

  @override
  String get importFieldMinRooms => 'Rooms from';

  @override
  String get importFieldNotes => 'Notes';

  @override
  String get importFieldPhone => 'Phone';

  @override
  String get importFieldPrice => 'Price';

  @override
  String get importFieldPropertyType => 'Property type';

  @override
  String get importFieldRooms => 'Rooms';

  @override
  String get importFieldStatus => 'Status';

  @override
  String get importFieldTags => 'Tags';

  @override
  String get importFieldLeadSource => 'Lead source';

  @override
  String get importFieldLeadSourceDetail => 'Lead source detail';

  @override
  String get importFieldTitle => 'Title';

  @override
  String get importFieldTotalFloors => 'Total floors';

  @override
  String get importFieldWantedCity => 'Wanted city';

  @override
  String get importFieldWantedType => 'Wanted property type';

  @override
  String get importFileTooLarge =>
      'The file is larger than 5 MB. Split it into parts.';

  @override
  String get importHowTo =>
      'Save the sheet as CSV in Excel or Google Sheets. Commas, semicolons and tabs all work, and so do Cyrillic files from a Russian Excel.';

  @override
  String get importInvalid => 'Not imported, errors';

  @override
  String get importKindClients => 'Clients';

  @override
  String get importKindClientsHint =>
      'Names, phones, what they are looking for';

  @override
  String get importKindProperties => 'Listings';

  @override
  String get importKindPropertiesHint => 'Addresses, prices, areas, rooms';

  @override
  String importMissingRequired(String field) {
    return 'Choose a column for $field';
  }

  @override
  String get importNoAgents => 'No colleagues found';

  @override
  String get importNoProblems => 'Every row is ready to import';

  @override
  String get importNotCsv =>
      'Choose a .csv file. In Excel: File, Save as, CSV.';

  @override
  String get importNothingToImport => 'Nothing to import';

  @override
  String get importOpenClients => 'Open clients';

  @override
  String get importOpenProperties => 'Open listings';

  @override
  String get importOptions => 'Options';

  @override
  String get importPickAgentSearch => 'Search by name';

  @override
  String get importProblems => 'Rows that need attention';

  @override
  String get importProblemsTruncated => 'Only the first 1000 are listed';

  @override
  String importRowLabel(int row) {
    return 'Row $row';
  }

  @override
  String importRowsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows in the file',
      one: '1 row in the file',
    );
    return '$_temp0';
  }

  @override
  String get importShowMore => 'Show more';

  @override
  String get importSkipColumn => 'Skip';

  @override
  String get importSkipDuplicates => 'Skip duplicates';

  @override
  String get importSkipDuplicatesHint =>
      'A client whose email is already in the agency is always skipped';

  @override
  String get importSkipped => 'Skipped duplicates';

  @override
  String get importSummaryDuplicates => 'Duplicates';

  @override
  String get importSummaryInvalid => 'With errors';

  @override
  String get importSummaryValid => 'Ready';

  @override
  String get importTemplateFailed => 'Could not prepare the template';

  @override
  String get importTitle => 'Import from a spreadsheet';

  @override
  String get importTooManyRows =>
      'The file has more than 5000 rows. Split it into parts.';

  @override
  String get leaderboardDealsLost => 'Deals lost';

  @override
  String get leaderboardEmptyBody =>
      'Agents who join the agency will be ranked here.';

  @override
  String get leaderboardEmptyTitle => 'No agents yet';

  @override
  String get leaderboardHint =>
      'Deals, commission and viewings, agent by agent';

  @override
  String get leaderboardInactive => 'Deactivated';

  @override
  String get leaderboardInactiveNote =>
      'Deactivated members are not ranked with the team. Anyone removed from the agency is not listed: their records moved to a colleague.';

  @override
  String get leaderboardLoadFailed => 'Could not load the leaderboard';

  @override
  String get leaderboardNoValue => '—';

  @override
  String get leaderboardPeriodCustom => 'Dates';

  @override
  String get leaderboardPeriodLastMonth => 'Last month';

  @override
  String get leaderboardPeriodQuarter => 'Quarter';

  @override
  String get leaderboardPeriodThisMonth => 'This month';

  @override
  String get leaderboardPickRange => 'Choose dates';

  @override
  String leaderboardRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get leaderboardSortCommission => 'Commission';

  @override
  String get leaderboardSortDealsWon => 'Deals won';

  @override
  String get leaderboardSortNewClients => 'New clients';

  @override
  String get leaderboardSortViewings => 'Viewings';

  @override
  String get leaderboardSortWinRate => 'Win rate';

  @override
  String leaderboardSummary(int won, int viewings, int clients) {
    return 'Won $won · Viewings $viewings · Clients $clients';
  }

  @override
  String get leaderboardTeamCommission => 'Agency commission';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardWonValue => 'Won value';

  @override
  String get lockAppLock => 'App lock';

  @override
  String get lockAppLockHint => 'Ask for a PIN to open the app';

  @override
  String get lockAutoLock => 'Lock after';

  @override
  String get lockAutoLockFifteenMinutes => '15 minutes in the background';

  @override
  String get lockAutoLockFiveMinutes => '5 minutes in the background';

  @override
  String get lockAutoLockImmediately => 'Immediately';

  @override
  String get lockAutoLockOneMinute => '1 minute in the background';

  @override
  String get lockAutoLockTitle => 'When to lock the app';

  @override
  String get lockCancel => 'Cancel';

  @override
  String get lockChangePin => 'Change PIN';

  @override
  String get lockConfirmPinTitle => 'Enter the PIN again';

  @override
  String get lockContinue => 'Continue';

  @override
  String get lockCurrentPinTitle => 'Enter your current PIN';

  @override
  String get lockDelete => 'Delete';

  @override
  String get lockDigitsHint => '4 to 6 digits';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockForgotPin => 'Forgot PIN?';

  @override
  String get lockForgotPinBody =>
      'Signing out removes the PIN and the client data saved on this phone. Then sign in again with your password.';

  @override
  String get lockMismatch => 'The PINs do not match. Try again.';

  @override
  String get lockNewPinTitle => 'Choose a PIN';

  @override
  String get lockPinChanged => 'PIN changed';

  @override
  String lockRetryIn(String time) {
    return 'Too many attempts. Try again in $time';
  }

  @override
  String get lockSecurity => 'Security';

  @override
  String get lockSignOutAgain => 'Sign out and sign in again';

  @override
  String get lockTooManyAttempts =>
      'Too many wrong PINs. Sign out and sign in again with your password.';

  @override
  String get lockTooShort => 'The PIN needs 4 to 6 digits.';

  @override
  String get lockTurnOn => 'Turn on';

  @override
  String get lockTurnedOff => 'App lock is off';

  @override
  String get lockTurnedOn => 'App lock is on';

  @override
  String get lockWrongPin => 'Wrong PIN';

  @override
  String get meetingsAgendaHint => 'Meeting agenda, talking points…';

  @override
  String get meetingsAgent => 'Agent';

  @override
  String meetingsAgentNumber(Object id) {
    return 'Agent #$id';
  }

  @override
  String get meetingsClient => 'Client';

  @override
  String meetingsClientNumber(Object id) {
    return 'Client #$id';
  }

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
  String get meetingsLocation => 'Location';

  @override
  String get meetingsMustBeInFuture => 'Pick a time in the future';

  @override
  String get meetingsNoAgentsToAssign => 'No agents to assign';

  @override
  String get meetingsNoLocation => 'No location on this meeting';

  @override
  String get meetingsNoMeetings => 'No meetings';

  @override
  String get meetingsNote => 'Meeting note';

  @override
  String get meetingsNothingUpcoming => 'Nothing upcoming';

  @override
  String get meetingsNothingUpcomingSubtitle =>
      'Past meetings stay in your history.';

  @override
  String get meetingsOutcome => 'How it went';

  @override
  String get meetingsOutcomeInterested => 'Interested';

  @override
  String get meetingsOutcomeNoShow => 'No show';

  @override
  String get meetingsOutcomeNote => 'What they said';

  @override
  String get meetingsOutcomeNoteHint => 'Too dark, the road is loud…';

  @override
  String get meetingsOutcomeRejected => 'Turned it down';

  @override
  String get meetingsOutcomeRejectedHint =>
      'A listing turned down stops being offered to this buyer';

  @override
  String get meetingsOutcomeSave => 'Save';

  @override
  String get meetingsPleaseSelectAgent => 'Please select an agent';

  @override
  String get meetingsPleaseSelectClient => 'Please select a client';

  @override
  String get meetingsPleaseSelectDateTime => 'Please select a date and time';

  @override
  String get meetingsProperty => 'Listing';

  @override
  String get meetingsSchedule => 'Schedule';

  @override
  String get meetingsScheduleFirst => 'Schedule your first meeting';

  @override
  String get meetingsScheduleMeeting => 'Schedule Meeting';

  @override
  String get meetingsScheduleViewing => 'Schedule a viewing';

  @override
  String get meetingsSearchByNameOrId => 'Search by name or ID…';

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
  String get meetingsTime => 'Time';

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get meetingsTitleFieldLabel => 'Title';

  @override
  String get meetingsTitleRequired => 'Title is required';

  @override
  String get meetingsUpcomingEyebrow => 'Next up';

  @override
  String get meetingsUpdateMeeting => 'Update Meeting';

  @override
  String get meetingsViewingOf => 'Viewing';

  @override
  String get meetingsWhen => 'When';

  @override
  String get meetingsWhoAndWhere => 'Who & where';

  @override
  String get mortgageAmortisation => 'Payment schedule';

  @override
  String get mortgageAnnuity => 'Annuity';

  @override
  String get mortgageDifferentiated => 'Differentiated';

  @override
  String get mortgageDownPayment => 'Down payment';

  @override
  String mortgageDownSummary(String percent, String rate, String term) {
    return '$percent% down · $rate% · $term';
  }

  @override
  String get mortgageFees => 'One-off fees';

  @override
  String get mortgageFeesHint => 'Appraisal, insurance, bank fee';

  @override
  String mortgageFromPerMonth(String amount) {
    return 'from $amount / month';
  }

  @override
  String mortgageIncomeHint(String percent) {
    return 'Keeps the payment within $percent% of income';
  }

  @override
  String get mortgageIncomeNeeded => 'Income needed';

  @override
  String get mortgageInterest => 'Interest';

  @override
  String get mortgageLoan => 'Loan';

  @override
  String mortgageMonthLabel(int number) {
    return 'Month $number';
  }

  @override
  String get mortgageMonthly => 'Monthly payment';

  @override
  String get mortgageMonthlyRange => 'First month → last month';

  @override
  String get mortgageNoLoan =>
      'The down payment covers the price, so there is nothing to borrow.';

  @override
  String get mortgageOpenCalculator => 'Open calculator';

  @override
  String get mortgageOverpayment => 'Overpayment';

  @override
  String get mortgagePresetHousingSavings => 'Housing savings';

  @override
  String get mortgagePresetMarket => 'Market rate';

  @override
  String get mortgagePresetStateProgram => '7-20-25 programme';

  @override
  String get mortgagePresetsNote =>
      'Typical rates, not bank offers. Rates change, so check with the bank.';

  @override
  String get mortgagePrice => 'Price';

  @override
  String get mortgagePrincipal => 'Principal';

  @override
  String mortgageRangePerMonth(String first, String last) {
    return '$first → $last / month';
  }

  @override
  String get mortgageRate => 'Annual rate, %';

  @override
  String get mortgageSend => 'Send to client';

  @override
  String get mortgageShareDisclaimer => 'Indicative estimate, not an offer.';

  @override
  String mortgageShareDown(String amount, String percent) {
    return 'Down payment: $amount ($percent%)';
  }

  @override
  String get mortgageShareFailed => 'Couldn\'t share the estimate';

  @override
  String get mortgageShareHeading => 'Mortgage estimate';

  @override
  String mortgageShareMonthly(String amount) {
    return 'Monthly payment: $amount';
  }

  @override
  String mortgageShareMonthlyRange(String first, String last) {
    return 'Monthly payment: $first in the first month, $last in the last';
  }

  @override
  String mortgageShareOverpayment(String amount) {
    return 'Total overpayment: $amount';
  }

  @override
  String mortgageSharePrice(String amount) {
    return 'Price: $amount';
  }

  @override
  String mortgageShareRate(String rate) {
    return 'Rate: $rate% a year';
  }

  @override
  String mortgageShareTerm(String term) {
    return 'Term: $term';
  }

  @override
  String get mortgageTerm => 'Term';

  @override
  String mortgageTermYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0';
  }

  @override
  String get mortgageTitle => 'Mortgage';

  @override
  String get mortgageTotalRepaid => 'Total repaid';

  @override
  String get mortgageType => 'Payment type';

  @override
  String mortgageYearLabel(int number) {
    return 'Year $number';
  }

  @override
  String get msgAgentInvited => 'Agent invited';

  @override
  String get msgChecklistSaved => 'Checklist saved';

  @override
  String get msgClientCreated => 'Client created';

  @override
  String get msgClientDeleted => 'Client deleted';

  @override
  String get msgClientUpdated => 'Client updated';

  @override
  String get msgClientsMerged => 'Cards merged';

  @override
  String get msgCodeSent => 'Code sent';

  @override
  String get msgCommentDeleted => 'Comment deleted';

  @override
  String get msgCommentUpdated => 'Comment updated';

  @override
  String get msgCurrencyChanged => 'Currency changed';

  @override
  String get msgDealCreated => 'Deal created';

  @override
  String get msgDealDeleted => 'Deal deleted';

  @override
  String get msgDealUpdated => 'Deal updated';

  @override
  String get msgDocumentDeleted => 'Document removed';

  @override
  String get msgDocumentUploaded => 'Document attached';

  @override
  String get msgInviteResent => 'Invite resent';

  @override
  String get msgMeetingCompleted => 'Meeting completed';

  @override
  String get msgMeetingCreated => 'Meeting created';

  @override
  String get msgMeetingDeleted => 'Meeting deleted';

  @override
  String get msgMeetingUpdated => 'Meeting updated';

  @override
  String get msgMemberRemoved => 'Agent removed from the team';

  @override
  String get msgNotificationsAllRead => 'All caught up';

  @override
  String get msgProfileUpdated => 'Profile updated';

  @override
  String get msgPropertyCreated => 'Property created';

  @override
  String get msgPropertyDeleted => 'Property deleted';

  @override
  String get msgPropertyUpdated => 'Property updated';

  @override
  String get msgRequestCancelled => 'Request withdrawn';

  @override
  String get msgRequestDeclined => 'Request declined';

  @override
  String get msgRequestSent => 'Request sent';

  @override
  String get msgRoleUpdated => 'Role updated';

  @override
  String get msgStatusUpdated => 'Status updated';

  @override
  String get msgTaskCompleted => 'Task done';

  @override
  String get msgTaskCreated => 'Task added';

  @override
  String get msgTaskDeleted => 'Task deleted';

  @override
  String get msgTaskReopened => 'Task reopened';

  @override
  String get msgTaskRepeatStopped => 'The task no longer repeats';

  @override
  String get msgTaskUpdated => 'Task updated';

  @override
  String get msgTeamAssigned => 'Team assigned';

  @override
  String get msgTeamCreated => 'Team created';

  @override
  String get msgTeamJoined => 'You have joined the team';

  @override
  String get msgTeamLeft => 'You have left the team';

  @override
  String get msgTeamUpdated => 'Team updated';

  @override
  String get msgTemplateDeleted => 'Template deleted';

  @override
  String get msgTemplateSaved => 'Template saved';

  @override
  String get msgUserActivated => 'User activated';

  @override
  String get msgUserDeactivated => 'User deactivated';

  @override
  String get msgUserDeleted => 'User deleted';

  @override
  String notificationsClientBirthday(String name) {
    return 'It\'s $name\'s birthday today';
  }

  @override
  String notificationsCountClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients',
      one: '1 client',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountDeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals',
      one: '1 deal',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountListings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listings',
      one: '1 listing',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountMeetings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetings',
      one: '1 meeting',
    );
    return '$_temp0';
  }

  @override
  String notificationsCountTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String notificationsDealComment(String author, String title) {
    return '$author commented on $title';
  }

  @override
  String notificationsDealMention(String author, String title) {
    return '$author mentioned you in $title';
  }

  @override
  String notificationsDealStatus(String actor, String status, String title) {
    return '$actor moved $title to $status';
  }

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get notificationsEmptyBody =>
      'A task someone gives you, clients handed to you or a listing that fits your buyers will show up here.';

  @override
  String get notificationsEmptyTitle => 'Nothing new';

  @override
  String notificationsFitsBuyers(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fits $count buyers: $names',
      one: 'Fits $names',
    );
    return '$_temp0';
  }

  @override
  String notificationsHandedOver(int count, String from) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$from handed you $_temp0';
  }

  @override
  String notificationsJoinAccepted(String agent, String team) {
    return '$agent joined $team';
  }

  @override
  String notificationsJoinRequest(String actor, String team) {
    return '$actor invites you to join $team';
  }

  @override
  String notificationsListingLead(String name, String title) {
    return '$name is interested in $title';
  }

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String notificationsMoreNames(int count, String names) {
    return '$names and $count more';
  }

  @override
  String notificationsNewMatch(String title) {
    return 'New listing for your buyers: $title';
  }

  @override
  String notificationsPriceDrop(String oldPrice, String price, String title) {
    return '$title is now $price, down from $oldPrice';
  }

  @override
  String notificationsPurchaseAnniversary(String name, int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years today since $name\'s purchase',
      one: 'A year today since $name\'s purchase',
    );
    return '$_temp0';
  }

  @override
  String get notificationsSomeone => 'Someone';

  @override
  String notificationsTaskAssigned(String actor, String title) {
    return '$actor gave you a task: $title';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsUnknown => 'Something changed in your work';

  @override
  String notificationsUnreadLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread notifications',
      one: '1 unread notification',
      zero: 'No unread notifications',
    );
    return '$_temp0';
  }

  @override
  String get offersAccept => 'Accept';

  @override
  String offersAcceptConfirm(String amount) {
    return '$amount becomes the agreed price. Other offers on this listing stay open as backups until you decide on them.';
  }

  @override
  String get offersAcceptTitle => 'Accept this offer?';

  @override
  String get offersAgent => 'Agent';

  @override
  String get offersAlreadyAccepted =>
      'Another offer on this listing is already accepted; withdraw it first';

  @override
  String get offersAlreadyOpen =>
      'This buyer already has an open offer here; counter it instead';

  @override
  String get offersAmount => 'Amount';

  @override
  String get offersAmountHint => 'What they offer';

  @override
  String offersAsking(String price) {
    return 'asking $price';
  }

  @override
  String get offersBackup =>
      'Another offer is accepted; this one waits as a backup';

  @override
  String get offersBuyer => 'Buyer';

  @override
  String get offersCardTitle => 'Offers';

  @override
  String get offersClientNone =>
      'No offers from this buyer yet. Record one from a listing.';

  @override
  String get offersClientNotBuyer => 'Only a buyer can make an offer';

  @override
  String get offersClosedHeading => 'Closed';

  @override
  String offersColleagueBuyer(String agent) {
    return 'Buyer of $agent';
  }

  @override
  String get offersCounter => 'Counter';

  @override
  String get offersCounterFrom => 'Whose figure';

  @override
  String get offersCounterTitle => 'New figure';

  @override
  String get offersDecidedOn => 'Decided';

  @override
  String get offersExpiresOn => 'Valid until';

  @override
  String get offersExpiryPast => 'The deadline cannot be before today';

  @override
  String get offersFigureBuyer => 'The buyer\'s figure';

  @override
  String get offersFigureSeller => 'The seller\'s figure';

  @override
  String get offersHiddenBuyer => 'A colleague\'s buyer';

  @override
  String get offersHistory => 'Negotiation';

  @override
  String get offersListLoadFailed => 'Could not load the offers';

  @override
  String get offersLoadFailed => 'Could not load the offer';

  @override
  String get offersNoBuyers => 'No buyers found';

  @override
  String get offersNoDeadline => 'No deadline';

  @override
  String get offersNoLongerOpen => 'This offer is no longer open';

  @override
  String get offersNone =>
      'No offers yet. Record one when a buyer names a price.';

  @override
  String get offersNote => 'Note';

  @override
  String get offersNoteHint => 'Terms, how they pay, what they asked for';

  @override
  String offersOfAsking(int percent) {
    return '$percent% of asking';
  }

  @override
  String offersOnTableNow(String amount) {
    return 'On the table now: $amount';
  }

  @override
  String get offersPartyBuyer => 'Buyer';

  @override
  String get offersPartySeller => 'Seller';

  @override
  String get offersPickBuyer => 'Choose a buyer';

  @override
  String get offersPropertySold =>
      'This listing is sold and takes no more offers';

  @override
  String get offersRecord => 'Record an offer';

  @override
  String get offersRecordTitle => 'Record an offer';

  @override
  String get offersReject => 'Reject';

  @override
  String get offersRejectConfirm =>
      'The offer is closed as rejected and cannot be reopened.';

  @override
  String get offersRejectTitle => 'Reject this offer?';

  @override
  String get offersSave => 'Save';

  @override
  String get offersSearchBuyers => 'Search buyers';

  @override
  String get offersShowAll => 'Show all';

  @override
  String get offersStatusAccepted => 'Accepted';

  @override
  String get offersStatusCountered => 'Countered';

  @override
  String get offersStatusExpired => 'Expired';

  @override
  String get offersStatusNew => 'New';

  @override
  String get offersStatusRejected => 'Rejected';

  @override
  String get offersStatusWithdrawn => 'Withdrawn';

  @override
  String get offersStepAccepted => 'Accepted';

  @override
  String get offersStepCounteredBuyer => 'Buyer\'s counter';

  @override
  String get offersStepCounteredSeller => 'Seller\'s counter';

  @override
  String get offersStepOffered => 'Offer from the buyer';

  @override
  String get offersStepOther => 'Change';

  @override
  String get offersStepRejected => 'Rejected';

  @override
  String get offersStepWithdrawn => 'Withdrawn';

  @override
  String get offersTitle => 'Offer';

  @override
  String offersValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get offersWithdraw => 'Withdraw';

  @override
  String get offersWithdrawConfirm =>
      'The buyer has pulled out. The offer is closed and cannot be reopened.';

  @override
  String get offersWithdrawTitle => 'Withdraw this offer?';

  @override
  String get openHouseActivity => 'Open house visit';

  @override
  String get openHouseAddVisitor => 'Add visitor';

  @override
  String get openHouseAlreadySignedIn => 'This number has already signed in';

  @override
  String openHouseColleagueClient(String agent) {
    return 'Client of $agent';
  }

  @override
  String get openHouseDate => 'Date';

  @override
  String get openHouseDelete => 'Cancel open house';

  @override
  String get openHouseDeleteConfirm =>
      'It is removed from the listing and the calendar.';

  @override
  String get openHouseEdit => 'Edit open house';

  @override
  String get openHouseEnds => 'Ends';

  @override
  String get openHouseEndsBeforeStart => 'It has to end after it starts';

  @override
  String get openHouseHasVisitors =>
      'People have signed in, so it cannot be cancelled';

  @override
  String openHouseHost(String name) {
    return 'Held by $name';
  }

  @override
  String get openHouseInterestLabel => 'Interest';

  @override
  String get openHouseInterested => 'Interested';

  @override
  String get openHouseJustLooking => 'Just looking';

  @override
  String get openHouseKnownClient => 'Already a client';

  @override
  String get openHouseLive => 'On now';

  @override
  String get openHouseLoadFailed => 'Could not load the open house';

  @override
  String get openHouseNewClient => 'New client';

  @override
  String get openHouseNoVisitors => 'Nobody has signed in yet';

  @override
  String get openHouseNoVisitorsHint =>
      'Add each visitor as they arrive. A number the agency does not know becomes a new buyer.';

  @override
  String get openHouseNone =>
      'No open houses yet. Schedule one and sign visitors in at the door.';

  @override
  String get openHouseNoteHint => 'Keys, parking, who to call at the door';

  @override
  String get openHouseNoteLabel => 'Note';

  @override
  String get openHousePast => 'Past';

  @override
  String get openHouseRemoveVisitor => 'Remove visitor';

  @override
  String openHouseRemoveVisitorConfirm(String name) {
    return '$name comes off the sheet and the visit leaves the client\'s history. A client this sign-in created stays.';
  }

  @override
  String get openHouseSave => 'Save';

  @override
  String get openHouseSchedule => 'Schedule an open house';

  @override
  String get openHouseSeeAll => 'Show all';

  @override
  String get openHouseSignIn => 'Save';

  @override
  String get openHouseSignInNext => 'Save and next';

  @override
  String get openHouseSignInSheet => 'Sign-in sheet';

  @override
  String openHouseSignedIn(String name) {
    return '$name signed in';
  }

  @override
  String get openHouseStarts => 'Starts';

  @override
  String get openHouseSummary => 'Summary';

  @override
  String get openHouseSummaryInterested => 'Interested';

  @override
  String get openHouseSummaryNewClients => 'New clients';

  @override
  String get openHouseSummaryVisitors => 'Visitors';

  @override
  String get openHouseTitle => 'Open house';

  @override
  String get openHouseTooLong => 'An open house lasts at most 12 hours';

  @override
  String get openHouseUpcoming => 'Upcoming';

  @override
  String get openHouseVisitorName => 'Name';

  @override
  String get openHouseVisitorNameHint => 'As they give it';

  @override
  String get openHouseVisitorNameRequired => 'Enter a name';

  @override
  String get openHouseVisitorNoteHint => 'What they asked about';

  @override
  String get openHouseVisitorPhone => 'Phone';

  @override
  String get openHouseVisitorPhoneInvalid => 'Enter a phone number';

  @override
  String openHouseVisitorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitors',
      one: '1 visitor',
      zero: 'No visitors',
    );
    return '$_temp0';
  }

  @override
  String get openHousesCardTitle => 'Open houses';

  @override
  String get profileAgentId => 'Agent ID';

  @override
  String get profileAgentIdCopied => 'Agent ID copied';

  @override
  String get profileApp => 'App';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String profileDeleteAccountConfirm(Object successor) {
    return 'Your clients, properties, deals and meetings move to $successor. The account is removed permanently and this cannot be undone.';
  }

  @override
  String get profileDeleteHandoverEmpty => 'No one else to hand them to';

  @override
  String get profileDeleteHandoverSearch => 'Search colleagues';

  @override
  String get profileDeleteHandoverTitle => 'Hand your records over to';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileEstateCrm => 'Estate CRM';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLegal => 'Legal';

  @override
  String get profileLinkFailed => 'Could not open the link';

  @override
  String get profileName => 'Name';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileReminders => 'Meeting reminders';

  @override
  String get profileRemindersOff => 'Off';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileSystemDefault => 'System default';

  @override
  String get profileTheme => 'Appearance';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeSystem => 'Follow system';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileVersion => 'Version';

  @override
  String get propertiesAddFirstListing => 'Add your first listing';

  @override
  String get propertiesAddPhotos => 'Add photos';

  @override
  String get propertiesAddressLabel => 'Address';

  @override
  String get propertiesAll => 'All';

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
  String get propertiesBrochure => 'Brochure (PDF)';

  @override
  String get propertiesBrochureContact => 'Contact';

  @override
  String get propertiesBrochureFailed =>
      'Couldn\'t put the brochure together. Try again.';

  @override
  String propertiesBrochureGenerated(String date) {
    return 'Prepared $date';
  }

  @override
  String propertiesBrochurePage(int page, int total) {
    return 'Page $page of $total';
  }

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
  String get propertiesInterested => 'Buyers looking for this';

  @override
  String get propertiesLink => 'Public link';

  @override
  String get propertiesLinkCopied => 'Link copied';

  @override
  String get propertiesLinkCopy => 'Copy';

  @override
  String get propertiesLinkCreate => 'Create link';

  @override
  String propertiesLinkEnquiries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enquiries from this link',
      one: '1 enquiry from this link',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLinkHint =>
      'A page with the photos, price and your contacts. Opens in any browser, no app or account needed.';

  @override
  String propertiesLinkLastViewed(String date) {
    return 'Last opened $date';
  }

  @override
  String get propertiesLinkRevoke => 'Switch off';

  @override
  String get propertiesLinkRevokeConfirm =>
      'Anyone you sent it to will no longer be able to open the listing. A new link will have a different address.';

  @override
  String get propertiesLinkRevokeTitle => 'Switch off the link?';

  @override
  String get propertiesLinkShare => 'Share';

  @override
  String propertiesLinkViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opened $count times',
      one: 'Opened once',
      zero: 'Not opened yet',
    );
    return '$_temp0';
  }

  @override
  String get propertiesLocation => 'Location';

  @override
  String get propertiesMandate => 'Seller agreement';

  @override
  String get propertiesMandateClearEndDate => 'Remove the end date';

  @override
  String get propertiesMandateEndDate => 'Last day';

  @override
  String propertiesMandateEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ended $count days ago',
      one: 'Ended 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndedYesterday => 'Ended yesterday';

  @override
  String propertiesMandateEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ends in $count days',
      one: 'Ends in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMandateEndsToday => 'Ends today';

  @override
  String get propertiesMandateEndsTomorrow => 'Ends tomorrow';

  @override
  String get propertiesMandateExclusive => 'Exclusive';

  @override
  String propertiesMandateExclusiveEnded(String date) {
    return 'Exclusive ended $date';
  }

  @override
  String propertiesMandateExclusiveUntil(String date) {
    return 'Exclusive until $date';
  }

  @override
  String get propertiesMandateNoEndDate => 'No end date';

  @override
  String get propertiesMandateNone => 'None';

  @override
  String get propertiesMandateOpen => 'Open';

  @override
  String get propertiesMandateOpenBadge => 'Open agreement';

  @override
  String propertiesMandateOpenEnded(String date) {
    return 'Agreement ended $date';
  }

  @override
  String propertiesMandateOpenUntil(String date) {
    return 'Open until $date';
  }

  @override
  String get propertiesMandatesEmpty => 'No agreements running out';

  @override
  String get propertiesMandatesEmptyHint =>
      'No seller agreement on a listing still for sale ends in the next two weeks.';

  @override
  String get propertiesMandatesLoadFailed =>
      'Could not load the agreements running out';

  @override
  String get propertiesMandatesTitle => 'Agreements running out';

  @override
  String propertiesMapCapped(int count) {
    return 'Showing $count — zoom in to see the rest';
  }

  @override
  String get propertiesMapEmpty => 'No listings in this area';

  @override
  String get propertiesMapLoading => 'Loading listings';

  @override
  String get propertiesMapPin => 'Pin on the map';

  @override
  String get propertiesMapPinClear => 'Remove pin';

  @override
  String get propertiesMapPinHint =>
      'Tap the map to drop a pin, drag it to adjust';

  @override
  String propertiesMapUnpinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listings have no location',
      one: '1 listing has no location',
    );
    return '$_temp0';
  }

  @override
  String get propertiesMapUnpinnedHint =>
      'Open a listing, choose Edit and drop a pin to show it on the map.';

  @override
  String get propertiesMapUnpinnedTitle => 'Not on the map';

  @override
  String get propertiesNewProperty => 'New Property';

  @override
  String get propertiesNextDetails => 'Next — details';

  @override
  String get propertiesNoInterested =>
      'No buyer has asked for anything like this yet';

  @override
  String get propertiesNoPhotos =>
      'No photos yet — the first one becomes the cover';

  @override
  String get propertiesNoProperties => 'No properties';

  @override
  String get propertiesNoResultsSubtitle => 'Try a different search or filter';

  @override
  String get propertiesNoViewings => 'This listing has not been shown yet';

  @override
  String get propertiesOpenInMaps => 'Open in Maps';

  @override
  String get propertiesOpenInMapsFailed => 'Could not open a maps app';

  @override
  String propertiesPhotoCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPhotoDelete => 'Remove photo';

  @override
  String get propertiesPhotoDeleteConfirm =>
      'Remove this photo from the listing?';

  @override
  String propertiesPhotoFailed(String name) {
    return 'Could not upload $name';
  }

  @override
  String propertiesPhotoTooLarge(String name) {
    return '$name is larger than 12 MB';
  }

  @override
  String get propertiesPhotos => 'Photos';

  @override
  String get propertiesPhotosHint =>
      'Hold a photo to move it — the first one is the cover';

  @override
  String get propertiesPriceCheck => 'Price check';

  @override
  String propertiesPriceCheckAbove(String percent) {
    return '$percent% above';
  }

  @override
  String get propertiesPriceCheckAtMedian => 'at the median';

  @override
  String propertiesPriceCheckBasedOn(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count listings in $city',
      one: 'Based on $count listing in $city',
    );
    return '$_temp0';
  }

  @override
  String propertiesPriceCheckBelow(String percent) {
    return '$percent% below';
  }

  @override
  String get propertiesPriceCheckComparables => 'Comparable listings';

  @override
  String propertiesPriceCheckDaysOnMarket(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days on the market',
      one: '$count day on the market',
    );
    return '$_temp0';
  }

  @override
  String get propertiesPriceCheckLowConfidence =>
      'Few similar listings yet, so treat this as a rough guide';

  @override
  String get propertiesPriceCheckSeeComparables => 'See comparables';

  @override
  String propertiesPriceCheckSold(String price) {
    return 'Sold at a median of $price';
  }

  @override
  String propertiesPriceCheckVsMedian(
      String price, String median, String difference) {
    return '$price / m² vs median $median ($difference)';
  }

  @override
  String propertiesPriceHintRange(String low, String high) {
    return 'Similar listings: $low–$high for this area';
  }

  @override
  String get propertiesPriceHintUseMedian => 'Use median';

  @override
  String get propertiesPriceHistory => 'Price history';

  @override
  String get propertiesPriceLabel => 'Price';

  @override
  String propertiesPricePerSqm(Object price) {
    return '$price per m²';
  }

  @override
  String get propertiesPriceReduced => 'Price reduced';

  @override
  String propertiesPriceWas(String price) {
    return 'Was $price';
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
  String get propertiesReport => 'Report for the seller';

  @override
  String propertiesReportAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get propertiesReportAwaitingOutcome => 'Not recorded yet';

  @override
  String get propertiesReportCurrentPrice => 'Now';

  @override
  String get propertiesReportDaysOnMarket => 'Days on the market';

  @override
  String get propertiesReportLinkLeads => 'Enquiries from the link';

  @override
  String get propertiesReportLinkViews => 'Link opens';

  @override
  String propertiesReportListedOn(String date) {
    return 'Listed on $date';
  }

  @override
  String get propertiesReportLoadFailed => 'Couldn\'t load the report';

  @override
  String get propertiesReportMatchingBuyers => 'Buyers it fits';

  @override
  String propertiesReportNextViewing(String date) {
    return 'Next viewing $date';
  }

  @override
  String get propertiesReportNoViewings => 'No viewings yet';

  @override
  String get propertiesReportOriginalPrice => 'Listed at';

  @override
  String get propertiesReportOutcomes => 'What viewers said';

  @override
  String get propertiesReportPrice => 'Price';

  @override
  String get propertiesReportPriceChange => 'Change';

  @override
  String get propertiesReportPriceChanges => 'Price changes';

  @override
  String get propertiesReportPriceUnchanged =>
      'The price has not changed since it was listed';

  @override
  String get propertiesReportShare => 'Share with the seller';

  @override
  String get propertiesReportShareFailed =>
      'Couldn\'t share the report. Try again.';

  @override
  String propertiesReportSoldOn(String date) {
    return 'Sold on $date';
  }

  @override
  String propertiesReportTextHeading(String title) {
    return 'Report for the seller: $title';
  }

  @override
  String propertiesReportTextLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get propertiesReportViewingsHeld => 'Viewings held';

  @override
  String get propertiesReportViewingsUpcoming => 'Viewings to come';

  @override
  String get propertiesRooms => 'Rooms';

  @override
  String propertiesRoomsCount(Object rooms) {
    return '$rooms rooms';
  }

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
  String get propertiesTitleLabel => 'Title';

  @override
  String get propertiesTotalFloors => 'Total Floors';

  @override
  String get propertiesType => 'Type';

  @override
  String get propertiesUpdateProperty => 'Update Property';

  @override
  String get propertiesViewList => 'List';

  @override
  String get propertiesViewMap => 'Map';

  @override
  String get propertiesViewings => 'Viewings';

  @override
  String get quickAddClient => 'New client';

  @override
  String get quickAddDeal => 'New deal';

  @override
  String quickAddFor(String name) {
    return 'For $name';
  }

  @override
  String get quickAddLastUsed => 'Last used';

  @override
  String get quickAddListing => 'New property';

  @override
  String get quickAddLogContact => 'Log a contact';

  @override
  String get quickAddMeeting => 'New meeting';

  @override
  String get quickAddNoClients => 'No clients yet — add one first';

  @override
  String get quickAddOpen => 'New';

  @override
  String get quickAddPickClient => 'Which client?';

  @override
  String get quickAddSearchClients => 'Search clients';

  @override
  String get quickAddTask => 'New task';

  @override
  String get quickAddTitle => 'Add';

  @override
  String remindersBody(Object time) {
    return 'Starts at $time';
  }

  @override
  String remindersBodyWithClient(Object client, Object time) {
    return 'Starts at $time with $client';
  }

  @override
  String get remindersFallbackTitle => 'Meeting';

  @override
  String get remindersLeadDay => '1 day before';

  @override
  String get remindersLeadHour => '1 hour before';

  @override
  String get remindersLeadQuarter => '15 minutes before';

  @override
  String get remindersPermissionDenied =>
      'Notifications are off for EstateCRM. Turn them on in your phone’s settings.';

  @override
  String get remindersTaskDue => 'Due now';

  @override
  String remindersTaskDueWithClient(Object client) {
    return 'Due now · $client';
  }

  @override
  String get routeAddPin => 'Add a pin';

  @override
  String get routeAppApple => 'Apple Maps';

  @override
  String get routeAppDgis => '2GIS';

  @override
  String get routeAppGoogle => 'Google Maps';

  @override
  String get routeAppNextOnly => 'Next stop only';

  @override
  String routeAppStops(int from, int to, int total) {
    return 'Stops $from–$to of $total';
  }

  @override
  String get routeAppWhole => 'Whole route, in order';

  @override
  String get routeAppYandex => 'Yandex Maps';

  @override
  String routeChooserNext(String title) {
    return 'Next stop: $title';
  }

  @override
  String get routeChooserTitle => 'Open in a maps app';

  @override
  String get routeChooserWhole =>
      'Every stop still ahead, in the order they are booked';

  @override
  String get routeDayOver => 'No stops left for this day';

  @override
  String get routeDone => 'Done';

  @override
  String routeDurationHourMin(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String routeDurationHours(int hours) {
    return '$hours h';
  }

  @override
  String routeDurationMin(int minutes) {
    return '$minutes min';
  }

  @override
  String get routeEmpty => 'No viewings this day';

  @override
  String get routeEmptyHint =>
      'A meeting booked on a listing shows up here as a stop.';

  @override
  String get routeEntryDay => 'Route for this day';

  @override
  String get routeEntryToday => 'Today\'s route';

  @override
  String routeFromPrevious(String km) {
    return '$km km from the previous stop';
  }

  @override
  String get routeLoadFailed => 'Couldn\'t load the route';

  @override
  String get routeNavigateNext => 'Navigate to next stop';

  @override
  String get routeNext => 'Next';

  @override
  String get routeNotOnMap => 'Not on the map';

  @override
  String get routeNotOnMapHint =>
      'These listings have no pin yet, so they are not in the route.';

  @override
  String get routeOpenFailed => 'Couldn\'t open a maps app';

  @override
  String get routeOpenWhole => 'Open the whole route';

  @override
  String get routeOverlap => 'Overlaps the next viewing';

  @override
  String routeStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get routeStraightLine =>
      'Straight lines between stops, not driving directions';

  @override
  String routeSummary(String stops, String km) {
    return '$stops · $km km straight-line';
  }

  @override
  String get routeTitle => 'Viewings route';

  @override
  String routeUntilNext(String duration) {
    return '$duration until the next one';
  }

  @override
  String get searchClear => 'Clear';

  @override
  String get searchClearRecent => 'Clear';

  @override
  String get searchHint => 'Clients, listings, deals…';

  @override
  String searchMoreCount(Object count) {
    return 'and $count more';
  }

  @override
  String get searchNoResults => 'Nothing found';

  @override
  String get searchNoResultsSubtitle =>
      'Try a different name, address or phone number';

  @override
  String get searchPromptSubtitle =>
      'Find a client, a listing or a deal by name, address, phone or id';

  @override
  String get searchPromptTitle => 'Search everything';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchSectionClients => 'Clients';

  @override
  String get searchSectionDeals => 'Deals';

  @override
  String get searchSectionProperties => 'Properties';

  @override
  String get searchTitle => 'Search';

  @override
  String get tasksAbout => 'What it is about';

  @override
  String get tasksAdd => 'Add task';

  @override
  String get tasksAllTasks => 'All tasks';

  @override
  String tasksAssignedTo(Object name) {
    return 'for $name';
  }

  @override
  String get tasksAssignee => 'Who does it';

  @override
  String get tasksClearLink => 'Remove link';

  @override
  String get tasksClient => 'Client';

  @override
  String get tasksComplete => 'Mark done';

  @override
  String tasksCounter(Object count) {
    return '$count open';
  }

  @override
  String get tasksDate => 'Date';

  @override
  String get tasksDeal => 'Deal';

  @override
  String get tasksDelete => 'Delete task';

  @override
  String get tasksDeleteBody =>
      'It disappears for everyone, together with its reminder.';

  @override
  String get tasksDeleteTitle => 'Delete this task?';

  @override
  String tasksDoneOn(Object date) {
    return 'Done $date';
  }

  @override
  String get tasksDoneTab => 'Done';

  @override
  String get tasksDue => 'Due';

  @override
  String tasksDueToday(Object time) {
    return 'Today, $time';
  }

  @override
  String tasksDueTomorrow(Object time) {
    return 'Tomorrow, $time';
  }

  @override
  String get tasksEdit => 'Edit task';

  @override
  String get tasksEmptyDone => 'Nothing done yet';

  @override
  String get tasksEmptyOpen => 'Nothing to do';

  @override
  String get tasksEmptyOpenHint =>
      'Follow-ups you add to clients and deals show up here.';

  @override
  String get tasksEmptyRecordHint => 'Add a follow-up so it is not forgotten.';

  @override
  String get tasksFieldTitle => 'What to do';

  @override
  String get tasksLoadFailed => 'Could not load tasks';

  @override
  String get tasksNew => 'New task';

  @override
  String get tasksNoAgents => 'No one to hand it to';

  @override
  String get tasksNote => 'Note';

  @override
  String get tasksNoteHint => 'Details, numbers, what to prepare…';

  @override
  String get tasksOpenTab => 'Open';

  @override
  String get tasksOverdue => 'Overdue';

  @override
  String get tasksQuickInThreeDays => 'In 3 days';

  @override
  String get tasksQuickTodayEvening => 'Today evening';

  @override
  String get tasksQuickTomorrowMorning => 'Tomorrow morning';

  @override
  String get tasksReopen => 'Reopen';

  @override
  String get tasksRepeat => 'Repeat';

  @override
  String get tasksRepeatCount => 'How many times';

  @override
  String get tasksRepeatCountInvalid => 'From 1 to 999';

  @override
  String get tasksRepeatDaily => 'Every day';

  @override
  String tasksRepeatDayOrdinal(int day, String suffix) {
    String _temp0 = intl.Intl.selectLogic(
      suffix,
      {
        'st': 'st',
        'nd': 'nd',
        'rd': 'rd',
        'other': 'th',
      },
    );
    return '$day$_temp0';
  }

  @override
  String get tasksRepeatDays => 'On these days';

  @override
  String get tasksRepeatEndAfter => 'After';

  @override
  String get tasksRepeatEndNever => 'Never';

  @override
  String get tasksRepeatEndOn => 'On a day';

  @override
  String get tasksRepeatEnds => 'Ends';

  @override
  String tasksRepeatLeapYear(Object rule) {
    return '$rule (28 February in other years)';
  }

  @override
  String tasksRepeatMonthly(Object day) {
    return 'Every month on the $day';
  }

  @override
  String get tasksRepeatNone => 'Does not repeat';

  @override
  String get tasksRepeatOptionDaily => 'Daily';

  @override
  String get tasksRepeatOptionMonthly => 'Monthly';

  @override
  String get tasksRepeatOptionQuarterly => 'Every 3 months';

  @override
  String get tasksRepeatOptionWeekly => 'Weekly';

  @override
  String get tasksRepeatOptionYearly => 'Yearly';

  @override
  String get tasksRepeatPickDay => 'Pick a day';

  @override
  String tasksRepeatQuarterly(Object day) {
    return 'Every 3 months on the $day';
  }

  @override
  String tasksRepeatShortMonths(Object rule) {
    return '$rule (last day in shorter months)';
  }

  @override
  String get tasksRepeatStop => 'Stop repeating';

  @override
  String get tasksRepeatStopBody =>
      'This one stays as it is; no more are added after it.';

  @override
  String get tasksRepeatStopTitle => 'Stop repeating this task?';

  @override
  String tasksRepeatTimes(num count, Object rule) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$rule, $count times',
      one: '$rule, once',
    );
    return '$_temp0';
  }

  @override
  String tasksRepeatUntil(Object date, Object rule) {
    return '$rule, until $date';
  }

  @override
  String get tasksRepeatUntilBeforeDue =>
      'The last day cannot be before the task is due';

  @override
  String get tasksRepeatUse => 'Done';

  @override
  String tasksRepeatWeekly(Object days) {
    return 'Every week on $days';
  }

  @override
  String tasksRepeatYearly(Object date) {
    return 'Every year on $date';
  }

  @override
  String get tasksSave => 'Save task';

  @override
  String get tasksSearchHint => 'Search by name or ID';

  @override
  String get tasksTime => 'Time';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksTitleHint => 'Call Irina back';

  @override
  String get tasksTitleRequired => 'Say what needs doing';

  @override
  String get tasksTitleTooLong => 'Keep it under 200 characters';

  @override
  String get teamsActive => 'Active';

  @override
  String get teamsAddAgent => 'Add agent';

  @override
  String get teamsAddAgentAction => 'Send';

  @override
  String get teamsAddAgentHint =>
      'If the agent already has an account they get a request to accept. If not, we email them an invite.';

  @override
  String get teamsAgents => 'Agents';

  @override
  String get teamsCancelRequest => 'Withdraw';

  @override
  String get teamsChecklist => 'Deal checklist';

  @override
  String get teamsChecklistAdd => 'Add item';

  @override
  String get teamsChecklistDelete => 'Delete item';

  @override
  String get teamsChecklistDiscard => 'Discard';

  @override
  String get teamsChecklistDiscardBody =>
      'Your changes to the checklist have not been saved.';

  @override
  String get teamsChecklistDiscardTitle => 'Discard changes?';

  @override
  String get teamsChecklistEmptyStage => 'No items at this stage yet';

  @override
  String get teamsChecklistHint => 'What a deal collects at each stage';

  @override
  String get teamsChecklistNewDealsOnly =>
      'Changes apply to new deals. Deals already under way keep their own list.';

  @override
  String get teamsChecklistRename => 'Rename';

  @override
  String get teamsChecklistReorder => 'Drag to reorder';

  @override
  String get teamsClients => 'Clients';

  @override
  String get teamsCouldNotLoadStats => 'Could not load stats';

  @override
  String get teamsCreate => 'Create';

  @override
  String get teamsCreateTeam => 'Create team';

  @override
  String get teamsCurrency => 'Agency currency';

  @override
  String get teamsCurrencyConfirm => 'Change currency';

  @override
  String teamsCurrencyConfirmBody(
      String currency, String before, String after) {
    return 'Everyone in the agency will see prices in $currency. Amounts are not converted: a listing priced $before will read $after.';
  }

  @override
  String get teamsCurrencyConfirmTitle => 'Change the agency currency?';

  @override
  String get teamsCurrencyEur => 'Euro (€)';

  @override
  String get teamsCurrencyHint => 'How prices read across the app';

  @override
  String get teamsCurrencyKgs => 'Kyrgyz som (KGS)';

  @override
  String get teamsCurrencyKzt => 'Tenge (₸)';

  @override
  String get teamsCurrencyRub => 'Rouble (₽)';

  @override
  String get teamsCurrencyUsd => 'US dollar (\$)';

  @override
  String get teamsCurrencyUzs => 'Uzbek som (UZS)';

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
  String teamsInviteSentBody(Object email) {
    return 'An invite has been emailed to $email.';
  }

  @override
  String get teamsLeaveTeam => 'Leave team';

  @override
  String get teamsLeaveTeamBody =>
      'Your clients, deals and meetings stay with the team. You will need a new invitation to come back.';

  @override
  String teamsLeaveTeamTitle(Object team) {
    return 'Leave $team?';
  }

  @override
  String get teamsManagerChip => 'Manager';

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
  String get teamsMembers => 'Members';

  @override
  String get teamsMyTeam => 'My Team';

  @override
  String get teamsNoManager => 'No manager';

  @override
  String get teamsNoMembers => 'Nobody here yet';

  @override
  String get teamsNoMembersBody => 'Add your first agent by email.';

  @override
  String get teamsNoPending => 'Nothing pending';

  @override
  String get teamsNoPendingBody =>
      'Requests waiting for an answer appear here.';

  @override
  String get teamsNoTeamLabel => 'No team';

  @override
  String get teamsPending => 'Pending';

  @override
  String get teamsPhoneOptional => 'Phone (optional)';

  @override
  String teamsRemoveInviteBody(Object name) {
    return 'The invite to $name will be revoked.';
  }

  @override
  String get teamsRemoveMember => 'Remove from team';

  @override
  String teamsRemoveMemberBody(Object successor) {
    return 'Their clients, deals and meetings stay in the team and go to $successor.';
  }

  @override
  String teamsRemoveMemberTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String teamsRequestSentBody(Object name) {
    return '$name has to accept before joining your team.';
  }

  @override
  String get teamsRequired => 'Required';

  @override
  String get teamsSave => 'Save';

  @override
  String get teamsStatusPendingInvite => 'Invited';

  @override
  String get teamsStatusPendingVerification => 'Not confirmed';

  @override
  String get teamsSuccessor => 'Records go to';

  @override
  String get teamsSuccessorMe => 'Me';

  @override
  String get teamsTeamLabel => 'Team';

  @override
  String get teamsTeamName => 'Team name';

  @override
  String get teamsUpcoming => 'Upcoming';

  @override
  String get templatesAdd => 'Add template';

  @override
  String get templatesBodyHint => 'What the agent will send';

  @override
  String get templatesBodyLabel => 'Text';

  @override
  String get templatesDelete => 'Delete template';

  @override
  String templatesDeleteBody(String title) {
    return '\"$title\" will no longer be offered to agents.';
  }

  @override
  String get templatesDeleteTitle => 'Delete template?';

  @override
  String get templatesEdit => 'Edit template';

  @override
  String get templatesEmpty => 'No templates yet';

  @override
  String get templatesEmptyBody =>
      'Add the messages your agents send most often.';

  @override
  String get templatesHint => 'Ready texts for WhatsApp and SMS';

  @override
  String get templatesInsert => 'Insert a placeholder';

  @override
  String get templatesIntro =>
      'Agents pick a template when writing to a client. Placeholders fill in with the client, the agent and the chosen listing.';

  @override
  String get templatesLoadFailed => 'Could not load templates';

  @override
  String get templatesNew => 'New template';

  @override
  String get templatesPlaceholderAddress => 'Address';

  @override
  String get templatesPlaceholderAgent => 'Agent\'s name';

  @override
  String get templatesPlaceholderClient => 'Client\'s name';

  @override
  String get templatesPlaceholderLink => 'Listing link';

  @override
  String get templatesPlaceholderListing => 'Listing';

  @override
  String get templatesPlaceholderPrice => 'Price';

  @override
  String get templatesTitle => 'Message templates';

  @override
  String get templatesTitleHint => 'For example, Viewing invitation';

  @override
  String get templatesTitleLabel => 'Title';

  @override
  String templatesUnknownPlaceholder(String names) {
    return 'Unknown placeholder: $names. Use the ones below.';
  }

  @override
  String get dealsKind => 'Sale or rent';

  @override
  String get dealsKindSale => 'Sale';

  @override
  String get dealsKindRent => 'Rent';

  @override
  String get leasesTitle => 'Lease';

  @override
  String get leasesMonthlyRent => 'Rent per month';

  @override
  String leasesPerMonth(String amount) {
    return '$amount a month';
  }

  @override
  String get leasesStart => 'Lease starts';

  @override
  String get leasesEnd => 'Lease ends';

  @override
  String get leasesPickDate => 'Pick a day';

  @override
  String get leasesReminderDays => 'Remind me, days before the end';

  @override
  String leasesReminderValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before the end',
      one: '1 day before the end',
    );
    return '$_temp0';
  }

  @override
  String get leasesReminder => 'Reminder';

  @override
  String get leasesLandlord => 'Landlord';

  @override
  String get leasesTenant => 'Tenant';

  @override
  String leasesTenantValue(String name) {
    return 'Tenant: $name';
  }

  @override
  String leasesLandlordValue(String name) {
    return 'Landlord: $name';
  }

  @override
  String get leasesRentRequired => 'Enter the rent per month';

  @override
  String get leasesDatesRequired =>
      'Pick the first and the last day of the lease';

  @override
  String get leasesEndBeforeStart => 'The lease has to end after it starts';

  @override
  String get leasesReminderInvalid => 'From 1 to 365 days';

  @override
  String get leasesEndsToday => 'Lease ends today';

  @override
  String get leasesEndsTomorrow => 'Lease ends tomorrow';

  @override
  String leasesEndsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lease ends in $count days',
      one: 'Lease ends in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get leasesEndedYesterday => 'Lease ended yesterday';

  @override
  String leasesEndedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lease ended $count days ago',
      one: 'Lease ended 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get leasesRenew => 'Renew lease';

  @override
  String get leasesRenewTitle => 'Renew the lease';

  @override
  String get leasesRenewNewEnd => 'New last day';

  @override
  String get leasesRenewHint =>
      'The deal stays the same; its lease runs on to the new day, and the discussion notes the change.';

  @override
  String get leasesRenewEndNotLater => 'Pick a day after the current end';

  @override
  String get leasesRenewed => 'Lease renewed';

  @override
  String get leasesRenewFailed => 'Couldn\'t renew the lease';

  @override
  String get leasesRenewWhenWon =>
      'A lease can be renewed once the deal is won.';

  @override
  String get leasesEndingTitle => 'Leases ending';

  @override
  String get leasesEndingLoadFailed => 'Couldn\'t load the leases';

  @override
  String get leasesEndingEmpty => 'No leases end in the next 30 days';

  @override
  String get leasesEndingEmptyHint =>
      'Won rent deals show here a month before their lease runs out.';

  @override
  String notificationsLeaseEnding(String dealTitle, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'The lease on $dealTitle ends in $days days',
      one: 'The lease on $dealTitle ends tomorrow',
      zero: 'The lease on $dealTitle ends today',
    );
    return '$_temp0';
  }

  @override
  String get clientsActivityHandover => 'Handed over';

  @override
  String clientsActivityHandoverDetail(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String clientsActivityHandoverTo(String to) {
    return 'To $to';
  }

  @override
  String get handoverAction => 'Hand over work';

  @override
  String handoverIntro(String name) {
    return '$name stays in the agency. Choose who takes over and what moves; each client\'s history will say so.';
  }

  @override
  String get handoverFrom => 'From';

  @override
  String get handoverTo => 'To';

  @override
  String get handoverChooseColleague => 'Choose a colleague';

  @override
  String get handoverNoColleagues => 'Nobody else can take it yet';

  @override
  String get handoverWhat => 'What moves';

  @override
  String get handoverPartClients => 'Clients';

  @override
  String get handoverPartClientsHint =>
      'With their open deals, meetings and tasks';

  @override
  String get handoverPartListings => 'Listings';

  @override
  String get handoverPartListingsHint => 'With open houses still to come';

  @override
  String get handoverPartDeals => 'Open deals';

  @override
  String get handoverPartDealsHint => 'Every deal not yet won or lost';

  @override
  String get handoverPartUpcoming => 'Meetings and tasks';

  @override
  String get handoverPartUpcomingHint => 'Meetings to come and tasks not done';

  @override
  String get handoverAllClients => 'All clients';

  @override
  String handoverSomeClients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients picked',
      one: '1 client picked',
    );
    return '$_temp0';
  }

  @override
  String get handoverPickClients => 'Choose clients';

  @override
  String get handoverPickAll => 'Select all';

  @override
  String get handoverPickNone => 'Clear';

  @override
  String get handoverPickDone => 'Done';

  @override
  String get handoverNoClients => 'No clients to pick';

  @override
  String get handoverPreview => 'What will move';

  @override
  String get handoverCountDeals => 'Deals';

  @override
  String get handoverCountMeetings => 'Meetings';

  @override
  String get handoverCountTasks => 'Tasks';

  @override
  String get handoverCountOpenHouses => 'Open houses';

  @override
  String get handoverPickTarget => 'Choose who takes over to see what moves';

  @override
  String get handoverNothingSelected =>
      'Choose at least one thing to hand over';

  @override
  String get handoverNothingToMove => 'Nothing to hand over';

  @override
  String get handoverPreviewFailed => 'Could not count what moves';

  @override
  String get handoverConfirm => 'Hand over';

  @override
  String handoverConfirmTitle(String name) {
    return 'Hand over to $name?';
  }

  @override
  String handoverConfirmBody(String from, String to) {
    return 'Work moves from $from to $to. Nobody leaves the agency, and each client\'s history will note it.';
  }

  @override
  String handoverDoneTitle(String name) {
    return 'Handed over to $name';
  }

  @override
  String handoverDoneBody(String name) {
    return '$name has been told what is now theirs.';
  }

  @override
  String get handoverDoneAction => 'Back to the team';

  @override
  String get handoverLoadFailed => 'Could not load the team';

  @override
  String get clientsLeadSourcePartner => 'Partner';

  @override
  String get partnersTitle => 'Partners';

  @override
  String get partnersHint => 'Brokers, notaries and others who send clients';

  @override
  String get partnersIntro =>
      'The agency\'s brokers, notaries, appraisers and other partners, the clients they sent and the fees owed on won deals.';

  @override
  String get partnersAdd => 'Add partner';

  @override
  String get partnersEmpty => 'No partners yet';

  @override
  String get partnersEmptyBody =>
      'Add the brokers, notaries and agencies you work with.';

  @override
  String get partnersNoMatches => 'No partners match';

  @override
  String get partnersLoadFailed => 'Could not load partners';

  @override
  String get partnersLoadFailedOne => 'Could not load the partner';

  @override
  String get partnersSearchHint => 'Name, company or phone';

  @override
  String get partnersFilterAll => 'All';

  @override
  String get partnersKindMortgageBroker => 'Mortgage broker';

  @override
  String get partnersKindLawyer => 'Lawyer or notary';

  @override
  String get partnersKindAppraiser => 'Appraiser';

  @override
  String get partnersKindDeveloper => 'Developer';

  @override
  String get partnersKindAgency => 'Other agency';

  @override
  String get partnersKindOther => 'Other';

  @override
  String partnersReferredCount(int count) {
    return 'Referred: $count';
  }

  @override
  String partnersFeePercent(String value) {
    return '$value% of commission';
  }

  @override
  String partnersFeeFixed(String amount) {
    return '$amount per deal';
  }

  @override
  String get partnersFeeNone => 'No referral fee';

  @override
  String get partnersStatReferred => 'Referred clients';

  @override
  String get partnersStatWon => 'Won deals';

  @override
  String get partnersStatFees => 'Fees owed';

  @override
  String get partnersStatHandoffs => 'Clients sent';

  @override
  String partnersFeesUnknown(int count) {
    return 'Won deals without a commission, not counted: $count';
  }

  @override
  String get partnersStatsScope => 'Counted over the clients you see.';

  @override
  String get partnersContact => 'Contact';

  @override
  String get partnersName => 'Name';

  @override
  String get partnersNameHint => 'Who you deal with';

  @override
  String get partnersNameRequired => 'Enter a name';

  @override
  String get partnersCompany => 'Company';

  @override
  String get partnersCompanyHint => 'Bank, firm or agency';

  @override
  String get partnersKind => 'What they do';

  @override
  String get partnersPhone => 'Phone';

  @override
  String get partnersEmail => 'Email';

  @override
  String get partnersNote => 'Note';

  @override
  String get partnersNoteHint =>
      'Terms, how to reach them, anything to remember';

  @override
  String get partnersFee => 'Referral fee';

  @override
  String get partnersFeeHint =>
      'Owed on each won deal of a client the partner sent.';

  @override
  String get partnersFeeTypeNone => 'None';

  @override
  String get partnersFeeTypePercent => '% of commission';

  @override
  String get partnersFeeTypeFixed => 'Fixed amount';

  @override
  String get partnersFeeValuePercent => 'Percent';

  @override
  String get partnersFeeValueAmount => 'Amount';

  @override
  String get partnersFeeInvalidPercent =>
      'Enter a percent above 0 and at most 100';

  @override
  String get partnersFeeInvalidAmount => 'Enter an amount above 0';

  @override
  String get partnersInvalidFee => 'Check the referral fee';

  @override
  String get partnersSave => 'Save';

  @override
  String get partnersNew => 'New partner';

  @override
  String get partnersEdit => 'Edit partner';

  @override
  String get partnersDelete => 'Delete partner';

  @override
  String partnersDeleteConfirm(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get partnersInUse =>
      'Clients are linked to this partner, so it cannot be deleted.';

  @override
  String get partnersRequired => 'Choose the partner who sent this client';

  @override
  String partnersAddedBy(String name) {
    return 'Added by $name';
  }

  @override
  String get partnersReferrals => 'Clients they referred';

  @override
  String get partnersNoReferrals => 'No clients from this partner yet';

  @override
  String partnersReferralWon(int count) {
    return 'Won deals: $count';
  }

  @override
  String partnersReferralFee(String amount) {
    return 'Fee $amount';
  }

  @override
  String get partnersReferralNoDeals => 'No won deals';

  @override
  String get partnersSentClients => 'Clients sent to them';

  @override
  String get partnersNoSentClients => 'No clients sent yet';

  @override
  String get partnersHandoffSent => 'Sent';

  @override
  String get partnersHandoffInProgress => 'In progress';

  @override
  String get partnersHandoffDone => 'Done';

  @override
  String get partnersClientCard => 'Partners';

  @override
  String get partnersReferredBy => 'Referred by';

  @override
  String get partnersSentTo => 'Sent to';

  @override
  String get partnersSendToPartner => 'Send to a partner';

  @override
  String get partnersClientNotSent => 'Not sent to any partner yet';

  @override
  String get partnersHandoffEdit => 'Update hand-off';

  @override
  String get partnersHandoffPartner => 'Partner';

  @override
  String get partnersHandoffDate => 'Sent on';

  @override
  String get partnersHandoffStatus => 'Status';

  @override
  String get partnersHandoffNoteHint => 'What they are helping with';

  @override
  String get partnersHandoffRemove => 'Remove hand-off';

  @override
  String get partnersHandoffRemoveConfirm =>
      'Take this hand-off off the client?';

  @override
  String partnersHandoffBy(String name) {
    return 'Sent by $name';
  }

  @override
  String get partnersPickPartner => 'Choose a partner';

  @override
  String get partnersPickerEmpty => 'No partners';

  @override
  String get partnersSentOnFuture => 'The day cannot be in the future';

  @override
  String partnersOpenHandoffs(int count) {
    return 'Still open: $count';
  }

  @override
  String get timeOffTitle => 'Time off';

  @override
  String get timeOffWhosOut => 'Who\'s out';

  @override
  String get timeOffAdd => 'Add time off';

  @override
  String get timeOffNewTitle => 'New time off';

  @override
  String get timeOffEditTitle => 'Time off';

  @override
  String get timeOffKind => 'Kind';

  @override
  String get timeOffKindVacation => 'Vacation';

  @override
  String get timeOffKindSickLeave => 'Sick leave';

  @override
  String get timeOffKindDayOff => 'Day off';

  @override
  String get timeOffKindOther => 'Other';

  @override
  String get timeOffPerson => 'Who is away';

  @override
  String get timeOffPickPerson => 'Choose who is away';

  @override
  String get timeOffSearchPeople => 'Search people';

  @override
  String get timeOffDaysEyebrow => 'Days';

  @override
  String get timeOffFirstDay => 'First day';

  @override
  String get timeOffLastDay => 'Last day';

  @override
  String get timeOffPickDate => 'Pick a day';

  @override
  String get timeOffDatesRequired => 'Choose the first and the last day';

  @override
  String get timeOffEndBeforeStart => 'The last day cannot be before the first';

  @override
  String timeOffDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get timeOffCover => 'Covering';

  @override
  String get timeOffNoCover => 'Nobody';

  @override
  String get timeOffCoverHint =>
      'While they are away, the cover also gets their notifications. Nothing changes hands.';

  @override
  String timeOffCoveredBy(String name) {
    return 'Covered by $name';
  }

  @override
  String get timeOffNobodyCovers => 'Nobody covers';

  @override
  String get timeOffNote => 'Note';

  @override
  String get timeOffNoteHint => 'Anything colleagues should know';

  @override
  String get timeOffSaved => 'Time off saved';

  @override
  String get timeOffCancelled => 'Time off cancelled';

  @override
  String get timeOffCancelAction => 'Cancel time off';

  @override
  String get timeOffKeep => 'Keep it';

  @override
  String get timeOffCancelConfirmTitle => 'Cancel this time off?';

  @override
  String get timeOffCancelConfirmBody =>
      'It comes off the team\'s list, and the cover stops getting the notifications.';

  @override
  String get timeOffLoadFailed => 'Could not load time off';

  @override
  String get timeOffEmpty => 'No time off yet';

  @override
  String get timeOffEmptyHint =>
      'Add a holiday or a day off, so the team knows who covers for you.';

  @override
  String get timeOffTeamEmpty => 'Everyone is in';

  @override
  String get timeOffTeamEmptyHint =>
      'Nobody has time off in the next three months.';

  @override
  String get timeOffSectionToday => 'Out today';

  @override
  String get timeOffSectionThisWeek => 'Starting this week';

  @override
  String get timeOffSectionLater => 'Later';

  @override
  String get timeOffSectionUpcoming => 'Now and coming up';

  @override
  String get timeOffSectionPast => 'Past';

  @override
  String get timeOffAwayNow => 'Away now';

  @override
  String timeOffAwayUntil(String date) {
    return 'Away until $date';
  }

  @override
  String timeOffAwayOnDay(String name, String kind, String date) {
    return '$name is away that day: $kind until $date';
  }

  @override
  String timeOffConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetings on these days',
      one: '1 meeting on these days',
    );
    return '$_temp0';
  }

  @override
  String get timeOffConflictsHint =>
      'They are still on the calendar. Move them, or hand the work to a colleague.';

  @override
  String get timeOffHandOver => 'Hand over work';

  @override
  String get timeOffErrorOverlaps =>
      'There is already time off on some of these days';

  @override
  String get timeOffErrorTooLong => 'Time off lasts at most a year';

  @override
  String get timeOffErrorCoverIsAbsent => 'Somebody else has to cover';

  @override
  String get timeOffErrorNotYours =>
      'Only the person away or a manager can change this';

  @override
  String timeOffOutToday(int count) {
    return 'Out today: $count';
  }

  @override
  String timeOffCoveringFor(String name) {
    return 'Covering for $name';
  }

  @override
  String notificationsTimeOffCover(String name) {
    return 'You are covering for $name';
  }

  @override
  String get splitsTitle => 'Commission split';

  @override
  String get splitsSheetSubtitle =>
      'Shares of the commission, adding up to 100%';

  @override
  String get splitsNotSplit => 'Not split';

  @override
  String splitsAllToAgent(String name) {
    return 'All of it goes to $name.';
  }

  @override
  String get splitsDealAgent => 'Deal agent';

  @override
  String get splitsColleague => 'Colleague';

  @override
  String get splitsCoBroker => 'Co-broker';

  @override
  String splitsCoBrokerFrom(String agency) {
    return 'Co-broker, $agency';
  }

  @override
  String get splitsInactive => 'No longer active';

  @override
  String splitsPercent(String value) {
    return '$value%';
  }

  @override
  String get splitsAmountUnknown =>
      'Amounts show once the price and the rate are set';

  @override
  String get splitsAdd => 'Split the commission';

  @override
  String get splitsEdit => 'Edit the split';

  @override
  String get splitsClear => 'Give it all to the agent';

  @override
  String get splitsLoadFailed => 'Could not load the commission split';

  @override
  String get splitsAddColleague => 'Add a colleague';

  @override
  String get splitsAddCoBroker => 'Add a co-broker';

  @override
  String get splitsCoBrokerName => 'Co-broker\'s name';

  @override
  String get splitsCoBrokerNameHint => 'Ivan Petrov';

  @override
  String get splitsCoBrokerAgency => 'Their agency';

  @override
  String get splitsCoBrokerAgencyHint => 'Optional';

  @override
  String get splitsCoBrokerNameMissing => 'Name the co-broker';

  @override
  String get splitsShare => 'Share, %';

  @override
  String get splitsRemove => 'Remove';

  @override
  String splitsTotal(String value) {
    return 'Total $value%';
  }

  @override
  String get splitsTotalMustBe100 => 'The shares have to add up to 100%';

  @override
  String get splitsPercentInvalid =>
      'A share is above 0 and at most 100, with up to two decimals';

  @override
  String get splitsBalance => 'Give the rest to the deal agent';

  @override
  String get splitsPickColleague => 'Choose a colleague';

  @override
  String get splitsSearchColleague => 'Search by name';

  @override
  String get splitsNoColleagues => 'Nobody else in the agency to add';

  @override
  String get splitsTooMany => 'At most 10 people share one commission';

  @override
  String get splitsColleagueInactive =>
      'Only active members of the agency can be given a share';

  @override
  String get splitsShareNote =>
      'A split deal\'s commission counts for each person by their share; a co-broker\'s share is not the agency\'s.';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesTotalCaption => 'Spent on this listing';

  @override
  String get expensesNone =>
      'Nothing spent on this listing yet. Record the photographer, ads and the rest to see what it costs.';

  @override
  String get expensesLoadFailed => 'Could not load the expenses';

  @override
  String get expensesLatest => 'Latest';

  @override
  String expensesShowAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String get expensesAdd => 'Add expense';

  @override
  String get expensesAddTitle => 'New expense';

  @override
  String get expensesCategory => 'Spent on';

  @override
  String get expensesAmount => 'Amount';

  @override
  String get expensesAmountHint => 'e.g. 45,000';

  @override
  String get expensesSpentOn => 'Paid on';

  @override
  String get expensesNote => 'Note';

  @override
  String get expensesNoteHint => 'Optional';

  @override
  String get expensesNoteTooLong => 'A note takes at most 500 characters';

  @override
  String get expensesDeleteTitle => 'Delete this expense?';

  @override
  String expensesDeleteBody(String category, String amount) {
    return '$category, $amount: it will no longer count towards this listing.';
  }

  @override
  String get expensesCategoryPhoto => 'Photography';

  @override
  String get expensesCategoryAdvertising => 'Advertising';

  @override
  String get expensesCategoryStaging => 'Staging';

  @override
  String get expensesCategoryCleaning => 'Cleaning';

  @override
  String get expensesCategoryLegal => 'Legal';

  @override
  String get expensesCategoryOther => 'Other';

  @override
  String get expensesSpendTitle => 'Marketing spend';

  @override
  String get expensesSpendHint =>
      'What was spent marketing listings in this period.';

  @override
  String get expensesSpendNone =>
      'Nothing was spent on listings in this period.';

  @override
  String get expensesSpendLoadFailed => 'Could not load marketing spend';

  @override
  String get expensesByCategory => 'By category';

  @override
  String get expensesTopListings => 'Costliest listings';
}
