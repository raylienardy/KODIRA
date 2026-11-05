import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Bar mastery 0.0–1.0 dengan label persentase.
class MasteryBar extends StatelessWidget {
  final double mastery;
  final Color color;

  const MasteryBar({super.key, required this.mastery, required this.color});

  @override
  Widget build(BuildContext context) {
    final double clamped = mastery.clamp(0.0, 1.0);
    final int percent = (clamped * 100).round();

    return Semantics(
      label: 'Mastery $percent persen',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mastery',
                  style: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (clamped >= 0.95) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: KodiraColors.success500,
                          borderRadius: BorderRadius.circular(KodiraRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Mastered',
                              style: KodiraTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(KodiraRadius.sm),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 8,
                backgroundColor: KodiraColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
