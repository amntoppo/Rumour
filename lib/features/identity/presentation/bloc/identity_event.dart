import 'package:equatable/equatable.dart';

sealed class IdentityEvent extends Equatable {
  const IdentityEvent();

  @override
  List<Object?> get props => [];
}

class LoadIdentity extends IdentityEvent {
  const LoadIdentity(this.roomCode);
  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}

class AcknowledgeReveal extends IdentityEvent {
  const AcknowledgeReveal();
}
