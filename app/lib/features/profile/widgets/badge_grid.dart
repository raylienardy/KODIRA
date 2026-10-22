import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/user_badge_model.dart';
import '../../../data/repositories/badge_logic.dart';
import '../../../data/repositories/profile_logic.dart';
import '../providers/profile_provider.dart';

/// Grid badge: seluruh katalog ditampilkan, yang belum diraih terkunci.
///
/// Jumlah kolom mengikuti lebar layar supaya tidak overflow di perangkat
/// kecil: 3 kolom untuk lebar 360dp ke atas, 2 kolom di bawahnya.
class BadgeGrid extends ConsumerWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);

    return badgesAsync.when(
      loading: () => const _BadgeSkeleton(),
      error: (error, stackTrace) => _ErrorNote(
        message: 'Gagal memuat badge.',
        onRetry: () => ref.invalidate(userBadgesProvider),
      ),
      data: (List<UserBadgeModel> badges) {
        final Map<String, UserBadgeModel> earned = <String, UserBadgeModel>{
          for (final UserBadgeModel badge in badges) badge.badgeCode: badge,
        };

        final double width = MediaQuery.sizeOf(context).width;
        final int crossAxisCount = width >= 360 ? 3 : 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (earned.isEmpty) ...[
              Text(
                'Belum ada badge. Selesaikan level atau jaga streak untuk '
                'membuka badge.',
                style: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
              const SizedBox(height: 12),
            ],
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: BadgeCatalog.all.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 104,
              ),
              itemBuilder: (context, index) {
                final String code = BadgeCatalog.all[index];
                return _BadgeTile(code: code, earnedAt: earned[code]?.earnedAt);
              },
            ),
          ],
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String code;
  final DateTime? earnedAt;

  const _BadgeTile({required this.code, this.earnedAt});

  @override
  Widget build(BuildContext context) {
    final bool isEarned = earnedAt != null;
    final String name = ProfileLogic.badgeDisplayName(code);
    final String earnedLabel = earnedAt == null
        ? 'belum diraih'
        : 'sudah diraih pada ${ProfileLogic.formatShortDate(earnedAt!)}';

    return Semantics(
      label: 'Badge $name — $earnedLabel',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isEarned ? KodiraColors.primary100 : KodiraColors.neutral100,
            borderRadius: BorderRadius.circular(KodiraRadius.md),
            border: Border.all(
              color: isEarned
                  ? KodiraColors.primary500
                  : KodiraColors.neutral200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEarned ? '🎖️' : '🔒',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: KodiraTextStyles.caption.copyWith(
                  color: isEarned
                      ? KodiraColors.primary900
                      : KodiraColors.neutral500,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEarned ? 'Diraih' : 'Belum',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: KodiraTextStyles.caption.copyWith(
                  color: isEarned
                      ? KodiraColors.success700
                      : KodiraColors.neutral300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeSkeleton extends StatelessWidget {
  const _BadgeSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 104,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: KodiraColors.neutral100,
          borderRadius: BorderRadius.circular(KodiraRadius.md),
        ),
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorNote({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: KodiraTextStyles.bodySm.copyWith(
              color: KodiraColors.alert700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            foregroundColor: KodiraColors.primary700,
            minimumSize: const Size(44, 44),
          ),
          child: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
