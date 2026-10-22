import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/profile_logic.dart';
import '../../home/providers/level_provider.dart';
import '../providers/profile_provider.dart';

/// Lima aktivitas terakhir dengan status dan tanggal relatif.
class ActivityList extends ConsumerWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);
    final levelsAsync = ref.watch(allLevelsProvider);

    final List<LevelModel> levels = levelsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => <LevelModel>[],
    );
    final Map<int, LevelModel> levelById = <int, LevelModel>{
      for (final LevelModel level in levels) level.id: level,
    };

    return activityAsync.when(
      loading: () => Column(
        children: List<Widget>.generate(
          3,
          (int index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 56,
            decoration: BoxDecoration(
              color: KodiraColors.neutral100,
              borderRadius: BorderRadius.circular(KodiraRadius.md),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => Row(
        children: [
          Expanded(
            child: Text(
              'Gagal memuat aktivitas.',
              style: KodiraTextStyles.bodySm.copyWith(
                color: KodiraColors.alert700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(recentActivityProvider),
            style: TextButton.styleFrom(
              foregroundColor: KodiraColors.primary700,
              minimumSize: const Size(44, 44),
            ),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
      data: (List<UserProgressModel> activities) {
        if (activities.isEmpty) {
          return Text(
            'Belum ada aktivitas. Mulai level pertama di Home.',
            style: KodiraTextStyles.bodySm.copyWith(
              color: KodiraColors.neutral500,
            ),
          );
        }

        return Column(
          children: [
            for (final UserProgressModel item in activities)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActivityTile(
                  item: item,
                  level: levelById[item.levelId],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final UserProgressModel item;
  final LevelModel? level;

  const _ActivityTile({required this.item, this.level});

  @override
  Widget build(BuildContext context) {
    final DateTime? date = item.lastAttemptAt ?? item.completedAt;
    final String statusLabel = ProfileLogic.activityStatusLabel(item.status);
    final String dateLabel = date == null
        ? 'Tanggal tidak tersedia'
        : ProfileLogic.formatRelativeDate(date);
    final String title = level?.title ?? 'Level ${item.levelId}';
    final int levelNumber = level?.levelNumber ?? item.levelId;

    return Semantics(
      label:
          '$title — $statusLabel — '
          '${date == null ? "tanggal tidak tersedia" : ProfileLogic.formatShortDate(date)}',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: KodiraColors.neutral100,
            borderRadius: BorderRadius.circular(KodiraRadius.md),
          ),
          child: Row(
            children: [
              Text(
                _statusIcon(item.status),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Level $levelNumber · $title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateLabel · $statusLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KodiraTextStyles.bodySm.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return '✅';
      case 'active':
        return '🟡';
      case 'remedial':
        return '🔁';
      default:
        return '🔒';
    }
  }
}
