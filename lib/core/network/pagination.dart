/// The result of a single cursor-based page fetch.
class PagedData<T> {
  const PagedData({required this.items, this.nextCursor});

  final List<T> items;

  /// Cursor pointing to the next page.
  /// `null` means the last page has been reached.
  final QueryCursor? nextCursor;

  bool get hasMore => nextCursor != null;
}

/// Opaque cursor returned by [RemoteClient] paginated calls.
/// Round-trip only — do not inspect or construct directly.
abstract class QueryCursor {
  const QueryCursor();
}
