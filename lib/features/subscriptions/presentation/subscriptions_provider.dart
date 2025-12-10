import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';

/// Subscriptions provider - fetches all subscriptions using service key to bypass RLS
final subscriptionsProvider = FutureProvider<List<SubscriptionEntity>>((
  ref,
) async {
  try {
    debugPrint('📦 Fetching subscriptions from database...');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final serviceKey =
        dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || serviceKey == null) {
      throw Exception('Missing Supabase credentials');
    }

    // Use direct REST API call with service key to bypass RLS
    final response = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/subscriptions?select=*,users(full_name,email,phone)&order=created_at.desc',
      ),
      headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch subscriptions: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    debugPrint('📦 Fetched ${responseList.length} subscriptions');

    final subscriptions = responseList
        .map(
          (json) => SubscriptionEntity.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return subscriptions;
  } catch (e, stack) {
    debugPrint('❌ Error fetching subscriptions: $e');
    debugPrint('❌ Stack trace: $stack');
    rethrow;
  }
});

/// Subscription stats provider
class SubscriptionStats {
  final int total;
  final int active;
  final int expired;
  final int pending;
  final double monthlyRevenue;
  final double totalRevenue;

  const SubscriptionStats({
    required this.total,
    required this.active,
    required this.expired,
    required this.pending,
    required this.monthlyRevenue,
    required this.totalRevenue,
  });
}

final subscriptionStatsProvider = FutureProvider<SubscriptionStats>((
  ref,
) async {
  final subscriptions = await ref.watch(subscriptionsProvider.future);

  final active = subscriptions
      .where((s) => s.status == SubscriptionStatus.active)
      .length;
  final expired = subscriptions
      .where((s) => s.status == SubscriptionStatus.expired)
      .length;
  final pending = subscriptions
      .where((s) => s.status == SubscriptionStatus.pending)
      .length;

  final totalRevenue = subscriptions
      .where((s) => s.status == SubscriptionStatus.active)
      .fold(0.0, (sum, s) => sum + s.totalPrice);

  // Calculate monthly revenue (subscriptions created this month)
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthlyRevenue = subscriptions
      .where(
        (s) =>
            s.status == SubscriptionStatus.active &&
            s.createdAt.isAfter(monthStart),
      )
      .fold(0.0, (sum, s) => sum + s.totalPrice);

  return SubscriptionStats(
    total: subscriptions.length,
    active: active,
    expired: expired,
    pending: pending,
    monthlyRevenue: monthlyRevenue,
    totalRevenue: totalRevenue,
  );
});
