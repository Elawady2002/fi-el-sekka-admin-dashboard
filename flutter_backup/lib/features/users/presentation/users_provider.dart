import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_fi_el_sekka/features/auth/domain/user_entity.dart';

/// Users provider - fetches all users using service key to bypass RLS
final usersProvider = FutureProvider<List<UserEntity>>((ref) async {
  try {
    debugPrint('📊 Fetching users from database...');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final serviceKey =
        dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || serviceKey == null) {
      throw Exception('Missing Supabase credentials');
    }

    // Use direct REST API call with service key to bypass RLS
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=*&order=created_at.desc'),
      headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    debugPrint('📦 Raw response count: ${responseList.length}');

    // Log first user for debugging
    if (responseList.isNotEmpty) {
      debugPrint('📦 First user data: ${responseList.first}');
    }

    // تحويل للكائنات مع معالجة الأخطاء
    final List<UserEntity> allUsers = [];
    for (final jsonData in responseList) {
      try {
        final user = UserEntity.fromJson(jsonData as Map<String, dynamic>);
        allUsers.add(user);
      } catch (e) {
        debugPrint('⚠️ Error parsing user: $e');
        debugPrint('⚠️ Problem user data: $jsonData');
      }
    }

    debugPrint('👥 Successfully parsed ${allUsers.length} users');

    // استبعاد المسؤولين فقط (user_type == admin)
    final users = allUsers.where((user) => !user.isAdmin).toList();

    debugPrint('👥 Users count (excluding admins): ${users.length}');

    // Log user emails for debugging
    for (final user in users) {
      debugPrint('  - ${user.email} (${user.fullName})');
    }

    return users;
  } catch (e, stack) {
    debugPrint('❌ Error fetching users: $e');
    debugPrint('❌ Stack trace: $stack');
    rethrow;
  }
});

/// User stats provider
class UserStats {
  final int total;
  final int students;
  final int drivers;
  final int verified;
  final int withActiveSubscription;

  const UserStats({
    required this.total,
    required this.students,
    required this.drivers,
    required this.verified,
    required this.withActiveSubscription,
  });
}

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final users = await ref.watch(usersProvider.future);

  return UserStats(
    total: users.length,
    students: users.where((u) => u.userType == UserType.student).length,
    drivers: users.where((u) => u.userType == UserType.driver).length,
    verified: users.where((u) => u.isVerified).length,
    withActiveSubscription: users.where((u) => u.hasActiveSubscription).length,
  );
});
