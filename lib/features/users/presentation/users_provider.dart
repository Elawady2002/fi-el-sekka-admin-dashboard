import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/auth/domain/user_entity.dart';

/// Users provider - fetches all users from Supabase
final usersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final supabase = SupabaseConfig.client;

  try {
    final response = await supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    final users = (response as List)
        .map((json) => UserEntity.fromJson(json))
        .toList();

    return users;
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  }
});
