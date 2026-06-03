import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/room/domain/usercases/join_room_usecase.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_state.dart';

class JoinRoomBloc extends Bloc<JoinRoomEvent, JoinRoomState> {
  JoinRoomBloc(this._joinRoomUseCase) : super(const JoinRoomInitial()) {
    on<JoinRoomSubmitted>(_onSubmitted);
    on<JoinRoomReset>(_onReset);
  }

  final JoinRoomUseCase _joinRoomUseCase;

  Future<void> _onSubmitted(
    JoinRoomSubmitted event,
    Emitter<JoinRoomState> emit,
  ) async {
    emit(const JoinRoomChecking());

    final result = await _joinRoomUseCase(event.code);

    switch (result) {
      case DataSuccess(:final data):
        emit(JoinRoomSuccess(data));
      case DataFailure(:final message):
        emit(JoinRoomFailure(message));
      case DataLoading():
        break; // use case never emits loading
    }
  }

  void _onReset(JoinRoomReset event, Emitter<JoinRoomState> emit) {
    emit(const JoinRoomInitial());
  }
}

