import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
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
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _GrowingClients extends FakeClientsRepository {
  final _rows = <ClientResponse>[const ClientResponse(id: 1, fullName: 'A')];

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) async =>
      List.of(_rows);

  @override
  Future<List<ClientListItem>> getClientsWithDetails() async => const [];

  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) async {
    final created = ClientResponse(id: _rows.length + 1, fullName: 'B');
    _rows.add(created);
    return created;
  }

  @override
  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) async {
    _rows[0] = const ClientResponse(id: 1, fullName: 'A renamed');
    return _rows[0];
  }
}

class _GrowingProperties extends FakePropertiesRepository {
  _GrowingProperties() : super(const []);
  final _rows = <PropertyResponse>[const PropertyResponse(id: 1, title: 'A')];

  @override
  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int size = 20,
  }) async =>
      PagedResponse(
        content: List.of(_rows),
        page: 0,
        totalPages: 1,
        totalElements: _rows.length,
        isLast: true,
      );

  @override
  Future<PropertyResponse> createProperty(Map<String, dynamic> data) async {
    final created = PropertyResponse(id: _rows.length + 1, title: 'B');
    _rows.add(created);
    return created;
  }
}

class _GrowingDeals extends FakeDealsRepository {
  _GrowingDeals() : super(const []);
  final _rows = <DealResponse>[
    const DealResponse(id: 1, clientId: 1, agentId: 1)
  ];

  @override
  Future<List<DealResponse>> getDeals(
          {int? agentId, DealStatus? status}) async =>
      List.of(_rows);

  @override
  Future<DealResponse> createDeal(Map<String, dynamic> data) async {
    final created = DealResponse(id: _rows.length + 1, clientId: 1, agentId: 1);
    _rows.add(created);
    return created;
  }
}

class _GrowingMeetings extends FakeMeetingsRepository {
  _GrowingMeetings() : super(const []);
  final _rows = <MeetingResponse>[
    MeetingResponse(id: 1, scheduledAt: DateTime(2030), agentId: 1, clientId: 1)
  ];

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) async =>
      List.of(_rows);

  @override
  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) async {
    final created = MeetingResponse(
        id: _rows.length + 1,
        scheduledAt: DateTime(2030),
        agentId: 1,
        clientId: 1);
    _rows.add(created);
    return created;
  }
}

void main() {
  group('a create is reflected in the list without a manual refresh', () {
    test('clients', () async {
      final bloc = ClientsBloc(_GrowingClients());
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();

      bloc.add(ClientsCreateEvent(const {'fullName': 'B'}));
      await _settle();

      final state = bloc.state;
      expect(state, isA<ClientsLoaded>());
      expect((state as ClientsLoaded).clients, hasLength(2));
    });

    test('properties', () async {
      final bloc = PropertiesBloc(_GrowingProperties());
      addTearDown(bloc.close);
      bloc.add(PropertiesLoadEvent());
      await _settle();

      bloc.add(PropertiesCreateEvent(const {'title': 'B'}));
      await _settle();

      final state = bloc.state;
      expect(state, isA<PropertiesLoaded>());
      expect((state as PropertiesLoaded).properties, hasLength(2));
    });

    test('deals', () async {
      final bloc = DealsBloc(_GrowingDeals());
      addTearDown(bloc.close);
      bloc.add(DealsLoadEvent());
      await _settle();

      bloc.add(DealsCreateEvent(const {'title': 'B'}));
      await _settle();

      expect((bloc.state as DealsLoaded).deals, hasLength(2));
    });

    test('meetings', () async {
      final bloc = MeetingsBloc(_GrowingMeetings());
      addTearDown(bloc.close);
      bloc.add(MeetingsLoadEvent());
      await _settle();

      bloc.add(MeetingsCreateEvent(const {'title': 'B'}));
      await _settle();

      expect((bloc.state as MeetingsLoaded).meetings, hasLength(2));
    });
  });

  test('an edit is reflected in the list without a manual refresh', () async {
    final bloc = ClientsBloc(_GrowingClients());
    addTearDown(bloc.close);
    bloc.add(ClientsLoadEvent());
    await _settle();

    bloc.add(ClientsUpdateEvent(1, const {'fullName': 'A renamed'}));
    await _settle();

    expect((bloc.state as ClientsLoaded).clients.first.fullName, 'A renamed');
  });

  group('refreshing already-loaded data does not blank it to a skeleton', () {
    test('clients', () async {
      final bloc = ClientsBloc(_GrowingClients());
      addTearDown(bloc.close);
      bloc.add(ClientsLoadEvent());
      await _settle();

      final seen = <ClientsState>[];
      final sub = bloc.stream.listen(seen.add);
      addTearDown(sub.cancel);

      bloc.add(ClientsLoadEvent());
      await _settle();

      expect(seen.whereType<ClientsLoading>(), isEmpty,
          reason: 'the loaded list should stay on screen while it refreshes');
      expect(seen.whereType<ClientsLoaded>(), isNotEmpty);
    });

    test('properties', () async {
      final bloc = PropertiesBloc(_GrowingProperties());
      addTearDown(bloc.close);
      bloc.add(PropertiesLoadEvent());
      await _settle();

      final seen = <PropertiesState>[];
      final sub = bloc.stream.listen(seen.add);
      addTearDown(sub.cancel);

      bloc.add(PropertiesLoadEvent());
      await _settle();

      expect(seen.whereType<PropertiesLoading>(), isEmpty);
    });

    test('but changing a filter does', () async {
      final bloc = PropertiesBloc(_GrowingProperties());
      addTearDown(bloc.close);
      bloc.add(PropertiesLoadEvent());
      await _settle();

      final seen = <PropertiesState>[];
      final sub = bloc.stream.listen(seen.add);
      addTearDown(sub.cancel);

      bloc.add(PropertiesLoadEvent(status: PropertyStatus.SOLD));
      await _settle();

      expect(seen.whereType<PropertiesLoading>(), isNotEmpty);
    });

    test('the first load still shows a skeleton', () async {
      final bloc = ClientsBloc(_GrowingClients());
      addTearDown(bloc.close);

      final seen = <ClientsState>[];
      final sub = bloc.stream.listen(seen.add);
      addTearDown(sub.cancel);

      bloc.add(ClientsLoadEvent());
      await _settle();

      expect(seen.whereType<ClientsLoading>(), isNotEmpty,
          reason: 'with nothing to show, the skeleton is the right answer');
    });
  });
}
