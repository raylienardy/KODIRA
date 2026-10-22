import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/error_type.dart';
import '../../../data/models/user_badge_model.dart';
import '../../../data/repositories/badge_logic.dart';
import '../../../data/repositories/profile_logic.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
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
      loading: () => const KodiraLoadingWidget(message: 'Memuat badge'),
      error: (error, stackTrace) => KodiraErrorWidget(
        error: ErrorType.fromException(error),
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
              const KodiraEmptyWidget(
                icon: Icons.military_tech_outlined,
                title: 'Belum ada badge',
                subtitle:
                    'Selesaikan level atau jaga streak untuk membuka badge.',
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
