import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_state.dart';

/// A manager hands some of an agent's work to a colleague. Every change of
/// who or what asks the server again for the counts, so what the manager
/// confirms is what moves.
class HandoverBloc extends Bloc<HandoverEvent, HandoverState> {
  final TeamsRepository _teams;
  final ClientsRepository _clients;

  /// Which preview is the latest asked for; an older answer is dropped.
  int _asked = 0;

  HandoverBloc(this._teams, this._clients, {required int fromId})
      : super(HandoverState(fromId: fromId)) {
    on<HandoverLoadEvent>(_onLoad);
    on<HandoverTargetEvent>(
        (e, emit) => _preview(emit, state.copyWith(toId: e.agentId)));
    on<HandoverPartEvent>((e, emit) => _preview(emit, _withPart(e)));
    on<HandoverClientsEvent>((e, emit) => _preview(
        emit,
        e.clientIds == null
            ? state.copyWith(clearPicked: true, clientsOn: true)
            : state.copyWith(picked: e.clientIds, clientsOn: true)));
    on<HandoverConfirmEvent>(_onConfirm);
  }

  HandoverState _withPart(HandoverPartEvent e) {
    switch (e.part) {
      case HandoverPart.clients:
        return state.copyWith(clientsOn: e.on);
      case HandoverPart.listings:
        return state.copyWith(listings: e.on);
      case HandoverPart.deals:
        return state.copyWith(deals: e.on);
      case HandoverPart.upcoming:
        return state.copyWith(upcoming: e.on);
    }
  }

  Future<void> _onLoad(HandoverLoadEvent e, Emitter<HandoverState> emit) async {
    emit(state.copyWith(status: HandoverStatus.loading));
    try {
      final results = await Future.wait([
        _teams.getMembers(),
        _clients.getClients(agentId: state.fromId),
      ]);
      final members = results[0] as List<TeamMemberResponse>;
      final from = members.where((m) => m.id == state.fromId).firstOrNull;
      if (from == null) {
        emit(state.copyWith(
            status: HandoverStatus.error,
            loadFailure: const ApiFailure(ApiFailureKind.notFound)));
        return;
      }
      final clients = results[1] as List<ClientResponse>;
      emit(state.copyWith(
        status: HandoverStatus.ready,
        from: from,
        candidates: members
            .where((m) => m.id != from.id && m.isActive)
            .where((m) => m.status == UserAccountStatus.active)
            .toList(),
        clients: [
          for (final c in clients)
            if (c.agentId == null || c.agentId == from.id) c,
        ],
      ));
    } catch (error) {
      emit(state.copyWith(
          status: HandoverStatus.error, loadFailure: ApiFailure.from(error)));
    }
  }

  Future<void> _preview(Emitter<HandoverState> emit, HandoverState next) async {
    final selection = next.selection;
    final ticket = ++_asked;
    if (selection == null || next.result != null) {
      emit(next.copyWith(
          clearPreview: true, previewing: false, clearPreviewFailure: true));
      return;
    }
    emit(next.copyWith(
        clearPreview: true, previewing: true, clearPreviewFailure: true));
    try {
      final preview = await _teams.previewHandover(selection);
      if (ticket != _asked) return;
      emit(state.copyWith(preview: preview, previewing: false));
    } catch (error) {
      if (ticket != _asked) return;
      emit(state.copyWith(
          previewing: false, previewFailure: ApiFailure.from(error)));
    }
  }

  Future<void> _onConfirm(
      HandoverConfirmEvent e, Emitter<HandoverState> emit) async {
    final selection = state.selection;
    if (selection == null || !state.canConfirm) return;
    emit(state.copyWith(saving: true));
    try {
      final result = await _teams.handOver(selection);
      emit(state.copyWith(saving: false, result: result));
    } catch (error) {
      emit(state.copyWith(
          saving: false, outcome: HandoverFailed(ApiFailure.from(error))));
    }
  }
}
