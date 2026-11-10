import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/models/teacher_class_entry.dart';
import '../providers/teacher_provider.dart';

/// Dashboard dosen: daftar kelas yang diampu.
///
/// Ketuk sebuah kartu kelas untuk membuka roster mahasiswa.
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(teacherClassesProvider);

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Kelas Saya',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherClassesProvider);
          await ref
              .read(teacherClassesProvider.future)
              .catchError((Object _) => const <TeacherClassEntry>[]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(KodiraSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              classesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(KodiraSpacing.s6),
                    child: CircularProgressIndicator(
                      color: KodiraColors.primary700,
                    ),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(KodiraSpacing.s4),
                    child: Text(
                      'Gagal memuat kelas: $err',
                      textAlign: TextAlign.center,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.alert700,
                      ),
                    ),
                  ),
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(KodiraSpacing.s6),
                      decoration: BoxDecoration(
                        color: KodiraColors.neutral0,
                        borderRadius: BorderRadius.circular(KodiraRadius.md),
                      ),
                      child: Text(
                        'Belum ada kelas. Buat kelas baru dulu via menu Buat Kelas.',
                        textAlign: TextAlign.center,
                        style: KodiraTextStyles.body.copyWith(
                          color: KodiraColors.neutral500,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: classes
                        .map((cls) => _ClassCard(cls: cls))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu satu kelas yang diampu. Ketuk → roster mahasiswa.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});

  final TeacherClassEntry cls;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: KodiraSpacing.s3),
      padding: const EdgeInsets.all(KodiraSpacing.s4),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        boxShadow: KodiraShadows.elevation1,
      ),
      child: InkWell(
        onTap: () => context.go('/teacher-roster/${cls.id}'),
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        child: Row(
          children: [
            const Icon(
              Icons.class_outlined,
              color: KodiraColors.primary700,
              size: 28,
            ),
            const SizedBox(width: KodiraSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KodiraTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: KodiraColors.neutral900,
                    ),
                  ),
                  Text(
                    'Kode: ${cls.code}',
                    style: KodiraTextStyles.caption.copyWith(
                      color: KodiraColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: KodiraColors.neutral500),
          ],
        ),
      ),
    );
  }
}
