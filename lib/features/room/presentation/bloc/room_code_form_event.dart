import 'package:equatable/equatable.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class RoomCodeFormEvent extends Equatable {
  const RoomCodeFormEvent();

  @override
  List<Object?> get props => [];
}

class RoomCodeDigitAdded extends RoomCodeFormEvent {
  const RoomCodeDigitAdded(this.digit);

  final String digit;

  @override
  List<Object?> get props => [digit];
}

class RoomCodeBackspaced extends RoomCodeFormEvent {
  const RoomCodeBackspaced();
}

class RoomCodeFormCleared extends RoomCodeFormEvent {
  const RoomCodeFormCleared();
}
