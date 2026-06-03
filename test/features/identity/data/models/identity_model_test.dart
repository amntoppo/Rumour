import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/features/identity/data/models/identity_model.dart';

void main() {
  group('IdentityModel.fromRandomUser', () {
    test('parses a complete randomuser.me JSON block', () {
      final json = {
        'name': {'first': 'Jane', 'last': 'Smith'},
        'login': {'uuid': 'abc-123', 'username': 'janesmith'},
        'picture': {'thumbnail': 'https://example.com/thumb.jpg'},
      };

      final model = IdentityModel.fromRandomUser(json, 'room_1');

      expect(model.id, 'abc-123');
      expect(model.displayName, 'Jane Smith');
      expect(model.username, 'janesmith');
      expect(model.roomId, 'room_1');
      expect(model.avatarUrl, 'https://example.com/thumb.jpg');
    });

    test('falls back to "Anonymous" when name fields are empty', () {
      final json = {
        'name': {'first': '', 'last': ''},
        'login': {'uuid': 'xyz-789', 'username': 'anon'},
        'picture': null,
      };

      final model = IdentityModel.fromRandomUser(json, 'room_2');

      expect(model.displayName, 'Anonymous');
      expect(model.avatarUrl, isNull);
    });

    test('falls back to "Anonymous" when name is absent', () {
      final json = {
        'login': {'uuid': 'no-name', 'username': 'ghost'},
      };

      final model = IdentityModel.fromRandomUser(json, 'room_3');

      expect(model.displayName, 'Anonymous');
    });

    test('handles missing uuid gracefully', () {
      final json = {
        'name': {'first': 'Bob', 'last': ''},
        'login': {'username': 'bob123'},
      };

      final model = IdentityModel.fromRandomUser(json, 'room_4');

      expect(model.id, '');
    });

    test('uses only first name when last name is blank', () {
      final json = {
        'name': {'first': 'Alice', 'last': ''},
        'login': {'uuid': 'id-001', 'username': 'alice'},
      };

      final model = IdentityModel.fromRandomUser(json, 'room_5');

      expect(model.displayName, 'Alice');
    });
  });

  group('IdentityModel.fromCache / toCacheJson round-trip', () {
    test('round-trips all fields including avatarUrl', () {
      const original = IdentityModel(
        id: 'cache-id',
        displayName: 'Cache User',
        username: 'cacheuser',
        roomId: 'room_cache',
        avatarUrl: 'https://cdn.example.com/avatar.png',
      );

      final json = original.toCacheJson();
      final restored = IdentityModel.fromCache(json);

      expect(restored.id, original.id);
      expect(restored.displayName, original.displayName);
      expect(restored.username, original.username);
      expect(restored.roomId, original.roomId);
      expect(restored.avatarUrl, original.avatarUrl);
    });

    test('round-trips without avatarUrl', () {
      const original = IdentityModel(
        id: 'no-avatar',
        displayName: 'Plain User',
        username: 'plain',
        roomId: 'room_x',
      );

      final json = original.toCacheJson();

      expect(json.containsKey('avatarUrl'), isFalse);

      final restored = IdentityModel.fromCache(json);
      expect(restored.avatarUrl, isNull);
    });
  });
}
