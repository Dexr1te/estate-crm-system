import 'package:real_estate_crm/core/models/models.dart';

class SearchResults {
  final List<ClientResponse> clients;
  final List<PropertyResponse> properties;
  final List<DealResponse> deals;

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
