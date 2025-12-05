import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/domain/activity_event.dart';

final recentActivityProvider = FutureProvider<List<ActivityEvent>>((ref) async {
  final supabase = SupabaseConfig.client;
  final events = <ActivityEvent>[];

  try {
    // Fetch recent subscriptions
    final subscriptionsData = await supabase
        .from('subscriptions')
        .select('id, user_id, subscription_status, created_at')
        .order('created_at', ascending: false)
        .limit(5);

    for (final sub in subscriptionsData) {
      final status = sub['subscription_status'] ?? 'نشط';
      events.add(
        ActivityEvent(
          id: sub['id'],
          type: ActivityType.subscription,
          title: 'اشتراك جديد',
          subtitle: 'حالة الاشتراك: $status',
          timestamp: DateTime.parse(sub['created_at']),
        ),
      );
    }

    // Fetch recent bookings
    final bookingsData = await supabase
        .from('bookings')
        .select('id, user_id, created_at')
        .order('created_at', ascending: false)
        .limit(5);

    for (final booking in bookingsData) {
      events.add(
        ActivityEvent(
          id: booking['id'],
          type: ActivityType.booking,
          title: 'حجز جديد',
          subtitle: 'تم إنشاء حجز جديد',
          timestamp: DateTime.parse(booking['created_at']),
        ),
      );
    }

    // Fetch recent users
    final usersData = await supabase
        .from('users')
        .select('id, full_name, user_type, created_at')
        .order('created_at', ascending: false)
        .limit(5);

    for (final user in usersData) {
      final userName = user['full_name'] ?? 'مستخدم';
      final userType = user['user_type'] == 'student' ? 'طالب' : 'مستخدم';
      events.add(
        ActivityEvent(
          id: user['id'],
          type: ActivityType.user,
          title: userName,
          subtitle: 'انضم كـ $userType',
          timestamp: DateTime.parse(user['created_at']),
        ),
      );
    }

    // Sort all events by timestamp (most recent first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return top 15 events
    return events.take(15).toList();
  } catch (e) {
    debugPrint('Error fetching activity events: $e');
    return [];
  }
});
