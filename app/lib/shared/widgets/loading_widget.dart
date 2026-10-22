import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Indikator loading standar KODIRA.
///
/// Menampilkan spinner dengan warna primary dan pesan opsional di bawahnya.
class KodiraLoadingWidget extends StatelessWidget {
  final String? message;

  const KodiraLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message ?? 'Memuat data',
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: KodiraColors.primary700,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
