import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rumour_app/core/local/hive_data_source.dart';
import 'package:rumour_app/features/chat/data/data_sources/hive_chat_local_data_source.dart';
import 'package:rumour_app/features/chat/data/models/message_model.dart';

// ── Fakes (copied from hive_data_source_test) ─────────────────────────────────

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

// ── Helper ────────────────────────────────────────────────────────────────────

MessageModel _msg(String id, String text) => MessageModel(
      id: id,
      text: text,
      senderId: 'u1',
      senderName: 'Alice',
      createdAt: DateTime.now(),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HiveChatLocalDataSource', () {
    late HiveChatLocalDataSource source;

    setUp(() {
      source = HiveChatLocalDataSource(HiveDataSource(hive: _FakeHive()));
    });

    test('getCachedMessages returns empty list on cache miss', () async {
      final result = await source.getCachedMessages('room_miss');
      expect(result, isEmpty);
    });

    test('cacheMessages and getCachedMessages round-trip', () async {
      final messages = [_msg('m1', 'Hello'), _msg('m2', 'World')];
      await source.cacheMessages('room_1', messages);

      final fetched = await source.getCachedMessages('room_1');

      expect(fetched.length, 2);
      expect(fetched[0].text, 'Hello');
      expect(fetched[1].text, 'World');
    });

    test('cacheMessages overwrites previous cache for the same room', () async {
      await source.cacheMessages('room_2', [_msg('old', 'Old message')]);
      await source.cacheMessages('room_2', [_msg('new', 'New message')]);

      final fetched = await source.getCachedMessages('room_2');
      expect(fetched.length, 1);
      expect(fetched[0].text, 'New message');
    });

    test('appendCachedMessage adds a new message', () async {
      await source.cacheMessages('room_3', [_msg('m1', 'First')]);
      await source.appendCachedMessage('room_3', _msg('m2', 'Second'));

      final fetched = await source.getCachedMessages('room_3');
      expect(fetched.length, 2);
    });

    test('appendCachedMessage de-duplicates by id', () async {
      final msg = _msg('dup', 'Duplicate');
      await source.cacheMessages('room_4', [msg]);
      await source.appendCachedMessage('room_4', msg); // same id

      final fetched = await source.getCachedMessages('room_4');
      expect(fetched.length, 1);
    });
  });
}
