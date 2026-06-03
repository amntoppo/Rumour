import 'package:rumour_app/core/network/remote_client.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.senderId,
    required super.senderName,
    super.avatarUrl,
    super.createdAt,
    super.type,
    super.isPending,
  });

  factory MessageModel.fromJson(DataMap json) {
    return MessageModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      senderId: (json['senderId'] ?? '') as String,
      senderName: (json['senderName'] ?? '') as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
      type: (json['type'] ?? 'text') as String,
      isPending: (json['_pending'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'type': type,
    };
  }

  Map<String, dynamic> toFirestore(Object serverTimestamp) {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': serverTimestamp,
      'type': type,
    };
  }

  MessageModel copyWith({
    String? id,
    String? text,
    String? senderId,
    String? senderName,
    String? avatarUrl,
    DateTime? createdAt,
    String? type,
    bool? isPending,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isPending: isPending ?? this.isPending,
    );
  }
}
