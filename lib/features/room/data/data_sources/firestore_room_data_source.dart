import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/core/exceptions/firebase_exceptions.dart';
import 'package:rumour_app/core/local/local_client.dart';
import 'package:rumour_app/core/network/firestore_client.dart';
import 'package:rumour_app/features/room/data/data_sources/room_remote_data_source.dart';
import 'package:rumour_app/features/room/data/models/room_dto.dart';

/// Firestore implementation of [RoomRemoteDataSource].
///
/// Schema: `rooms/{roomCode}`
/// ```
/// {
///   roomCode:    string,
///   createdAt:   timestamp,
///   createdBy:   string,
///   memberCount: number
/// }
/// ```
class FirestoreRoomDataSource implements RoomRemoteDataSource {
  const FirestoreRoomDataSource(this._client, this._localClient);

  final FirestoreClient _client;
  final LocalClient _localClient;

  static String _path(String code) => 'rooms/$code';

  // ── Fetch ──────────────────────────────────────────────────────────────────

  @override
  Future<RoomDto?> fetchRoom(String code) {
    return _client.get(_path(code), RoomDto.fromMap);
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  @override
  Future<RoomDto> createRoom(String code, IdentityEntity identity) async {
    final userUuid = await _localClient.get<String>(
      'user/uuid',
      (data) => data['uuid'] as String,
    );

    if (userUuid == null) {
      throw const FirestoreOperationException('User UUID not found in local storage.', code: 'local-uuid-missing');
    }

    final dto = RoomDto(
      id: code,
      roomCode: code,
      createdAt: DateTime.now(), // replaced by server timestamp on write
      createdBy: userUuid,
      memberCount: 1,
    );

    // save() writes at the document path so the room code IS the document id
    await _client.put(
      _path(code),
      dto,
      (d) => d.toMap(_client.timestampSentinel),
    );

    // Save identity data in the Room database
    await _client.put(
      'rooms/$code/identities/$userUuid',
      identity,
      (i) => <String, dynamic>{
        'id': i.id,
        'displayName': i.displayName,
        'username': i.username,
        'roomId': i.roomId,
        if (i.avatarUrl != null) 'avatarUrl': i.avatarUrl,
      },
    );

    // Re-fetch so the returned DTO reflects the server-stamped createdAt
    final saved = await _client.get(_path(code), RoomDto.fromMap);
    return saved ?? dto;
  }

  // ── Join ───────────────────────────────────────────────────────────────────

  @override
  Future<RoomDto> joinRoom(String code, IdentityEntity identity) async {
    final userUuid = await _localClient.get<String>(
      'user/uuid',
      (data) => data['uuid'] as String,
    );

    if (userUuid == null) {
      throw const FirestoreOperationException('User UUID not found in local storage.', code: 'local-uuid-missing');
    }

    final existingIdentity = await _client.get(
      'rooms/$code/identities/$userUuid',
      (data) => data,
    );

    if (existingIdentity == null) {
      // User is joining for the first time, increment counter and save identity
      await _client.incrementAndSave(
        docPath: _path(code),
        counterField: 'memberCount',
        subDocPath: 'rooms/$code/identities/$userUuid',
        subDocValue: identity,
        subDocToMap: (i) => <String, dynamic>{
          'id': i.id,
          'displayName': i.displayName,
          'username': i.username,
          'roomId': i.roomId,
          if (i.avatarUrl != null) 'avatarUrl': i.avatarUrl,
        },
      );
    }

    final saved = await _client.get(_path(code), RoomDto.fromMap);
    if (saved == null) {
      throw DocumentNotFoundException('Room not found after joining: $code');
    }
    return saved;
  }
}
