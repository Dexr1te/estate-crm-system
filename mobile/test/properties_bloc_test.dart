import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

import 'fakes.dart';

const _properties = [
  PropertyResponse(id: 1, title: 'A', status: PropertyStatus.AVAILABLE),
  PropertyResponse(id: 2, title: 'B', status: PropertyStatus.RESERVED),
];

/// Serves each `getProperties` call from a future the test completes by hand,
/// so two loads can be put in flight at once.
class _ManualPropertiesRepository extends FakePropertiesRepository {
  _ManualPropertiesRepository() : super(_properties);

  final _pending = <Completer<PagedResponse<PropertyResponse>>>[];
  int get inFlight => _pending.length;

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
  }) {
    final c = Completer<PagedResponse<PropertyResponse>>();
    _pending.add(c);
    return c.future;
  }

  void complete(int index, List<PropertyResponse> content) {
    _pending[index].complete(PagedResponse(
      content: content,
      page: 0,
      totalPages: 1,
      totalElements: content.length,
      isLast: true,
    ));
  }
}

void main() {
  test('overlapping reloads do not duplicate the list', () async {
    // Reproduces the reported bug: changing a property's status twice fires
    // two reloads, and bloc's default transformer runs them concurrently.
    final repo = _ManualPropertiesRepository();
    final bloc = PropertiesBloc(repo);
    addTearDown(bloc.close);

    bloc.add(PropertiesLoadEvent());
    await Future<void>.delayed(Duration.zero);
    bloc.add(PropertiesLoadEvent());
    await Future<void>.delayed(Duration.zero);
    expect(repo.inFlight, 2, reason: 'both loads should be in flight');

    // Resolve out of order: the first request answers last.
    repo.complete(1, _properties);
    await Future<void>.delayed(Duration.zero);
    repo.complete(0, _properties);
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state;
    expect(state, isA<PropertiesLoaded>());
    final loaded = state as PropertiesLoaded;
    expect(loaded.properties, hasLength(2),
        reason: 'the stale response must be dropped, not appended');
    expect(loaded.properties.map((p) => p.id), [1, 2]);
  });

  test('a load-more that lands after a reload is discarded', () async {
    final repo = _ManualPropertiesRepository();
    final bloc = PropertiesBloc(repo);
    addTearDown(bloc.close);

    // First page, with more available.
    bloc.add(PropertiesLoadEvent());
    await Future<void>.delayed(Duration.zero);
    repo._pending[0].complete(const PagedResponse(
      content: [PropertyResponse(id: 1, title: 'A')],
      page: 0,
      totalPages: 2,
      totalElements: 2,
      isLast: false,
    ));
    await Future<void>.delayed(Duration.zero);

    // Page two starts, then a reload overtakes it.
    bloc.add(PropertiesLoadMoreEvent());
    await Future<void>.delayed(Duration.zero);
    bloc.add(PropertiesLoadEvent());
    await Future<void>.delayed(Duration.zero);

    repo.complete(1, const [PropertyResponse(id: 2, title: 'B')]); // load-more
    await Future<void>.delayed(Duration.zero);
    repo.complete(2, const [PropertyResponse(id: 1, title: 'A')]); // reload
    await Future<void>.delayed(Duration.zero);

    final loaded = bloc.state as PropertiesLoaded;
    expect(loaded.properties.map((p) => p.id), [1],
        reason: 'the superseded page must not be appended to the fresh list');
  });
}
