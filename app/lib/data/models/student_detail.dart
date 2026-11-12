class StudentDetail {
  final String classId;
  final String studentId;
  final String name;
  final String nim;
  final int totalXp;
  final int levelsCompleted;
  final double avgMastery;

  /// Map of levelIdString to masteryScore (0..1)
  final Map<String, double> masteryByLevel;

  const StudentDetail({
    required this.classId,
    required this.studentId,
    required this.name,
    required this.nim,
    required this.totalXp,
    required this.levelsCompleted,
    required this.avgMastery,
    required this.masteryByLevel,
  });
}
