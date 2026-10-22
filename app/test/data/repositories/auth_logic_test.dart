import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/auth_logic.dart';

void main() {
  group('AuthLogic.isValidNim', () {
    test('NIM 13 digit dianggap valid', () {
      expect(AuthLogic.isValidNim('2402095010141'), isTrue);
    });

    test('NIM 13 digit dengan nol di depan valid', () {
      expect(AuthLogic.isValidNim('0123456789012'), isTrue);
    });

    test('NIM 12 digit tidak valid', () {
      expect(AuthLogic.isValidNim('240209501014'), isFalse);
    });

    test('NIM 14 digit tidak valid', () {
      expect(AuthLogic.isValidNim('24020950101410'), isFalse);
    });

    test('NIM dengan huruf tidak valid', () {
      expect(AuthLogic.isValidNim('24020950101a1'), isFalse);
    });

    test('NIM kosong tidak valid', () {
      expect(AuthLogic.isValidNim(''), isFalse);
    });
  });

  group('AuthLogic.nimToEmail', () {
    test('mengubah NIM menjadi email internal Supabase', () {
      expect(
        AuthLogic.nimToEmail('2402095010141'),
        'nim_2402095010141@kodira.local',
      );
    });

    test('NIM pendek tetap mengikuti format yang sama', () {
      expect(AuthLogic.nimToEmail('1'), 'nim_1@kodira.local');
    });
  });

  group('AuthLogic.isInvalidCredentials', () {
    test('pesan invalid login credentials terdeteksi', () {
      expect(
        AuthLogic.isInvalidCredentials('Invalid login credentials'),
        isTrue,
      );
    });

    test('pesan invalid_credentials terdeteksi', () {
      expect(AuthLogic.isInvalidCredentials('invalid_credentials'), isTrue);
    });

    test('huruf besar pada pesan tetap terdeteksi', () {
      expect(
        AuthLogic.isInvalidCredentials('INVALID LOGIN CREDENTIALS'),
        isTrue,
      );
    });

    test('pesan lain tidak dianggap kredensial salah', () {
      expect(AuthLogic.isInvalidCredentials('Email not confirmed'), isFalse);
    });
  });

  group('AuthLogic.mapAuthError', () {
    test(
      'kode invalid_credentials dipetakan ke pesan NIM atau password salah',
      () {
        expect(
          AuthLogic.mapAuthError('invalid_credentials', null),
          'NIM atau password salah.',
        );
      },
    );

    test('kode user_not_found dipetakan ke pesan akun tidak ditemukan', () {
      expect(
        AuthLogic.mapAuthError('user_not_found', null),
        'Akun tidak ditemukan.',
      );
    });

    test(
      'kode email_not_confirmed dipetakan ke pesan akun belum dikonfirmasi',
      () {
        expect(
          AuthLogic.mapAuthError('email_not_confirmed', null),
          'Akun belum dikonfirmasi.',
        );
      },
    );

    test('kode lain memakai pesan dari server bila ada', () {
      expect(
        AuthLogic.mapAuthError(
          'over_request_rate_limit',
          'Terlalu banyak percobaan',
        ),
        'Terlalu banyak percobaan',
      );
    });

    test('kode lain tanpa pesan memakai pesan bawaan', () {
      expect(
        AuthLogic.mapAuthError('unknown', null),
        'Terjadi kesalahan. Coba lagi.',
      );
    });
  });
}
