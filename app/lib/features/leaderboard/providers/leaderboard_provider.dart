import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/leaderboard_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider repository leaderboard (berbasis view `leaderboard_global`).
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LeaderboardRepository(client);
});

/// Top 10 peringkat global (urut menurun berdasarkan total XP).
final top10LeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
      return ref.watch(leaderboardRepositoryProvider).fetchTop10();
    });

/// Peringkat personal user aktif — tetap tampil walau di luar top 10.
final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return null;
  return ref.watch(leaderboardRepositoryProvider).fetchMyRank(user.id);
});
