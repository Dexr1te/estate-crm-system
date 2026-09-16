import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>
    with SingleFlight
    implements Listenable {
  final AuthRepository _repo;
  final List<VoidCallback> _listeners = [];

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthVerifyEmailEvent>(_onVerifyEmail);
    on<AuthResendCodeEvent>(_onResendCode);
    on<AuthRefreshMeEvent>(_onRefreshMe);
    on<AuthAcceptInviteEvent>(_onAcceptInvite);
    on<AuthResetPasswordEvent>(_onResetPassword);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
    on<AuthLogoutEvent>(_onLogout);
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);
  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in List<VoidCallback>.of(_listeners)) {
      l();
    }
  }

  @override
  Future<void> close() {
    _listeners.clear();
    return super.close();
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  bool get isSessionResolved => state is! AuthInitial;
  AuthResponse? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  /// The router waits on [isSessionResolved] before it will route anywhere, so
  /// this handler has to reach an answer even when reading the stored session
  /// throws — an unhandled failure here parks the app on the splash forever.
  Future<void> _onCheck(AuthCheckEvent e, Emitter<AuthState> emit) async {
    AuthResponse? user;
    try {
      user = await _repo.getSavedUser();
    } catch (_) {
      user = null;
    }
    emit(user != null && _repo.isLoggedIn
        ? AuthAuthenticated(user)
        : AuthUnauthenticated());
    _notify();
  }

  /// Signing in twice is two round trips for one intent, and the second answer
  /// can land after the router has already moved on. One at a time.
  Future<void> _onLogin(AuthLoginEvent e, Emitter<AuthState> emit) =>
      once('login', () async {
        emit(AuthLoading());
        try {
          final auth = await _repo.login(e.email, e.password);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          final failure = ApiFailure.from(err);
          // An account that never confirmed its address is not a failed
          // sign-in, it is an unfinished sign-up: the backend has just mailed
          // another code, so carry on to the screen that takes it.
          emit(failure.serverCode == 'EMAIL_NOT_VERIFIED'
              ? AuthVerificationRequired(e.email)
              : AuthError(failure));
        }
      });

  /// Signing up. The account exists after this but cannot be used yet, so the
  /// state stays outside [AuthAuthenticated] and the router keeps the person on
  /// the sign-up side of the app until the code is entered.
  Future<void> _onRegister(AuthRegisterEvent e, Emitter<AuthState> emit) =>
      once('register', () async {
        emit(AuthLoading());
        try {
          await _repo.register(
            fullName: e.fullName,
            email: e.email,
            password: e.password,
            role: e.role,
            phone: e.phone,
          );
          emit(AuthVerificationRequired(e.email));
        } catch (err) {
          emit(AuthError(ApiFailure.from(err)));
        }
      });

  /// The code is spent by the first request that reaches the backend, the same
  /// as an invite — so it takes the same one-at-a-time guard.
  Future<void> _onVerifyEmail(
          AuthVerifyEmailEvent e, Emitter<AuthState> emit) =>
      once('verify-email', () async {
        emit(AuthLoading());
        try {
          final auth = await _repo.verifyEmail(e.email, e.code);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          emit(AuthError(ApiFailure.from(err)));
        }
      });

  /// Asking for another code must not disturb the screen: it stays on the code
  /// form, which is why this reports through the outcome states instead of
  /// [AuthLoading].
  Future<void> _onResendCode(AuthResendCodeEvent e, Emitter<AuthState> emit) =>
      once('resend-code', () async {
        try {
          await _repo.resendVerification(e.email);
          emit(AuthCodeResent(e.email, ActionMessage.codeSent));
        } catch (err) {
          emit(AuthCodeResendFailed(e.email, ApiFailure.from(err)));
        }
      });

  /// Re-reads the account the session belongs to — the only way to notice that
  /// a manager has let this agent into their team, or that they have left one.
  ///
  /// Deliberately never emits [AuthLoading], for the same reason as a profile
  /// edit: the router reads the session off this state and a moment of "not
  /// authenticated" would bounce the user to the sign-in screen.
  Future<void> _onRefreshMe(AuthRefreshMeEvent e, Emitter<AuthState> emit) =>
      once('refresh-me', () async {
        if (currentUser == null) return;
        try {
          emit(AuthAuthenticated(await _repo.refreshMe()));
          _notify();
        } catch (_) {
          // Nothing to say: whatever the session was, it still is.
        }
      });

  /// The invite token is spent by the first request that reaches the backend,
  /// so a second one — a double tap, or Enter and then the button — comes back
  /// as "Invalid invite token". That tells the invitee their invite failed at
  /// the exact moment it succeeded, and leaves them on the form with a password
  /// that already works.
  ///
  /// Handlers run concurrently unless told otherwise, and the button's disabled
  /// state only takes effect a rebuild later, so neither the screen nor the
  /// default transformer can hold this. The guard belongs where the invariant
  /// is: one accept per invite.
  Future<void> _onAcceptInvite(
          AuthAcceptInviteEvent e, Emitter<AuthState> emit) =>
      once('accept-invite', () async {
        emit(AuthLoading());
        try {
          final auth = await _repo.acceptInvite(e.token, e.newPassword);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          emit(AuthError(ApiFailure.from(err)));
        }
      });

  /// A reset token is spent by the first request that reaches the backend, the
  /// same as an invite — so it takes the same guard.
  Future<void> _onResetPassword(
          AuthResetPasswordEvent e, Emitter<AuthState> emit) =>
      once('reset-password', () async {
        emit(AuthLoading());
        try {
          final auth = await _repo.resetPassword(e.token, e.newPassword);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          emit(AuthError(ApiFailure.from(err)));
        }
      });

  /// Renaming yourself, or correcting the address you sign in with.
  ///
  /// Deliberately never emits [AuthLoading]: the router reads the session off
  /// this state, and a moment of "not authenticated" mid-save would land the
  /// user on the sign-in screen. The sheet shows its own progress instead.
  Future<void> _onUpdateProfile(
          AuthUpdateProfileEvent e, Emitter<AuthState> emit) =>
      once('update-profile', () async {
        final current = currentUser;
        if (current == null) return;
        try {
          final updated = await _repo.updateProfile(e.fullName, e.email);
          emit(AuthProfileUpdated(updated, ActionMessage.profileUpdated));
          _notify();
        } catch (err) {
          emit(AuthProfileUpdateFailed(current, ApiFailure.from(err)));
        }
      });

  /// Signing out is local: whatever the store says, the session is over. A
  /// failure here that left the app signed in would strand someone on an
  /// account they have asked to leave.
  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    try {
      await _repo.logout();
    } catch (_) {
      // Nothing to recover: the tokens are already unusable to us.
    }
    emit(AuthUnauthenticated());
    _notify();
  }
}
