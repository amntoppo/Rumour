import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

/// DTO/Model that maps between the external randomuser.me API response, local Hive cache, and domain [IdentityEntity].
class IdentityModel extends IdentityEntity {
  const IdentityModel({
    required super.id,
    required super.displayName,
    required super.username,
    required super.roomId,
    super.avatarUrl,
  });

  /// Parse the randomuser.me user JSON block (the item inside "results" array).
  factory IdentityModel.fromRandomUser(Map<String, dynamic> json, String roomId) {
    final name = (json['name'] as Map?)?.cast<String, dynamic>() ?? const {};
    final login = (json['login'] as Map?)?.cast<String, dynamic>() ?? const {};
    final picture = (json['picture'] as Map?)?.cast<String, dynamic>();

    final first = (name['first'] as String?)?.trim() ?? '';
    final last = (name['last'] as String?)?.trim() ?? '';
    final display = [first, last].where((s) => s.isNotEmpty).join(' ');

    return IdentityModel(
      id: (login['uuid'] as String?) ?? '',
      displayName: display.isEmpty ? 'Anonymous' : display,
      username: (login['username'] as String?) ?? 'anon',
      roomId: roomId,
      avatarUrl: picture?['thumbnail'] as String?,
    );
  }

  /// Parse from Hive local cache.
  factory IdentityModel.fromCache(Map<String, dynamic> json) {
    return IdentityModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      username: json['username'] as String,
      roomId: json['roomId'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Serialize to Hive local cache map.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'displayName': displayName,
        'username': username,
        'roomId': roomId,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}
