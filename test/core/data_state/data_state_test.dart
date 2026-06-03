import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';

class _FakeException extends AppException {
  const _FakeException(super.message);
}

void main() {
  group('DataState', () {
    group('DataSuccess', () {
      test('holds the provided data', () {
        const state = DataSuccess(42);
        expect(state.data, 42);
      });

      test('is a DataState subtype', () {
        const state = DataSuccess('hello');
        expect(state, isA<DataState<String>>());
      });

      test('works with nullable data', () {
        const state = DataSuccess<String?>(null);
        expect(state.data, isNull);
      });
    });

    group('DataFailure', () {
      test('holds the provided AppException', () {
        const err = _FakeException('something went wrong');
        const state = DataFailure<int>(err);
        expect(state.error, err);
      });

      test('message proxies to error.message', () {
        const err = _FakeException('network error');
        const state = DataFailure<void>(err);
        expect(state.message, 'network error');
      });

      test('is a DataState subtype', () {
        const state = DataFailure<String>(_FakeException('err'));
        expect(state, isA<DataState<String>>());
      });
    });

    group('DataLoading', () {
      test('is a DataState subtype', () {
        const state = DataLoading<int>();
        expect(state, isA<DataState<int>>());
      });

      test('two instances are of the same type', () {
        const a = DataLoading<String>();
        const b = DataLoading<String>();
        expect(a.runtimeType, b.runtimeType);
      });
    });

    group('pattern matching', () {
      test('switch correctly identifies each subtype', () {
        final states = <DataState<int>>[
          const DataSuccess(1),
          const DataFailure(_FakeException('fail')),
          const DataLoading(),
        ];

        final labels = states.map((s) => switch (s) {
          DataSuccess() => 'success',
          DataFailure() => 'failure',
          DataLoading() => 'loading',
        }).toList();

        expect(labels, ['success', 'failure', 'loading']);
      });
    });
  });
}
