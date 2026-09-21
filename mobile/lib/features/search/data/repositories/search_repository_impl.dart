import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  static const pageSize = 20;

  final ClientsRepository _clients;
  final PropertiesRepository _properties;
  final DealsRepository _deals;

  SearchRepositoryImpl(this._clients, this._properties, this._deals);

  @override
  Future<SearchResults> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return SearchResults.empty;

    final answers = await Future.wait<Object>([
      _clients.getClients(search: q),
      _properties.getProperties(search: q, size: pageSize),
      _deals.getDeals(),
    ]);

    final listings = answers[1] as PagedResponse<PropertyResponse>;

    return SearchResults(
      clients: answers[0] as List<ClientResponse>,
      properties: listings.content,
      propertiesTotal: listings.totalElements,
      deals: (answers[2] as List<DealResponse>)
          .where((d) => dealMatches(d, q))
          .toList(),
    );
  }
}

bool dealMatches(DealResponse deal, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return false;

  bool has(String? value) => value != null && value.toLowerCase().contains(q);

  return has(deal.title) ||
      has(deal.clientName) ||
      has(deal.agentName) ||
      has(deal.propertyTitle) ||
      q == '${deal.id}' ||
      q == '#${deal.id}';
}
