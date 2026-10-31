import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/session/session_transitions.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

const _inTeam = AuthResponse(
    userId: 6, fullName: 'Aigerim', role: Role.AGENT, teamId: 1, teamName: 'A');
const _noTeam = AuthResponse(userId: 6, fullName: 'Aigerim', role: Role.AGENT);

void main() {
  // Leaving an agency keeps the session, so only a sign-out used to clear the
  // feature lists and cancel the reminders. The old agency's rows stayed on
  // screen and its meetings kept ringing.
  test('leaving an agency, or joining one, changes the agency', () {
    expect(
        agencyChanged(AuthAuthenticated(_inTeam), AuthAuthenticated(_noTeam)),
        isTrue);
    expect(
        agencyChanged(AuthAuthenticated(_noTeam), AuthAuthenticated(_inTeam)),
        isTrue);
    expect(
        agencyChanged(AuthAuthenticated(_inTeam),
            AuthAuthenticated(_inTeam.copyWith(teamId: 2))),
        isTrue);
  });

  test('a profile refresh in the same agency is not a change', () {
    expect(
        agencyChanged(AuthAuthenticated(_inTeam),
            AuthAuthenticated(_inTeam.copyWith(fullName: 'Aigerim S.'))),
        isFalse);
  });

  test('signing out ends the session, which is not an agency change', () {
    expect(sessionEnded(AuthAuthenticated(_inTeam), AuthUnauthenticated()),
        isTrue);
    expect(agencyChanged(AuthAuthenticated(_inTeam), AuthUnauthenticated()),
        isFalse);
  });
}
