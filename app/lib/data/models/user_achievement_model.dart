/// Model data achievement milik user (P4-010).
///
/// Sesuai skema tabel `user_achievements`:
/// - `id` menjadi primary key (UUID).
/// - `achievement_code` adalah kode achievement bebas (tanpa tabel katalog).
/// - `earned_at` bertipe TIMESTAMPTZ dan boleh null.
class UserAchievementModel {
  /// Id baris achievement.
  final String id;

  /// Id user pemilik achievement.
  final String userId;

  /// Kode achievement, contoh `first_login`.
  final String achievementCode;

  /// Waktu achievement diberikan.
  final DateTime? earnedAt;

  const UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementCode,
    this.earnedAt,
  });

  /// Model dari baris tabel `user_achievements`.
  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementCode: json['achievement_code'] as String,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'] as String)
          : null,
    );
  }

  /// Salinan dengan sebagian field diganti.
  UserAchievementModel copyWith({String? achievementCode, DateTime? earnedAt}) {
    return UserAchievementModel(
      id: id,
      userId: userId,
      achievementCode: achievementCode ?? this.achievementCode,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}
