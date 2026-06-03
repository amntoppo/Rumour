import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;

  @override
  Future<DataState<PagedData<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    QueryCursor? after,
  }) async {
    try {
      final pagedData = await _remoteDataSource.loadMessages(
        roomCode: roomCode,
        pageSize: pageSize,
        after: after,
      );
      return DataSuccess(pagedData);
    } on AppException catch (e) {
      return DataFailure(e);
    } catch (e) {
      return DataFailure(UnknownException(e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> streamLatestMessages({
    required String roomCode,
    required int limit,
  }) {
    return _remoteDataSource.streamLatestMessages(
      roomCode: roomCode,
      limit: limit,
    );
  }

  @override
  Future<DataState<void>> sendMessage({
    required String roomCode,
    required String text,
    required IdentityEntity sender,
  }) async {
    final tempId = const Uuid().v4();
    final message = MessageModel(
      id: tempId,
      text: text,
      senderId: sender.id,
      senderName: sender.displayName,
      avatarUrl: sender.avatarUrl,
      createdAt: DateTime.now(),
      isPending: false,
    );

    try {
      // Append cached message locally immediately for quick UI response
      await _localDataSource.appendCachedMessage(roomCode, message);

      await _remoteDataSource.sendMessage(
        roomCode: roomCode,
        message: message,
      );
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailure(e);
    } catch (e) {
      return DataFailure(UnknownException(e.toString()));
    }
  }

  @override
  Future<List<MessageEntity>> getCachedMessages(String roomCode) async {
    return _localDataSource.getCachedMessages(roomCode);
  }

  @override
  Future<void> cacheMessages(
    String roomCode,
    List<MessageEntity> messages,
  ) async {
    final models = messages
        .map((m) => MessageModel(
              id: m.id,
              text: m.text,
              senderId: m.senderId,
              senderName: m.senderName,
              avatarUrl: m.avatarUrl,
              createdAt: m.createdAt,
              type: m.type,
              isPending: m.isPending,
            ))
        .toList();
    await _localDataSource.cacheMessages(roomCode, models);
  }

  @override
  Stream<int> watchRoomMemberCount(String roomCode) {
    return _remoteDataSource.watchRoomMemberCount(roomCode);
  }
}
