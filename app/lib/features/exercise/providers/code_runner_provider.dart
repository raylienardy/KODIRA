import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/code_runner_repository.dart';
import '../../../data/sources/remote/code_runner_source.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider untuk [CodeRunnerSource].
final codeRunnerSourceProvider = Provider<CodeRunnerSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CodeRunnerSource(client);
});

/// Provider untuk [CodeRunnerRepository].
final codeRunnerRepositoryProvider = Provider<CodeRunnerRepository>((ref) {
  final source = ref.watch(codeRunnerSourceProvider);
  return CodeRunnerRepository(source);
});
