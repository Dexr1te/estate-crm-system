import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';

// Events
abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email, password;
  AuthLoginEvent(this.email, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String fullName, email, password;
  final String? phone;
  final Role role;
  AuthRegisterEvent(
      {required this.fullName,
      required this.email,
      required this.password,
      this.phone,
      this.role = Role.AGENT});
}

class AuthLogoutEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponse user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> implements Listenable {
  final ApiService _api;
  final List<VoidCallback> _listeners = [];

  AuthBloc(this._api) : super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
  }

  // Listenable for GoRouter
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);
  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) l();
  }

  bool get isAuthenticated => state is AuthAuthenticated;
  AuthResponse? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  Future<void> _onCheck(AuthCheckEvent e, Emitter<AuthState> emit) async {
    final user = await _api.getSavedUser();
    if (user != null && _api.isLoggedIn) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
    _notify();
  }

  Future<void> _onLogin(AuthLoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _api.login(e.email, e.password);
      await _api.saveAuth(auth);
      emit(AuthAuthenticated(auth));
      _notify();
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onRegister(AuthRegisterEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _api.register(
          fullName: e.fullName,
          email: e.email,
          password: e.password,
          phone: e.phone,
          role: e.role);
      await _api.saveAuth(auth);
      emit(AuthAuthenticated(auth));
      _notify();
    } catch (err) {
      emit(AuthError(_parseError(err)));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    await _api.clearAuth();
    emit(AuthUnauthenticated());
    _notify();
  }

  String _parseError(dynamic e) {
    final s = e.toString();
    if (s.contains('401')) return 'Invalid email or password';
    if (s.contains('409')) return 'Email already registered';
    if (s.contains('SocketException') || s.contains('Connection'))
      return 'Cannot connect to server';
    return 'Something went wrong. Please try again.';
  }
}
