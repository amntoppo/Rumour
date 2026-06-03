import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/features/room/data/models/room_dto.dart';

void main() {
  group('RoomDto.fromMap', () {
    test('parses all required fields correctly', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final map = {
        '_id': 'room_abc',
        'roomCode': 'ABC123',
        'createdAt': now,
        'createdBy': 'user_uuid_1',
        'memberCount': 5,
      };

      final dto = RoomDto.fromMap(map);

      expect(dto.id, 'room_abc');
      expect(dto.roomCode, 'ABC123');
      expect(dto.createdAt, now);
      expect(dto.createdBy, 'user_uuid_1');
      expect(dto.memberCount, 5);
    });

    test('uses fallback code key when roomCode is absent', () {
      final map = {
        '_id': 'room_xyz',
        'code': 'XYZ789',
        'createdAt': DateTime.now(),
        'createdBy': 'user_1',
        'memberCount': 1,
      };

      final dto = RoomDto.fromMap(map);
      expect(dto.roomCode, 'XYZ789');
    });

    test('defaults memberCount to 0 when missing', () {
      final map = {
        '_id': 'room_no_count',
        'roomCode': 'NOCOUNT',
        'createdAt': DateTime.now(),
        'createdBy': 'user_2',
      };

      final dto = RoomDto.fromMap(map);
      expect(dto.memberCount, 0);
    });

    test('defaults createdBy to empty string when missing', () {
      final map = {
        '_id': 'room_no_creator',
        'roomCode': 'NOCREATOR',
        'createdAt': DateTime.now(),
      };

      final dto = RoomDto.fromMap(map);
      expect(dto.createdBy, '');
    });

    test('handles non-DateTime createdAt with DateTime.now() fallback', () {
      final map = {
        '_id': 'room_bad_ts',
        'roomCode': 'BADTS',
        'createdAt': 'not-a-datetime',
        'createdBy': 'user_3',
        'memberCount': 1,
      };

      final before = DateTime.now();
      final dto = RoomDto.fromMap(map);
      final after = DateTime.now();

      expect(
        dto.createdAt.isAfter(before) || dto.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        dto.createdAt.isBefore(after) || dto.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
    });
  });

  group('RoomDto.toEntity', () {
    test('maps to RoomEntity with correct fields', () {
      final dto = RoomDto(
        id: 'room_ent',
        roomCode: 'ENTITY',
        createdAt: DateTime.now(),
        createdBy: 'user_x',
        memberCount: 2,
      );

      final entity = dto.toEntity();

      expect(entity.id, 'room_ent');
      expect(entity.code, 'ENTITY');
    });
  });
}
