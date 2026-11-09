import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../app/theme.dart';
import '../providers/class_provider.dart';

class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kode harus 6 karakter')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(classRepositoryProvider).joinClass(code);

      final error = result['error'] as String?;
      final success = result['success'] as bool?;
      final alreadyMember = result['already_member'] as bool?;
      final className = result['class_name'] as String? ?? '';

      if (!mounted) return;

      if (error != null) {
        String message = 'Gagal join kelas: $error';
        if (error == 'class_not_found') {
          message = 'Kelas tidak ditemukan';
        } else if (error == 'not_authenticated') {
          message = 'Sesi habis, login ulang';
        } else if (error == 'invalid_code_format') {
          message = 'Kode harus 6 karakter';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else if (alreadyMember == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamu sudah member kelas $className')),
        );
      } else if (success == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Berhasil join $className')));
        _codeController.clear();
        ref.invalidate(myClassesProvider);
      }
    } on supa.AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal join kelas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSetPrimary(String classId, String className) async {
    try {
      await ref.read(classRepositoryProvider).setPrimaryClass(classId);
      ref.invalidate(myClassesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$className dijadikan kelas utama')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal set primary: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myClassesAsync = ref.watch(myClassesProvider);

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Ganti Kelas',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KodiraSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(KodiraSpacing.s4),
              decoration: BoxDecoration(
                color: KodiraColors.primary100,
                borderRadius: BorderRadius.circular(KodiraRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gabung Kelas Baru',
                    style: KodiraTextStyles.h3.copyWith(
                      color: KodiraColors.primary700,
                    ),
                  ),
                  const SizedBox(height: KodiraSpacing.s2),
                  Text(
                    'Masukkan kode 6 karakter dari dosen Anda',
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: KodiraSpacing.s4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          maxLength: 6,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'PTIK24',
                            hintStyle: KodiraTextStyles.body.copyWith(
                              color: KodiraColors.neutral300,
                            ),
                            filled: true,
                            fillColor: KodiraColors.neutral0,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                KodiraRadius.md,
                              ),
                              borderSide: const BorderSide(
                                color: KodiraColors.neutral200,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: KodiraSpacing.s3,
                              vertical: KodiraSpacing.s3,
                            ),
                            counterText: '',
                          ),
                          style: KodiraTextStyles.h3.copyWith(
                            letterSpacing: 2.0,
                            color: KodiraColors.neutral900,
                          ),
                        ),
                      ),
                      const SizedBox(width: KodiraSpacing.s2),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KodiraColors.primary700,
                            foregroundColor: KodiraColors.neutral0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                KodiraRadius.md,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: KodiraSpacing.s5,
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleJoin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      KodiraColors.neutral0,
                                    ),
                                  ),
                                )
                              : const Text('Gabung'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: KodiraSpacing.s6),
            Text(
              'Kelas Saya',
              style: KodiraTextStyles.h3.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: KodiraSpacing.s3),
            myClassesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(KodiraSpacing.s6),
                  child: CircularProgressIndicator(
                    color: KodiraColors.primary700,
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(KodiraSpacing.s4),
                  child: Text(
                    'Gagal memuat kelas: $err',
                    textAlign: TextAlign.center,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.alert700,
                    ),
                  ),
                ),
              ),
              data: (classes) {
                if (classes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(KodiraSpacing.s6),
                    decoration: BoxDecoration(
                      color: KodiraColors.neutral0,
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                    ),
                    child: Text(
                      'Kamu belum terdaftar di kelas manapun',
                      textAlign: TextAlign.center,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  );
                }

                return Column(
                  children: classes.map((cls) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: KodiraSpacing.s3),
                      padding: const EdgeInsets.all(KodiraSpacing.s4),
                      decoration: BoxDecoration(
                        color: KodiraColors.neutral0,
                        borderRadius: BorderRadius.circular(KodiraRadius.md),
                        boxShadow: KodiraShadows.elevation1,
                        border: cls.isPrimary
                            ? Border.all(
                                color: KodiraColors.primary500,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cls.isPrimary ? Icons.star : Icons.school_outlined,
                            color: cls.isPrimary
                                ? KodiraColors.reward500
                                : KodiraColors.neutral500,
                            size: 28,
                          ),
                          const SizedBox(width: KodiraSpacing.s3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        cls.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: KodiraTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: KodiraColors.neutral900,
                                        ),
                                      ),
                                    ),
                                    if (cls.isPrimary) ...[
                                      const SizedBox(width: KodiraSpacing.s2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: KodiraSpacing.s2,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: KodiraColors.primary100,
                                          borderRadius: BorderRadius.circular(
                                            KodiraRadius.full,
                                          ),
                                        ),
                                        child: Text(
                                          'Primary',
                                          style: KodiraTextStyles.caption
                                              .copyWith(
                                                color: KodiraColors.primary700,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  'Kode: ${cls.code}',
                                  style: KodiraTextStyles.caption.copyWith(
                                    color: KodiraColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!cls.isPrimary)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: KodiraColors.primary700,
                                side: const BorderSide(
                                  color: KodiraColors.primary500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    KodiraRadius.sm,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: KodiraSpacing.s3,
                                ),
                                textStyle: KodiraTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () =>
                                  _handleSetPrimary(cls.id, cls.name),
                              child: const Text('Set Primary'),
                            )
                          else
                            const Icon(
                              Icons.check_circle_outline,
                              color: KodiraColors.primary700,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
