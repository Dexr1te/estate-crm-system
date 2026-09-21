abstract class SearchEvent {}

class SearchRecentLoadEvent extends SearchEvent {}

class SearchQueryEvent extends SearchEvent {
  final String query;
  SearchQueryEvent(this.query);
}

class SearchClearedEvent extends SearchEvent {}

class SearchRememberEvent extends SearchEvent {
  final String query;
  SearchRememberEvent(this.query);
}

class SearchForgetAllEvent extends SearchEvent {}
