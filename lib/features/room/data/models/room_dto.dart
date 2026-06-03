import 'package:rumour_app/core/network/remote_client.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';

/// DTO that maps between Firestore's `rooms/{code}` document and [RoomEntity].
class RoomDto {
  const RoomDto({
    required this.id,
    required this.roomCode,
    required this.createdAt,
    required this.createdBy,
    required this.memberCount,
  });

  final String id;
  final String roomCode;
  final DateTime createdAt;
  final String createdBy;
  final int memberCount;

  // ── Firestore → DTO ───────────────────────────────────────────────────────

  factory RoomDto.fromMap(DataMap data) {
    return RoomDto(
      id: data['_id'] as String,
      roomCode: (data['roomCode'] ?? data['code'] ?? '') as String,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : DateTime.now(),
      createdBy: (data['createdBy'] ?? '') as String,
      memberCount: (data['memberCount'] as num? ?? 0).toInt(),
    );
  }

  // ── DTO → Firestore ───────────────────────────────────────────────────────

  DataMap toMap(Object serverTimestamp) => <String, dynamic>{
        'roomCode': roomCode,
        'createdAt': serverTimestamp,
        'createdBy': createdBy,
        'memberCount': memberCount,
      };

  // ── DTO → Domain ──────────────────────────────────────────────────────────

  RoomEntity toEntity() => RoomEntity(id: id, code: roomCode);
}
