import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../app/theme.dart';
import '../../../data/repositories/auth_logic.dart';
import '../providers/auth_provider.dart';

/// Layar Registrasi Self-Service (Fitur #3).
///
/// Mahasiswa membuat akun dengan NIM + Nama Lengkap + Password. Setelah
/// berhasil, user otomatis terdaftar di kelas default "PTIK B 2024" dan
/// langsung masuk ke Home.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static const String _defaultClassName = 'PTIK B 2024';

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithNim(
            nim: _nimController.text.trim(),
            name: _nameController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      // Auto-login: auth.signUp langsung membuat session (email confirmation
      // dimatikan di Supabase Dashboard), jadi getCurrentUser mengembalikan
      // user lengkap untuk restoreSession.
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (!mounted) return;
      if (user != null) {
        ref.read(authStateProvider.notifier).restoreSession(user);
      }

      if (context.mounted) context.go('/home');
    } on supa.AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Judul
                  const Text(
                    'KODIRA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat akun baru untuk mulai belajar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NIM
                        const _FieldLabel('NIM'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _nimController,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          decoration: _inputDecoration(
                            'Masukkan NIM Anda',
                          ).copyWith(counterText: ''),
                          validator: (value) {
                            final nim = value?.trim() ?? '';
                            if (nim.isEmpty) return 'NIM wajib diisi';
                            if (!AuthLogic.isValidNim(nim)) {
                              return 'NIM harus 13 digit angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Nama Lengkap
                        const _FieldLabel('Nama Lengkap'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          decoration: _inputDecoration('Masukkan nama lengkap'),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return 'Nama wajib diisi';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password
                        const _FieldLabel('Password'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          decoration: _inputDecoration('Masukkan password')
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Konfirmasi Password
                        const _FieldLabel('Konfirmasi Password'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          decoration: _inputDecoration('Ulangi password')
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password wajib diisi';
                            }
                            if (value != _passwordController.text) {
                              return 'Konfirmasi password tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  // Info kelas default
                  const SizedBox(height: 12),
                  Text(
                    'Kamu akan otomatis terdaftar di kelas $_defaultClassName.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KodiraColors.neutral0,
                        foregroundColor: KodiraColors.primary700,
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KodiraRadius.md),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  KodiraColors.primary700,
                                ),
                              ),
                            )
                          : const Text('Daftar'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sudah punya akun
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Label kecil di atas field, pola visual sama dengan LoginScreen.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 13,
      color: Colors.white.withValues(alpha: 0.5),
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(KodiraRadius.md),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
