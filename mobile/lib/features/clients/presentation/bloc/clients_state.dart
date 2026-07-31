import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<ClientSummary> clients;
  ClientsLoaded(this.clients);
}

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [ClientsActionFailure] instead.
class ClientsError extends ClientsState {
  final String message;
  ClientsError(this.message);
}

/// A write succeeded. Extends [ClientsLoaded] and carries the list forward so
/// the screen keeps its content while the reload runs.
class ClientsActionSuccess extends ClientsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  ClientsActionSuccess(this.message, super.clients);
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list rather than replacing the screen with an error page.
class ClientsActionFailure extends ClientsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  ClientsActionFailure(this.message, super.clients);
}

/// Emitted after a successful create, carrying the new client's id.
///
/// Extends [ClientsLoaded] so the list survives the round trip: the reload
/// this triggers checks whether anything is already on screen before deciding
/// to show a skeleton.
class ClientCreated extends ClientsLoaded {
  final ClientResponse client;
  ClientCreated(this.client, super.clients);
}

/// One row of the clients list.
///
/// `/clients/with-details` returns one row **per client-deal pair** and omits
/// the client type and agent; `/clients` has those but no deal figures. This
/// joins the two so the list card can show the designed type chip, deal count
/// and value without a backend change.
class ClientSummary {
  final int id;
  final String fullName;
  final String? phone;
  final String? email;
  final ClientType type;
  final String? agentName;
  final int dealCount;

  /// Sum of the client's deal budgets. Zero when nothing is quantified yet.
  final double totalBudget;

  /// The stage of the most advanced deal, used as the trailing label when
  /// there is no value to show.
  final DealStatus? status;

  final DateTime? nextMeetingAt;

  const ClientSummary({
    required this.id,
    required this.fullName,
    required this.type,
    this.phone,
    this.email,
    this.agentName,
    this.dealCount = 0,
    this.totalBudget = 0,
    this.status,
    this.nextMeetingAt,
  });

  bool matches(String query) {
    final q = query.toLowerCase();
    return fullName.toLowerCase().contains(q) ||
        (email?.toLowerCase().contains(q) ?? false) ||
        (phone?.contains(q) ?? false);
  }

  /// Joins the authoritative client records with the detail rows.
  static List<ClientSummary> join(
    List<ClientResponse> clients,
    List<ClientListItem> details,
  ) {
    final byClient = <int, List<ClientListItem>>{};
    for (final d in details) {
      byClient.putIfAbsent(d.id, () => []).add(d);
    }

    return clients.map((c) {
      final rows = byClient[c.id] ?? const <ClientListItem>[];
      // A row only counts as a deal when it actually carries deal data — the
      // endpoint emits a bare row for clients with none.
      final dealRows = rows
          .where((r) =>
              r.propertyTitle != null || r.budget != null || r.status != null)
          .toList();

      return ClientSummary(
        id: c.id,
        fullName: c.fullName,
        phone: c.phone,
        email: c.email,
        type: c.type,
        agentName: c.agentName,
        dealCount: dealRows.length,
        totalBudget: dealRows.fold(0.0, (sum, r) => sum + (r.budget ?? 0)),
        status: _mostAdvanced(dealRows),
        nextMeetingAt: rows
            .map((r) => r.nextMeetingAt)
            .whereType<DateTime>()
            .fold<DateTime?>(
                null, (a, b) => a == null || b.isBefore(a) ? b : a),
      );
    }).toList();
  }

  static DealStatus? _mostAdvanced(List<ClientListItem> rows) {
    const order = [
      DealStatus.CLOSED_WON,
      DealStatus.NEGOTIATION,
      DealStatus.LEAD,
      DealStatus.CLOSED_LOST,
    ];
    for (final s in order) {
      if (rows.any((r) => r.status == s)) return s;
    }
    return null;
  }
}
