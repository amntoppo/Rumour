import 'package:rumour_app/core/local/local_client.dart';
import 'package:rumour_app/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';

class HiveChatLocalDataSource implements ChatLocalDataSource {
  HiveChatLocalDataSource(this._localClient);

  final LocalClient _localClient;

  static String _path(String roomCode) => 'messages/$roomCode';

  @override
  Future<List<MessageModel>> getCachedMessages(String roomCode) async {
    final data = await _localClient.fetchOne(_path(roomCode), (map) => map);
    if (data == null) return const [];
    final rawList = data['messages'] as List<dynamic>? ?? const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .toList();
  }

  @override
  Future<void> cacheMessages(
    String roomCode,
    List<MessageModel> messages,
  ) async {
    await _localClient.save(
      _path(roomCode),
      messages,
      (list) => <String, dynamic>{
        'messages': list.map((m) => m.toJson()).toList(),
      },
    );
  }

  @override
  Future<void> appendCachedMessage(
    String roomCode,
    MessageModel message,
  ) async {
    final cached = await getCachedMessages(roomCode);
    if (!cached.any((m) => m.id == message.id)) {
      final updated = List<MessageModel>.from(cached)..insert(0, message);
      await cacheMessages(roomCode, updated);
    }
  }
}
