import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';

void main() {
  group('MessageModel.fromJson', () {
    test('parses all fields from a complete map', () {
      final now = DateTime(2024, 6, 15, 14, 30);
      final json = {
        '_id': 'msg_001',
        'text': 'Hello world',
        'senderId': 'user_1',
        'senderName': 'Alice',
        'avatarUrl': 'https://cdn.example.com/alice.jpg',
        'createdAt': now,
        'type': 'text',
        '_pending': false,
      };

      final model = MessageModel.fromJson(json);

      expect(model.id, 'msg_001');
      expect(model.text, 'Hello world');
      expect(model.senderId, 'user_1');
      expect(model.senderName, 'Alice');
      expect(model.avatarUrl, 'https://cdn.example.com/alice.jpg');
      expect(model.createdAt, now);
      expect(model.type, 'text');
      expect(model.isPending, isFalse);
    });

    test('uses fallback "id" key when "_id" is absent', () {
      final json = {
        'id': 'msg_fallback',
        'text': 'Hi',
        'senderId': 's1',
        'senderName': 'Bob',
      };

      final model = MessageModel.fromJson(json);
      expect(model.id, 'msg_fallback');
    });

    test('defaults type to "text" when absent', () {
      final json = {
        '_id': 'msg_notype',
        'text': 'no type field',
        'senderId': 's1',
        'senderName': 'Bob',
      };

      final model = MessageModel.fromJson(json);
      expect(model.type, 'text');
    });

    test('marks isPending as true when _pending is true', () {
      final json = {
        '_id': 'msg_pending',
        'text': 'optimistic',
        'senderId': 's1',
        'senderName': 'Alice',
        '_pending': true,
      };

      final model = MessageModel.fromJson(json);
      expect(model.isPending, isTrue);
    });

    test('parses createdAt from ISO 8601 string', () {
      final json = {
        '_id': 'msg_str_ts',
        'text': 'timestamp as string',
        'senderId': 's1',
        'senderName': 'Alice',
        'createdAt': '2024-06-15T14:30:00.000',
      };

      final model = MessageModel.fromJson(json);
      expect(model.createdAt, isNotNull);
      expect(model.createdAt!.year, 2024);
    });

    test('sets createdAt to null for unrecognised timestamp type', () {
      final json = {
        '_id': 'msg_bad_ts',
        'text': 'bad timestamp',
        'senderId': 's1',
        'senderName': 'Alice',
        'createdAt': 12345, // int — not a valid DateTime or String
      };

      final model = MessageModel.fromJson(json);
      expect(model.createdAt, isNull);
    });
  });

  group('MessageModel.toJson', () {
    test('round-trips through fromJson', () {
      final now = DateTime(2024, 6, 15, 9, 0);
      final original = MessageModel(
        id: 'msg_rt',
        text: 'Round trip',
        senderId: 'u1',
        senderName: 'Carol',
        avatarUrl: 'https://cdn.example.com/carol.jpg',
        createdAt: now,
      );

      final json = original.toJson();
      final restored = MessageModel.fromJson({...json, '_id': json['id']});

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.senderName, original.senderName);
      expect(restored.avatarUrl, original.avatarUrl);
    });

    test('omits avatarUrl when null', () {
      final model = MessageModel(
        id: 'msg_noavatar',
        text: 'No avatar',
        senderId: 'u1',
        senderName: 'Dave',
        createdAt: DateTime.now(),
      );

      final json = model.toJson();
      expect(json.containsKey('avatarUrl'), isFalse);
    });
  });

  group('MessageModel.toFirestore', () {
    test('uses the provided server timestamp sentinel', () {
      const sentinel = 'FIRESTORE_SERVER_TIMESTAMP';
      final model = MessageModel(
        id: 'msg_fs',
        text: 'Firestore write',
        senderId: 'u1',
        senderName: 'Eve',
        createdAt: DateTime.now(),
      );

      final map = model.toFirestore(sentinel);

      expect(map['createdAt'], sentinel);
      expect(map['text'], 'Firestore write');
      // 'id' is never written — it becomes the Firestore doc ID
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('MessageModel.copyWith', () {
    test('overrides specified fields only', () {
      final original = MessageModel(
        id: 'msg_cw',
        text: 'Original',
        senderId: 'u1',
        senderName: 'Frank',
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith(text: 'Updated', isPending: true);

      expect(copy.text, 'Updated');
      expect(copy.isPending, isTrue);
      expect(copy.id, original.id);
      expect(copy.senderId, original.senderId);
    });
  });
}
