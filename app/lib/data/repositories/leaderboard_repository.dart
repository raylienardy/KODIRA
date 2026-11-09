import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class LeaderboardEntry {
  final String userId;
  final String name;
  final String nim;
  final int totalXp;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.nim,
    required this.totalXp,
    required this.rank,
  });
}

class LeaderboardRepository {
  final supa.SupabaseClient _client;
  LeaderboardRepository(this._client);

  /// Top 10 global leaderboard
  Future<List<LeaderboardEntry>> fetchTop10() async {
    final response = await _client
        .from('leaderboard_global')
        .select()
        .limit(10);
    final data = List<Map<String, dynamic>>.from(response);
    return data
        .asMap()
        .entries
        .map(
          (e) => LeaderboardEntry(
            userId: e.value['user_id'] as String,
            name: e.value['name'] as String,
            nim: e.value['nim'] as String,
            totalXp: e.value['total_xp'] as int,
            rank: e.key + 1,
          ),
        )
        .toList();
  }

  /// Personal rank (user sendiri, even if outside top 10)
  Future<LeaderboardEntry?> fetchMyRank(String userId) async {
    final response = await _client.from('leaderboard_global').select();
    final all = List<Map<String, dynamic>>.from(response);
    final index = all.indexWhere((r) => r['user_id'] == userId);
    if (index < 0) return null;
    return LeaderboardEntry(
      userId: userId,
      name: all[index]['name'] as String,
      nim: all[index]['nim'] as String,
      totalXp: all[index]['total_xp'] as int,
      rank: index + 1,
    );
  }

  /// Top 10 leaderboard per class (filter by class_id).
  Future<List<LeaderboardEntry>> fetchTop10ByClass(String classId) async {
    final response = await _client
        .from('leaderboard_by_class')
        .select()
        .eq('class_id', classId)
        .limit(10);
    final data = List<Map<String, dynamic>>.from(response);
    return data
        .asMap()
        .entries
        .map(
          (e) => LeaderboardEntry(
            userId: e.value['user_id'] as String,
            name: e.value['name'] as String,
            nim: e.value['nim'] as String,
            totalXp: e.value['total_xp'] as int,
            rank: e.key + 1,
          ),
        )
        .toList();
  }

  /// Personal rank within a class.
  Future<LeaderboardEntry?> fetchMyRankByClass(
    String userId,
    String classId,
  ) async {
    final response = await _client
        .from('leaderboard_by_class')
        .select()
        .eq('class_id', classId);
    final all = List<Map<String, dynamic>>.from(response);
    final index = all.indexWhere((r) => r['user_id'] == userId);
    if (index < 0) return null;
    return LeaderboardEntry(
      userId: userId,
      name: all[index]['name'] as String,
      nim: all[index]['nim'] as String,
      totalXp: all[index]['total_xp'] as int,
      rank: index + 1,
    );
  }
}
