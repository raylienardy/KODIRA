import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../adaptive/models/mastery_breakdown.dart';

/// Bottom sheet rincian komponen mastery untuk satu percobaan kuis.
///
/// Data berasal dari [MasteryBreakdown] yang dihitung saat submit dan hanya
/// hidup di memori; sheet ini tidak membaca database.
class MasteryBreakdownSheet extends StatelessWidget {
  final MasteryBreakdown breakdown;

  const MasteryBreakdownSheet({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final int accuracyPercent = (breakdown.accuracy * 100).round();
    final int consistencyPercent = (breakdown.consistency * 100).round();
    final int speedPercent = ((1.0 - breakdown.timeNorm) * 100).round();
    final int totalPercent = (breakdown.total * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: KodiraColors.neutral200,
                  borderRadius: BorderRadius.circular(KodiraRadius.full),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Breakdown Mastery',
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rincian komponen nilai mastery pada percobaan ini.',
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral500,
              ),
            ),
            const SizedBox(height: 20),
            _BreakdownRow(
              label: 'Akurasi (A) — bobot 65%',
              semanticsLabel: 'Akurasi $accuracyPercent persen',
              percent: accuracyPercent,
              value: breakdown.accuracy,
              color: KodiraColors.primary700,
            ),
            _BreakdownRow(
              label: 'Konsistensi (C) — bobot 25%',
              semanticsLabel: 'Konsistensi $consistencyPercent persen',
              percent: consistencyPercent,
              value: breakdown.consistency,
              color: KodiraColors.success500,
            ),
            _BreakdownRow(
              label: 'Kecepatan (1 − Tn) — bobot 10%',
              semanticsLabel: 'Kecepatan $speedPercent persen',
              percent: speedPercent,
              value: 1.0 - breakdown.timeNorm,
              color: KodiraColors.reward500,
            ),
            const SizedBox(height: 4),
            Text(
              'E = 1 − A, kontribusinya sudah termasuk dalam Akurasi.',
              style: KodiraTextStyles.bodySm.copyWith(
                color: KodiraColors.neutral500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: KodiraColors.primary100,
                borderRadius: BorderRadius.circular(KodiraRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formula',
                    style: KodiraTextStyles.caption.copyWith(
                      color: KodiraColors.primary700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'M = 0.65·A + 0.25·C + 0.10·(1 − Tn)',
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Total mastery $totalPercent persen',
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Mastery',
                      style: KodiraTextStyles.h3.copyWith(
                        color: KodiraColors.neutral900,
                      ),
                    ),
                    Text(
                      '$totalPercent%',
                      style: KodiraTextStyles.h2.copyWith(
                        color: KodiraColors.primary700,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: KodiraColors.neutral700,
                ),
                child: Text(
                  'Tutup',
                  style: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final int percent;
  final double value;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.semanticsLabel,
    required this.percent,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
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
                      fontWeight: FontWeight.w700,
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
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
