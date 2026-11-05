import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../app/theme.dart';

/// Halaman informasi statis (About & Panduan) KODIRA.
///
/// Membaca konten markdown dari `assets/content/about.md` dan merendernya
/// dengan gaya desain sistem KODIRA.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'Tentang Aplikasi',
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/content/about.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: KodiraColors.primary700),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat konten panduan. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                  style: KodiraTextStyles.body.copyWith(
                    color: KodiraColors.alert700,
                  ),
                ),
              ),
            );
          }

          final String markdownData = snapshot.data ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: MarkdownBody(
              data: markdownData,
              styleSheet: MarkdownStyleSheet(
                h1: KodiraTextStyles.h2.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w700,
                ),
                h2: KodiraTextStyles.h3.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w600,
                ),
                h3: KodiraTextStyles.bodyLg.copyWith(
                  color: KodiraColors.primary700,
                  fontWeight: FontWeight.w600,
                ),
                p: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral700,
                  height: 1.5,
                ),
                listBullet: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral700,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: KodiraColors.neutral900,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: KodiraColors.primary100,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: KodiraColors.primary700, width: 4),
                  ),
                ),
                codeblockDecoration: BoxDecoration(
                  color: KodiraColors.neutral900,
                  borderRadius: BorderRadius.circular(8),
                ),
                code: KodiraTextStyles.code.copyWith(
                  color: KodiraColors.primary500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
