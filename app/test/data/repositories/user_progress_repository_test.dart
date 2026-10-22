import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/progress_logic.dart';

/// Kontrak tulis pada tabel `user_progress`.
///
/// CATATAN PENTING — integration test di-defer ke Phase 6 (P6-001):
///
/// [UserProgressRepository] menerima `SupabaseClient` (kelas konkret, bukan
/// interface), sehingga perilakunya tidak bisa dipalsukan tanpa mock.
/// Menambahkan `mocktail` belum dilakukan karenanilainya rendah dibanding
/// biaya dependensi, dan seluruh aturan bisnisnya sudah berada di
/// [ProgressLogic] yang diuji penuh di `progress_logic_test.dart`.
///
/// Test di bawah memverifikasi **payload persis** yang dikirim repository ke
/// Supabase pada cabang INSERT dan UPDATE, sehingga regresi pada nama kolom,
/// aturan status, mastery, XP, attempts, maupun completed_at akan tertangkap.
void main() {
  final DateTime now = DateTime.utc(2026, 10, 22, 8);
  final DateTime lama = DateTime.utc(2026, 1, 2, 3);

  group('payload insert UserProgressRepository', () {
    test('menyimpan user, level, status, nilai, dan percobaan', () {
      final Map<String, dynamic> payload = ProgressLogic.buildInsertPayload(
        userId: 'user-1',
        levelId: 1,
        status: 'completed',
        masteryScore: 1.0,
        xpEarned: 100,
        attempts: 1,
        now: now,
      );

      expect(payload['user_id'], 'user-1');
      expect(payload['level_id'], 1);
      expect(payload['status'], 'completed');
      expect(payload['mastery_score'], 1.0);
      expect(payload['xp_earned'], 100);
      expect(payload['attempts'], 1);
      expect(payload['last_attempt_at'], now.toIso8601String());
      expect(payload['completed_at'], now.toIso8601String());
    });

    test('kuis gagal tidak mengisi completed_at', () {
      final Map<String, dynamic> payload = ProgressLogic.buildInsertPayload(
        userId: 'user-1',
        levelId: 1,
        status: 'active',
        masteryScore: 0.2,
        xpEarned: 0,
        attempts: 1,
        now: now,
      );

      expect(payload['status'], 'active');
      expect(payload['completed_at'], isNull);
    });

    test('kunci payload sama dengan kolom tabel user_progress', () {
      final Map<String, dynamic> payload = ProgressLogic.buildInsertPayload(
        userId: 'user-1',
        levelId: 1,
        status: 'active',
        masteryScore: 0.4,
        xpEarned: 50,
        attempts: 1,
        now: now,
      );

      expect(payload.keys.toSet(), <String>{
        'user_id',
        'level_id',
        'status',
        'mastery_score',
        'xp_earned',
        'attempts',
        'last_attempt_at',
        'completed_at',
      });
    });
  });

  group('payload update UserProgressRepository', () {
    test('retake level selesai tidak menurunkan status maupun nilai', () {
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

    test('kuis ulang yang lulus menaikkan status dan menambah attempts', () {
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

    test('kunci payload update tidak memuat user_id dan level_id', () {
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

      expect(payload.containsKey('user_id'), isFalse);
      expect(payload.containsKey('level_id'), isFalse);
      expect(payload['last_attempt_at'], now.toIso8601String());
    });
  });
}
