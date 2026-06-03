import 'package:rumour_app/core/exceptions/app_exception.dart';

/// Represents the outcome of any data operation across the app.
///
/// Pattern-match on the subtypes:
/// ```dart
/// switch (state) {
///   DataSuccess(:final data)   => // use data
///   DataFailure(:final error)  => // show error.message
///   DataLoading()              => // show spinner
/// }
/// ```
sealed class DataState<T> {
  const DataState();
}

/// The operation completed and [data] is available.
final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(this.data);

  final T data;
}

/// The operation failed with a typed [AppException].
final class DataFailure<T> extends DataState<T> {
  const DataFailure(this.error);

  final AppException error;

  /// Convenience accessor for the human-readable message.
  String get message => error.message;
}

/// The operation is in progress.
final class DataLoading<T> extends DataState<T> {
  const DataLoading();
}
