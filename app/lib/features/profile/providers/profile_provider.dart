import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_achievement_model.dart';
import '../../../data/models/user_badge_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/profile_logic.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/level_provider.dart';

/// Seluruh badge milik user yang sedang login, terbaru di atas.
final userBadgesProvider = FutureProvider<List<UserBadgeModel>>((ref) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return <UserBadgeModel>[];

  final data = await ref
      .watch(supabaseClientProvider)
      .from('user_badges')
      .select()
      .eq('user_id', user.id)
      .order('earned_at', ascending: false);

  return (data as List<dynamic>)
      .map((item) => UserBadgeModel.fromJson(item as Map<String, dynamic>))
      .toList();
});

/// Seluruh achievement milik user yang sedang login, terbaru di atas.
final userAchievementsProvider = FutureProvider<List<UserAchievementModel>>((
  ref,
) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return <UserAchievementModel>[];

  final data = await ref
      .watch(supabaseClientProvider)
      .from('user_achievements')
      .select()
      .eq('user_id', user.id)
      .order('earned_at', ascending: false);

  return (data as List<dynamic>)
      .map(
        (item) => UserAchievementModel.fromJson(item as Map<String, dynamic>),
      )
      .toList();
});

/// Rata-rata mastery per topik: `{topic: 0.0 - 1.0}`.
///
/// Hanya baris dengan mastery di atas nol yang dihitung, dan level tanpa
/// topik dikelompokkan ke "Umum" supaya layar tidak crash.
final masteryByTopicProvider = FutureProvider<Map<String, double>>((ref) async {
  final levels = await ref.watch(allLevelsProvider.future);
  final progress = await ref.watch(allProgressProvider.future);

  final Map<int, String> levelIdToTopic = <int, String>{
    for (final level in levels)
      if (level.topic != null && level.topic!.trim().isNotEmpty)
        level.id: level.topic!.trim(),
  };

  return ProfileLogic.groupMasteryByTopic(
    progress: progress
        .map(
          (UserProgressModel item) => <String, dynamic>{
            'levelId': item.levelId,
            'masteryScore': item.masteryScore,
          },
        )
        .toList(),
    levelIdToTopic: levelIdToTopic,
  );
});

/// Lima aktivitas terakhir berdasarkan waktu percobaan terakhir.
///
/// `last_attempt_at` boleh null (baris lama), jadi urutan memakai
/// `lastAttemptAt` lalu `completedAt`. Bila keduanya null, baris diletakkan
/// paling bawah dengan urutan level menurun supaya hasilnya tetap stabil.
final recentActivityProvider = FutureProvider<List<UserProgressModel>>((
  ref,
) async {
  final progress = await ref.watch(allProgressProvider.future);
  final List<UserProgressModel> sorted = <UserProgressModel>[...progress]
    ..sort((UserProgressModel a, UserProgressModel b) {
      final DateTime? aTime = a.lastAttemptAt ?? a.completedAt;
      final DateTime? bTime = b.lastAttemptAt ?? b.completedAt;

      if (aTime == null && bTime == null) {
        return b.levelId.compareTo(a.levelId);
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

  return sorted.take(5).toList();
});
