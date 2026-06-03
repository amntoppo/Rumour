import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/chat/domain/usercases/load_messages_usecase.dart';
import 'package:rumour_app/features/chat/domain/usercases/send_message_usecase.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository repository,
    required LoadMessagesUseCase loadMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required this.identity,
  })  : _repository = repository,
        _loadMessages = loadMessagesUseCase,
        _sendMessage = sendMessageUseCase,
        mySenderId = identity.id,
        super(const ChatInitial()) {
    on<ChatSubscribed>(_onSubscribed);
    on<ChatLiveUpdateReceived>(_onLiveUpdateReceived);
    on<ChatLoadMoreRequested>(_onLoadMoreRequested);
    on<ChatMessageSent>(_onMessageSent);
  }

  final ChatRepository _repository;
  final LoadMessagesUseCase _loadMessages;
  final SendMessageUseCase _sendMessage;
  final IdentityEntity identity;
  final String mySenderId;

  static const int _pageSize = 30;
  String? _roomCode;
  StreamSubscription<List<MessageEntity>>? _liveSub;

  bool isMyMessage(MessageEntity message) => message.senderId == mySenderId;

  Future<void> _onSubscribed(
    ChatSubscribed event,
    Emitter<ChatState> emit,
  ) async {
    _roomCode = event.roomCode;

    emit(ChatLoading(
      messages: state.messages,
      hasMore: state.hasMore,
      cursor: state.cursor,
    ));

    // 1. Load from Hive local cache first to ensure immediate display
    final cached = await _repository.getCachedMessages(event.roomCode);
    if (cached.isNotEmpty) {
      emit(ChatLoaded(
        messages: cached,
        hasMore: state.hasMore,
        cursor: state.cursor,
      ));
    }

    // 2. Subscribe to the live Firestore collection
    await _liveSub?.cancel();
    _liveSub = _repository
        .streamLatestMessages(roomCode: event.roomCode, limit: _pageSize)
        .listen(
      (messages) {
        add(ChatLiveUpdateReceived(messages));
      },
      onError: (err) {
        // Log or handle stream errors gracefully
      },
    );

    // 3. Fetch initial remote page to set the first pagination cursor
    final result = await _loadMessages(LoadMessagesParams(
      roomCode: event.roomCode,
      pageSize: _pageSize,
      after: null,
    ));

    if (isClosed) return;

    switch (result) {
      case DataSuccess(:final data):
        final nextCursor = data.nextCursor;
        final hasMore = data.hasMore;

        // Merge initial page into current list (which might have cache or pending updates)
        final remoteIds = data.items.map((m) => m.id).toSet();
        final merged = <MessageEntity>[
          ...data.items,
          for (final msg in state.messages)
            if (!remoteIds.contains(msg.id)) msg,
        ];

        emit(ChatLoaded(
          messages: merged,
          hasMore: hasMore,
          cursor: nextCursor,
        ));

        // Cache the newly retrieved list
        await _repository.cacheMessages(event.roomCode, merged);

      case DataFailure(:final error):
        // Fallback to cache without breaking the screen if remote fails on startup
        if (state.messages.isEmpty) {
          emit(ChatFailure(
            message: error.message,
            messages: state.messages,
            hasMore: state.hasMore,
            cursor: state.cursor,
          ));
        } else {
          emit(ChatLoaded(
            messages: state.messages,
            hasMore: state.hasMore,
            cursor: state.cursor,
          ));
        }
      case DataLoading():
        break;
    }
  }

  void _onLiveUpdateReceived(
    ChatLiveUpdateReceived event,
    Emitter<ChatState> emit,
  ) {
    if (isClosed) return;

    final latestIds = event.messages.map((m) => m.id).toSet();
    final merged = <MessageEntity>[
      ...event.messages,
      for (final msg in state.messages)
        if (!latestIds.contains(msg.id)) msg,
    ];

    emit(ChatLoaded(
      messages: merged,
      hasMore: state.hasMore,
      cursor: state.cursor,
    ));

    if (_roomCode != null) {
      _repository.cacheMessages(_roomCode!, merged);
    }
  }

  Future<void> _onLoadMoreRequested(
    ChatLoadMoreRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoading || !state.hasMore || state.cursor == null) return;

    emit(ChatLoading(
      messages: state.messages,
      hasMore: state.hasMore,
      cursor: state.cursor,
    ));

    final result = await _loadMessages(LoadMessagesParams(
      roomCode: event.roomCode,
      pageSize: _pageSize,
      after: state.cursor,
    ));

    if (isClosed) return;

    switch (result) {
      case DataSuccess(:final data):
        final nextMessages = data.items;
        final hasMore = data.hasMore;
        final nextCursor = data.nextCursor;

        final current = state.messages;
        final currentIds = current.map((m) => m.id).toSet();

        final merged = <MessageEntity>[
          ...current,
          for (final msg in nextMessages)
            if (!currentIds.contains(msg.id)) msg,
        ];

        emit(ChatLoaded(
          messages: merged,
          hasMore: hasMore,
          cursor: nextCursor,
        ));

        await _repository.cacheMessages(event.roomCode, merged);

      case DataFailure(:final error):
        emit(ChatFailure(
          message: error.message,
          messages: state.messages,
          hasMore: state.hasMore,
          cursor: state.cursor,
        ));
      case DataLoading():
        break;
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final trimmed = event.text.trim();
    if (trimmed.isEmpty || _roomCode == null) return;

    final result = await _sendMessage(SendMessageParams(
      roomCode: _roomCode!,
      text: trimmed,
      sender: identity,
    ));

    if (isClosed) return;

    switch (result) {
      case DataSuccess():
        break;
      case DataFailure(:final error):
        emit(ChatFailure(
          message: error.message,
          messages: state.messages,
          hasMore: state.hasMore,
          cursor: state.cursor,
        ));
      case DataLoading():
        break;
    }
  }

  @override
  Future<void> close() {
    _liveSub?.cancel();
    return super.close();
  }
}
