import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/app/theme.dart';
import 'package:kodira/data/logic/xp_logic.dart';
import 'package:kodira/features/quiz/widgets/result_logic.dart';

void main() {
  group('ResultLogic.computeTier', () {
    test('0 dari 3 jawaban benar masuk fail', () {
      expect(ResultLogic.computeTier(0, 3), ResultTier.fail);
    });

    test('1 dari 3 (33%) masuk fail', () {
      expect(ResultLogic.computeTier(1, 3), ResultTier.fail);
    });

    test('2 dari 3 (66%) masuk remedial', () {
      expect(ResultLogic.computeTier(2, 3), ResultTier.remedial);
    });

    test('3 dari 3 (100%) masuk pass', () {
      expect(ResultLogic.computeTier(3, 3), ResultTier.pass);
    });

    test('7 dari 10 tepat di batas 70% masuk pass', () {
      expect(ResultLogic.computeTier(7, 10), ResultTier.pass);
    });

    test('4 dari 10 tepat di batas 40% masuk remedial', () {
      expect(ResultLogic.computeTier(4, 10), ResultTier.remedial);
    });

    test('total 0 masuk fail tanpa pembagian nol', () {
      expect(ResultLogic.computeTier(0, 0), ResultTier.fail);
    });
  });

  group('ResultLogic.titleFor', () {
    test('judul sesuai tingkat', () {
      expect(ResultLogic.titleFor(ResultTier.pass), 'Lulus!');
      expect(ResultLogic.titleFor(ResultTier.remedial), 'Hampir!');
      expect(ResultLogic.titleFor(ResultTier.fail), 'Belum Lulus');
    });
  });

  group('ResultLogic.subtitleFor', () {
    test('subjudul sesuai tingkat', () {
      expect(
        ResultLogic.subtitleFor(ResultTier.pass),
        'Kamu berhasil menyelesaikan level ini.',
      );
      expect(
        ResultLogic.subtitleFor(ResultTier.remedial),
        'Coba sekali lagi untuk memperbaiki skor.',
      );
      expect(
        ResultLogic.subtitleFor(ResultTier.fail),
        'Yuk pelajari materinya lagi sebelum mencoba.',
      );
    });
  });

  group('ResultLogic.primaryLabelFor', () {
    test('fail mengulang kuis', () {
      expect(
        ResultLogic.primaryLabelFor(
          tier: ResultTier.fail,
          levelId: 3,
          isLastLevel: false,
        ),
        'Coba Lagi',
      );
    });

    test('remedial mengulang kuis', () {
      expect(
        ResultLogic.primaryLabelFor(
          tier: ResultTier.remedial,
          levelId: 3,
          isLastLevel: false,
        ),
        'Coba Lagi',
      );
    });

    test('pass non-level terakhir menuju level berikutnya', () {
      expect(
        ResultLogic.primaryLabelFor(
          tier: ResultTier.pass,
          levelId: 3,
          isLastLevel: false,
        ),
        'Lanjut ke Level 4',
      );
    });

    test('pass level terakhir kembali ke Home', () {
      expect(
        ResultLogic.primaryLabelFor(
          tier: ResultTier.pass,
          levelId: 50,
          isLastLevel: true,
        ),
        'Kembali ke Home',
      );
    });
  });

  group('ResultLogic.secondaryLabelFor', () {
    test('fail menampilkan Review Materi', () {
      expect(
        ResultLogic.secondaryLabelFor(
          tier: ResultTier.fail,
          isLastLevel: false,
        ),
        'Review Materi',
      );
    });

    test('remedial menampilkan Review Materi', () {
      expect(
        ResultLogic.secondaryLabelFor(
          tier: ResultTier.remedial,
          isLastLevel: false,
        ),
        'Review Materi',
      );
    });

    test('pass non-level terakhir menampilkan Kembali ke Home', () {
      expect(
        ResultLogic.secondaryLabelFor(
          tier: ResultTier.pass,
          isLastLevel: false,
        ),
        'Kembali ke Home',
      );
    });

    test('pass level terakhir tidak punya tombol secondary', () {
      expect(
        ResultLogic.secondaryLabelFor(tier: ResultTier.pass, isLastLevel: true),
        isNull,
      );
    });
  });

  group('ResultLogic.xpMessageFor', () {
    test('penyelesaian pertama dengan XP memakai XP percobaan ini', () {
      final String message = ResultLogic.xpMessageFor(
        xpEarned: 100,
        xpThisAttempt: 100,
        isFirstCompletion: true,
        attempts: 1,
      );

      expect(message, 'Kamu mendapat 100 XP');
    });

    test('penyelesaian pertama tanpa XP menyarankan perbaikan skor', () {
      final String message = ResultLogic.xpMessageFor(
        xpEarned: 0,
        xpThisAttempt: 0,
        isFirstCompletion: true,
        attempts: 1,
      );

      expect(message, 'Belum dapat XP. Coba tingkatkan skormu.');
    });

    test('percobaan ulang memakai XP efektif dan nomor percobaan', () {
      final String message = ResultLogic.xpMessageFor(
        xpEarned: 100,
        xpThisAttempt: 50,
        isFirstCompletion: false,
        attempts: 3,
      );

      expect(message, 'XP sudah maksimal (100). Percobaan ke-3.');
    });

    test('percobaan ulang tanpa XP hanya menyebut nomor percobaan', () {
      final String message = ResultLogic.xpMessageFor(
        xpEarned: 0,
        xpThisAttempt: 0,
        isFirstCompletion: false,
        attempts: 2,
      );

      expect(message, 'Percobaan ke-2.');
    });
  });

  group('ResultLogic.xpMessageForResult', () {
    test('perbaikan XP menampilkan XP percobaan', () {
      const XpResult result = XpResult(
        baseXp: 100,
        multiplier: 1.5,
        attemptXp: 150,
        previousXp: 50,
        finalXp: 150,
        isPass: true,
        isRemedial: false,
        isFail: false,
      );

      expect(ResultLogic.xpMessageForResult(result), 'Kamu mendapat 150 XP');
    });

    test('tanpa perbaikan menampilkan XP maksimal', () {
      const XpResult result = XpResult(
        baseXp: 50,
        multiplier: 1.0,
        attemptXp: 50,
        previousXp: 200,
        finalXp: 200,
        isPass: true,
        isRemedial: false,
        isFail: false,
      );

      expect(
        ResultLogic.xpMessageForResult(result),
        'XP kamu sudah maksimal (200)',
      );
    });

    test('gagal tanpa XP menyarankan remedial', () {
      const XpResult result = XpResult(
        baseXp: 0,
        multiplier: 2.5,
        attemptXp: 0,
        previousXp: 0,
        finalXp: 0,
        isPass: false,
        isRemedial: false,
        isFail: true,
      );

      expect(
        ResultLogic.xpMessageForResult(result),
        'Belum dapat XP — coba remedial',
      );
    });

    test('gagal dengan XP lama tetap menampilkan XP maksimal', () {
      const XpResult result = XpResult(
        baseXp: 0,
        multiplier: 1.0,
        attemptXp: 0,
        previousXp: 120,
        finalXp: 120,
        isPass: false,
        isRemedial: false,
        isFail: true,
      );

      expect(
        ResultLogic.xpMessageForResult(result),
        'XP kamu sudah maksimal (120)',
      );
    });
  });

  group('ResultLogic.masteryColorFor', () {
    test('warna aksen mengikuti tingkat', () {
      expect(
        ResultLogic.masteryColorFor(ResultTier.pass),
        KodiraColors.success500,
      );
      expect(
        ResultLogic.masteryColorFor(ResultTier.remedial),
        KodiraColors.reward500,
      );
      expect(
        ResultLogic.masteryColorFor(ResultTier.fail),
        KodiraColors.alert700,
      );
    });
  });
}
