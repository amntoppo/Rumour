import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/core/exceptions/firebase_exceptions.dart';
import 'package:rumour_app/core/network/firestore_client.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/core/network/remote_client.dart';


/// `cloud_firestore` implementation of [FirestoreClient].
///
/// All Firestore-specific types stay inside this file:
/// - [Timestamp] values are converted to [DateTime] by [_normalise].
/// - `_id` and `_pending` flags are injected so DTOs can track
///   optimistic-write state (e.g. pending clock icon) without importing
///   the Firestore SDK.
class FirebaseFirestoreClient implements FirestoreClient {
  FirebaseFirestoreClient([FirebaseFirestore? instance])
      : _db = instance ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  bool _configured = false;

  // ── Setup ─────────────────────────────────────────────────────────────────

  @override
  Future<void> configure() async {
    if (_configured) return;
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {
      // Settings may only be applied once — safe to ignore on hot restart.
    }
    _configured = true;
  }

  @override
  Object get timestampSentinel => FieldValue.serverTimestamp();

  // ── CRUD ──────────────────────────────────────────────────────────────────

  @override
  Future<T?> fetchOne<T>(String path, FromMap<T> fromMap) async {
    try {
      final snap = await _db.doc(path).get();
      if (!snap.exists) return null;
      return fromMap(_normalise(snap.id, snap.data(), snap.metadata));
    } on FirebaseException catch (e) {
      throw _wrap(e, 'fetchOne');
    }
  }

  @override
  Future<void> save<T>(String path, T value, ToMap<T> toMap) async {
    try {
      await _db.doc(path).set(toMap(value));
    } on FirebaseException catch (e) {
      throw _wrap(e, 'save');
    }
  }

  @override
  Future<void> merge<T>(String path, T value, ToMap<T> toMap) async {
    try {
      await _db.doc(path).set(toMap(value), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _wrap(e, 'merge');
    }
  }

  @override
  Future<String> create<T>(
    String collectionPath,
    T value,
    ToMap<T> toMap,
  ) async {
    try {
      final ref = await _db.collection(collectionPath).add(toMap(value));
      return ref.id;
    } on FirebaseException catch (e) {
      throw _wrap(e, 'create');
    }
  }

  @override
  Future<void> patch<T>(String path, T value, ToMap<T> toMap) async {
    try {
      await _db.doc(path).update(toMap(value));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') throw DocumentNotFoundException('No document at $path.');
      if (e.code == 'permission-denied') throw FirestorePermissionException(e.message ?? 'Permission denied for $path.');
      throw _wrap(e, 'patch');
    }
  }

  @override
  Future<void> remove(String path) async {
    try {
      await _db.doc(path).delete();
    } on FirebaseException catch (e) {
      throw _wrap(e, 'remove');
    }
  }

  @override
  Future<void> appendAndSync({
    required String path,
    required String listField,
    required String sizeField,
    required dynamic item,
  }) async {
    try {
      final ref = _db.doc(path);
      await _db.runTransaction<void>((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw DocumentNotFoundException('No document at $path.');

        final data = snap.data() ?? const <String, dynamic>{};
        final raw = data[listField];
        final current = raw is List ? raw.toList() : <dynamic>[];

        bool exists = false;
        if (item is Map) {
          final itemId = item['id'];
          exists = current.any((element) => element is Map && element['id'] == itemId);
        } else {
          exists = current.contains(item);
        }

        if (!exists) {
          current.add(item);
        }

        tx.update(ref, <String, dynamic>{
          listField: current,
          sizeField: current.length,
        });
      });
    } on DocumentNotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreTransactionException(
        e.message ?? 'Transaction failed at $path.',
        code: e.code,
      );
    }
  }

  @override
  Future<void> incrementAndSave({
    required String docPath,
    required String counterField,
    required String subDocPath,
    required dynamic subDocValue,
    required Map<String, dynamic> Function(dynamic) subDocToMap,
  }) async {
    try {
      final roomRef = _db.doc(docPath);
      final subRef = _db.doc(subDocPath);

      await _db.runTransaction<void>((tx) async {
        final snap = await tx.get(roomRef);
        if (!snap.exists) throw DocumentNotFoundException('No document at $docPath.');

        final data = snap.data() ?? const <String, dynamic>{};
        final currentCount = (data[counterField] as num? ?? 0).toInt();

        tx.update(roomRef, <String, dynamic>{
          counterField: currentCount + 1,
        });

        tx.set(subRef, subDocToMap(subDocValue));
      });
    } on DocumentNotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreTransactionException(
        e.message ?? 'Transaction failed at $docPath.',
        code: e.code,
      );
    }
  }

  // ── Live streams ──────────────────────────────────────────────────────────

  @override
  Stream<T?> watchDoc<T>(String path, FromMap<T> fromMap) {
    return _db
        .doc(path)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
      if (!snap.exists) return null;
      return fromMap(_normalise(snap.id, snap.data(), snap.metadata));
    });
  }

  @override
  Stream<List<T>> watchCollection<T>(
    String collectionPath,
    FromMap<T> fromMap, {
    String? orderBy,
    bool descending = false,
    bool tieBreakById = false,
    int? limit,
  }) {
    Query<DataMap> q = _db.collection(collectionPath);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    if (orderBy != null && tieBreakById) {
      q = q.orderBy(FieldPath.documentId, descending: descending);
    }
    if (limit != null) q = q.limit(limit);

    return q
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs
            .map((d) => fromMap(_normalise(d.id, d.data(), d.metadata)))
            .toList(growable: false));
  }

  // ── Paginated queries ─────────────────────────────────────────────────────

  @override
  Future<PagedData<T>> fetchPage<T>(
    String collectionPath,
    FromMap<T> fromMap, {
    required String orderBy,
    bool descending = true,
    bool tieBreakById = false,
    required int pageSize,
    QueryCursor? after,
  }) async {
    try {
      Query<DataMap> q = _db
          .collection(collectionPath)
          .orderBy(orderBy, descending: descending);

      if (tieBreakById) {
        q = q.orderBy(FieldPath.documentId, descending: descending);
      }
      q = q.limit(pageSize);

      if (after is _DocumentCursor) {
        q = q.startAfterDocument(after.snapshot);
      }

      final snap = await q.get();
      final items = snap.docs
          .map((d) => fromMap(_normalise(d.id, d.data(), d.metadata)))
          .toList(growable: false);

      final lastDoc = snap.docs.isEmpty ? null : snap.docs.last;
      final next = (lastDoc == null || items.length < pageSize)
          ? null
          : _DocumentCursor(lastDoc);

      return PagedData<T>(items: items, nextCursor: next);
    } on FirebaseException catch (e) {
      throw _wrap(e, 'fetchPage');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts [Timestamp] → [DateTime] and injects metadata fields so that
  /// no DTO ever needs to import `cloud_firestore`.
  DataMap _normalise(
    String id,
    DataMap? data,
    SnapshotMetadata meta,
  ) {
    final out = <String, dynamic>{};
    if (data != null) {
      for (final e in data.entries) {
        out[e.key] = e.value is Timestamp
            ? (e.value as Timestamp).toDate()
            : e.value;
      }
    }
    out['_id'] = id;
    out['_pending'] = meta.hasPendingWrites;
    return out;
  }

  /// Maps a raw [FirebaseException] to a typed [FirestoreOperationException],
  /// with special-cased subtypes for known error codes.
  AppException _wrap(FirebaseException e, String op) {
    final msg = e.message ?? 'Firestore $op failed.';
    return switch (e.code) {
      'permission-denied' => FirestorePermissionException(msg),
      'unavailable' => FirestoreUnavailableException(msg),
      'not-found' => DocumentNotFoundException(msg),
      _ => FirestoreOperationException('[$op] $msg', code: e.code),
    };
  }
}

// ── Internal cursor ───────────────────────────────────────────────────────────

class _DocumentCursor extends QueryCursor {
  const _DocumentCursor(this.snapshot);
  final DocumentSnapshot<DataMap> snapshot;
}
