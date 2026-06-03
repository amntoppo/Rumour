import 'package:equatable/equatable.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class JoinRoomState extends Equatable {
  const JoinRoomState();

  @override
  List<Object?> get props => [];
}

class JoinRoomInitial extends JoinRoomState {
  const JoinRoomInitial();
}

class JoinRoomChecking extends JoinRoomState {
  const JoinRoomChecking();
}

class JoinRoomSuccess extends JoinRoomState {
  const JoinRoomSuccess(this.room);

  final RoomEntity room;

  @override
  List<Object?> get props => [room];
}

class JoinRoomFailure extends JoinRoomState {
  const JoinRoomFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
