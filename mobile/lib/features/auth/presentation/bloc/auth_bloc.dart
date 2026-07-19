import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> implements Listenable {
  final AuthRepository _repo;
  final List<VoidCallback> _listeners = [];

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthAcceptInviteEvent>(_onAcceptInvite);
    on<AuthLogoutEvent>(_onLogout);
  }

  // Listenable for GoRouter
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);
  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  bool get isAuthenticated => state is AuthAuthenticated;
  AuthResponse? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  Future<void> _onCheck(AuthCheckEvent e, Emitter<AuthState> emit) async {
    final user = await _repo.getSavedUser();
    if (user != null && _repo.isLoggedIn) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
    _notify();
  }

  Future<void> _onLogin(AuthLoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.login(e.email, e.password);
      emit(AuthAuthenticated(auth));
      _notify();
    } catch (err) {
      emit(AuthError(apiErrorMessage(err)));
    }
  }

  Future<void> _onAcceptInvite(
      AuthAcceptInviteEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.acceptInvite(e.token, e.newPassword);
      emit(AuthAuthenticated(auth));
      _notify();
    } catch (err) {
      emit(AuthError(apiErrorMessage(err)));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthUnauthenticated());
    _notify();
  }
}
