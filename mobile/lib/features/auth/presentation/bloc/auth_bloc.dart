import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
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
    on<AuthAcceptInviteEvent>(_onAcceptInvite);
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
          emit(AuthError(apiErrorMessage(err)));
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
          emit(AuthError(apiErrorMessage(err)));
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
