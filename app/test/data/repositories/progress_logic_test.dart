import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/progress_logic.dart';

void main() {
  group('ProgressLogic.computeStatus', () {
    test('completed tidak boleh turun ke active', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'completed',
          newStatus: 'active',
        ),
        'completed',
      );
    });

    test('completed tidak boleh turun ke remedial', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'completed',
          newStatus: 'remedial',
        ),
        'completed',
      );
    });

    test('completed tetap completed saat diulang', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'completed',
          newStatus: 'completed',
        ),
        'completed',
      );
    });

    test('active boleh naik ke completed', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'active',
          newStatus: 'completed',
        ),
        'completed',
      );
    });

    test('active tetap active saat diulang dengan nilai lebih rendah', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'active',
          newStatus: 'active',
        ),
        'active',
      );
    });

    test('locked mengikuti status baru', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'locked',
          newStatus: 'active',
        ),
        'active',
      );
    });

    test('remedial pada level completed ditahan', () {
      expect(
        ProgressLogic.computeStatus(
          existingStatus: 'completed',
          newStatus: 'remedial',
        ),
        'completed',
      );
    });
  });

  group('ProgressLogic.computeMastery', () {
    test('memakai nilai yang lebih tinggi', () {
      expect(ProgressLogic.computeMastery(0.4, 0.9), 0.9);
    });

    test('nilai lama dipakai saat lebih tinggi', () {
      expect(ProgressLogic.computeMastery(0.95, 0.3), 0.95);
    });

    test('nilai sama dipertahankan', () {
      expect(ProgressLogic.computeMastery(0.7, 0.7), 0.7);
    });
  });

  group('ProgressLogic.computeXp', () {
    test('memakai nilai yang lebih tinggi', () {
      expect(ProgressLogic.computeXp(0, 100), 100);
    });

    test('nilai lama dipakai saat lebih tinggi', () {
      expect(ProgressLogic.computeXp(100, 50), 100);
    });

    test('nilai sama dipertahankan', () {
      expect(ProgressLogic.computeXp(50, 50), 50);
    });
  });

  group('ProgressLogic.computeAttempts', () {
    test('percobaan pertama menjadi satu', () {
      expect(ProgressLogic.computeAttempts(0), 1);
    });

    test('percobaan bertambah satu', () {
      expect(ProgressLogic.computeAttempts(4), 5);
    });
  });

  group('ProgressLogic.computeCompletedAt', () {
    final DateTime now = DateTime.utc(2026, 10, 22, 8);

    test('status completed tanpa waktu lama memakai waktu sekarang', () {
      expect(
        ProgressLogic.computeCompletedAt(
          finalStatus: 'completed',
          existing: null,
          now: now,
        ),
        now,
      );
    });

    test('status completed mempertahankan waktu penyelesaian asli', () {
      final DateTime lama = DateTime.utc(2026, 1, 2, 3);
      expect(
        ProgressLogic.computeCompletedAt(
          finalStatus: 'completed',
          existing: lama,
          now: now,
        ),
        lama,
      );
    });

    test('status selain completed mengosongkan waktu penyelesaian', () {
      expect(
        ProgressLogic.computeCompletedAt(
          finalStatus: 'active',
          existing: DateTime.utc(2026, 1, 2, 3),
          now: now,
        ),
        isNull,
      );
    });
  });

  group('ProgressLogic.buildInsertPayload', () {
    final DateTime now = DateTime.utc(2026, 10, 22, 8);

    test('berisi seluruh kolom baris baru', () {
      final Map<String, dynamic> payload = ProgressLogic.buildInsertPayload(
        userId: 'user-1',
        levelId: 3,
        status: 'active',
        masteryScore: 0.5,
        xpEarned: 50,
        attempts: 1,
        now: now,
      );

      expect(payload['user_id'], 'user-1');
      expect(payload['level_id'], 3);
      expect(payload['status'], 'active');
      expect(payload['mastery_score'], 0.5);
      expect(payload['xp_earned'], 50);
      expect(payload['attempts'], 1);
      expect(payload['last_attempt_at'], now.toIso8601String());
      expect(payload['completed_at'], isNull);
    });

    test('status completed mengisi completed_at', () {
      final Map<String, dynamic> payload = ProgressLogic.buildInsertPayload(
        userId: 'user-1',
        levelId: 1,
        status: 'completed',
        masteryScore: 1.0,
        xpEarned: 100,
        attempts: 1,
        now: now,
      );

      expect(payload['completed_at'], now.toIso8601String());
    });
  });

  group('ProgressLogic.buildUpdatePayload', () {
    final DateTime now = DateTime.utc(2026, 10, 22, 8);
    final DateTime lama = DateTime.utc(2026, 1, 2, 3);

    test('retake dengan nilai lebih rendah tidak menurunkan status', () {
      final Map<String, dynamic> payload = ProgressLogic.buildUpdatePayload(
        existingStatus: 'completed',
        existingMasteryScore: 0.9,
        existingXpEarned: 100,
        existingAttempts: 1,
        existingCompletedAt: lama,
        newStatus: 'active',
        newMasteryScore: 0.3,
        newXpEarned: 0,
        now: now,
      );

      expect(payload['status'], 'completed');
      expect(payload['mastery_score'], 0.9);
      expect(payload['xp_earned'], 100);
      expect(payload['attempts'], 2);
      expect(payload['completed_at'], lama.toIso8601String());
    });

    test('kenaikan status dan nilai tetap dipakai', () {
      final Map<String, dynamic> payload = ProgressLogic.buildUpdatePayload(
        existingStatus: 'active',
        existingMasteryScore: 0.5,
        existingXpEarned: 50,
        existingAttempts: 2,
        existingCompletedAt: null,
        newStatus: 'completed',
        newMasteryScore: 0.8,
        newXpEarned: 100,
        now: now,
      );

      expect(payload['status'], 'completed');
      expect(payload['mastery_score'], 0.8);
      expect(payload['xp_earned'], 100);
      expect(payload['attempts'], 3);
      expect(payload['completed_at'], now.toIso8601String());
    });

    test('payload update memakai nama kolom tabel', () {
      final Map<String, dynamic> payload = ProgressLogic.buildUpdatePayload(
        existingStatus: 'active',
        existingMasteryScore: 0.5,
        existingXpEarned: 50,
        existingAttempts: 1,
        existingCompletedAt: null,
        newStatus: 'active',
        newMasteryScore: 0.6,
        newXpEarned: 50,
        now: now,
      );

      expect(payload.keys.toSet(), <String>{
        'status',
        'mastery_score',
        'xp_earned',
        'attempts',
        'last_attempt_at',
        'completed_at',
      });
    });
  });
}
