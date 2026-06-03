import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/room/data/models/room_dto.dart';

/// Contract for remote room operations.
///
/// Implementations talk to a specific backend (Firestore, REST, mock).
abstract class RoomRemoteDataSource {
  /// Fetches the room document at `rooms/{code}`.
  /// Returns `null` when the document does not exist.
  Future<RoomDto?> fetchRoom(String code);

  /// Creates a new room document at `rooms/{code}` and returns it.
  Future<RoomDto> createRoom(String code, IdentityEntity identity);

  /// Joins an existing room document at `rooms/{code}` and returns it.
  Future<RoomDto> joinRoom(String code, IdentityEntity identity);
}


