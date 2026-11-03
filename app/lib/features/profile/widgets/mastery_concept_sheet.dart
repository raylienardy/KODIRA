import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Bottom sheet penjelasan konsep mastery dan tips perbaikan.
///
/// Sheet ini sengaja tidak menampilkan angka breakdown karena data komponen
/// hanya tersedia saat submit kuis, bukan dari riwayat yang tersimpan.
class MasteryConceptSheet extends StatelessWidget {
  const MasteryConceptSheet({super.key});

  static const List<String> _tips = <String>[
    'Kerjakan ulang kuis level ini untuk penguatan.',
    'Perhatikan feedback AI Mentor saat salah.',
    'Ulang materi jika mastery di bawah 40%.',
  ];

  @override
  Widget build(BuildContext context) {
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
              'Apa itu Mastery?',
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mastery adalah nilai penguasaan level yang dihitung dari '
              'akurasi jawaban, konsistensi hasil sebelumnya, dan kecepatan '
              'mengerjakan soal. Nilai ini membantu kamu melihat seberapa '
              'kuat pemahamanmu, bukan hanya jumlah soal yang benar.',
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tips meningkatkan mastery',
              style: KodiraTextStyles.h3.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            for (final String tip in _tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: KodiraColors.primary700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: KodiraTextStyles.body.copyWith(
                          color: KodiraColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
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
