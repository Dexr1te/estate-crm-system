import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';

abstract class SearchState {}

/// Nothing asked for yet: either the field is empty or what is in it is still
/// too short to be worth a round trip.
class SearchIdle extends SearchState {
  final List<String> recent;
  SearchIdle([this.recent = const []]);
}

class SearchLoading extends SearchState {
  final String query;
  SearchLoading(this.query);
}

class SearchLoaded extends SearchState {
  final String query;
  final SearchResults results;
  SearchLoaded(this.query, this.results);
}

class SearchError extends SearchState {
  final String query;
  final ApiFailure failure;
  SearchError(this.query, this.failure);
}
