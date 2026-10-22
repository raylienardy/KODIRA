import 'dart:async';

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
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({UserModel? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
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

  Future<void> login(String nim, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repo.signInWithNim(nim: nim, password: password);
      state = state.copyWith(user: user, isLoading: false);
      refreshProgressProviders();
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
    : _repo = repo,
      _client = client,
      _ref = ref,
      super(
        client.auth.currentSession == null
            ? SessionStatus.unauthenticated
            : SessionStatus.loading,
      ) {
    if (state == SessionStatus.loading) {
      _restoreSession();
    } else {
      _listenAuthChanges();
    }
  }

  final AuthRepository _repo;
  final SupabaseClient _client;
  final Ref _ref;
  StreamSubscription<bool>? _authSubscription;

  /// Validasi session tersimpan, isi AuthState dengan user, lalu mulai
  /// memantau perubahan auth berikutnya.
  Future<void> _restoreSession() async {
    try {
      final user = await _repo.getCurrentUser().timeout(
        const Duration(seconds: 5),
      );
      if (!mounted) return;

      if (user != null) {
        _ref.read(authStateProvider.notifier).restoreSession(user);
        state = SessionStatus.authenticated;
        _ref.invalidate(allProgressProvider);
        _ref.invalidate(totalXpProvider);
      } else {
        state = SessionStatus.unauthenticated;
      }
    } catch (_) {
      // Validasi gagal (mis. jaringan) — jangan paksa login ulang selama
      // session lokal masih ada.
      if (!mounted) return;
      state = _client.auth.currentSession != null
          ? SessionStatus.authenticated
          : SessionStatus.unauthenticated;
      if (state == SessionStatus.authenticated) {
        _ref.invalidate(allProgressProvider);
        _ref.invalidate(totalXpProvider);
      }
    } finally {
      if (mounted) _listenAuthChanges();
    }
  }

  void _listenAuthChanges() {
    _authSubscription = _repo.authStateChanges().listen((hasSession) {
      state = hasSession
          ? SessionStatus.authenticated
          : SessionStatus.unauthenticated;
    });
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
