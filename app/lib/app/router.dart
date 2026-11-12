import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/class/screens/create_class_screen.dart';
import '../features/class/screens/join_class_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/about_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';
import '../features/teacher/screens/class_roster_screen.dart';
import '../features/teacher/screens/student_detail_screen.dart';
import '../features/teacher/screens/teacher_dashboard_screen.dart';

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

      // 2) Login atau register berhasil → ke home (aturan lama, timing tetap).
      if (user != null && (path == '/login' || path == '/register')) {
        return '/home';
      }

      // 3) Session tersimpan valid → lewati login.
      if (sessionStatus == SessionStatus.authenticated && path == '/splash') {
        return '/home';
      }

      // 4) Tidak ada session → ke login. Register tetap boleh diakses
      //    supaya user baru bisa mendaftar tanpa session.
      if (sessionStatus == SessionStatus.unauthenticated &&
          path != '/login' &&
          path != '/register') {
        return '/login';
      }

      // 5) Buat Kelas hanya untuk dosen.
      if (path == '/create-class' && (user == null || user.role != 'teacher')) {
        return '/home';
      }

      // 6) Teacher Dashboard + roster hanya untuk dosen.
      if ((path == '/teacher-dashboard' ||
              path.startsWith('/teacher-roster/')) &&
          (user == null || user.role != 'teacher')) {
        return '/home';
      }

      // 7) Dosen login ke /home → langsung ke Teacher Dashboard.
      // Dosen tidak seharusnya melihat home screen mahasiswa (XP/level/streak).
      if (user != null && user.role == 'teacher' && path == '/home') {
        return '/teacher-dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // Terlindungi otomatis oleh aturan 4 di redirect: tanpa session,
      // path ini dipaksa kembali ke /login.
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Route ganti password.
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // Route tentang aplikasi.
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      // Route ganti kelas (join via kode + pilih kelas primary).
      GoRoute(
        path: '/join-class',
        builder: (context, state) => const JoinClassScreen(),
      ),
      // Route buat kelas (khusus dosen).
      GoRoute(
        path: '/create-class',
        builder: (context, state) => const CreateClassScreen(),
      ),
      // Route leaderboard.
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      // Route dashboard dosen (daftar kelas yang diampu).
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      // Route roster mahasiswa per kelas.
      GoRoute(
        path: '/teacher-roster/:classId',
        builder: (context, state) =>
            ClassRosterScreen(classId: state.pathParameters['classId']!),
      ),
      // Route detail satu mahasiswa (drill-down dari roster).
      GoRoute(
        path: '/teacher-roster/:classId/student/:studentId',
        builder: (context, state) => StudentDetailScreen(
          classId: state.pathParameters['classId']!,
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      // Route edit profil (nama saja, NIM immutable).
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
