import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';

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
    ],
  );
});
