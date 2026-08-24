import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';

/// Search has no endpoint of its own. It fans one query out over the listings
/// that already exist and stands the three answers side by side — which is why
/// this feature has no datasource: there is no new call to make.
///
/// Clients and listings are filtered by the server, which knows about phone
/// numbers and addresses. Deals have no `search` parameter, so their list —
/// short by nature, one row per open negotiation — is fetched whole and matched
/// here rather than left out of the results.
class SearchRepositoryImpl implements SearchRepository {
  /// Deliberately larger than a screenful: the count in each section header is
  /// the real total, and a short page would make "and 180 more" the answer to
  /// almost every query.
  static const pageSize = 20;

  final ClientsRepository _clients;
  final PropertiesRepository _properties;
  final DealsRepository _deals;

  SearchRepositoryImpl(this._clients, this._properties, this._deals);

  @override
  Future<SearchResults> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return SearchResults.empty;

    // Future.wait rather than three awaits: it rethrows the first failure and
    // still takes the other two off the loop, instead of leaving a rejected
    // future to surface later as an unhandled error.
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

/// Everything about a deal someone would think to type: what it is called, who
/// it is for, who is running it, the listing behind it, and the id off a card.
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
