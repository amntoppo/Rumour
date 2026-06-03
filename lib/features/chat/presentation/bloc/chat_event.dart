import 'package:equatable/equatable.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSubscribed extends ChatEvent {
  const ChatSubscribed(this.roomCode);
  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}

class ChatLiveUpdateReceived extends ChatEvent {
  const ChatLiveUpdateReceived(this.messages);
  final List<MessageEntity> messages;

  @override
  List<Object?> get props => [messages];
}

class ChatLoadMoreRequested extends ChatEvent {
  const ChatLoadMoreRequested(this.roomCode);
  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);
  final String text;

  @override
  List<Object?> get props => [text];
}
