import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<PagedData<MessageModel>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  });

  Stream<List<MessageModel>> streamLatestMessages({
    required String roomCode,
    required int limit,
  });

  Future<String> sendMessage({
    required String roomCode,
    required MessageModel message,
  });

  Stream<int> watchRoomMemberCount(String roomCode);
}
