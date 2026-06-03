import 'package:rumour_app/core/network/remote_client.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_remote_data_source.dart';
import 'package:rumour_app/features/identity/data/models/identity_model.dart';
import 'package:rumour_app/core/exceptions/network_exceptions.dart';

class HttpIdentityRemoteDataSource implements IdentityRemoteDataSource {
  HttpIdentityRemoteDataSource(this._client);

  final RemoteClient _client;

  @override
  Future<IdentityModel> fetchRandomIdentity(String roomId) async {
    final response = await _client.get<IdentityModel>(
      '/',
      (data) {
        final results = data['results'] as List?;
        if (results == null || results.isEmpty) {
          throw const ResponseParseException('randomuser.me returned an empty results array.');
        }
        final firstResult = results.first as Map<dynamic, dynamic>;
        return IdentityModel.fromRandomUser(
          firstResult.cast<String, dynamic>(),
          roomId,
        );
      },
    );

    if (response == null) {
      throw const ResponseParseException('randomuser.me returned null response.');
    }
    return response;
  }
}
