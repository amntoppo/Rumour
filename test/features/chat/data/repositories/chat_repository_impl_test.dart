import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';
import 'package:rumour_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

class FakeChatRemoteDataSource implements ChatRemoteDataSource {
  final Map<String, List<MessageModel>> db = {};
  int loadCallCount = 0;
  int streamCallCount = 0;
  int sendCallCount = 0;
  int watchMembersCallCount = 0;

  @override
  Future<PagedData<MessageModel>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  }) async {
    loadCallCount++;
    final list = db[roomCode] ?? [];
    return PagedData(items: list, nextCursor: null);
  }

  @override
  Stream<List<MessageModel>> streamLatestMessages({
    required String roomCode,
    required int limit,
  }) {
    streamCallCount++;
    return Stream.value(db[roomCode] ?? []);
  }

  @override
  Future<String> sendMessage({
    required String roomCode,
    required MessageModel message,
  }) async {
    sendCallCount++;
    db.putIfAbsent(roomCode, () => []).add(message);
    return message.id;
  }

  @override
  Stream<int> watchRoomMemberCount(String roomCode) {
    watchMembersCallCount++;
    return Stream.value(5);
  }
}

class FakeChatLocalDataSource implements ChatLocalDataSource {
  final Map<String, List<MessageModel>> cache = {};
  int getCallCount = 0;
  int cacheCallCount = 0;
  int appendCallCount = 0;

  @override
  Future<List<MessageModel>> getCachedMessages(String roomCode) async {
    getCallCount++;
    return cache[roomCode] ?? [];
  }

  @override
  Future<void> cacheMessages(String roomCode, List<MessageModel> messages) async {
    cacheCallCount++;
    cache[roomCode] = messages;
  }

  @override
  Future<void> appendCachedMessage(String roomCode, MessageModel message) async {
    appendCallCount++;
    cache.putIfAbsent(roomCode, () => []).add(message);
  }
}

void main() {
  group('ChatRepositoryImpl Tests', () {
    late FakeChatRemoteDataSource remoteDataSource;
    late FakeChatLocalDataSource localDataSource;
    late ChatRepositoryImpl repository;

    setUp(() {
      remoteDataSource = FakeChatRemoteDataSource();
      localDataSource = FakeChatLocalDataSource();
      repository = ChatRepositoryImpl(remoteDataSource, localDataSource);
    });

    test('loadMessages returns success and loads remote data', () async {
      remoteDataSource.db['room_123'] = [
        MessageModel(
          id: 'msg_1',
          text: 'Hello',
          senderId: 'user_1',
          senderName: 'Alice',
          createdAt: DateTime.now(),
        )
      ];

      final result = await repository.loadMessages(roomCode: 'room_123', pageSize: 10);

      expect(result, isA<DataSuccess<PagedData<MessageEntity>>>());
      final success = result as DataSuccess<PagedData<MessageEntity>>;
      expect(success.data.items.first.text, 'Hello');
      expect(remoteDataSource.loadCallCount, 1);
    });

    test('sendMessage appends locally and submits remotely', () async {
      final sender = const IdentityEntity(
        id: 'user_1',
        displayName: 'Alice',
        username: 'alice',
        roomId: 'room_123',
      );

      final result = await repository.sendMessage(
        roomCode: 'room_123',
        text: 'Howdy',
        sender: sender,
      );

      expect(result, isA<DataSuccess<void>>());
      expect(localDataSource.appendCallCount, 1);
      expect(remoteDataSource.sendCallCount, 1);
      expect(remoteDataSource.db['room_123']?.first.text, 'Howdy');
    });

    test('watchRoomMemberCount routes stream from remote source', () async {
      final stream = repository.watchRoomMemberCount('room_123');
      final first = await stream.first;

      expect(first, 5);
      expect(remoteDataSource.watchMembersCallCount, 1);
    });
  });
}
