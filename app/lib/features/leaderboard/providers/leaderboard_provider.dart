import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/leaderboard_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Active tab: 'global' atau 'class'.
final leaderboardTabProvider = StateProvider<String>((ref) => 'global');

/// Current user's primary class_id (null kalau belum enrolled).
final currentUserClassIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return null;

  // 1. Try from UserModel if available
  if (user.primaryClassId != null) {
    return user.primaryClassId;
  }

  // 2. Fetch from users table if needed
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('users')
      .select('primary_class_id')
      .eq('id', user.id)
      .maybeSingle();
  return response?['primary_class_id'] as String?;
});

/// Top 10 per class.
final top10ByClassProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, classId) async {
      return ref.read(leaderboardRepositoryProvider).fetchTop10ByClass(classId);
    });

/// Personal rank per class.
final myRankByClassProvider = FutureProvider.family<LeaderboardEntry?, String>((
  ref,
  classId,
) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return null;
  return ref
      .read(leaderboardRepositoryProvider)
      .fetchMyRankByClass(user.id, classId);
});

/// Provider repository leaderboard (berbasis view `leaderboard_global`).
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LeaderboardRepository(client);
});

/// Top 10 peringkat global (urut menurun berdasarkan total XP).
final top10LeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((
  ref,
) async {
  return ref.watch(leaderboardRepositoryProvider).fetchTop10();
});

/// Peringkat personal user aktif — tetap tampil walau di luar top 10.
final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return null;
  return ref.watch(leaderboardRepositoryProvider).fetchMyRank(user.id);
});
