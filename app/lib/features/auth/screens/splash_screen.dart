import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Layar loading singkat saat app memeriksa session tersimpan.
///
/// Ditampilkan oleh redirect router selama status session masih `loading`,
/// supaya layar login tidak berkedip sebelum redirect ke home.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KodiraColors.primary700, KodiraColors.primary500],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: KodiraColors.neutral0,
                borderRadius: BorderRadius.circular(KodiraRadius.xl2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'K',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: KodiraColors.primary700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KODIRA',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Memuat profil...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: KodiraColors.neutral0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
