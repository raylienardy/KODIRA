import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
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
    return Scaffold(
      backgroundColor: KodiraColors.neutral0,
      appBar: AppBar(
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
          children: const <Widget>[
            ProfileHeader(),
            SizedBox(height: 16),
            StatCards(),
            SizedBox(height: 24),
            _SectionHeader(title: 'Badge'),
            SizedBox(height: 10),
            BadgeGrid(),
            SizedBox(height: 24),
            _SectionHeader(title: 'Achievement'),
            SizedBox(height: 10),
            AchievementList(),
            SizedBox(height: 24),
            _SectionHeader(title: 'Mastery per Topik'),
            SizedBox(height: 10),
            MasterySection(),
            SizedBox(height: 24),
            _SectionHeader(title: 'Aktivitas Terakhir'),
            SizedBox(height: 10),
            ActivityList(),
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
