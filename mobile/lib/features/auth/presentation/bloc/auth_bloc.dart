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

          emit(failure.serverCode == 'EMAIL_NOT_VERIFIED'
              ? AuthVerificationRequired(e.email)
              : AuthError(failure));
        }
      });

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

  Future<void> _onResendCode(AuthResendCodeEvent e, Emitter<AuthState> emit) =>
      once('resend-code', () async {
        try {
          await _repo.resendVerification(e.email);
          emit(AuthCodeResent(e.email, ActionMessage.codeSent));
        } catch (err) {
          emit(AuthCodeResendFailed(e.email, ApiFailure.from(err)));
        }
      });

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
    emit(AuthUnauthenticated());
    _notify();
  }
}
