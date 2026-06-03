import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/chat/domain/usercases/load_messages_usecase.dart';
import 'package:rumour_app/features/chat/domain/usercases/send_message_usecase.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

class FakeChatRepository implements ChatRepository {
  List<MessageEntity> cached = [];
  final Stream<List<MessageEntity>> liveStream = Stream.value([]);

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
  }) => liveStream;

  @override
  Future<DataState<PagedData<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  }) async {
    return DataSuccess(PagedData(items: [], nextCursor: null));
  }

  @override
  Future<DataState<void>> sendMessage({
    required String roomCode,
    required String text,
    required IdentityEntity sender,
  }) async {
    return const DataSuccess(null);
  }

  @override
  Stream<int> watchRoomMemberCount(String roomCode) => Stream.value(1);
}

class FakeLoadMessagesUseCase implements LoadMessagesUseCase {
  @override
  Future<DataState<PagedData<MessageEntity>>> call(LoadMessagesParams params) async {
    return DataSuccess(PagedData(items: [], nextCursor: null));
  }
}

class FakeSendMessageUseCase implements SendMessageUseCase {
  @override
  Future<DataState<void>> call(SendMessageParams params) async {
    return const DataSuccess(null);
  }
}

void main() {
  group('ChatBloc Tests', () {
    late FakeChatRepository repository;
    late FakeLoadMessagesUseCase loadMessagesUseCase;
    late FakeSendMessageUseCase sendMessageUseCase;
    late IdentityEntity identity;
    late ChatBloc bloc;

    setUp(() {
      repository = FakeChatRepository();
      loadMessagesUseCase = FakeLoadMessagesUseCase();
      sendMessageUseCase = FakeSendMessageUseCase();
      identity = const IdentityEntity(
        id: 'user_123',
        displayName: 'Test Anon',
        username: 'testanon',
        roomId: 'room_123',
      );
      bloc = ChatBloc(
        repository: repository,
        loadMessagesUseCase: loadMessagesUseCase,
        sendMessageUseCase: sendMessageUseCase,
        identity: identity,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ChatInitial', () {
      expect(bloc.state, isA<ChatInitial>());
    });

    test('isMyMessage returns true for sender, false otherwise', () {
      final msgMine = MessageEntity(
        id: '1',
        text: 'Hi',
        senderId: 'user_123',
        senderName: 'Test Anon',
        createdAt: DateTime.now(),
      );
      final msgOther = MessageEntity(
        id: '2',
        text: 'Hi back',
        senderId: 'user_456',
        senderName: 'Other Anon',
        createdAt: DateTime.now(),
      );

      expect(bloc.isMyMessage(msgMine), true);
      expect(bloc.isMyMessage(msgOther), false);
    });
  });
}
