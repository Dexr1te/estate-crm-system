import 'package:real_estate_crm/core/models/models.dart';

/// What one query found, kept apart by kind so the screen can head each group
/// and send a tap to the right detail route.
class SearchResults {
  final List<ClientResponse> clients;
  final List<PropertyResponse> properties;
  final List<DealResponse> deals;

  /// How many listings matched altogether. The listings endpoint pages, so
  /// [properties] can be the first page of a longer answer and the screen has
  /// to say so rather than quietly showing twenty of two hundred.
  final int propertiesTotal;

  const SearchResults({
    this.clients = const [],
    this.properties = const [],
    this.deals = const [],
    this.propertiesTotal = 0,
  });

  static const empty = SearchResults();

  int get count => clients.length + properties.length + deals.length;

  bool get isEmpty => count == 0;
}

abstract class SearchRepository {
  Future<SearchResults> search(String query);
}
