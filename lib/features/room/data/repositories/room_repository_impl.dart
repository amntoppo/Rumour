import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/domain/repositories/identity_repository.dart';
import 'package:rumour_app/features/room/data/data_sources/room_remote_data_source.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';
import 'package:rumour_app/features/room/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  const RoomRepositoryImpl(this._dataSource, this._identityRepository);

  final RoomRemoteDataSource _dataSource;
  final IdentityRepository _identityRepository;

  @override
  Future<DataState<RoomEntity>> joinRoom(String code) async {
    try {
      // 1. Create or fetch anonymous identity for this room
      final identityRes = await _identityRepository.getOrFetchIdentity(code);
      if (identityRes is DataFailure<IdentityEntity>) {
        return DataFailure(identityRes.error);
      }
      final identity = (identityRes as DataSuccess<IdentityEntity>).data;

      // 2. Perform room joining or creation
      final existing = await _dataSource.fetchRoom(code);
      if (existing != null) {
        final joined = await _dataSource.joinRoom(code, identity);
        return DataSuccess(joined.toEntity());
      }

      final created = await _dataSource.createRoom(code, identity);
      return DataSuccess(created.toEntity());
    } on AppException catch (e) {
      return DataFailure(e);
    }
  }
}

