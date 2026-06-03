import 'package:flutter/foundation.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_remote_data_source.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  const IdentityRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final IdentityLocalDataSource local;
  final IdentityRemoteDataSource remote;

  @override
  Future<DataState<IdentityEntity>> getOrFetchIdentity(String roomId) async {
    try {
      // 1. Try to read from local cache
      final cached = await local.getIdentity(roomId);
      if (cached != null) {
        return DataSuccess(cached);
      }

      // 2. Cache miss: Fetch from API
      final fetched = await remote.fetchRandomIdentity(roomId);

      // 3. Best-effort cache write
      try {
        await local.saveIdentity(roomId, fetched);
      } catch (e) {
        debugPrint('[identity] Cache write failed for roomId $roomId: $e');
      }

      return DataSuccess(fetched);
    } on AppException catch (e) {
      return DataFailure(e);
    } catch (e) {
      // Return a general fallback failure
      return DataFailure(GeneralException(e.toString()));
    }
  }
}

/// A fallback general exception if non-AppException occurs.
class GeneralException extends AppException {
  const GeneralException(super.message);
}
