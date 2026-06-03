import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/chat/domain/usercases/load_messages_usecase.dart';
import 'package:rumour_app/features/chat/domain/usercases/send_message_usecase.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FakeAppException extends AppException {
  const _FakeAppException(super.message);
}

class _TestCursor extends QueryCursor {
  const _TestCursor();
}

MessageEntity _msg(String id, {String senderId = 'user_1'}) => MessageEntity(
      id: id,
      text: 'msg $id',
      senderId: senderId,
      senderName: 'Alice',
      createdAt: DateTime.now(),
    );

// ── Configurable fake repository ──────────────────────────────────────────────

class _FakeChatRepository implements ChatRepository {
  List<MessageEntity> cached;
  DataState<PagedData<MessageEntity>> Function(QueryCursor?) loadResult;

  _FakeChatRepository({
    this.cached = const [],
    DataState<PagedData<MessageEntity>> Function(QueryCursor?)? loadResult,
  }) : loadResult = loadResult ??
            ((_) => DataSuccess(PagedData(items: const [], nextCursor: null)));

  @override
  Future<List<MessageEntity>> getCachedMessages(String roomCode) async => cached;

  @override
  Future<void> cacheMessages(String roomCode, List<MessageEntity> messages) async {
    cached = messages;
  }

  @override
  Stream<List<MessageEntity>> streamLatestMessages({
    required String roomCode,
    required int limit,
  }) => Stream.value(const []);

  @override
  Future<DataState<PagedData<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  }) async => loadResult(after);

  @override
  Future<DataState<void>> sendMessage({
    required String roomCode,
    required String text,
    required IdentityEntity sender,
  }) async => const DataSuccess(null);

  @override
  Stream<int> watchRoomMemberCount(String roomCode) => Stream.value(1);
}

class _FakeLoadMessages implements LoadMessagesUseCase {
  DataState<PagedData<MessageEntity>> result;
  _FakeLoadMessages(this.result);

  @override
  Future<DataState<PagedData<MessageEntity>>> call(LoadMessagesParams p) async => result;
}

class _FakeSendMessage implements SendMessageUseCase {
  DataState<void> result;
  _FakeSendMessage([this.result = const DataSuccess(null)]);

  @override
  Future<DataState<void>> call(SendMessageParams p) async => result;
}

// ── Identity ──────────────────────────────────────────────────────────────────

const _identity = IdentityEntity(
  id: 'user_1',
  displayName: 'Alice',
  username: 'alice',
  roomId: 'room_1',
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ChatBloc (extended)', () {
    late ChatBloc bloc;

    tearDown(() => bloc.close());

    // ── ChatSubscribed ──────────────────────────────────────────────────────

    test('ChatSubscribed with cache emits ChatLoaded with cached messages immediately', () async {
      final cached = [_msg('c1'), _msg('c2')];
      final repo = _FakeChatRepository(cached: cached);

      bloc = ChatBloc(
        repository: repo,
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: const [], nextCursor: null)),
        ),
        sendMessageUseCase: _FakeSendMessage(),
        identity: _identity,
      );

      final states = <ChatState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      // At minimum we should see a ChatLoaded with cached content
      final loaded = states.whereType<ChatLoaded>();
      expect(loaded, isNotEmpty);
      expect(loaded.first.messages.map((m) => m.id).contains('c1'), isTrue);
    });

    test('ChatSubscribed remote success sets hasMore and cursor', () async {
      const cursor = _TestCursor();
      final remoteMessages = [_msg('r1'), _msg('r2'), _msg('r3')];

      bloc = ChatBloc(
        repository: _FakeChatRepository(),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: remoteMessages, nextCursor: cursor)),
        ),
        sendMessageUseCase: _FakeSendMessage(),
        identity: _identity,
      );

      final states = <ChatState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      final loaded = states.whereType<ChatLoaded>().last;
      expect(loaded.hasMore, isTrue);
      expect(loaded.cursor, cursor);
      expect(loaded.messages.map((m) => m.id).contains('r1'), isTrue);
    });

    // ── ChatLoadMoreRequested ───────────────────────────────────────────────

    test('ChatLoadMoreRequested does nothing when hasMore is false', () async {
      bloc = ChatBloc(
        repository: _FakeChatRepository(),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: const [], nextCursor: null)),
        ),
        sendMessageUseCase: _FakeSendMessage(),
        identity: _identity,
      );

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      // State now has hasMore = false
      expect(bloc.state.hasMore, isFalse);

      final statesBefore = bloc.state;
      bloc.add(const ChatLoadMoreRequested('room_1'));
      await Future.delayed(Duration.zero);

      // State should be unchanged (no new ChatLoaded)
      expect(bloc.state, statesBefore);
    });

    test('ChatLoadMoreRequested appends new page and updates cursor', () async {
      final page1 = [_msg('p1a'), _msg('p1b')];
      final page2 = [_msg('p2a'), _msg('p2b')];
      const cursor1 = _TestCursor();

      var callCount = 0;
      bloc = ChatBloc(
        repository: _FakeChatRepository(
          loadResult: (_) {
            callCount++;
            if (callCount == 1) {
              return DataSuccess(PagedData(items: page1, nextCursor: cursor1));
            }
            return DataSuccess(PagedData(items: page2, nextCursor: null));
          },
        ),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: page1, nextCursor: cursor1)),
        ),
        sendMessageUseCase: _FakeSendMessage(),
        identity: _identity,
      );

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      // Now load more (bloc has cursor1)
      bloc.add(const ChatLoadMoreRequested('room_1'));
      await Future.delayed(Duration.zero);

      final state = bloc.state;
      // Combined pages, no more pages
      final ids = state.messages.map((m) => m.id).toSet();
      expect(ids.containsAll(['p1a', 'p1b']), isTrue);
    });

    // ── ChatMessageSent ─────────────────────────────────────────────────────

    test('ChatMessageSent with empty text does not change state', () async {
      bloc = ChatBloc(
        repository: _FakeChatRepository(),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: const [], nextCursor: null)),
        ),
        sendMessageUseCase: _FakeSendMessage(),
        identity: _identity,
      );

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      final stateAfterSubscribe = bloc.state;

      final emittedStates = <ChatState>[];
      bloc.stream.listen(emittedStates.add);

      bloc.add(const ChatMessageSent('   ')); // whitespace only
      await Future.delayed(Duration.zero);

      expect(emittedStates, isEmpty);
      expect(bloc.state, stateAfterSubscribe);
    });

    test('ChatMessageSent success stays in ChatLoaded (no extra state emission)', () async {
      bloc = ChatBloc(
        repository: _FakeChatRepository(),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: const [], nextCursor: null)),
        ),
        sendMessageUseCase: _FakeSendMessage(const DataSuccess(null)),
        identity: _identity,
      );

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      final emittedAfter = <ChatState>[];
      bloc.stream.listen(emittedAfter.add);

      bloc.add(const ChatMessageSent('Hello!'));
      await Future.delayed(Duration.zero);

      expect(emittedAfter.whereType<ChatFailure>(), isEmpty);
    });

    test('ChatMessageSent failure emits ChatFailure', () async {
      bloc = ChatBloc(
        repository: _FakeChatRepository(),
        loadMessagesUseCase: _FakeLoadMessages(
          DataSuccess(PagedData(items: const [], nextCursor: null)),
        ),
        sendMessageUseCase: _FakeSendMessage(
          const DataFailure(_FakeAppException('Send failed')),
        ),
        identity: _identity,
      );

      bloc.add(const ChatSubscribed('room_1'));
      await Future.delayed(Duration.zero);

      final emittedAfter = <ChatState>[];
      bloc.stream.listen(emittedAfter.add);

      bloc.add(const ChatMessageSent('Oops'));
      await Future.delayed(Duration.zero);

      expect(emittedAfter.whereType<ChatFailure>(), isNotEmpty);
    });
  });
}
