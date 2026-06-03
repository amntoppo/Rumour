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
  /// Fetches the document at [path] and deserialises it with [fromMap].
  /// Returns `null` when the document does not exist.
  Future<T?> get<T>(String path, FromMap<T> fromMap);

  /// Creates a new document in [collectionPath] and returns its generated id.
  Future<String> post<T>(String collectionPath, T value, ToMap<T> toMap);

  /// Writes [value] at [path], completely replacing any prior content.
  Future<void> put<T>(String path, T value, ToMap<T> toMap);

  /// Applies a partial update to the document at [path].
  Future<void> patch<T>(String path, T value, ToMap<T> toMap);

  /// Permanently removes the document at [path].
  Future<void> delete(String path);
}
