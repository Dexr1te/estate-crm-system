import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

enum HandoverStatus { loading, ready, error }

class HandoverState {
  final int fromId;
  final HandoverStatus status;
  final ApiFailure? loadFailure;

  /// The agent whose work moves.
  final TeamMemberResponse? from;

  /// Everybody who can take it: active members other than [from].
  final List<TeamMemberResponse> candidates;

  /// The source's clients, for picking some of them.
  final List<ClientResponse> clients;

  final int? toId;
  final bool clientsOn;
  final bool listings;
  final bool deals;
  final bool upcoming;

  /// Only these clients; null for all of them.
  final Set<int>? picked;

  /// What the current choice moves, as the server counts it.
  final HandoverSummary? preview;
  final bool previewing;
  final ApiFailure? previewFailure;

  final bool saving;

  /// Set once the work has changed hands.
  final HandoverSummary? result;

  final ActionOutcome? outcome;

  const HandoverState({
    required this.fromId,
    this.status = HandoverStatus.loading,
    this.loadFailure,
    this.from,
    this.candidates = const [],
    this.clients = const [],
    this.toId,
    this.clientsOn = true,
    this.listings = true,
    this.deals = true,
    this.upcoming = true,
    this.picked,
    this.preview,
    this.previewing = false,
    this.previewFailure,
    this.saving = false,
    this.result,
    this.outcome,
  });

  TeamMemberResponse? get to {
    for (final c in candidates) {
      if (c.id == toId) return c;
    }
    return null;
  }

  bool get _someClients => clientsOn && (picked == null || picked!.isNotEmpty);

  /// What to ask the server about; null until there is somebody to take it
  /// and something to take.
  HandoverSelection? get selection {
    final target = toId;
    if (target == null || (!_someClients && !listings && !deals && !upcoming)) {
      return null;
    }
    return HandoverSelection(
      fromAgentId: fromId,
      toAgentId: target,
      clients: _someClients,
      listings: listings,
      deals: deals,
      upcoming: upcoming,
      clientIds: _someClients && picked != null ? picked!.toList() : null,
    );
  }

  bool get canConfirm =>
      selection != null &&
      !previewing &&
      !saving &&
      result == null &&
      (preview?.total ?? 0) > 0;

  HandoverState copyWith({
    HandoverStatus? status,
    ApiFailure? loadFailure,
    TeamMemberResponse? from,
    List<TeamMemberResponse>? candidates,
    List<ClientResponse>? clients,
    int? toId,
    bool? clientsOn,
    bool? listings,
    bool? deals,
    bool? upcoming,
    Set<int>? picked,
    bool clearPicked = false,
    HandoverSummary? preview,
    bool clearPreview = false,
    bool? previewing,
    ApiFailure? previewFailure,
    bool clearPreviewFailure = false,
    bool? saving,
    HandoverSummary? result,
    ActionOutcome? outcome,
  }) =>
      HandoverState(
        fromId: fromId,
        status: status ?? this.status,
        loadFailure: loadFailure ?? this.loadFailure,
        from: from ?? this.from,
        candidates: candidates ?? this.candidates,
        clients: clients ?? this.clients,
        toId: toId ?? this.toId,
        clientsOn: clientsOn ?? this.clientsOn,
        listings: listings ?? this.listings,
        deals: deals ?? this.deals,
        upcoming: upcoming ?? this.upcoming,
        picked: clearPicked ? null : picked ?? this.picked,
        preview: clearPreview ? null : preview ?? this.preview,
        previewing: previewing ?? this.previewing,
        previewFailure:
            clearPreviewFailure ? null : previewFailure ?? this.previewFailure,
        saving: saving ?? this.saving,
        result: result ?? this.result,
        outcome: outcome,
      );
}

class HandoverFailed with ActionFailed {
  @override
  final ApiFailure failure;
  HandoverFailed(this.failure);
}
