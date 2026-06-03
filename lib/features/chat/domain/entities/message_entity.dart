import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.avatarUrl,
    this.createdAt,
    this.type = 'text',
    this.isPending = false,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String type;
  final bool isPending;

  bool isAuthoredBy(String identityId) => senderId == identityId;

  @override
  List<Object?> get props => [
        id,
        text,
        senderId,
        senderName,
        avatarUrl,
        createdAt,
        type,
        isPending,
      ];
}
