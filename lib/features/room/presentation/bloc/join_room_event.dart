import 'package:equatable/equatable.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class JoinRoomEvent extends Equatable {
  const JoinRoomEvent();

  @override
  List<Object?> get props => [];
}

class JoinRoomSubmitted extends JoinRoomEvent {
  const JoinRoomSubmitted(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class JoinRoomReset extends JoinRoomEvent {
  const JoinRoomReset();
}
