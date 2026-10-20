import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kodira/features/lesson/screens/material_screen.dart';

import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/level_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/user_progress_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final allLevels = ref.watch(allLevelsProvider);
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: KodiraColors.neutral0,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderWidget(user: user),
            Expanded(
              child: allLevels.when(
                data: (levels) => userProgress.when(
                  data: (progressList) => _buildMap(levels, progressList, ref),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      _errorState(e, () => ref.refresh(allLevelsProvider)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    _errorState(e, () => ref.refresh(allLevelsProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(Object e, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Terjadi kesalahan: $e'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: retry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildMap(
    List<LevelModel> levels,
    List<UserProgressModel> progresses,
    WidgetRef ref,
  ) {
    if (levels.isEmpty) {
      return const Center(child: Text('Belum ada level'));
    }
    // map progress by levelId for quick lookup
    final progressMap = {for (var p in progresses) p.levelId: p};
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final progress = progressMap[level.id];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LevelCard(level: level, progress: progress),
        );
      },
    );
  }
}

// -------------------------------------------------------------------
// Header widget
class _HeaderWidget extends ConsumerWidget {
  final UserModel? user;
  const _HeaderWidget({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // compute current level and xp aggregation
    final List<UserProgressModel> progressList = ref
        .watch(userProgressProvider)
        .maybeWhen(data: (v) => v, orElse: () => <UserProgressModel>[]);
    var currentLevel = 1;
    var totalXp = 0;
    var completedCount = 0;
    for (var p in progressList) {
      totalXp += p.xpEarned;
      if (p.isCompleted) completedCount++;
      if (p.isActive) currentLevel = p.levelId;
    }
    // placeholder target xp
    final int targetXp = currentLevel * 100;
    const topic = '';
    // find current topic from level model if needed (omitted for brevity)

    return Container(
      color: KodiraColors.neutral0,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hai, ${user?.name ?? "Mahasiswa"}',
                    style: KodiraTextStyles.h2.copyWith(
                      color: KodiraColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level $currentLevel — $topic',
                    style: KodiraTextStyles.bodySm.copyWith(
                      color: KodiraColors.neutral500,
                    ),
                  ),
                ],
              ),
              // Avatar + menu akun
              PopupMenuButton<String>(
                tooltip: 'Menu akun',
                position: PopupMenuPosition.under,
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _confirmLogout(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout,
                          size: 20,
                          color: KodiraColors.alert700,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: KodiraTextStyles.body.copyWith(
                            color: KodiraColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            KodiraColors.primary700,
                            KodiraColors.success500,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (user?.name ?? 'M').substring(0, 1).toUpperCase(),
                        style: KodiraTextStyles.bodyLg.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stat chips row
          Wrap(
            spacing: 8,
            children: [
              // ignore: prefer_const_constructors
              _StatChip(icon: '⚡', value: totalXp.toString(), label: 'XP'),
              const _StatChip(icon: '🔥', value: '0', label: 'Streak'),
              _StatChip(
                icon: '🏆',
                value: completedCount.toString(),
                label: 'Level',
              ),
            ],
          ),
          const SizedBox(height: 14),
          // XP progress bar container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: KodiraColors.neutral100,
              borderRadius: BorderRadius.circular(KodiraRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $currentLevel',
                  style: KodiraTextStyles.bodySm.copyWith(
                    color: KodiraColors.neutral900,
                  ),
                ),
                Text(
                  '$totalXp / $targetXp XP',
                  style: KodiraTextStyles.bodySm.copyWith(
                    color: KodiraColors.neutral900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: targetXp == 0 ? 0 : totalXp / targetXp,
            minHeight: 6,
            backgroundColor: KodiraColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              KodiraColors.reward500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: KodiraColors.alert700),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(authStateProvider.notifier).logout();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal logout. Coba lagi.')));
    }
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: KodiraColors.neutral100,
        borderRadius: BorderRadius.circular(KodiraRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: KodiraTextStyles.bodySm.copyWith(
              color: KodiraColors.neutral900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: KodiraTextStyles.bodySm.copyWith(
              color: KodiraColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// Level card widget
class _LevelCard extends StatelessWidget {
  final LevelModel level;
  final UserProgressModel? progress;

  const _LevelCard({required this.level, this.progress});

  @override
  Widget build(BuildContext context) {
    final isLocked = progress == null || progress?.status == 'locked';
    final isCompleted = progress?.isCompleted ?? false;
    final isActive = progress?.isActive ?? false;
    Color badgeBg;
    Color badgeText;
    String subtitle;
    Widget? trailing;

    if (isLocked) {
      badgeBg = KodiraColors.neutral200;
      badgeText = KodiraColors.neutral300;
      subtitle = 'Terkunci';
    } else if (isCompleted) {
      badgeBg = KodiraColors.success500;
      badgeText = Colors.white;
      subtitle = 'Selesai • ${progress!.xpEarned} XP';
      trailing = const Icon(Icons.check, color: KodiraColors.success500);
    } else if (isActive) {
      badgeBg = KodiraColors.primary700;
      badgeText = Colors.white;
      subtitle = 'Sedang dipelajari';
    } else {
      // default fallback locked style
      badgeBg = KodiraColors.neutral200;
      badgeText = KodiraColors.neutral300;
      subtitle = 'Terkunci';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                MaterialScreen(levelId: level.id, levelTitle: level.title),
          ),
        );
      },
      child: Opacity(
        opacity: isLocked ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: KodiraColors.neutral0,
            borderRadius: BorderRadius.circular(KodiraRadius.lg),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: KodiraColors.primary700.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
            border: isActive
                ? Border.all(color: KodiraColors.primary700, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Badge
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  level.levelNumber.toString(),
                  style: KodiraTextStyles.bodyLg.copyWith(color: badgeText),
                ),
              ),
              const SizedBox(width: 12),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: KodiraTextStyles.h3.copyWith(
                        color: isLocked
                            ? KodiraColors.neutral500
                            : KodiraColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: KodiraTextStyles.bodySm.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
