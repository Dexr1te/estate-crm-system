/// Guards a bloc against out-of-order loads.
///
/// `bloc`'s default event transformer runs handlers **concurrently**. Two
/// loads triggered close together — a mutation queuing a reload while a
/// pull-to-refresh is already in flight, or two quick status changes — can
/// therefore resolve in either order, and without a guard the *slower* one
/// wins simply because it answered last.
///
/// Each load takes a ticket with [startLoad] before its first `await` and
/// checks [isStale] after every one; a stale handler returns without emitting,
/// leaving the newest load to produce the final state.
mixin LoadGeneration {
  int _generation = 0;

  /// Marks the start of a fresh load and returns its ticket.
  int startLoad() => ++_generation;

  /// The ticket of the load currently in force. Work that is not itself a
  /// fresh load — paging in the next page, say — takes this before awaiting so
  /// it can tell whether a reload has superseded it.
  int get currentLoad => _generation;

  /// Whether a newer load has started since [ticket] was issued.
  bool isStale(int ticket) => ticket != _generation;
}
