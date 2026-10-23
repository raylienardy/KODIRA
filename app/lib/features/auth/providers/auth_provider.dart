import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/errors/auth_exception.dart';
import '../../home/providers/level_provider.dart';

// Supabase client singleton
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// AuthRepository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

// Auth state class
class AuthState {
  final UserModel? user;
  final bool isLoading;

  /// True bila session lokal ada, tetapi data user gagal dimuat dari server.
  ///
  /// Selama flag ini aktif, fitur yang butuh `user.id` (mis. simpan progress)
  /// harus mencoba memuat ulang user sebelum menyerah.
  final bool userLoadFailed;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.userLoadFailed = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? userLoadFailed,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      userLoadFailed: userLoadFailed ?? this.userLoadFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AuthState());

  /// Segarkan cache progress belajar setiap kali user berubah, supaya layar
  /// Home langsung menampilkan XP dan status level milik user yang masuk.
  void refreshProgressProviders() {
    _ref.invalidate(allProgressProvider);
    _ref.invalidate(totalXpProvider);
  }

  /// Perbarui streak harian user setiap kali dia masuk (P4-010).
  ///
  /// Penulisan streak tidak boleh mengganggu alur login, jadi kegagalannya
  /// hanya dicatat dan alur login tetap berjalan.
  Future<void> refreshStreak(String userId) async {
    try {
      await _ref
          .read(streakRepositoryProvider)
          .updateOnActivity(userId: userId, now: DateTime.now());
      _ref.invalidate(currentStreakProvider);
    } catch (e) {
      debugPrint('Failed to update streak: $e');
    }
  }

  /// Periksa milestone lalu berikan badge dan achievement yang baru (P4-010).
  ///
  /// Kegagalan tidak boleh mengganggu alur login, jadi hanya dicatat.
  Future<void> refreshBadges(String userId) async {
    try {
      await _ref.read(badgeRepositoryProvider).checkAndAward(userId);
      _ref.invalidate(badgeCountProvider);
    } catch (e) {
      debugPrint('Badge check failed: $e');
    }
  }

  Future<void> login(String nim, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repo.signInWithNim(nim: nim, password: password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        userLoadFailed: false,
      );
      refreshProgressProviders();
      unawaited(refreshStreak(user.id));
      unawaited(refreshBadges(user.id));
    } on KodiraAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = const AuthState();
  }

  /// Mengisi user hasil session restore saat app dibuka.
  /// Tidak mengubah alur login/logout yang sudah ada.
  void restoreSession(UserModel user) {
    state = AuthState(user: user);
    unawaited(refreshStreak(user.id));
    unawaited(refreshBadges(user.id));
  }

  /// Tandai bahwa session ada, tetapi data user belum berhasil dimuat.
  void setUserLoadFailed() {
    state = state.copyWith(userLoadFailed: true);
  }

  /// Ambil user untuk operasi simpan; muat ulang sekali bila state kosong.
  ///
  /// Dipakai alur kuis supaya hasil tidak hilang diam-diam ketika cold start
  /// gagal memuat user. Mengembalikan `null` bila user tetap tidak tersedia.
  Future<UserModel?> resolveUserForSave() async {
    final UserModel? current = state.user;
    if (current != null) return current;

    try {
      final UserModel? reloaded = await _repo.getCurrentUser().timeout(
        const Duration(seconds: 5),
      );
      if (reloaded != null) {
        state = state.copyWith(user: reloaded, userLoadFailed: false);
        return reloaded;
      }
    } catch (e) {
      debugPrint('Failed to reload user for save: $e');
    }

    return null;
  }

  /// Muat ulang profil dari banner Home setelah cold start gagal.
  ///
  /// Selain mengisi [AuthState.user], method ini menyegarkan streak dan badge
  /// supaya chip di Home tidak tertinggal di nilai 0 sampai app di-restart.
  /// Mengembalikan `true` bila user berhasil dimuat.
  Future<bool> retryUserLoad() async {
    final UserModel? user = await resolveUserForSave();
    if (user == null) {
      setUserLoadFailed();
      return false;
    }

    state = state.copyWith(userLoadFailed: false);
    // Provider progress/streak/badge di-invalidate oleh pemanggil (Home).
    // Invalidasi dari ref AuthNotifier akan memicu CircularDependencyError
    // karena provider-provider tersebut bergantung pada authStateProvider.
    await refreshStreak(user.id);
    await refreshBadges(user.id);
    return true;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo, ref);
});

// Session status saat app dibuka
enum SessionStatus { loading, authenticated, unauthenticated }

/// Menentukan status session saat launch: memvalidasi session tersimpan
/// lewat [AuthRepository.getCurrentUser], mengisi [AuthState] dengan user,
/// lalu memantau perubahan login/logout lewat stream Supabase.
class SessionNotifier extends StateNotifier<SessionStatus> {
  SessionNotifier(AuthRepository repo, SupabaseClient client, Ref ref)
    : this._(
        repo,
        ref,
        const Duration(seconds: 5),
        const <Duration>[
          Duration.zero,
          Duration(seconds: 5),
          Duration(seconds: 10),
          Duration(seconds: 15),
        ],
        hasStoredSession: client.auth.currentSession != null,
      );

  /// Konstruktor dengan dependency yang bisa dikontrol test.
  @visibleForTesting
  SessionNotifier.forTesting(
    AuthRepository repo,
    Ref ref, {
    required bool hasStoredSession,
    Duration restoreTimeout = const Duration(seconds: 5),
    List<Duration> retryDelays = const <Duration>[
      Duration.zero,
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 15),
    ],
  }) : this._(
         repo,
         ref,
         restoreTimeout,
         retryDelays,
         hasStoredSession: hasStoredSession,
       );

  SessionNotifier._(
    this._repo,
    this._ref,
    this._restoreTimeout,
    this._retryDelays, {
    required bool hasStoredSession,
  }) : super(
         hasStoredSession
             ? SessionStatus.loading
             : SessionStatus.unauthenticated,
       ) {
    if (state == SessionStatus.loading) {
      _restoreFuture = _restoreSession();
    } else {
      _listenAuthChanges();
    }
  }

  final AuthRepository _repo;
  final Ref _ref;
  final Duration _restoreTimeout;
  final List<Duration> _retryDelays;
  StreamSubscription<bool>? _authSubscription;
  Future<void>? _restoreFuture;
  Future<void>? _userResolution;

  /// Future yang selesai saat percobaan restore awal selesai.
  @visibleForTesting
  Future<void> get restoreCompleted => _restoreFuture ?? Future<void>.value();

  /// Validasi session tersimpan, isi AuthState dengan user, lalu mulai
  /// memantau perubahan auth berikutnya.
  ///
  /// Percobaan pertama langsung jalan; percobaan berikutnya menunggu backoff
  /// dari [_retryDelays]. Retry hanya untuk gangguan sementara; error domain
  /// auth langsung membersihkan session tanpa retry.
  Future<void> _restoreSession() async {
    try {
      for (var attempt = 0; attempt < _retryDelays.length; attempt++) {
        final Duration delay = _retryDelays[attempt];
        if (delay > Duration.zero) {
          await Future<void>.delayed(delay);
        }
        if (!mounted) return;

        try {
          final UserModel? user = await _repo.getCurrentUser().timeout(
            _restoreTimeout,
          );
          if (!mounted) return;

          if (user != null) {
            _applyUser(user);
            return;
          }

          // Session valid tetapi baris user tidak ada: perlakukan sebagai
          // session tidak valid, bukan gangguan jaringan.
          state = SessionStatus.unauthenticated;
          return;
        } on KodiraAuthException catch (error) {
          debugPrint('Session restore rejected: ${error.message}');
          if (!mounted) return;
          await _clearStoredSession();
          if (!mounted) return;
          state = SessionStatus.unauthenticated;
          return;
        } catch (error) {
          debugPrint('Restore attempt ${attempt + 1} failed: $error');
        }
      }

      if (!mounted) return;
      _ref.read(authStateProvider.notifier).setUserLoadFailed();
      state = SessionStatus.authenticated;
    } finally {
      if (mounted) _listenAuthChanges();
    }
  }

  void _applyUser(UserModel user) {
    _ref.read(authStateProvider.notifier).restoreSession(user);
    state = SessionStatus.authenticated;
    _ref.invalidate(allProgressProvider);
    _ref.invalidate(totalXpProvider);
  }

  Future<void> _clearStoredSession() async {
    try {
      await _repo.signOut();
    } catch (error) {
      debugPrint('Failed to clear stored session: $error');
    }
  }

  void _listenAuthChanges() {
    _authSubscription = _repo.authStateChanges().listen((hasSession) {
      if (!mounted) return;
      if (!hasSession) {
        state = SessionStatus.unauthenticated;
        return;
      }

      state = SessionStatus.authenticated;
      if (_ref.read(authStateProvider).user == null) {
        _resolveUserAfterAuthEvent();
      }
    });
  }

  void _resolveUserAfterAuthEvent() {
    _userResolution ??= _resolveUserOnce().whenComplete(() {
      _userResolution = null;
    });
  }

  Future<void> _resolveUserOnce() async {
    final UserModel? user = await _ref
        .read(authStateProvider.notifier)
        .resolveUserForSave();
    if (!mounted) return;
    if (user == null) {
      _ref.read(authStateProvider.notifier).setUserLoadFailed();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Status session global; dipakai redirect router untuk gerbang splash/login.
final sessionStatusProvider =
    StateNotifierProvider<SessionNotifier, SessionStatus>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      final client = ref.watch(supabaseClientProvider);
      return SessionNotifier(repo, client, ref);
    });
