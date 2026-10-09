import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/keys/domain/repositories/keys_repository.dart';

abstract class KeysOutEvent {}

class KeysOutLoadEvent extends KeysOutEvent {}

abstract class KeysOutState {
  const KeysOutState();
}

class KeysOutInitial extends KeysOutState {
  const KeysOutInitial();
}

class KeysOutLoading extends KeysOutState {
  const KeysOutLoading();
}

/// Overdue first, then by the day due back, as the server sends them.
class KeysOutLoaded extends KeysOutState {
  final List<KeyHandover> keys;
  const KeysOutLoaded(this.keys);

  int get overdueCount => keys.where((k) => k.overdue).length;
}

class KeysOutError extends KeysOutState {
  final ApiFailure failure;
  const KeysOutError(this.failure);
}

/// Every key out of a listing the user can see.
class KeysOutBloc extends Bloc<KeysOutEvent, KeysOutState>
    with SingleFlight, CollectionBloc<KeysOutEvent, KeysOutState> {
  final KeysRepository _repo;

  KeysOutBloc(this._repo) : super(const KeysOutInitial()) {
    on<KeysOutLoadEvent>((e, emit) => load(
          emit,
          keepVisible: state is KeysOutLoaded,
          skeleton: const KeysOutLoading(),
          fetch: _repo.getKeysOut,
          onData: KeysOutLoaded.new,
          onFailure: KeysOutError.new,
        ));
  }
}
