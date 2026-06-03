import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

abstract class IdentityRepository {
  /// Retrieves the identity for the given [roomId].
  ///
  /// This is a cache-first operation: if an identity is cached locally,
  /// it returns the cached identity. Otherwise, it fetches a new random
  /// identity from the API, caches it locally, and returns it.
  Future<DataState<IdentityEntity>> getOrFetchIdentity(String roomId);

  /// Retrieves the identity for the given [roomId] only if it is cached locally.
  /// Otherwise, returns `null`.
  Future<IdentityEntity?> getCachedIdentity(String roomId);
}
