import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What a completed write says to the person who asked for it.
///
/// A bloc has no [BuildContext] and so cannot reach the localizations. It names
/// the outcome instead and the screen showing it supplies the wording — the same
/// split `roleLabel` and `dealStatusLabel` already use for enums.
enum ActionMessage {
  clientCreated,
  clientUpdated,
  clientDeleted,
  propertyCreated,
  propertyUpdated,
  propertyDeleted,
  dealCreated,
  dealUpdated,
  dealDeleted,
  meetingCreated,
  meetingUpdated,
  meetingDeleted,
  meetingCompleted,
  documentUploaded,
  documentDeleted,
  statusUpdated,
  teamCreated,
  teamUpdated,
  agentInvited,
  userActivated,
  userDeactivated,
  userDeleted,
  roleUpdated,
  teamAssigned,
  inviteResent,
  profileUpdated,
  codeSent,
  requestSent,
  requestCancelled,
  teamJoined,
  requestDeclined,
  memberRemoved,
  teamLeft,
}

String actionMessageLabel(AppLocalizations l10n, ActionMessage message) {
  switch (message) {
    case ActionMessage.clientCreated:
      return l10n.msgClientCreated;
    case ActionMessage.clientUpdated:
      return l10n.msgClientUpdated;
    case ActionMessage.clientDeleted:
      return l10n.msgClientDeleted;
    case ActionMessage.propertyCreated:
      return l10n.msgPropertyCreated;
    case ActionMessage.propertyUpdated:
      return l10n.msgPropertyUpdated;
    case ActionMessage.propertyDeleted:
      return l10n.msgPropertyDeleted;
    case ActionMessage.dealCreated:
      return l10n.msgDealCreated;
    case ActionMessage.dealUpdated:
      return l10n.msgDealUpdated;
    case ActionMessage.dealDeleted:
      return l10n.msgDealDeleted;
    case ActionMessage.meetingCreated:
      return l10n.msgMeetingCreated;
    case ActionMessage.meetingUpdated:
      return l10n.msgMeetingUpdated;
    case ActionMessage.meetingDeleted:
      return l10n.msgMeetingDeleted;
    case ActionMessage.meetingCompleted:
      return l10n.msgMeetingCompleted;
    case ActionMessage.documentUploaded:
      return l10n.msgDocumentUploaded;
    case ActionMessage.documentDeleted:
      return l10n.msgDocumentDeleted;
    case ActionMessage.statusUpdated:
      return l10n.msgStatusUpdated;
    case ActionMessage.teamCreated:
      return l10n.msgTeamCreated;
    case ActionMessage.teamUpdated:
      return l10n.msgTeamUpdated;
    case ActionMessage.agentInvited:
      return l10n.msgAgentInvited;
    case ActionMessage.userActivated:
      return l10n.msgUserActivated;
    case ActionMessage.userDeactivated:
      return l10n.msgUserDeactivated;
    case ActionMessage.userDeleted:
      return l10n.msgUserDeleted;
    case ActionMessage.roleUpdated:
      return l10n.msgRoleUpdated;
    case ActionMessage.teamAssigned:
      return l10n.msgTeamAssigned;
    case ActionMessage.inviteResent:
      return l10n.msgInviteResent;
    case ActionMessage.codeSent:
      return l10n.msgCodeSent;
    case ActionMessage.requestSent:
      return l10n.msgRequestSent;
    case ActionMessage.requestCancelled:
      return l10n.msgRequestCancelled;
    case ActionMessage.teamJoined:
      return l10n.msgTeamJoined;
    case ActionMessage.requestDeclined:
      return l10n.msgRequestDeclined;
    case ActionMessage.memberRemoved:
      return l10n.msgMemberRemoved;
    case ActionMessage.teamLeft:
      return l10n.msgTeamLeft;
    case ActionMessage.profileUpdated:
      return l10n.msgProfileUpdated;
  }
}

/// Something the phone itself refused, with no request involved.
///
/// [ApiFailure] cannot say these: nothing was sent. A file too large to attach
/// is caught before the upload, and a phone with no app for a downloaded type
/// is a fact about the phone rather than an error from the server.
enum LocalProblem { fileTooLarge, noAppForFile, fileOpenFailed }

String localProblemLabel(AppLocalizations l10n, LocalProblem problem) {
  switch (problem) {
    case LocalProblem.fileTooLarge:
      return l10n.documentsTooLarge(maxDocumentBytes ~/ (1024 * 1024));
    case LocalProblem.noAppForFile:
      return l10n.documentsNoApp;
    case LocalProblem.fileOpenFailed:
      return l10n.documentsOpenFailed;
  }
}

/// The sentence shown for a failed request.
///
/// Anything the backend said wins: it knows the rule that was broken, and a
/// generic line in the right language helps less than a specific one in the
/// wrong one.
String apiFailureLabel(AppLocalizations l10n, ApiFailure failure) {
  final server = failure.serverText;
  if (server != null) return server;

  switch (failure.kind) {
    case ApiFailureKind.credentials:
      return l10n.coreErrorCredentials;
    case ApiFailureKind.forbidden:
      return l10n.coreErrorForbidden;
    case ApiFailureKind.notFound:
      return l10n.coreErrorNotFound;
    case ApiFailureKind.conflict:
      return l10n.coreErrorConflict;
    case ApiFailureKind.badRequest:
      return l10n.coreErrorBadRequest;
    case ApiFailureKind.server:
      return l10n.coreErrorServer;
    case ApiFailureKind.timeout:
      return l10n.coreErrorTimeout;
    case ApiFailureKind.offline:
      return l10n.coreErrorOffline;
    case ApiFailureKind.unknown:
      return l10n.coreErrorUnknown;
  }
}
