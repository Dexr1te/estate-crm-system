abstract class SearchEvent {}

/// Reads the remembered queries back so an empty field has something to offer.
class SearchRecentLoadEvent extends SearchEvent {}

/// A query worth running — the screen debounces the typing behind it.
class SearchQueryEvent extends SearchEvent {
  final String query;
  SearchQueryEvent(this.query);
}

/// The field was emptied, so the results go and the recent queries come back.
class SearchClearedEvent extends SearchEvent {}

/// A query that led somewhere, worth offering back next time.
class SearchRememberEvent extends SearchEvent {
  final String query;
  SearchRememberEvent(this.query);
}

class SearchForgetAllEvent extends SearchEvent {}
