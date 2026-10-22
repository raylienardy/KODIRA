import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/core/errors/error_type.dart';
import 'package:kodira/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success menandai isSuccess true dan isFailure false', () {
      const Result<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Failure menandai isFailure true dan isSuccess false', () {
      const Result<int> result = Failure(ErrorType.network);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('valueOrNull mengembalikan nilai pada Success', () {
      const Result<String> result = Success('kodira');

      expect(result.valueOrNull, 'kodira');
      expect(result.errorOrNull, isNull);
    });

    test('errorOrNull mengembalikan error pada Failure', () {
      const Result<String> result = Failure(ErrorType.timeout);

      expect(result.errorOrNull, ErrorType.timeout);
      expect(result.valueOrNull, isNull);
    });

    test('map mengubah nilai pada Success', () {
      const Result<int> result = Success(2);

      final Result<String> mapped = result.map((int value) => 'nilai $value');

      expect(mapped.isSuccess, isTrue);
      expect(mapped.valueOrNull, 'nilai 2');
    });

    test('map meneruskan Failure tanpa mengubah error', () {
      const Result<int> result = Failure(ErrorType.server);

      final Result<String> mapped = result.map((int value) => 'tidak dipakai');

      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, ErrorType.server);
    });

    test('when memanggil callback success pada Success', () {
      const Result<int> result = Success(7);

      final String output = result.when(
        success: (int value) => 'sukses $value',
        failure: (ErrorType error) => 'gagal',
      );

      expect(output, 'sukses 7');
    });

    test('when memanggil callback failure pada Failure', () {
      const Result<int> result = Failure(ErrorType.unauthorized);

      final String output = result.when(
        success: (int value) => 'sukses',
        failure: (ErrorType error) => 'gagal ${error.name}',
      );

      expect(output, 'gagal unauthorized');
    });

    test('map berantai mempertahankan nilai hasil transformasi', () {
      const Result<int> result = Success(3);

      final Result<int> mapped = result
          .map((int value) => value * 2)
          .map((int value) => value + 1);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.valueOrNull, 7);
    });
  });
}
