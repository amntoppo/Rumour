import 'package:rumour_app/core/network/firestore_client.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';

class FirestoreChatRemoteDataSource implements ChatRemoteDataSource {
  FirestoreChatRemoteDataSource(this._client);

  final FirestoreClient _client;

  static String _path(String roomCode) => 'rooms/$roomCode/messages';

  @override
  Future<PagedData<MessageModel>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  }) {
    return _client.fetchPage<MessageModel>(
      _path(roomCode),
      MessageModel.fromJson,
      orderBy: 'createdAt',
      descending: true,
      tieBreakById: true,
      pageSize: pageSize,
      after: after,
    );
  }

  @override
  Stream<List<MessageModel>> streamLatestMessages({
    required String roomCode,
    required int limit,
  }) {
    return _client.watchCollection<MessageModel>(
      _path(roomCode),
      MessageModel.fromJson,
      orderBy: 'createdAt',
      descending: true,
      tieBreakById: true,
      limit: limit,
    );
  }

  @override
  Future<String> sendMessage({
    required String roomCode,
    required MessageModel message,
  }) async {
    return _client.create(
      _path(roomCode),
      message,
      (m) => m.toFirestore(_client.timestampSentinel),
    );
  }

  @override
  Stream<int> watchRoomMemberCount(String roomCode) {
    return _client.watchDoc<Map<String, dynamic>?>(
      'rooms/$roomCode',
      (map) => map,
    ).map((map) => (map?['memberCount'] ?? 0) as int);
  }
}
