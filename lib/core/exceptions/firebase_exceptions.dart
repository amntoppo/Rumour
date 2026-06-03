import 'package:rumour_app/core/exceptions/app_exception.dart';

// ─── Firebase Init ────────────────────────────────────────────────────────────

/// Thrown when `Firebase.initializeApp()` fails for a reason other than
/// a duplicate-app hot-restart.
class FirebaseInitException extends AppException {
  const FirebaseInitException(super.message);
}

// ─── Firestore operations ─────────────────────────────────────────────────────

/// General Firestore read/write failure.
/// Wraps the original Firebase error code for structured handling.
class FirestoreOperationException extends AppException {
  const FirestoreOperationException(super.message, {required this.code});

  /// The underlying Firebase error code, e.g. `'permission-denied'`.
  final String code;

  @override
  String toString() => 'FirestoreOperationException[$code]: $message';
}

/// Thrown when a required Firestore document does not exist.
class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException(super.message);
}

/// Thrown when a Firestore transaction fails.
class FirestoreTransactionException extends AppException {
  const FirestoreTransactionException(super.message, {required this.code});

  final String code;

  @override
  String toString() => 'FirestoreTransactionException[$code]: $message';
}

/// Thrown when the caller lacks permission to read or write a document.
class FirestorePermissionException extends AppException {
  const FirestorePermissionException(super.message);
}

/// Thrown when a Firestore operation is attempted while offline and
/// no cached data is available.
class FirestoreUnavailableException extends AppException {
  const FirestoreUnavailableException(super.message);
}
