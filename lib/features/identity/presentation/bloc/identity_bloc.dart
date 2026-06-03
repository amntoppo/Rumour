import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/identity/domain/usecases/get_identity_usecase.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_event.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_state.dart';
import 'package:rumour_app/features/room/domain/usercases/join_room_usecase.dart';

class IdentityBloc extends Bloc<IdentityEvent, IdentityState> {
  IdentityBloc(
    this._getIdentityUseCase,
    this._joinRoomUseCase,
  ) : super(IdentityInitial()) {
    on<LoadIdentity>(_onLoadIdentity);
    on<AcknowledgeReveal>(_onAcknowledgeReveal);
  }

  final GetIdentityUseCase _getIdentityUseCase;
  final JoinRoomUseCase _joinRoomUseCase;

  Future<void> _onLoadIdentity(
    LoadIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    if (state is IdentityLoading || state is IdentitySuccess) {
      return;
    }

    // 1. Check if identity is cached locally
    final cached = await _getIdentityUseCase.getCached(event.roomCode);
    if (cached != null) {
      // Data exists locally: emit success immediately, do not show loading
      emit(IdentitySuccess(cached, isFresh: false));
      return;
    }

    // 2. Cache miss: emit loading state
    emit(IdentityLoading());

    // 3. Perform room joining / creation (which fetches and caches the identity)
    final result = await _joinRoomUseCase(event.roomCode);
    switch (result) {
      case DataSuccess():
        // Since joinRoom succeeded, the identity is guaranteed to be cached
        final identity = await _getIdentityUseCase.getCached(event.roomCode);
        if (identity != null) {
          emit(IdentitySuccess(identity, isFresh: true));
        } else {
          emit(const IdentityFailure('Failed to load identity after joining room.'));
        }
      case DataFailure(:final error):
        emit(IdentityFailure(error.message));
      case DataLoading():
        break;
    }
  }

  void _onAcknowledgeReveal(
    AcknowledgeReveal event,
    Emitter<IdentityState> emit,
  ) {
    final current = state;
    if (current is IdentitySuccess) {
      emit(IdentitySuccess(current.identity, isFresh: false));
    }
  }
}
