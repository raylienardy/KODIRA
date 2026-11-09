import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/my_class_model.dart';
import '../../../data/repositories/class_repository.dart';
import '../../auth/providers/auth_provider.dart';

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ClassRepository(client);
});

final myClassesProvider = FutureProvider<List<MyClass>>((ref) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return [];
  return ref.read(classRepositoryProvider).getMyClasses(user.id);
});
