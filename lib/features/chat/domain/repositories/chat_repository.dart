import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

abstract class ChatRepository {
  Future<DataState<PagedData<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  });

  Stream<List<MessageEntity>> streamLatestMessages({
    required String roomCode,
    required int limit,
  });

  Future<DataState<void>> sendMessage({
    required String roomCode,
    required String text,
    required IdentityEntity sender,
  });

  Future<List<MessageEntity>> getCachedMessages(String roomCode);
  Future<void> cacheMessages(String roomCode, List<MessageEntity> messages);

  Stream<int> watchRoomMemberCount(String roomCode);
}
