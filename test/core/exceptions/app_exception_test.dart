import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/core/exceptions/network_exceptions.dart';
import 'package:rumour_app/core/exceptions/firebase_exceptions.dart';

void main() {
  group('AppException', () {
    test('stores message correctly', () {
      const e = UnknownException('something broke');
      expect(e.message, 'something broke');
    });

    test('toString includes runtimeType and message', () {
      const e = UnknownException('bad state');
      expect(e.toString(), contains('UnknownException'));
      expect(e.toString(), contains('bad state'));
    });

    test('is an Exception', () {
      const e = UnknownException('x');
      expect(e, isA<Exception>());
    });
  });

  group('NetworkException subtypes', () {
    test('NetworkException stores message', () {
      const e = NetworkException('timeout');
      expect(e.message, 'timeout');
      expect(e, isA<AppException>());
    });

    test('ServerException stores statusCode and body', () {
      const e = ServerException('internal error', statusCode: 500, body: {'detail': 'crash'});
      expect(e.message, 'internal error');
      expect(e.statusCode, 500);
      expect(e.body, {'detail': 'crash'});
    });

    test('ServerException has null statusCode by default', () {
      const e = ServerException('oops');
      expect(e.statusCode, isNull);
      expect(e.body, isNull);
    });

    test('UnauthorisedException stores statusCode', () {
      const e = UnauthorisedException('forbidden', statusCode: 403);
      expect(e.message, 'forbidden');
      expect(e.statusCode, 403);
    });

    test('ResourceNotFoundException stores message', () {
      const e = ResourceNotFoundException('not found');
      expect(e.message, 'not found');
    });

    test('ResponseParseException stores message', () {
      const e = ResponseParseException('bad json');
      expect(e.message, 'bad json');
    });
  });

  group('FirebaseException subtypes', () {
    test('FirestorePermissionException is an AppException', () {
      const e = FirestorePermissionException('denied');
      expect(e.message, 'denied');
      expect(e, isA<AppException>());
    });

    test('FirestoreUnavailableException stores message', () {
      const e = FirestoreUnavailableException('offline');
      expect(e.message, 'offline');
    });

    test('DocumentNotFoundException stores message', () {
      const e = DocumentNotFoundException('missing doc');
      expect(e.message, 'missing doc');
    });

    test('FirestoreOperationException stores code', () {
      const e = FirestoreOperationException('op failed', code: 'cancelled');
      expect(e.message, 'op failed');
      expect(e.code, 'cancelled');
    });

    test('FirestoreTransactionException stores code', () {
      const e = FirestoreTransactionException('tx failed', code: 'aborted');
      expect(e.message, 'tx failed');
      expect(e.code, 'aborted');
    });
  });
}
