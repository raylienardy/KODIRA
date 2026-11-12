import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../providers/class_provider.dart';

/// Layar Buat Kelas (Fitur #P3).
///
/// Hanya untuk akun dengan `role = 'teacher'`. Form meminta nama kelas
/// (wajib) dan deskripsi (opsional). Server yang menghasilkan kode
/// 6-karakter unik, lalu teacher otomatis tercatat sebagai owner kelas.
class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(classRepositoryProvider)
          .createClass(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (!mounted) return;

      final error = result['error'] as String?;
      if (error != null) {
        String message = 'Gagal membuat kelas';
        if (error == 'not_teacher') {
          message = 'Hanya dosen yang bisa membuat kelas';
        } else if (error == 'not_authenticated') {
          message = 'Sesi habis, login ulang';
        } else if (error == 'code_generation_failed') {
          message = 'Gagal membuat kode kelas, coba lagi';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final bool success = result['success'] as bool? ?? false;
      final String code = result['code'] as String? ?? '';
      final String className = result['name'] as String? ?? '';

      if (success) {
        ref.invalidate(myClassesProvider);
        _nameController.clear();
        _descriptionController.clear();
        await _showCodeDialog(className, code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat kelas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Tampilkan kode kelas setelah berhasil dibuat.
  Future<void> _showCodeDialog(String className, String code) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: KodiraColors.neutral0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KodiraRadius.lg),
          ),
          title: Text(
            'Kelas berhasil dibuat',
            style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                className,
                textAlign: TextAlign.center,
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: KodiraSpacing.s4),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: KodiraSpacing.s3,
                  horizontal: KodiraSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: KodiraColors.primary100,
                  borderRadius: BorderRadius.circular(KodiraRadius.md),
                ),
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: KodiraTextStyles.h2.copyWith(
                    color: KodiraColors.primary700,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: KodiraSpacing.s3),
              Text(
                'Bagikan kode ini ke mahasiswa untuk bergabung.',
                textAlign: TextAlign.center,
                style: KodiraTextStyles.caption.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Kode disalin')));
              },
              child: Text(
                'Salin Kode',
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.primary700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KodiraColors.primary700,
                foregroundColor: KodiraColors.neutral0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KodiraRadius.md),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: KodiraColors.neutral900,
        title: Text(
          'Buat Kelas',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KodiraSpacing.s4),
        child: Form(
          key: _formKey,
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
                      'Kelas Baru',
                      style: KodiraTextStyles.h3.copyWith(
                        color: KodiraColors.primary700,
                      ),
                    ),
                    const SizedBox(height: KodiraSpacing.s2),
                    Text(
                      'Buat kelas untuk mengelompokkan mahasiswa',
                      style: KodiraTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: KodiraColors.primary700,
                      ),
                    ),
                    const SizedBox(height: KodiraSpacing.s2),
                    Text(
                      'Setelah dibuat, sistem akan membuat kode 6 karakter unik. '
                      'Bagikan kode ke mahasiswa supaya mereka bisa join. '
                      'Anda bisa memantau progress mereka di menu "Kelas Saya".',
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KodiraSpacing.s5),

              // Nama kelas
              Text(
                'Nama Kelas',
                style: KodiraTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: KodiraColors.neutral700,
                ),
              ),
              const SizedBox(height: KodiraSpacing.s2),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: 'Pemrograman Dasar - A',
                  hintStyle: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral300,
                  ),
                  filled: true,
                  fillColor: KodiraColors.neutral0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                    borderSide: const BorderSide(
                      color: KodiraColors.neutral200,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KodiraSpacing.s3,
                    vertical: KodiraSpacing.s3,
                  ),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Nama kelas wajib diisi';
                  if (name.length < 3) {
                    return 'Nama kelas minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KodiraSpacing.s4),

              // Deskripsi (opsional)
              Text(
                'Deskripsi (opsional)',
                style: KodiraTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: KodiraColors.neutral700,
                ),
              ),
              const SizedBox(height: KodiraSpacing.s2),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Deskripsi singkat tentang kelas ini',
                  hintStyle: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.neutral300,
                  ),
                  filled: true,
                  fillColor: KodiraColors.neutral0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                    borderSide: const BorderSide(
                      color: KodiraColors.neutral200,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KodiraSpacing.s3,
                    vertical: KodiraSpacing.s3,
                  ),
                ),
              ),
              const SizedBox(height: KodiraSpacing.s6),

              // Tombol Buat Kelas
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KodiraColors.primary700,
                    foregroundColor: KodiraColors.neutral0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
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
                      : const Text('Buat Kelas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
