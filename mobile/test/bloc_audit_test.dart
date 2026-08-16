import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

import 'fakes.dart';

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FailingProperties extends FakePropertiesRepository {
  _FailingProperties() : super(const [PropertyResponse(id: 1, title: 'A')]);
  @override
  Future<PropertyResponse> updatePropertyStatus(int id, PropertyStatus s) =>
      Future.error(Exception('network down'));
}

class _FailingClients extends FakeClientsRepository {
  _FailingClients()
      : super(clients: const [ClientResponse(id: 1, fullName: 'A')]);
  @override
  Future<void> deleteClient(int id) => Future.error(Exception('forbidden'));
}

class _FailingDeals extends FakeDealsRepository {
  _FailingDeals() : super(const [DealResponse(id: 1, clientId: 1, agentId: 1)]);
  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus s) =>
      Future.error(Exception('network down'));
}

class _FailingMeetings extends FakeMeetingsRepository {
  _FailingMeetings()
      : super([
          MeetingResponse(
              id: 1,
              title: 'A',
              scheduledAt: DateTime(2030),
              agentId: 1,
              clientId: 1)
        ]);
  @override
  Future<MeetingResponse> completeMeeting(int id) =>
      Future.error(Exception('network down'));
}

void main() {
  group('a failed mutation must not destroy the loaded list', () {
    test('properties', () async {
      final bloc = PropertiesBloc(_FailingProperties());
      addTearDown(bloc.close);
      bloc.add(PropertiesLoadEvent());
      await _settle();
      expect(bloc.state, isA<PropertiesLoaded>());

      bloc.add(PropertiesUpdateStatusEvent(1, PropertyStatus.SOLD));
      await _settle();

      expect(bloc.state, isA<PropertiesLoaded>(),
          reason: 'the list is still valid; a failed write should surface a '
              'message, not replace the screen with a full-page error');
    });

    test('clients', () async {
      final bloc = ClientsBloc(_FailingClients());
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();
      expect(bloc.state, isA<ClientsLoaded>());

      bloc.add(ClientsDeleteEvent(1));
      await _settle();

      expect(bloc.state, isA<ClientsLoaded>(),
          reason: 'a failed delete must not blank the list');
    });

    test('deals', () async {
      final bloc = DealsBloc(_FailingDeals());
      addTearDown(bloc.close);
      bloc.add(DealsLoadEvent());
      await _settle();
      expect(bloc.state, isA<DealsLoaded>());

      bloc.add(DealsUpdateStatusEvent(1, DealStatus.CLOSED_WON));
      await _settle();

      expect(bloc.state, isA<DealsLoaded>(),
          reason: 'a failed status change must not blank the list');
    });

    test('meetings', () async {
      final bloc = MeetingsBloc(_FailingMeetings());
      addTearDown(bloc.close);
      bloc.add(MeetingsLoadEvent());
      await _settle();
      expect(bloc.state, isA<MeetingsLoaded>());

      bloc.add(MeetingsCompleteEvent(1));
      await _settle();

      expect(bloc.state, isA<MeetingsLoaded>(),
          reason: 'a failed completion must not blank the list');
    });
  });

  test('overlapping client reloads resolve newest-last', () async {
    final repo = _ManualClients();
    final bloc = ClientsBloc(repo);
    addTearDown(bloc.close);

    bloc.add(ClientsLoadEvent());
    await _settle();
    bloc.add(ClientsLoadEvent());
    await _settle();
    expect(repo.inFlight, 2, reason: 'both loads should be in flight');

    repo.complete(1, 'fresh');
    await _settle();
    repo.complete(0, 'stale');
    await _settle();

    final loaded = bloc.state as ClientsLoaded;
    expect(loaded.clients.single.fullName, 'fresh',
        reason: 'the superseded response must not overwrite the newer one');
  });

  group('signing out drops the previous account\'s data', () {
    test('clients', () async {
      final bloc = ClientsBloc(FakeClientsRepository(
          clients: const [ClientResponse(id: 1, fullName: 'A')]));
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();
      expect((bloc.state as ClientsLoaded).clients, hasLength(1));

      bloc.add(ClientsResetEvent());
      await _settle();
      expect(bloc.state, isA<ClientsInitial>(),
          reason: 'the bloc outlives the session, so the next account must not '
              'render these rows on its first frame');
    });

    test('a load in flight when the session ends cannot repopulate', () async {
      final repo = _ManualClients();
      final bloc = ClientsBloc(repo);
      addTearDown(bloc.close);

      bloc.add(ClientsLoadEvent());
      await _settle();
      bloc.add(ClientsResetEvent());
      await _settle();

      repo.complete(0, 'previous account');
      await _settle();

      expect(bloc.state, isA<ClientsInitial>(),
          reason: 'a response fetched with the old token must be discarded');
    });
  });

  group('a write that is already running is not sent twice', () {
    test('a double-tapped create files one client', () async {
      final repo = _GatedClients();
      final bloc = ClientsBloc(repo);
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();

      bloc.add(ClientsCreateEvent(const {'fullName': 'B'}));
      bloc.add(ClientsCreateEvent(const {'fullName': 'B'}));
      await _settle();

      expect(repo.creates, 1,
          reason: 'the second tap arrives before the button can disable, and '
              'two rows is not what anyone meant by tapping twice');

      repo.finish();
      await _settle();
    });

    test('but a different row is still its own write', () async {
      final repo = _GatedClients();
      final bloc = ClientsBloc(repo);
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();

      bloc.add(ClientsDeleteEvent(1));
      bloc.add(ClientsDeleteEvent(2));
      await _settle();

      expect(repo.deleted, [1, 2],
          reason: 'deleting two clients in a row is two intents');
    });
  });

  group('signing out is local, and always lands', () {
    test('a store that fails to clear still ends the session', () async {
      final bloc = AuthBloc(_FailingLogout());
      addTearDown(bloc.close);
      bloc.add(AuthLoginEvent('a@b.c', 'pw'));
      await _settle();
      expect(bloc.state, isA<AuthAuthenticated>());

      bloc.add(AuthLogoutEvent());
      await _settle();

      expect(bloc.state, isA<AuthUnauthenticated>(),
          reason: 'nobody should be stranded on an account they have left');
    });

    test('an unreadable stored session still resolves the splash', () async {
      final bloc = AuthBloc(_UnreadableSession());
      addTearDown(bloc.close);
      bloc.add(AuthCheckEvent());
      await _settle();

      expect(bloc.isSessionResolved, isTrue,
          reason: 'the router waits on this; an unhandled throw parks the app '
              'on the splash forever');
      expect(bloc.state, isA<AuthUnauthenticated>());
    });
  });

  test('an in-flight mutation survives the bloc being closed', () async {
    final repo = _SlowAdmin();
    final bloc = AdminUsersBloc(repo);
    bloc.add(AdminDeactivateUserEvent(1));
    await _settle();
    await bloc.close();
    repo.finish();
    await _settle();
  });
}

class _GatedClients extends FakeClientsRepository {
  _GatedClients()
      : super(clients: const [
          ClientResponse(id: 1, fullName: 'A'),
          ClientResponse(id: 2, fullName: 'B'),
        ]);

  int creates = 0;
  final deleted = <int>[];
  final _gate = Completer<ClientResponse>();

  void finish() =>
      _gate.complete(const ClientResponse(id: 3, fullName: 'created'));

  @override
  Future<List<ClientListItem>> getClientsWithDetails() async => const [];

  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) {
    creates++;
    return _gate.future;
  }

  @override
  Future<void> deleteClient(int id) async => deleted.add(id);
}

class _FailingLogout extends FakeAuthRepository {
  _FailingLogout()
      : super(
            user: const AuthResponse(
                accessToken: 'a',
                refreshToken: 'r',
                userId: 1,
                fullName: 'A',
                email: 'a@b.c',
                role: Role.AGENT));

  @override
  Future<void> logout() => Future.error(Exception('storage unavailable'));
}

class _UnreadableSession extends FakeAuthRepository {
  @override
  Future<AuthResponse?> getSavedUser() =>
      Future.error(Exception('storage unavailable'));
}

class _ManualClients extends FakeClientsRepository {
  final _pending = <Completer<List<ClientResponse>>>[];
  int get inFlight => _pending.length;

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) {
    final c = Completer<List<ClientResponse>>();
    _pending.add(c);
    return c.future;
  }

  @override
  Future<List<ClientListItem>> getClientsWithDetails() async => const [];

  void complete(int i, String name) =>
      _pending[i].complete([ClientResponse(id: 1, fullName: name)]);
}

class _SlowAdmin implements AdminRepository {
  final _gate = Completer<AgentResponse>();
  void finish() => _gate.complete(const AgentResponse(
      id: 1, fullName: 'A', email: 'a@b.c', role: Role.AGENT, isActive: false));

  @override
  Future<AgentResponse> deactivateUser(int id) => _gate.future;
  @override
  Future<List<AgentResponse>> getUsers() async => const [];
  @override
  noSuchMethod(Invocation i) => throw UnimplementedError();
}
