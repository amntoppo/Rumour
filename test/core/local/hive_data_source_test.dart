import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rumour_app/core/local/hive_data_source.dart';

class FakeBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _storage = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) => _storage[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _storage.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #get) {
      return get(invocation.positionalArguments[0]);
    }
    if (invocation.memberName == #put) {
      return put(invocation.positionalArguments[0], invocation.positionalArguments[1]);
    }
    if (invocation.memberName == #delete) {
      return delete(invocation.positionalArguments[0]);
    }
    return super.noSuchMethod(invocation);
  }
}

class FakeHive implements HiveInterface {
  final Map<String, FakeBox> _boxes = {};

  @override
  bool isBoxOpen(String name) => _boxes.containsKey(name);

  @override
  Box<T> box<T>(String name) => _boxes[name]! as Box<T>;

  @override
  Future<Box<E>> openBox<E>(
    String name, {
    Uint8List? bytes,
    String? collection,
    bool Function(int, int)? compactionStrategy,
    bool crashRecovery = true,
    HiveCipher? encryptionCipher,
    List<int>? encryptionKey,
    int Function(dynamic, dynamic)? keyComparator,
    String? path,
  }) async {
    return _boxes.putIfAbsent(name, () => FakeBox()) as Box<E>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #isBoxOpen) {
      return isBoxOpen(invocation.positionalArguments[0] as String);
    }
    if (invocation.memberName == #box) {
      return box(invocation.positionalArguments[0] as String);
    }
    if (invocation.memberName == #openBox) {
      return openBox(invocation.positionalArguments[0] as String);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('HiveDataSource Tests', () {
    late FakeHive fakeHive;
    late HiveDataSource dataSource;

    setUp(() {
      fakeHive = FakeHive();
      dataSource = HiveDataSource(hive: fakeHive);
    });

    test('put and get works correctly', () async {
      final data = {'name': 'John', 'age': 30};
      await dataSource.put('users/user_1', data, (val) => val);

      final fetched = await dataSource.get<Map<String, dynamic>>(
        'users/user_1',
        (map) => map,
      );

      expect(fetched, isNotNull);
      expect(fetched!['name'], 'John');
      expect(fetched['age'], 30);
      expect(fetched['_id'], 'user_1');
    });

    test('get returns null when document does not exist', () async {
      final fetched = await dataSource.get<Map<String, dynamic>>(
        'users/nonexistent',
        (map) => map,
      );
      expect(fetched, isNull);
    });

    test('post generates a uuid and saves document', () async {
      final data = {'name': 'Alice'};
      final id = await dataSource.post('users', data, (val) => val);

      expect(id, isNotEmpty);

      final fetched = await dataSource.get<Map<String, dynamic>>(
        'users/$id',
        (map) => map,
      );

      expect(fetched, isNotNull);
      expect(fetched!['name'], 'Alice');
      expect(fetched['_id'], id);
    });

    test('patch performs partial updates without overwriting unrelated fields', () async {
      final initialData = {'name': 'Bob', 'role': 'user'};
      await dataSource.put('users/user_2', initialData, (val) => val);

      final update = {'role': 'admin'};
      await dataSource.patch('users/user_2', update, (val) => val);

      final fetched = await dataSource.get<Map<String, dynamic>>(
        'users/user_2',
        (map) => map,
      );

      expect(fetched, isNotNull);
      expect(fetched!['name'], 'Bob');   // untouched
      expect(fetched['role'], 'admin');  // updated
    });

    test('delete removes the document', () async {
      await dataSource.put('users/user_3', {'name': 'Charlie'}, (val) => val);

      await dataSource.delete('users/user_3');

      final fetched = await dataSource.get<Map<String, dynamic>>(
        'users/user_3',
        (map) => map,
      );

      expect(fetched, isNull);
    });

    test('path with multiple segments is parsed correctly', () async {
      await dataSource.put(
        'rooms/room_1/messages/msg_1',
        {'text': 'hello'},
        (val) => val,
      );

      final fetched = await dataSource.get<Map<String, dynamic>>(
        'rooms/room_1/messages/msg_1',
        (map) => map,
      );

      expect(fetched, isNotNull);
      expect(fetched!['text'], 'hello');
      expect(fetched['_id'], 'room_1/messages/msg_1');
    });

    test('parsePath throws on single-segment path', () {
      expect(
        () async => dataSource.get<dynamic>('onlyone', (m) => m),
        throwsArgumentError,
      );
    });
  });
}
