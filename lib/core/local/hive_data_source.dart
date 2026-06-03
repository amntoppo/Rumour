import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:rumour_app/core/local/local_client.dart';

/// Hive-based implementation of [LocalClient].
///
/// This data source translates document-like paths (e.g. `collectionName/documentId`)
/// into Hive boxes and keys.
class HiveDataSource implements LocalClient {
  HiveDataSource({HiveInterface? hive}) : _hive = hive ?? Hive;

  final HiveInterface _hive;

  /// Helper to split a path like `boxName/key` into `(boxName, key)`.
  (String, String) _parsePath(String path) {
    final parts = path.split('/');
    if (parts.length < 2) {
      throw ArgumentError(
        'Path must be in the format: collectionName/documentId (got: "$path")',
      );
    }
    final boxName = parts.first;
    final key = parts.skip(1).join('/');
    return (boxName, key);
  }

  /// Opens the box if not already open, and returns it.
  Future<Box<dynamic>> _getBox(String boxName) async {
    if (_hive.isBoxOpen(boxName)) {
      return _hive.box<dynamic>(boxName);
    }
    return await _hive.openBox<dynamic>(boxName);
  }

  /// Recursively casts a Hive map (`Map<dynamic, dynamic>`) to `Map<String, dynamic>`.
  Map<String, dynamic>? _castMap(Map<dynamic, dynamic>? raw) {
    if (raw == null) return null;
    return raw.map((key, value) {
      final keyString = key.toString();
      if (value is Map) {
        return MapEntry(keyString, _castMap(value));
      }
      if (value is List) {
        return MapEntry(
          keyString,
          value.map((item) => item is Map ? _castMap(item) : item).toList(),
        );
      }
      return MapEntry(keyString, value);
    });
  }

  @override
  Future<T?> fetchOne<T>(String path, FromMap<T> fromMap) async {
    final (boxName, key) = _parsePath(path);
    final box = await _getBox(boxName);
    final rawData = box.get(key);
    if (rawData == null) return null;
    if (rawData is Map) {
      final map = _castMap(rawData);
      if (map != null) {
        // Inject '_id' to match firestore_client behavior
        map['_id'] = key;
        return fromMap(map);
      }
    }
    return null;
  }

  @override
  Future<void> save<T>(String path, T value, ToMap<T> toMap) async {
    final (boxName, key) = _parsePath(path);
    final box = await _getBox(boxName);
    await box.put(key, toMap(value));
  }

  @override
  Future<String> create<T>(
    String collectionPath,
    T value,
    ToMap<T> toMap,
  ) async {
    final id = const Uuid().v4();
    final box = await _getBox(collectionPath);
    await box.put(id, toMap(value));
    return id;
  }

  @override
  Future<void> patch<T>(String path, T value, ToMap<T> toMap) async {
    final (boxName, key) = _parsePath(path);
    final box = await _getBox(boxName);
    final rawData = box.get(key);
    final updateData = toMap(value);

    Map<String, dynamic> existingMap = {};
    if (rawData is Map) {
      existingMap = _castMap(rawData) ?? {};
    }

    final mergedMap = {...existingMap, ...updateData};
    await box.put(key, mergedMap);
  }

  @override
  Future<void> remove(String path) async {
    final (boxName, key) = _parsePath(path);
    final box = await _getBox(boxName);
    await box.delete(key);
  }
}
