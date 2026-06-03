import 'package:rumour_app/core/local/local_client.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/models/identity_model.dart';

class HiveIdentityLocalDataSource implements IdentityLocalDataSource {
  HiveIdentityLocalDataSource(this._localClient);

  final LocalClient _localClient;

  static String _path(String roomId) => 'identities/$roomId';

  @override
  Future<IdentityModel?> getIdentity(String roomId) {
    return _localClient.get(_path(roomId), IdentityModel.fromCache);
  }

  @override
  Future<void> saveIdentity(String roomId, IdentityModel identity) {
    return _localClient.put(_path(roomId), identity, (m) => m.toCacheJson());
  }
}
