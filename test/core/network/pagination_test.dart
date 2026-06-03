import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/network/pagination.dart';

// Concrete QueryCursor for testing — normally the SDK provides this.
class _TestCursor extends QueryCursor {
  const _TestCursor();
}

void main() {
  group('PagedData', () {
    group('hasMore', () {
      test('is true when nextCursor is non-null', () {
        final paged = PagedData<int>(
          items: [1, 2, 3],
          nextCursor: const _TestCursor(),
        );
        expect(paged.hasMore, isTrue);
      });

      test('is false when nextCursor is null', () {
        final paged = PagedData<int>(items: [1, 2], nextCursor: null);
        expect(paged.hasMore, isFalse);
      });

      test('is false for an empty last page', () {
        final paged = PagedData<String>(items: [], nextCursor: null);
        expect(paged.hasMore, isFalse);
      });
    });

    group('items', () {
      test('stores the provided list', () {
        final items = ['a', 'b', 'c'];
        final paged = PagedData<String>(items: items, nextCursor: null);
        expect(paged.items, items);
      });

      test('stores an empty list without error', () {
        final paged = PagedData<int>(items: [], nextCursor: null);
        expect(paged.items, isEmpty);
      });
    });

    group('nextCursor', () {
      test('is accessible when provided', () {
        const cursor = _TestCursor();
        final paged = PagedData<int>(items: [], nextCursor: cursor);
        expect(paged.nextCursor, cursor);
      });

      test('is null when not provided', () {
        final paged = PagedData<int>(items: []);
        expect(paged.nextCursor, isNull);
      });
    });
  });
}
