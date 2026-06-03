import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';

class RoomCodeFormBloc extends Bloc<RoomCodeFormEvent, RoomCodeFormState> {
  RoomCodeFormBloc() : super(const RoomCodeFormState()) {
    on<RoomCodeDigitAdded>(_onDigitAdded);
    on<RoomCodeBackspaced>(_onBackspaced);
    on<RoomCodeFormCleared>(_onCleared);
  }

  void _onDigitAdded(
    RoomCodeDigitAdded event,
    Emitter<RoomCodeFormState> emit,
  ) {
    if (state.isComplete) return; // already full
    final updated = List<String>.from(state.digits)..add(event.digit);
    emit(state.copyWith(digits: updated));
  }

  void _onBackspaced(
    RoomCodeBackspaced event,
    Emitter<RoomCodeFormState> emit,
  ) {
    if (state.digits.isEmpty) return;
    final updated = List<String>.from(state.digits)..removeLast();
    emit(state.copyWith(digits: updated));
  }

  void _onCleared(
    RoomCodeFormCleared event,
    Emitter<RoomCodeFormState> emit,
  ) {
    emit(const RoomCodeFormState());
  }
}
