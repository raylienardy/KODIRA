import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/error_type.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/profile_provider.dart';

/// Rata-rata mastery per topik dengan progress bar.
class MasterySection extends ConsumerWidget {
  const MasterySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAsync = ref.watch(masteryByTopicProvider);

    return masteryAsync.when(
      loading: () => const KodiraLoadingWidget(message: 'Memuat mastery'),
      error: (error, stackTrace) => KodiraErrorWidget(
        error: ErrorType.fromException(error),
        onRetry: () => ref.invalidate(masteryByTopicProvider),
      ),
      data: (Map<String, double> mastery) {
        if (mastery.isEmpty) {
          return const KodiraEmptyWidget(
            icon: Icons.insights_outlined,
            title: 'Belum ada data mastery',
            subtitle: 'Selesaikan kuis untuk mengisi.',
          );
        }

        final List<MapEntry<String, double>> entries = mastery.entries.toList()
          ..sort(
            (MapEntry<String, double> a, MapEntry<String, double> b) =>
                b.value.compareTo(a.value),
          );

        return Column(
          children: [
            for (final MapEntry<String, double> entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MasteryRow(topic: entry.key, value: entry.value),
              ),
          ],
        );
      },
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final String topic;
  final double value;

  const _MasteryRow({required this.topic, required this.value});

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);
    final int percent = (clamped * 100).round();

    return Semantics(
      label: '$topic: $percent% mastery',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percent%',
                  style: KodiraTextStyles.bodySm.copyWith(
                    color: KodiraColors.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(KodiraRadius.full),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 8,
                backgroundColor: KodiraColors.neutral200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  KodiraColors.primary700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
