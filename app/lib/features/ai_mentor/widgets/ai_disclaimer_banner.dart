import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Banner peringatan yang ditampilkan di bawah setiap output AI
/// (hint, feedback, dan kuis yang di-generate AI).
class AiDisclaimerBanner extends StatelessWidget {
  const AiDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KodiraColors.reward100,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        border: Border.all(color: KodiraColors.reward500),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: KodiraColors.reward700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Catatan: Jawaban ini dihasilkan oleh AI dan tidak selalu 100% akurat. '
              'Selalu periksa kembali dengan materi atau dosen.',
              style: KodiraTextStyles.bodySm.copyWith(
                color: KodiraColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
