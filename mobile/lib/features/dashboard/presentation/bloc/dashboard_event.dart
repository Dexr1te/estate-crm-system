abstract class DashboardEvent {}

class DashboardLoadEvent extends DashboardEvent {}

/// Drops the cached summary on sign-out. See `ClientsResetEvent` for why.
class DashboardResetEvent extends DashboardEvent {}