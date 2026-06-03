import 'package:rumour_app/features/chat/data/models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<MessageModel>> getCachedMessages(String roomCode);
  Future<void> cacheMessages(String roomCode, List<MessageModel> messages);
  Future<void> appendCachedMessage(String roomCode, MessageModel message);
}
