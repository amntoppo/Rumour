import 'package:rumour_app/core/exceptions/app_exception.dart';

// ─── Network / REST ───────────────────────────────────────────────────────────

/// Connection timeout, DNS failure, or any transport-level error.
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// The server replied with a non-2xx status code that isn't specifically handled.
class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode, this.body});

  final int? statusCode;
  final Object? body;

  @override
  String toString() =>
      'ServerException[${statusCode ?? '?'}]: $message';
}

/// HTTP 401 / 403 — caller is not authenticated or not authorised.
class UnauthorisedException extends AppException {
  const UnauthorisedException(super.message, {this.statusCode});

  final int? statusCode;
}

/// HTTP 404 — the requested resource does not exist.
class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException(super.message);
}

/// A response body could not be decoded into the expected shape.
class ResponseParseException extends AppException {
  const ResponseParseException(super.message);
}
