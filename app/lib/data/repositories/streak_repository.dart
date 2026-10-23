import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/user_streak_model.dart';
import 'i_streak_repository.dart';
import 'streak_logic.dart';

/// Repository untuk tabel `user_streaks` yang menyimpan streak harian user.
class StreakRepository implements IStreakRepository {
  final supa.SupabaseClient _client;

  StreakRepository(this._client);

  /// Ambil streak milik satu user, atau null bila belum pernah aktif.
  @override
  Future<UserStreakModel?> getForUser(String userId) async {
    try {
      final response = await _client
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserStreakModel.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat streak: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat streak: $e');
    }
  }

  /// Perbarui streak saat user aktif. Idempotent per hari: kalau user sudah
  /// aktif hari ini, tidak ada baris yang ditulis ulang.
  @override
  Future<UserStreakModel> updateOnActivity({
    required String userId,
    required DateTime now,
  }) async {
    final UserStreakModel? existing = await getForUser(userId);

    final int newCurrent = StreakLogic.computeCurrentStreak(
      lastActiveDate: existing?.lastActiveDate,
      currentStreak: existing?.currentStreak ?? 0,
      now: now,
    );
    final int newLongest = StreakLogic.computeLongestStreak(
      currentStreak: newCurrent,
      longestStreak: existing?.longestStreak ?? 0,
    );

    if (existing == null) {
      final Map<String, dynamic> payload = StreakLogic.buildInsertPayload(
        userId: userId,
        currentStreak: newCurrent,
        longestStreak: newLongest,
        lastActiveDate: now,
      );
      await _client.from('user_streaks').insert(payload);
      return UserStreakModel.fromJson(payload);
    }

    // Sudah aktif hari ini -> streak tidak perlu disentuh.
    if (StreakLogic.isActiveToday(
      lastActiveDate: existing.lastActiveDate,
      now: now,
    )) {
      return existing;
    }

    await _client
        .from('user_streaks')
        .update(
          StreakLogic.buildUpdatePayload(
            currentStreak: newCurrent,
            longestStreak: newLongest,
            lastActiveDate: now,
          ),
        )
        .eq('user_id', userId);

    return existing.copyWith(
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastActiveDate: DateTime(now.year, now.month, now.day),
    );
  }
}
