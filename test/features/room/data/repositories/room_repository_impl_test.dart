import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/domain/repositories/identity_repository.dart';
import 'package:rumour_app/features/room/data/data_sources/room_remote_data_source.dart';
import 'package:rumour_app/features/room/data/models/room_dto.dart';
import 'package:rumour_app/features/room/data/repositories/room_repository_impl.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';

class FakeRoomRemoteDataSource implements RoomRemoteDataSource {
  final Map<String, RoomDto> db = {};
  int fetchCallCount = 0;
  int createCallCount = 0;
  int joinCallCount = 0;

  @override
  Future<RoomDto?> fetchRoom(String code) async {
    fetchCallCount++;
    return db[code];
  }

  @override
  Future<RoomDto> createRoom(String code, IdentityEntity identity) async {
    createCallCount++;
    final newRoom = RoomDto(
      id: code,
      roomCode: code,
      createdAt: DateTime.now(),
      createdBy: 'test_uuid_123',
      memberCount: 1,
    );
    db[code] = newRoom;
    return newRoom;
  }

  @override
  Future<RoomDto> joinRoom(String code, IdentityEntity identity) async {
    joinCallCount++;
    final existing = db[code]!;
    final updated = RoomDto(
      id: code,
      roomCode: code,
      createdAt: existing.createdAt,
      createdBy: existing.createdBy,
      memberCount: existing.memberCount + 1,
    );
    db[code] = updated;
    return updated;
  }
}

class FakeIdentityRepository implements IdentityRepository {
  @override
  Future<DataState<IdentityEntity>> getOrFetchIdentity(String roomId) async {
    return DataSuccess(IdentityEntity(
      id: 'identity_id_123',
      displayName: 'Test Anon',
      username: 'testanon',
      roomId: roomId,
    ));
  }
}

void main() {
  group('RoomRepositoryImpl Tests', () {
    late FakeRoomRemoteDataSource dataSource;
    late FakeIdentityRepository identityRepository;
    late RoomRepositoryImpl repository;

    setUp(() {
      dataSource = FakeRoomRemoteDataSource();
      identityRepository = FakeIdentityRepository();
      repository = RoomRepositoryImpl(dataSource, identityRepository);
    });

    test('should create room when it does not exist', () async {
      final result = await repository.joinRoom('xyz');

      expect(result, isA<DataSuccess<RoomEntity>>());
      final success = result as DataSuccess<RoomEntity>;
      expect(success.data.code, 'xyz');
      expect(dataSource.fetchCallCount, 1);
      expect(dataSource.createCallCount, 1);
      expect(dataSource.joinCallCount, 0);
    });

    test('should join room when it already exists', () async {
      dataSource.db['abc'] = RoomDto(
        id: 'abc',
        roomCode: 'abc',
        createdAt: DateTime.now(),
        createdBy: 'user_1',
        memberCount: 1,
      );

      final result = await repository.joinRoom('abc');

      expect(result, isA<DataSuccess<RoomEntity>>());
      final success = result as DataSuccess<RoomEntity>;
      expect(success.data.code, 'abc');
      expect(dataSource.db['abc']!.memberCount, 2);

      expect(dataSource.fetchCallCount, 1);
      expect(dataSource.createCallCount, 0);
      expect(dataSource.joinCallCount, 1);
    });
  });
}
