import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/user_progress_model.dart';
import 'i_user_progress_repository.dart';
import 'progress_logic.dart';

/// Repository untuk tabel `user_progress` yang menyimpan progress belajar
/// per level untuk setiap user.
class UserProgressRepository implements IUserProgressRepository {
  final supa.SupabaseClient _client;

  UserProgressRepository(this._client);

  /// Ambil seluruh progress milik satu user.
  @override
  Future<List<UserProgressModel>> getAllForUser(String userId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId);

      final list = response as List<dynamic>;
      return list
          .map(
            (item) =>
                UserProgressModel.fromSupabase(item as Map<String, dynamic>),
          )
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat progress belajar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat progress: $e');
    }
  }

  /// Ambil progress user pada satu level, atau null bila belum ada.
  @override
  Future<UserProgressModel?> getForLevel(String userId, int levelId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('level_id', levelId)
          .maybeSingle();

      if (response == null) return null;
      return UserProgressModel.fromSupabase(response);
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat progress level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat progress level: $e');
    }
  }

  /// Simpan hasil belajar untuk satu level.
  ///
  /// Bila progress untuk level tersebut belum ada, data baru di-insert.
  /// Bila sudah ada, baris yang sama di-update dengan aturan:
  /// - `mastery_score` dan `xp_earned` memakai nilai tertinggi antara nilai
  ///   baru dan nilai lama, jadi skor terbaik user tidak pernah turun.
  /// - `attempts` bertambah satu karena ada percobaan baru.
  /// - `status` memakai status baru (override) dan `completed_at` diisi
  ///   sekarang bila statusnya `completed`, dibersihkan bila tidak.
  @override
  Future<void> upsert({
    required String userId,
    required int levelId,
    required String status,
    required double masteryScore,
    required int xpEarned,
    required int attempts,
  }) async {
    final existing = await getForLevel(userId, levelId);
    final now = DateTime.now();

    try {
      if (existing == null) {
        await _client
            .from('user_progress')
            .insert(
              ProgressLogic.buildInsertPayload(
                userId: userId,
                levelId: levelId,
                status: status,
                masteryScore: masteryScore,
                xpEarned: xpEarned,
                attempts: attempts,
                now: now,
              ),
            );
        return;
      }

      await _client
          .from('user_progress')
          .update(
            ProgressLogic.buildUpdatePayload(
              existingStatus: existing.status,
              existingMasteryScore: existing.masteryScore,
              existingXpEarned: existing.xpEarned,
              existingAttempts: existing.attempts,
              existingCompletedAt: existing.completedAt,
              newStatus: status,
              newMasteryScore: masteryScore,
              newXpEarned: xpEarned,
              now: now,
            ),
          )
          .eq('id', existing.id);
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal menyimpan progress: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menyimpan progress: $e');
    }
  }

  /// Total XP yang sudah dikumpulkan user dari seluruh level.
  @override
  Future<int> getTotalXp(String userId) async {
    final progress = await getAllForUser(userId);
    return progress.fold<int>(0, (sum, item) => sum + item.xpEarned);
  }
}
