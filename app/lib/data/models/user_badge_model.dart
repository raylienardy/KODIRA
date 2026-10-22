/// Model data badge milik user (P4-010).
///
/// Sesuai skema tabel `user_badges`:
/// - `id` menjadi primary key (UUID).
/// - `badge_code` adalah kode badge bebas (tanpa tabel katalog).
/// - `earned_at` bertipe TIMESTAMPTZ dan boleh null.
class UserBadgeModel {
  /// Id baris badge.
  final String id;

  /// Id user pemilik badge.
  final String userId;

  /// Kode badge, contoh `streak_3`.
  final String badgeCode;

  /// Waktu badge diberikan.
  final DateTime? earnedAt;

  const UserBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeCode,
    this.earnedAt,
  });

  /// Model dari baris tabel `user_badges`.
  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeCode: json['badge_code'] as String,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'] as String)
          : null,
    );
  }

  /// Salinan dengan sebagian field diganti.
  UserBadgeModel copyWith({String? badgeCode, DateTime? earnedAt}) {
    return UserBadgeModel(
      id: id,
      userId: userId,
      badgeCode: badgeCode ?? this.badgeCode,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}
