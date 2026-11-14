import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/level_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/achievement_list.dart';
import '../widgets/activity_list.dart';
import '../widgets/badge_grid.dart';
import '../widgets/mastery_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_cards.dart';

/// Layar Profil & Progress (P4-011).
///
/// Menampilkan enam bagian: informasi user, statistik, badge, achievement,
/// mastery per topik, dan lima aktivitas terakhir.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isTeacher = authState.user?.role == 'teacher';

    return Scaffold(
      backgroundColor: KodiraColors.neutral0,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Profil',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: RefreshIndicator(
        color: KodiraColors.primary700,
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: <Widget>[
            ProfileHeader(isTeacher: isTeacher),
            if (!isTeacher) ...[
              const SizedBox(height: 16),
              const StatCards(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Badge'),
              const SizedBox(height: 10),
              const BadgeGrid(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Achievement'),
              const SizedBox(height: 10),
              const AchievementList(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Mastery per Topik'),
              const SizedBox(height: 10),
              const MasterySection(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Aktivitas Terakhir'),
              const SizedBox(height: 10),
              const ActivityList(),
            ] else ...[
              const SizedBox(height: 16),
              const _TeacherInfoCard(),
            ],
          ],
        ),
      ),
    );
  }

  /// Segarkan seluruh data profil lalu tunggu semuanya selesai.
  ///
  /// Kegagalan salah satu provider tidak menghentikan yang lain; pesan error
  /// ringan sudah ditampilkan di section masing-masing.
  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(allProgressProvider);
    ref.invalidate(totalXpProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(badgeCountProvider);
    ref.invalidate(userBadgesProvider);
    ref.invalidate(userAchievementsProvider);
    ref.invalidate(masteryByTopicProvider);
    ref.invalidate(recentActivityProvider);

    try {
      await Future.wait<Object?>(<Future<Object?>>[
        ref.read(allProgressProvider.future),
        ref.read(totalXpProvider.future),
        ref.read(currentStreakProvider.future),
        ref.read(badgeCountProvider.future),
        ref.read(userBadgesProvider.future),
        ref.read(userAchievementsProvider.future),
        ref.read(masteryByTopicProvider.future),
        ref.read(recentActivityProvider.future),
      ]);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Profile refresh failed: $error');
      }
    }
  }
}

class _TeacherInfoCard extends StatelessWidget {
  const _TeacherInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KodiraSpacing.s4),
      decoration: BoxDecoration(
        color: KodiraColors.primary100,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anda Dosen',
            style: KodiraTextStyles.h3.copyWith(color: KodiraColors.primary700),
          ),
          const SizedBox(height: KodiraSpacing.s2),
          Text(
            'Akses menu "Kelas Saya (Dosen)" di drawer untuk melihat daftar '
            'kelas, roster mahasiswa, dan detail progress mereka.',
            style: KodiraTextStyles.body.copyWith(
              color: KodiraColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
      ),
    );
  }
}
