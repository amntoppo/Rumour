import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_remote_data_source.dart';
import 'package:rumour_app/features/identity/data/models/identity_model.dart';
import 'package:rumour_app/features/identity/data/repositories/identity_repository_impl.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

class FakeIdentityLocalDataSource implements IdentityLocalDataSource {
  final Map<String, IdentityModel> cache = {};

  @override
  Future<IdentityModel?> getIdentity(String roomId) async {
    return cache[roomId];
  }

  @override
  Future<void> saveIdentity(String roomId, IdentityModel identity) async {
    cache[roomId] = identity;
  }
}

class FakeIdentityRemoteDataSource implements IdentityRemoteDataSource {
  IdentityModel? nextResult;
  AppException? errorToThrow;

  @override
  Future<IdentityModel> fetchRandomIdentity(String roomId) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return nextResult!;
  }
}

void main() {
  group('IdentityRepositoryImpl Tests', () {
    late FakeIdentityLocalDataSource localDataSource;
    late FakeIdentityRemoteDataSource remoteDataSource;
    late IdentityRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeIdentityLocalDataSource();
      remoteDataSource = FakeIdentityRemoteDataSource();
      repository = IdentityRepositoryImpl(
        local: localDataSource,
        remote: remoteDataSource,
      );
    });

    test('should return cached identity when cache hit', () async {
      const cached = IdentityModel(
        id: '123',
        displayName: 'John Doe',
        username: 'johndoe',
        roomId: 'room_a',
      );
      localDataSource.cache['room_a'] = cached;

      final result = await repository.getOrFetchIdentity('room_a');

      expect(result, isA<DataSuccess<IdentityEntity>>());
      final success = result as DataSuccess<IdentityEntity>;
      expect(success.data, cached);
      expect(remoteDataSource.nextResult, isNull); // Remote not called
    });

    test('should fetch and cache identity on cache miss', () async {
      const fetched = IdentityModel(
        id: '456',
        displayName: 'Alice Smith',
        username: 'alice',
        roomId: 'room_b',
      );
      remoteDataSource.nextResult = fetched;

      final result = await repository.getOrFetchIdentity('room_b');

      expect(result, isA<DataSuccess<IdentityEntity>>());
      final success = result as DataSuccess<IdentityEntity>;
      expect(success.data, fetched);
      expect(localDataSource.cache['room_b'], fetched); // Cached
    });

    test('should return DataFailure when remote fetch fails', () async {
      remoteDataSource.errorToThrow = const TestAppException('API down');

      final result = await repository.getOrFetchIdentity('room_c');

      expect(result, isA<DataFailure<IdentityEntity>>());
      final failure = result as DataFailure<IdentityEntity>;
      expect(failure.message, 'API down');
    });
  });
}

class TestAppException extends AppException {
  const TestAppException(super.message);
}
