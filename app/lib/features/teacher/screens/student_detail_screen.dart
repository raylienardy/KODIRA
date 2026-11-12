import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/student_detail.dart';
import '../../home/providers/level_provider.dart';
import '../providers/teacher_provider.dart';

/// Detail progress mahasiswa untuk dosen.
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({
    super.key,
    required this.classId,
    required this.studentId,
  });

  final String classId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      studentDetailProvider(
        StudentDetailParams(classId: classId, studentId: studentId),
      ),
    );
    final levelsAsync = ref.watch(allLevelsProvider);

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Detail Mahasiswa',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: KodiraColors.primary700),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(KodiraSpacing.s4),
            child: Text(
              'Gagal memuat detail: $err',
              textAlign: TextAlign.center,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.alert700,
              ),
            ),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Data mahasiswa tidak ditemukan'));
          }

          final levels = levelsAsync.value ?? [];
          final Map<int, LevelModel> levelMap = {
            for (final l in levels) l.id: l,
          };

          // Group by topic
          final Map<String, List<double>> masteryByTopic = {};
          for (final entry in detail.masteryByLevel.entries) {
            final int? levelId = int.tryParse(entry.key);
            if (levelId == null) continue;
            final LevelModel? level = levelMap[levelId];
            final String topic = level?.topic?.trim().isNotEmpty == true
                ? level!.topic!.trim()
                : 'Umum';
            masteryByTopic.putIfAbsent(topic, () => []).add(entry.value);
          }

          final List<MapEntry<String, double>> topicMastery =
              masteryByTopic.entries.map((e) {
                final avg = e.value.reduce((a, b) => a + b) / e.value.length;
                return MapEntry(e.key, avg);
              }).toList()..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(KodiraSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(detail: detail),
                const SizedBox(height: KodiraSpacing.s4),
                Text(
                  'Mastery per Topik',
                  style: KodiraTextStyles.h3.copyWith(
                    color: KodiraColors.neutral900,
                  ),
                ),
                const SizedBox(height: KodiraSpacing.s2),
                if (detail.masteryByLevel.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(KodiraSpacing.s4),
                    decoration: BoxDecoration(
                      color: KodiraColors.neutral0,
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                    ),
                    child: Text(
                      'Belum ada progress tersimpan untuk mahasiswa ini',
                      textAlign: TextAlign.center,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  )
                else
                  ...topicMastery.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: KodiraSpacing.s3),
                      child: Container(
                        padding: const EdgeInsets.all(KodiraSpacing.s4),
                        decoration: BoxDecoration(
                          color: KodiraColors.neutral0,
                          borderRadius: BorderRadius.circular(KodiraRadius.md),
                          boxShadow: KodiraShadows.elevation1,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: KodiraTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: KodiraColors.neutral900,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(entry.value * 100).toStringAsFixed(0)}%',
                                  style: KodiraTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: KodiraColors.primary700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: KodiraSpacing.s2),
                            LinearProgressIndicator(
                              value: entry.value.clamp(0.0, 1.0),
                              color: KodiraColors.primary700,
                              backgroundColor: KodiraColors.neutral200,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.detail});

  final StudentDetail detail;

  @override
  Widget build(BuildContext context) {
    final String initial = detail.name.trim().isEmpty
        ? '?'
        : detail.name.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(KodiraSpacing.s4),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        boxShadow: KodiraShadows.elevation1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: KodiraColors.primary100,
                child: Text(
                  initial,
                  style: KodiraTextStyles.h3.copyWith(
                    color: KodiraColors.primary700,
                  ),
                ),
              ),
              const SizedBox(width: KodiraSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: KodiraTextStyles.h3.copyWith(
                        color: KodiraColors.neutral900,
                      ),
                    ),
                    Text(
                      'NIM: ${detail.nim}',
                      style: KodiraTextStyles.caption.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KodiraSpacing.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: 'XP',
                value: '${detail.totalXp}',
                color: KodiraColors.primary700,
              ),
              _StatColumn(
                label: 'Level Selesai',
                value: '${detail.levelsCompleted}',
                color: KodiraColors.neutral900,
              ),
              _StatColumn(
                label: 'Avg Mastery',
                value: '${(detail.avgMastery * 100).toStringAsFixed(0)}%',
                color: KodiraColors.success500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: KodiraTextStyles.h3.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: KodiraTextStyles.caption.copyWith(
            color: KodiraColors.neutral500,
          ),
        ),
      ],
    );
  }
}
