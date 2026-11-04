import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Layar sementara untuk route `/change-password`.
///
/// Menampilkan SnackBar "Segera hadir" saat pertama kali dibuka. Akan diganti
/// oleh `ChangePasswordScreen` pada BUILD #4a.
class ChangePasswordPlaceholderScreen extends StatefulWidget {
  const ChangePasswordPlaceholderScreen({super.key});

  @override
  State<ChangePasswordPlaceholderScreen> createState() =>
      _ChangePasswordPlaceholderScreenState();
}

class _ChangePasswordPlaceholderScreenState
    extends State<ChangePasswordPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Segera hadir')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KodiraColors.neutral0,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Ganti Password',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: KodiraColors.neutral300,
              ),
              const SizedBox(height: 12),
              Text(
                'Fitur Ganti Password akan segera hadir.',
                textAlign: TextAlign.center,
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
