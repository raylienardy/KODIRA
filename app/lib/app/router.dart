import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'theme.dart';

/// Listenable adapter for GoRouter.
/// Triggers redirect re-evaluation whenever auth state or session status
/// changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        notifyListeners();
      }
    });
    ref.listen<SessionStatus>(sessionStatusProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final sessionStatus = ref.read(sessionStatusProvider);
      final user = ref.read(authStateProvider).user;
      final path = state.matchedLocation;

      // 1) Session masih diperiksa → tahan di splash supaya layar login
      //    tidak berkedip sebelum redirect.
      if (sessionStatus == SessionStatus.loading) {
        return path == '/splash' ? null : '/splash';
      }

      // 2) Login berhasil → ke home (aturan lama, timing tetap).
      if (user != null && path == '/login') return '/home';

      // 3) Session tersimpan valid → lewati login.
      if (sessionStatus == SessionStatus.authenticated && path == '/splash') {
        return '/home';
      }

      // 4) Tidak ada session → ke login.
      if (sessionStatus == SessionStatus.unauthenticated && path != '/login') {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // Terlindungi otomatis oleh aturan 4 di redirect: tanpa session,
      // path ini dipaksa kembali ke /login.
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Placeholder sementara sampai fitur #4a (Ganti Password) di-BUILD.
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPlaceholderScreen(),
      ),
    ],
  );
});

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
