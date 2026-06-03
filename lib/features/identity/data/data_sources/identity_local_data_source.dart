import 'package:rumour_app/features/identity/data/models/identity_model.dart';

abstract class IdentityLocalDataSource {
  /// Reads the cached identity for [roomId].
  Future<IdentityModel?> getIdentity(String roomId);

  /// Caches the given [identity] under [roomId].
  Future<void> saveIdentity(String roomId, IdentityModel identity);
}
