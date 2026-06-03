/// Base class for all application-level exceptions.
///
/// Prefer throwing a concrete subclass so callers can pattern-match
/// on the specific failure type.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Generic unknown fallback exception.
class UnknownException extends AppException {
  const UnknownException(super.message);
}
