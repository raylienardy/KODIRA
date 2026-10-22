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
                Text(
                  '$percent%',
                  style: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
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
