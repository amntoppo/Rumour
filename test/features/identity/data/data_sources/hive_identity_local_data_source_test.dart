import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rumour_app/core/local/hive_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/hive_identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/models/identity_model.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _storage = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) => _storage[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async => _storage[key] = value;

  @override
  Future<void> delete(dynamic key) async => _storage.remove(key);

  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #get) return get(i.positionalArguments[0]);
    if (i.memberName == #put) return put(i.positionalArguments[0], i.positionalArguments[1]);
    if (i.memberName == #delete) return delete(i.positionalArguments[0]);
    return super.noSuchMethod(i);
  }
}

class _FakeHive implements HiveInterface {
  final Map<String, _FakeBox> _boxes = {};

  @override
  bool isBoxOpen(String name) => _boxes.containsKey(name);

  @override
  Box<T> box<T>(String name) => _boxes[name]! as Box<T>;

  @override
  Future<Box<E>> openBox<E>(String name, {
    Uint8List? bytes, String? collection,
    bool Function(int, int)? compactionStrategy,
    bool crashRecovery = true, HiveCipher? encryptionCipher,
    List<int>? encryptionKey, int Function(dynamic, dynamic)? keyComparator,
    String? path,
  }) async => _boxes.putIfAbsent(name, () => _FakeBox()) as Box<E>;

  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #isBoxOpen) return isBoxOpen(i.positionalArguments[0] as String);
    if (i.memberName == #box) return box(i.positionalArguments[0] as String);
    if (i.memberName == #openBox) return openBox(i.positionalArguments[0] as String);
    return super.noSuchMethod(i);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HiveIdentityLocalDataSource', () {
    late HiveIdentityLocalDataSource source;

    setUp(() {
      source = HiveIdentityLocalDataSource(HiveDataSource(hive: _FakeHive()));
    });

    test('getIdentity returns null on cache miss', () async {
      final result = await source.getIdentity('room_miss');
      expect(result, isNull);
    });

    test('saveIdentity and getIdentity round-trip all fields', () async {
      const identity = IdentityModel(
        id: 'id-42',
        displayName: 'Test User',
        username: 'testuser',
        roomId: 'room_a',
        avatarUrl: 'https://cdn.example.com/test.jpg',
      );

      await source.saveIdentity('room_a', identity);
      final fetched = await source.getIdentity('room_a');

      expect(fetched, isNotNull);
      expect(fetched!.id, identity.id);
      expect(fetched.displayName, identity.displayName);
      expect(fetched.username, identity.username);
      expect(fetched.roomId, identity.roomId);
      expect(fetched.avatarUrl, identity.avatarUrl);
    });

    test('saveIdentity overwrites existing entry for the same roomId', () async {
      const first = IdentityModel(
        id: 'first-id', displayName: 'First', username: 'first', roomId: 'room_b',
      );
      const second = IdentityModel(
        id: 'second-id', displayName: 'Second', username: 'second', roomId: 'room_b',
      );

      await source.saveIdentity('room_b', first);
      await source.saveIdentity('room_b', second);

      final fetched = await source.getIdentity('room_b');
      expect(fetched!.id, 'second-id');
    });

    test('different rooms are stored independently', () async {
      const identityA = IdentityModel(
        id: 'id-a', displayName: 'Alice', username: 'alice', roomId: 'room_a',
      );
      const identityB = IdentityModel(
        id: 'id-b', displayName: 'Bob', username: 'bob', roomId: 'room_b',
      );

      await source.saveIdentity('room_a', identityA);
      await source.saveIdentity('room_b', identityB);

      final fetchedA = await source.getIdentity('room_a');
      final fetchedB = await source.getIdentity('room_b');

      expect(fetchedA!.id, 'id-a');
      expect(fetchedB!.id, 'id-b');
    });
  });
}
