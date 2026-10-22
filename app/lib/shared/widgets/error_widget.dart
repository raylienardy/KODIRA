import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/errors/error_type.dart';

/// Tampilan error standar KODIRA dengan tombol coba lagi.
///
/// Dinamai `KodiraErrorWidget` supaya tidak bentrok dengan `ErrorWidget`
/// bawaan Flutter yang diekspor `material.dart`.
class KodiraErrorWidget extends StatelessWidget {
  final ErrorType error;
  final VoidCallback? onRetry;

  const KodiraErrorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool showRetry = error.isRetryable && onRetry != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Error: ${error.userMessage}',
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: KodiraColors.alert700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error.userMessage,
                      textAlign: TextAlign.center,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.lg),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
