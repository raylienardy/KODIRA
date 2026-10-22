import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/core/errors/error_type.dart';

void main() {
  group('ErrorType.fromException', () {
    test('SocketException dipetakan ke network', () {
      final ErrorType type = ErrorType.fromException(
        Exception('SocketException: Failed host lookup'),
      );

      expect(type, ErrorType.network);
    });

    test('pesan network dipetakan ke network', () {
      final ErrorType type = ErrorType.fromException(
        Exception('Network error, periksa koneksi'),
      );

      expect(type, ErrorType.network);
    });

    test('TimeoutException dipetakan ke timeout', () {
      final ErrorType type = ErrorType.fromException(
        Exception('TimeoutException after 30s'),
      );

      expect(type, ErrorType.timeout);
    });

    test('status 401 dipetakan ke unauthorized', () {
      final ErrorType type = ErrorType.fromException(
        Exception('401 Unauthorized'),
      );

      expect(type, ErrorType.unauthorized);
    });

    test('pesan jwt dipetakan ke unauthorized', () {
      final ErrorType type = ErrorType.fromException(Exception('JWT expired'));

      expect(type, ErrorType.unauthorized);
    });

    test('status 404 dipetakan ke notFound', () {
      final ErrorType type = ErrorType.fromException(
        Exception('404 Not Found'),
      );

      expect(type, ErrorType.notFound);
    });

    test('status 400 dipetakan ke validation', () {
      final ErrorType type = ErrorType.fromException(
        Exception('400 bad request'),
      );

      expect(type, ErrorType.validation);
    });

    test('status 500 dipetakan ke server', () {
      final ErrorType type = ErrorType.fromException(
        Exception('500 Internal Server Error'),
      );

      expect(type, ErrorType.server);
    });

    test('exception tak dikenal dipetakan ke unknown', () {
      final ErrorType type = ErrorType.fromException(Exception('boom'));

      expect(type, ErrorType.unknown);
    });
  });

  group('ErrorType.isRetryable', () {
    test('network, timeout, dan server bisa dicoba ulang', () {
      expect(ErrorType.network.isRetryable, isTrue);
      expect(ErrorType.timeout.isRetryable, isTrue);
      expect(ErrorType.server.isRetryable, isTrue);
    });

    test('error non-sementara tidak bisa dicoba ulang', () {
      expect(ErrorType.unauthorized.isRetryable, isFalse);
      expect(ErrorType.notFound.isRetryable, isFalse);
      expect(ErrorType.validation.isRetryable, isFalse);
      expect(ErrorType.unknown.isRetryable, isFalse);
    });
  });

  group('ErrorType.userMessage', () {
    test('semua nilai punya pesan Bahasa Indonesia yang non-kosong', () {
      for (final ErrorType type in ErrorType.values) {
        expect(type.userMessage.trim(), isNotEmpty);
      }
    });
  });
}
