import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/keys/domain/repositories/keys_repository.dart';

abstract class PropertyKeysEvent {}

class PropertyKeysLoadEvent extends PropertyKeysEvent {}

class PropertyKeysHandOverEvent extends PropertyKeysEvent {
  final KeyHandoverDraft draft;
  PropertyKeysHandOverEvent(this.draft);
}

class PropertyKeysReturnEvent extends PropertyKeysEvent {}

enum PropertyKeysStatus { loading, loaded, error }

/// A write the server refused. The card says why, and the keys are read
/// again, since the refusal usually means somebody else got there first.
class PropertyKeysWriteFailed {
  final ApiFailure failure;
  const PropertyKeysWriteFailed(this.failure);
}

class PropertyKeysState {
  final PropertyKeysStatus status;
  final PropertyKeys keys;
  final bool saving;

  /// Bumped on every write the server took.
  final int saved;
  final ApiFailure? loadFailure;

  /// Set on the one state that reports a refused write, cleared after.
  final PropertyKeysWriteFailed? writeFailure;

  const PropertyKeysState({
    this.status = PropertyKeysStatus.loading,
    this.keys = PropertyKeys.empty,
    this.saving = false,
    this.saved = 0,
    this.loadFailure,
    this.writeFailure,
  });

  PropertyKeysState copyWith({
    PropertyKeysStatus? status,
    PropertyKeys? keys,
    bool? saving,
    int? saved,
    ApiFailure? loadFailure,
    PropertyKeysWriteFailed? writeFailure,
  }) =>
      PropertyKeysState(
        status: status ?? this.status,
        keys: keys ?? this.keys,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        loadFailure: loadFailure ?? this.loadFailure,
        writeFailure: writeFailure,
      );
}

/// One listing's keys, and handing them out and taking them back from its
/// card.
class PropertyKeysBloc extends Bloc<PropertyKeysEvent, PropertyKeysState> {
  final KeysRepository _repo;
  final int propertyId;

  PropertyKeysBloc(this._repo, {required this.propertyId})
      : super(const PropertyKeysState()) {
    on<PropertyKeysLoadEvent>(_onLoad);
    on<PropertyKeysHandOverEvent>(
        (e, emit) => _write(emit, () => _repo.handOver(propertyId, e.draft)));
    on<PropertyKeysReturnEvent>(
        (e, emit) => _write(emit, () => _repo.returnKeys(propertyId)));
  }

  Future<void> _onLoad(
      PropertyKeysLoadEvent e, Emitter<PropertyKeysState> emit) async {
    final wasLoaded = state.status == PropertyKeysStatus.loaded;
    if (!wasLoaded) {
      emit(state.copyWith(status: PropertyKeysStatus.loading));
    }
    try {
      final keys = await _repo.getForProperty(propertyId);
      emit(state.copyWith(status: PropertyKeysStatus.loaded, keys: keys));
    } catch (error) {
      final failure = ApiFailure.from(error);
      emit(wasLoaded
          ? state.copyWith(writeFailure: PropertyKeysWriteFailed(failure))
          : state.copyWith(
              status: PropertyKeysStatus.error, loadFailure: failure));
    }
  }

  Future<void> _write(
    Emitter<PropertyKeysState> emit,
    Future<PropertyKeys> Function() call,
  ) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final keys = await call();
      emit(state.copyWith(keys: keys, saving: false, saved: state.saved + 1));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          writeFailure: PropertyKeysWriteFailed(ApiFailure.from(error))));
      if (!isClosed) add(PropertyKeysLoadEvent());
    }
  }
}
