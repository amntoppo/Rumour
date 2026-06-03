/// Raw key-value map exchanged with a remote source.
typedef DataMap = Map<String, dynamic>;

/// Maps a [DataMap] from a remote source into domain type [T].
typedef FromMap<T> = T Function(DataMap data);

/// Maps domain type [T] into a [DataMap] for a remote source.
typedef ToMap<T> = DataMap Function(T value);

/// Defines the minimum contract any remote data source must satisfy.
///
/// Repositories program against this interface; concrete implementations
/// (REST, Firestore, mock) are wired in the DI layer.
abstract class RemoteClient {
  /// Fetches the document at [path] and maps it with [fromMap].
  /// Returns `null` when the document does not exist.
  Future<T?> fetchOne<T>(String path, FromMap<T> fromMap);

  /// Writes [value] at [path], completely replacing any prior content.
  Future<void> save<T>(String path, T value, ToMap<T> toMap);

  /// Creates a new document in [collectionPath] and returns its id.
  Future<String> create<T>(
    String collectionPath,
    T value,
    ToMap<T> toMap,
  );

  /// Applies a partial update to the document at [path].
  Future<void> patch<T>(String path, T value, ToMap<T> toMap);

  /// Permanently removes the document at [path].
  Future<void> remove(String path);
}
