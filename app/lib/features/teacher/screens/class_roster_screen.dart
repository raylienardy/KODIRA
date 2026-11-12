import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/models/class_roster_entry.dart';
import '../providers/teacher_provider.dart';

/// Roster mahasiswa pada satu kelas yang diampu dosen.
///
/// Data diambil dari view `leaderboard_by_class`, jadi mahasiswa tanpa
/// progress tetap muncul dengan XP 0.
class ClassRosterScreen extends ConsumerStatefulWidget {
  const ClassRosterScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<ClassRosterScreen> createState() => _ClassRosterScreenState();
}

class _ClassRosterScreenState extends ConsumerState<ClassRosterScreen> {
  @override
  Widget build(BuildContext context) {
    final rosterAsync = ref.watch(classRosterProvider(widget.classId));

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Daftar Mahasiswa',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: rosterAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(KodiraSpacing.s6),
            child: CircularProgressIndicator(color: KodiraColors.primary700),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(KodiraSpacing.s4),
            child: Text(
              'Gagal memuat roster: $err',
              textAlign: TextAlign.center,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.alert700,
              ),
            ),
          ),
        ),
        data: (roster) {
          if (roster.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(KodiraSpacing.s4),
              padding: const EdgeInsets.all(KodiraSpacing.s6),
              decoration: BoxDecoration(
                color: KodiraColors.neutral0,
                borderRadius: BorderRadius.circular(KodiraRadius.md),
              ),
              child: Text(
                'Belum ada mahasiswa di kelas ini',
                textAlign: TextAlign.center,
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(KodiraSpacing.s4),
            itemCount: roster.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: KodiraSpacing.s2),
            itemBuilder: (context, index) {
              final ClassRosterEntry r = roster[index];
              final String initial = r.name.trim().isEmpty
                  ? '?'
                  : r.name.trim().substring(0, 1).toUpperCase();

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go(
                    '/teacher-roster/${widget.classId}/student/${r.userId}',
                  ),
                  borderRadius: BorderRadius.circular(KodiraRadius.md),
                  child: Container(
                    padding: const EdgeInsets.all(KodiraSpacing.s3),
                    decoration: BoxDecoration(
                      color: KodiraColors.neutral0,
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                      boxShadow: KodiraShadows.elevation1,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: KodiraColors.primary100,
                          child: Text(
                            initial,
                            style: KodiraTextStyles.body.copyWith(
                              color: KodiraColors.primary700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: KodiraSpacing.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: KodiraTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: KodiraColors.neutral900,
                                ),
                              ),
                              Text(
                                'NIM: ${r.nim}',
                                style: KodiraTextStyles.caption.copyWith(
                                  color: KodiraColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${r.totalXp}',
                              style: KodiraTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: KodiraColors.primary700,
                              ),
                            ),
                            Text(
                              'XP',
                              style: KodiraTextStyles.caption.copyWith(
                                color: KodiraColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
