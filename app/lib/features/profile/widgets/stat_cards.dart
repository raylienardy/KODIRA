import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/profile_logic.dart';
import '../../home/providers/level_provider.dart';

/// Tiga kartu ringkasan: total XP, level aktif, dan streak.
class StatCards extends ConsumerWidget {
  const StatCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXpAsync = ref.watch(totalXpProvider);
    final progressAsync = ref.watch(allProgressProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    final int totalXp = totalXpAsync.maybeWhen(
      data: (value) => value,
      orElse: () => 0,
    );
    final List<UserProgressModel> progress = progressAsync.maybeWhen(
      data: (value) => value,
      orElse: () => <UserProgressModel>[],
    );
    final int activeLevel = ProfileLogic.computeActiveLevel(
      progress
          .map(
            (UserProgressModel item) => <String, dynamic>{
              'levelId': item.levelId,
              'status': item.status,
            },
          )
          .toList(),
    );
    final int streak =
        streakAsync.maybeWhen(
          data: (value) => value?.currentStreak,
          orElse: () => 0,
        ) ??
        0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '⚡',
            value: totalXpAsync.isLoading ? '…' : '$totalXp',
            label: 'Total XP',
            semanticsLabel: 'Total XP: $totalXp',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: '📚',
            value: progressAsync.isLoading ? '…' : '$activeLevel',
            label: 'Level Aktif',
            semanticsLabel: 'Level aktif: $activeLevel',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: '🔥',
            value: streakAsync.isLoading ? '…' : '$streak',
            label: 'Streak',
            semanticsLabel: 'Streak: $streak hari',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final String semanticsLabel;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 88, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: KodiraColors.neutral100,
            borderRadius: BorderRadius.circular(KodiraRadius.md),
            border: Border.all(color: KodiraColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: KodiraTextStyles.h3.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: KodiraTextStyles.caption.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
