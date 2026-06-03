import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/core/network/remote_client.dart';

/// Extends [RemoteClient] with Firestore-specific capabilities:
/// live document/collection streams, cursor-based pagination,
/// merge-writes, atomic array mutations, and a server-timestamp token.
abstract class FirestoreClient extends RemoteClient {
  /// Must be called once at app startup before any Firestore read or write.
  /// Subsequent calls are no-ops.
  Future<void> configure();

  /// A write-time sentinel telling Firestore to stamp the server's clock.
  /// Typed as [Object] so this contract remains free of `cloud_firestore`.
  Object get timestampSentinel;

  /// Merges [value] into the document at [path] instead of replacing it.
  Future<void> merge<T>(String path, T value, ToMap<T> toMap);

  /// Inside a single transaction, appends [item] to [listField] and
  /// updates [sizeField] to the new list length.
  Future<void> appendAndSync({
    required String path,
    required String listField,
    required String sizeField,
    required dynamic item,
  });

  /// Inside a single transaction, increments [counterField] in [docPath] by 1
  /// and saves a sub-document at [subDocPath].
  Future<void> incrementAndSave({
    required String docPath,
    required String counterField,
    required String subDocPath,
    required dynamic subDocValue,
    required Map<String, dynamic> Function(dynamic) subDocToMap,
  });

  // ── Live streams ─────────────────────────────────────────────────────────

  /// Emits the decoded document at [path] on every server/cache change.
  /// Emits `null` if the document is absent.
  Stream<T?> watchDoc<T>(String path, FromMap<T> fromMap);

  /// Emits the full decoded collection at [collectionPath] on every change.
  Stream<List<T>> watchCollection<T>(
    String collectionPath,
    FromMap<T> fromMap, {
    String? orderBy,
    bool descending = false,
    bool tieBreakById = false,
    int? limit,
  });

  // ── Paginated queries ────────────────────────────────────────────────────

  /// Returns one page of [pageSize] documents from [collectionPath],
  /// starting after [after] if provided.
  Future<PagedData<T>> fetchPage<T>(
    String collectionPath,
    FromMap<T> fromMap, {
    required String orderBy,
    bool descending = true,
    bool tieBreakById = false,
    required int pageSize,
    QueryCursor? after,
  });
}
