import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/clients/domain/client_birthday.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/compose_message_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the history keeps of a greeting, as the client card keeps it.
const _maxNote = 2000;

/// Whether the viewer looks at the agency's dates rather than only their
/// own, so each row names whose client it is. False where nobody is signed in.
bool seesAgencyDates(BuildContext context) =>
    _orNull(() => context.isAdminOrManager) ?? false;

/// The signed-in user's details are not there outside the app's shell.
T? _orNull<T>(T Function() read) {
  try {
    return read();
  } catch (_) {
    // No AuthBloc above this context.
    return null;
  }
}

Future<void> callClientDate(
    BuildContext context, UpcomingClientDate date) async {
  final l10n = AppLocalizations.of(context);
  if (!await ContactActions.call(date.phone) && context.mounted) {
    showActionUnavailable(context, l10n.clientsNoPhone);
  }
}

/// Opens the message sheet for the client whose date it is — on a birthday,
/// already filled from the agency's birthday greeting if it has one — and
/// writes what was sent into the client's history, as the client card does.
Future<void> greetClientDate(
    BuildContext context, UpcomingClientDate date) async {
  final l10n = AppLocalizations.of(context);
  if ((date.phone ?? '').replaceAll(RegExp(r'\D'), '').isEmpty) {
    showActionUnavailable(context, l10n.clientsNoPhone);
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  await showComposeMessageSheet(
    context,
    client: ClientResponse(
      id: date.clientId,
      fullName: date.clientName,
      phone: date.phone,
      type: date.clientType ?? ClientType.BUYER,
      agentId: date.agentId,
      agentName: date.agentName,
    ),
    agentName: _orNull<String?>(() => context.currentUserName),
    preferTemplate:
        date.kind == ClientDateKind.birthday ? isBirthdayGreeting : null,
    onSent: (text, propertyId) async {
      try {
        await Injector.clientsRepository.logActivity(date.clientId,
            type: ActivityType.MESSAGE,
            note: text.length > _maxNote ? text.substring(0, _maxNote) : text,
            propertyIds: [if (propertyId != null) propertyId]);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(l10n.clientsSendLogged,
                  maxLines: 2, overflow: TextOverflow.ellipsis)));
      } catch (_) {
        // The greeting is out; the history simply misses this one.
      }
    },
  );
}
