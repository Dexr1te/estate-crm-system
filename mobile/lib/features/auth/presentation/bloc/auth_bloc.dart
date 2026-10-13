import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/auth_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/money.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/auth/domain/email_verifier.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>
    with SingleFlight
    implements Listenable {
  final AuthRepository _repo;
  final EmailVerifier _verifier;
  final List<VoidCallback> _listeners = [];

  AuthBloc(this._repo, {EmailVerifier? verifier})
      : _verifier = verifier ?? const _NoEmailVerifier(),
        super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthStartDemoEvent>(_onStartDemo);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthConfirmEmailEvent>(_onConfirmEmail);
    on<AuthResendLinkEvent>(_onResendLink);
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

  /// Keeps the app-wide currency on the signed-in agency's: set on sign-in and
  /// every refresh of the profile, back to dollars on sign-out.
  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (next is AuthAuthenticated) {
      AppCurrency.setCode(next.user.teamCurrency);
    } else if (next is AuthUnauthenticated) {
      AppCurrency.reset();
    }
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  bool get isSessionResolved => state is! AuthInitial;
  AuthResponse? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

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

  Future<void> _onLogin(AuthLoginEvent e, Emitter<AuthState> emit) =>
      once('login', () async {
        emit(AuthLoading());
        try {
          final auth = await _repo.login(e.email, e.password);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          final failure = ApiFailure.from(err);
          if (failure.serverCode != 'EMAIL_NOT_VERIFIED') {
            emit(AuthError(failure));
            return;
          }
          try {
            await _sendLink(
                await _repo.startVerification(e.email, e.password), emit);
          } catch (err) {
            emit(AuthError(ApiFailure.from(err)));
          }
        }
      });

  Future<void> _onStartDemo(AuthStartDemoEvent e, Emitter<AuthState> emit) =>
      once('demo', () async {
        emit(AuthDemoStarting());
        try {
          final auth = await _repo.startDemo();
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          final status = err is DioException ? err.response?.statusCode : null;
          emit(AuthDemoFailed(ApiFailure.from(err),
              unavailable: status == 404 || status == 429));
        }
      });

  Future<void> _onRegister(AuthRegisterEvent e, Emitter<AuthState> emit) =>
      once('register', () async {
        emit(AuthLoading());
        try {
          final result = await _repo.register(
            fullName: e.fullName,
            email: e.email,
            password: e.password,
            role: e.role,
            phone: e.phone,
          );
          switch (result) {
            case RegisterSignedIn(:final auth):
              emit(AuthAuthenticated(auth));
              _notify();
            case VerificationTicket ticket:
              await _sendLink(ticket, emit);
          }
        } catch (err) {
          emit(AuthError(ApiFailure.from(err)));
        }
      });

  Future<void> _sendLink(
      VerificationTicket ticket, Emitter<AuthState> emit) async {
    try {
      await _verifier.sendLink(ticket.firebaseToken);
      emit(AuthVerificationRequired(ticket.email));
    } catch (err) {
      emit(AuthLinkFailed(ticket.email, _problemOf(err)));
    }
  }

  Future<void> _onConfirmEmail(
          AuthConfirmEmailEvent e, Emitter<AuthState> emit) =>
      once('confirm-email', () async {
        if (!e.silent) emit(AuthVerificationChecking(e.email));
        final String? idToken;
        try {
          idToken = await _verifier.confirmedIdToken();
        } catch (err) {
          if (!e.silent) emit(AuthLinkFailed(e.email, _problemOf(err)));
          return;
        }
        if (idToken == null) {
          if (!e.silent) emit(AuthEmailNotConfirmed(e.email));
          return;
        }
        try {
          final auth = await _repo.verifyEmail(idToken);
          emit(AuthAuthenticated(auth));
          _notify();
        } catch (err) {
          if (e.silent) return;
          final failure = ApiFailure.from(err);
          emit(failure.serverCode == 'EMAIL_NOT_CONFIRMED'
              ? AuthEmailNotConfirmed(e.email)
              : AuthVerificationFailed(e.email, failure));
          return;
        }
        try {
          await _verifier.signOut();
        } catch (_) {}
      });

  Future<void> _onResendLink(AuthResendLinkEvent e, Emitter<AuthState> emit) =>
      once('resend-link', () async {
        try {
          await _verifier.resendLink();
          emit(AuthLinkResent(e.email));
        } catch (err) {
          emit(AuthLinkFailed(e.email, _problemOf(err)));
        }
      });

  static EmailVerificationProblem _problemOf(Object err) =>
      err is EmailVerificationException
          ? err.problem
          : EmailVerificationProblem.unknown;

  Future<void> _onRefreshMe(AuthRefreshMeEvent e, Emitter<AuthState> emit) =>
      once('refresh-me', () async {
        if (currentUser == null) return;
        try {
          emit(AuthAuthenticated(await _repo.refreshMe()));
          _notify();
        } catch (_) {}
      });

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

  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    try {
      await _repo.logout();
    } catch (_) {}
    try {
      await _verifier.signOut();
    } catch (_) {}
    emit(AuthUnauthenticated());
    _notify();
  }
}

class _NoEmailVerifier implements EmailVerifier {
  const _NoEmailVerifier();

  @override
  Future<void> sendLink(String firebaseToken) => _missing();
  @override
  Future<void> resendLink() => _missing();
  @override
  Future<String?> confirmedIdToken() => _missing();
  @override
  Future<void> signOut() async {}

  static Future<Never> _missing() =>
      Future.error(StateError('AuthBloc was given no EmailVerifier'));
}
