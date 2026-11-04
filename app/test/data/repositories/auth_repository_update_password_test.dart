import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/auth_repository.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthRepository.updatePassword Interface & Contract', () {
    final SupabaseClient client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
    );

    test('AuthRepository implements IAuthRepository', () {
      final repository = AuthRepository(client);
      expect(repository, isA<IAuthRepository>());
    });

    test('updatePassword method exists on AuthRepository', () {
      final repository = AuthRepository(client);
      expect(repository.updatePassword, isNotNull);
    });
  });
}
