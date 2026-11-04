import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../logic/password_strength_logic.dart';

/// Layar Ganti Password (Fase 1c #4a).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  PasswordStrength _currentStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onNewPasswordChanged);
  }

  void _onNewPasswordChanged() {
    final strength = PasswordStrengthLogic.evaluate(
      _newPasswordController.text,
    );
    if (strength != _currentStrength) {
      setState(() {
        _currentStrength = strength;
      });
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(authStateProvider).user;
      if (user == null) {
        throw const supa.AuthException('User tidak ditemukan');
      }

      await ref
          .read(authRepositoryProvider)
          .updatePassword(
            nim: user.nim,
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
      context.pop();
    } on supa.AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Password Lama
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    hintText: 'Masukkan password lama',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOld ? Icons.visibility_off : Icons.visibility,
                        color: KodiraColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureOld = !_obscureOld;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password lama wajib diisi';
                    }
                    if (value.length < PasswordStrengthLogic.minLength) {
                      return 'Minimal ${PasswordStrengthLogic.minLength} karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Baru
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    hintText: 'Masukkan password baru',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: KodiraColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password baru wajib diisi';
                    }
                    if (value.length < PasswordStrengthLogic.minLength) {
                      return 'Minimal ${PasswordStrengthLogic.minLength} karakter';
                    }
                    if (value == _oldPasswordController.text) {
                      return 'Password baru harus berbeda dengan password lama';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Strength Meter
                _PasswordStrengthIndicator(strength: _currentStrength),
                const SizedBox(height: 20),

                // Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    hintText: 'Ulangi password baru',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: KodiraColors.neutral500,
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
                    if (value != _newPasswordController.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol Simpan
                FilledButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: KodiraColors.primary700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan Password',
                          style: KodiraTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthIndicator({required this.strength});

  @override
  Widget build(BuildContext context) {
    final label = PasswordStrengthLogic.label(strength);
    Color color;
    double progress;

    switch (strength) {
      case PasswordStrength.weak:
        color = KodiraColors.alert700;
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = Colors.amber.shade700;
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = Colors.green.shade700;
        progress = 1.0;
        break;
    }

    return Semantics(
      label: 'Kekuatan password: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kekuatan Password',
                style: KodiraTextStyles.caption.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
              Text(
                label,
                style: KodiraTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: KodiraColors.neutral100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
