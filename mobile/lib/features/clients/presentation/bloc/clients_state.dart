import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<ClientSummary> clients;
  ClientsLoaded(this.clients);
}

class ClientsError extends ClientsState {
  final ApiFailure failure;
  ClientsError(this.failure);
}

class ClientsActionSuccess extends ClientsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  ClientsActionSuccess(this.message, super.clients);
}

class ClientsActionFailure extends ClientsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  ClientsActionFailure(this.failure, super.clients);
}

class ClientCreated extends ClientsLoaded {
  final ClientResponse client;
  ClientCreated(this.client, super.clients);
}

class ClientSummary {
  final int id;
  final String fullName;
  final String? phone;
  final String? email;
  final ClientType type;
  final String? agentName;
  final int dealCount;

  final double totalBudget;

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
