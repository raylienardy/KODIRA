import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/profile_logic.dart';

void main() {
  group('ProfileLogic.groupMasteryByTopic', () {
    test('progress kosong menghasilkan peta kosong', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[],
        levelIdToTopic: <int, String>{1: 'Variabel'},
      );

      expect(result, isEmpty);
    });

    test('satu topik memakai nilai mastery baris itu', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0.9},
        ],
        levelIdToTopic: <int, String>{1: 'Variabel'},
      );

      expect(result['Variabel'], closeTo(0.9, 0.0001));
    });

    test('beberapa level satu topik dirata-rata', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0.8},
          <String, dynamic>{'levelId': 2, 'masteryScore': 0.6},
        ],
        levelIdToTopic: <int, String>{1: 'Operator', 2: 'Operator'},
      );

      expect(result['Operator'], closeTo(0.7, 0.0001));
    });

    test('topik berbeda dipisah dan dihitung sendiri-sendiri', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0.5},
          <String, dynamic>{'levelId': 2, 'masteryScore': 1.0},
          <String, dynamic>{'levelId': 3, 'masteryScore': 0.9},
        ],
        levelIdToTopic: <int, String>{1: 'Operator', 2: 'Array', 3: 'Array'},
      );

      expect(result['Operator'], closeTo(0.5, 0.0001));
      expect(result['Array'], closeTo(0.95, 0.0001));
    });

    test('mastery nol dilewati karena belum ada penguasaan', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0},
          <String, dynamic>{'levelId': 2, 'masteryScore': 0.4},
        ],
        levelIdToTopic: <int, String>{1: 'Array', 2: 'Array'},
      );

      expect(result['Array'], closeTo(0.4, 0.0001));
    });

    test('levelId yang tidak dikenal masuk topik cadangan tanpa crash', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 99, 'masteryScore': 0.8},
        ],
        levelIdToTopic: <int, String>{1: 'Array'},
      );

      expect(result[ProfileLogic.fallbackTopic], closeTo(0.8, 0.0001));
    });

    test('topik null jatuh ke topik cadangan Umum', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0.7},
        ],
        levelIdToTopic: <int, String>{},
      );

      expect(result[ProfileLogic.fallbackTopic], closeTo(0.7, 0.0001));
    });

    test('topik berisi spasi saja dianggap kosong', () {
      final Map<String, double> result = ProfileLogic.groupMasteryByTopic(
        progress: <Map<String, dynamic>>[
          <String, dynamic>{'levelId': 1, 'masteryScore': 0.3},
        ],
        levelIdToTopic: <int, String>{1: '   '},
      );

      expect(result[ProfileLogic.fallbackTopic], closeTo(0.3, 0.0001));
    });
  });

  group('ProfileLogic.formatRelativeDate', () {
    final DateTime now = DateTime(2026, 10, 22, 10);
    final DateTime today = DateTime(2026, 10, 22, 1);
    final DateTime yesterday = DateTime(2026, 10, 21, 23);
    final DateTime threeDaysAgo = DateTime(2026, 10, 19);
    final DateTime eightDaysAgo = DateTime(2026, 10, 14);
    final DateTime fortyFiveDaysAgo = DateTime(2026, 9, 7);
    final DateTime overOneYearAgo = now.subtract(const Duration(days: 400));

    test('tanggal hari ini menjadi "Hari ini"', () {
      expect(ProfileLogic.formatRelativeDate(today, now: now), 'Hari ini');
    });

    test('kemarin menjadi "Kemarin"', () {
      expect(ProfileLogic.formatRelativeDate(yesterday, now: now), 'Kemarin');
    });

    test('tiga hari lalu menjadi "3 hari lalu"', () {
      expect(
        ProfileLogic.formatRelativeDate(threeDaysAgo, now: now),
        '3 hari lalu',
      );
    });

    test('delapan hari lalu menjadi "1 minggu lalu"', () {
      expect(
        ProfileLogic.formatRelativeDate(eightDaysAgo, now: now),
        '1 minggu lalu',
      );
    });

    test('empat puluh lima hari lalu menjadi "1 bulan lalu"', () {
      expect(
        ProfileLogic.formatRelativeDate(fortyFiveDaysAgo, now: now),
        '1 bulan lalu',
      );
    });

    test('lebih dari satu tahun menjadi "1 tahun lalu"', () {
      expect(
        ProfileLogic.formatRelativeDate(overOneYearAgo, now: now),
        '1 tahun lalu',
      );
    });

    test('tanggal masa depan tetap aman dibaca "Hari ini"', () {
      expect(
        ProfileLogic.formatRelativeDate(DateTime(2026, 10, 25), now: now),
        'Hari ini',
      );
    });
  });

  group('ProfileLogic.computeActiveLevel', () {
    test('tanpa progress memakai level 1', () {
      expect(ProfileLogic.computeActiveLevel(<Map<String, dynamic>>[]), 1);
    });

    test('level 1-3 selesai berlanjut ke level 4', () {
      final int level = ProfileLogic.computeActiveLevel(<Map<String, dynamic>>[
        <String, dynamic>{'levelId': 1, 'status': 'completed'},
        <String, dynamic>{'levelId': 2, 'status': 'completed'},
        <String, dynamic>{'levelId': 3, 'status': 'completed'},
      ]);

      expect(level, 4);
    });

    test('level active 5 dipakai walau ada level selesai', () {
      final int level = ProfileLogic.computeActiveLevel(<Map<String, dynamic>>[
        <String, dynamic>{'levelId': 1, 'status': 'completed'},
        <String, dynamic>{'levelId': 2, 'status': 'completed'},
        <String, dynamic>{'levelId': 5, 'status': 'active'},
        <String, dynamic>{'levelId': 3, 'status': 'locked'},
      ]);

      expect(level, 5);
    });

    test('active yang lebih rendah tidak menurunkan saran completed + 1', () {
      final int level = ProfileLogic.computeActiveLevel(<Map<String, dynamic>>[
        <String, dynamic>{'levelId': 1, 'status': 'completed'},
        <String, dynamic>{'levelId': 2, 'status': 'completed'},
        <String, dynamic>{'levelId': 3, 'status': 'completed'},
        <String, dynamic>{'levelId': 4, 'status': 'completed'},
        <String, dynamic>{'levelId': 5, 'status': 'completed'},
        <String, dynamic>{'levelId': 3, 'status': 'active'},
      ]);

      expect(level, 6);
    });
  });

  group('ProfileLogic.formatShortDate', () {
    test('format tanggal Indonesia ringkas', () {
      expect(
        ProfileLogic.formatShortDate(DateTime(2026, 10, 22)),
        '22 Okt 2026',
      );
    });

    test('bulan Januari dan hari pertama', () {
      expect(ProfileLogic.formatShortDate(DateTime(2026, 1, 1)), '1 Jan 2026');
    });
  });

  group('ProfileLogic nama tampilan', () {
    test('sembilan badge punya nama tampilan', () {
      expect(ProfileLogic.badgeDisplayName('streak_3'), '3 Hari');
      expect(ProfileLogic.badgeDisplayName('streak_7'), 'Seminggu');
      expect(ProfileLogic.badgeDisplayName('streak_30'), 'Sebulan');
      expect(ProfileLogic.badgeDisplayName('level_5'), '5 Level');
      expect(ProfileLogic.badgeDisplayName('level_10'), '10 Level');
      expect(ProfileLogic.badgeDisplayName('level_25'), '25 Level');
      expect(ProfileLogic.badgeDisplayName('xp_100'), '100 XP');
      expect(ProfileLogic.badgeDisplayName('xp_500'), '500 XP');
      expect(ProfileLogic.badgeDisplayName('xp_1000'), '1000 XP');
    });

    test('kode badge tak dikenal ditampilkan apa adanya', () {
      expect(ProfileLogic.badgeDisplayName('streak_365'), 'streak_365');
    });

    test('tiga achievement punya nama tampilan', () {
      expect(
        ProfileLogic.achievementDisplayName('first_login'),
        'Login Pertama',
      );
      expect(
        ProfileLogic.achievementDisplayName('first_quiz_pass'),
        'Kuis Pertama Lulus',
      );
      expect(
        ProfileLogic.achievementDisplayName('complete_chapter_1'),
        'Bab 1 Selesai (L1-15)',
      );
    });

    test('kode achievement tak dikenal ditampilkan apa adanya', () {
      expect(ProfileLogic.achievementDisplayName('chapter_2'), 'chapter_2');
    });
  });

  group('ProfileLogic.activityStatusLabel', () {
    test('status dikenal memakai label Indonesia', () {
      expect(ProfileLogic.activityStatusLabel('completed'), 'Selesai');
      expect(ProfileLogic.activityStatusLabel('active'), 'Sedang belajar');
      expect(ProfileLogic.activityStatusLabel('remedial'), 'Remedial');
      expect(ProfileLogic.activityStatusLabel('locked'), 'Terkunci');
    });

    test('status tak dikenal dikembalikan apa adanya', () {
      expect(ProfileLogic.activityStatusLabel('paused'), 'paused');
    });
  });
}
