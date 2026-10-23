import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/material_model.dart';
import '../../../data/repositories/i_material_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../auth/providers/auth_provider.dart';

final materialRepositoryProvider = Provider<IMaterialRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MaterialRepository(client);
});

final materialsByLevelProvider =
    FutureProvider.family<List<MaterialModel>, int>((ref, levelId) async {
      final repo = ref.watch(materialRepositoryProvider);
      return repo.getMaterialsByLevel(levelId);
    });
