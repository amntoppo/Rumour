import 'package:rumour_app/features/identity/data/models/identity_model.dart';

abstract class IdentityRemoteDataSource {
  /// Fetches a random identity from the external API for a specific [roomId].
  Future<IdentityModel> fetchRandomIdentity(String roomId);
}
