import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';

/// Listenable adapter for GoRouter.
/// Triggers redirect re‑evaluation whenever authStateProvider changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        notifyListeners();
      }
    });
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(authStateProvider).user;
      final loggingIn = state.matchedLocation == '/login';

      if (user == null && !loggingIn) return '/login';
      if (user != null && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
