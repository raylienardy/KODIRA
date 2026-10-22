import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/user_achievement_model.dart';
import '../../../data/repositories/badge_logic.dart';
import '../../../data/repositories/profile_logic.dart';
import '../providers/profile_provider.dart';

/// Daftar achievement: yang sudah diraih bisa diketuk untuk melihat tanggal.
class AchievementList extends ConsumerWidget {
  const AchievementList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider);

    return achievementsAsync.when(
      loading: () => Column(
        children: List<Widget>.generate(
          3,
          (int index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 60,
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
              'Gagal memuat achievement.',
              style: KodiraTextStyles.bodySm.copyWith(
                color: KodiraColors.alert700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(userAchievementsProvider),
            style: TextButton.styleFrom(
              foregroundColor: KodiraColors.primary700,
              minimumSize: const Size(44, 44),
            ),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
      data: (List<UserAchievementModel> achievements) {
        final Map<String, UserAchievementModel> earned =
            <String, UserAchievementModel>{
              for (final UserAchievementModel item in achievements)
                item.achievementCode: item,
            };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (earned.isEmpty) ...[
              Text(
                'Belum ada achievement. Login & lulus kuis pertama untuk '
                'memulai.',
                style: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
              const SizedBox(height: 12),
            ],
            for (final String code in AchievementCatalog.all)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AchievementTile(
                  code: code,
                  earnedAt: earned[code]?.earnedAt,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String code;
  final DateTime? earnedAt;

  const _AchievementTile({required this.code, this.earnedAt});

  @override
  Widget build(BuildContext context) {
    final bool isEarned = earnedAt != null;
    final String name = ProfileLogic.achievementDisplayName(code);
    final DateTime? date = earnedAt;
    final String earnedLabel = date == null
        ? 'belum diraih'
        : 'sudah diraih pada ${ProfileLogic.formatShortDate(date)}';
    final String subtitle = date == null
        ? 'Belum diraih'
        : 'Diraih ${ProfileLogic.formatShortDate(date)}';

    return Semantics(
      button: isEarned,
      label: 'Achievement $name — $earnedLabel',
      onTap: isEarned ? () => _showDetail(context, name, date) : null,
      child: ExcludeSemantics(
        child: Material(
          color: isEarned ? KodiraColors.success100 : KodiraColors.neutral100,
          borderRadius: BorderRadius.circular(KodiraRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(KodiraRadius.md),
            onTap: isEarned ? () => _showDetail(context, name, date) : null,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    isEarned ? '🏅' : '🔒',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KodiraTextStyles.body.copyWith(
                            color: isEarned
                                ? KodiraColors.neutral900
                                : KodiraColors.neutral500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KodiraTextStyles.bodySm.copyWith(
                            color: isEarned
                                ? KodiraColors.success700
                                : KodiraColors.neutral300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEarned)
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: KodiraColors.neutral300,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, String name, DateTime? date) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name),
        content: Text(
          date == null
              ? 'Tanggal tidak tersedia.'
              : 'Diraih pada ${ProfileLogic.formatShortDate(date)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: KodiraColors.primary700,
              minimumSize: const Size(44, 44),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
