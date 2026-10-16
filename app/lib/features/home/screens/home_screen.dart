import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('KODIRA'),
        backgroundColor: KodiraColors.primary700,
      ),
      backgroundColor: KodiraColors.primary700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selamat datang',
              style: KodiraTextStyles.h1.copyWith(color: Colors.white),
            ),
            Text(
              user?.name ?? 'Mahasiswa',
              style: KodiraTextStyles.bodyLg.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
