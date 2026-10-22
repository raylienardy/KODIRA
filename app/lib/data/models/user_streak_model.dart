/// Model data streak harian user (P4-010).
///
/// Sesuai skema tabel `user_streaks`:
/// - `user_id` menjadi primary key, jadi model tidak punya field `id`.
/// - `last_active_date` bertipe DATE (tanpa jam) dan boleh null.
class UserStreakModel {
  /// Id user pemilik streak.
  final String userId;

  /// Jumlah hari belajar beruntun saat ini.
  final int currentStreak;

  /// Rekor streak terpanjang.
  final int longestStreak;

  /// Tanggal terakhir user aktif (tanpa jam).
  final DateTime? lastActiveDate;

  const UserStreakModel({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
  });

  /// Model dari baris tabel `user_streaks`.
  factory UserStreakModel.fromJson(Map<String, dynamic> json) {
    final Object? lastActive = json['last_active_date'];
    return UserStreakModel(
      userId: json['user_id'] as String,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: lastActive == null
          ? null
          : DateTime.parse(lastActive as String),
    );
  }

  /// Salinan dengan sebagian field diganti.
  UserStreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) {
    return UserStreakModel(
      userId: userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
