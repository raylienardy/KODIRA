import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.freezed.dart';
part 'user_progress_model.g.dart';

@freezed
class UserProgressModel with _$UserProgressModel {
  const UserProgressModel._();

  const factory UserProgressModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'level_id') required int levelId,
    required String status, // locked/active/completed/remedial
    required double masteryScore,
    required int xpEarned,
    required int attempts,
    int? remedialLevelId,
    DateTime? lastAttemptAt,
    DateTime? completedAt,
  }) = _UserProgressModel;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);

  factory UserProgressModel.fromSupabase(Map<String, dynamic> map) {
    return UserProgressModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      levelId: map['level_id'] as int,
      status: map['status'] as String,
      masteryScore: (map['mastery_score'] as num).toDouble(),
      xpEarned: map['xp_earned'] as int,
      attempts: map['attempts'] as int,
      remedialLevelId: map['remedial_level_id'] as int?,
      lastAttemptAt: map['last_attempt_at'] != null
          ? DateTime.parse(map['last_attempt_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  // Getters
  bool get isCompleted => status == 'completed' || completedAt != null;
  bool get isLocked => status == 'locked';
  bool get isActive => status == 'active';
}
