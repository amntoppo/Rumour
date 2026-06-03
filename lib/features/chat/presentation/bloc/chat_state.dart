import 'package:equatable/equatable.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';

sealed class ChatState extends Equatable {
  const ChatState({
    required this.messages,
    required this.hasMore,
    required this.cursor,
  });

  final List<MessageEntity> messages;
  final bool hasMore;
  final QueryCursor? cursor;

  @override
  List<Object?> get props => [messages, hasMore, cursor];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(messages: const [], hasMore: true, cursor: null);
}

class ChatLoading extends ChatState {
  const ChatLoading({
    required super.messages,
    required super.hasMore,
    required super.cursor,
  });
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required super.messages,
    required super.hasMore,
    required super.cursor,
  });
}

class ChatFailure extends ChatState {
  const ChatFailure({
    required this.message,
    required super.messages,
    required super.hasMore,
    required super.cursor,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
