import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

/// The session ended: everything the account could see has to go.
bool sessionEnded(AuthState prev, AuthState curr) =>
    prev is AuthAuthenticated && curr is! AuthAuthenticated;

/// Still signed in, but every record behind the session changed: the person
/// left their agency, was taken into one, or was moved to another.
bool agencyChanged(AuthState prev, AuthState curr) =>
    prev is AuthAuthenticated &&
    curr is AuthAuthenticated &&
    prev.user.teamId != curr.user.teamId;
