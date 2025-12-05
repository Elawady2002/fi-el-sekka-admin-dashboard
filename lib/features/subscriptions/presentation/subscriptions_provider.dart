import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';

/// Subscriptions provider - fetches all subscriptions with user data
final subscriptionsProvider = FutureProvider<List<SubscriptionEntity>>((
  ref,
) async {
  final supabase = SupabaseConfig.client;

  try {
    final response = await supabase
        .from('subscriptions')
        .select('*, users(full_name, email)')
        .order('created_at', ascending: false);

    final subscriptions = (response as List)
        .map((json) => SubscriptionEntity.fromJson(json))
        .toList();

    return subscriptions;
  } catch (e) {
    debugPrint('Error fetching subscriptions: $e');
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

  const SubscriptionStats({
    required this.total,
    required this.active,
    required this.expired,
    required this.pending,
    required this.monthlyRevenue,
  });
}

final subscriptionStatsProvider = FutureProvider<SubscriptionStats>((
  ref,
) async {
  final subscriptionsAsync = await ref.watch(subscriptionsProvider.future);

  final total = subscriptionsAsync.length;
  final active = subscriptionsAsync.where((s) => s.isActive).length;
  final expired = subscriptionsAsync.where((s) => s.isExpired).length;
  final pending = subscriptionsAsync
      .where((s) => s.status == SubscriptionStatus.pending)
      .length;

  // Calculate monthly revenue from active subscriptions
  final monthlyRevenue = subscriptionsAsync
      .where((s) => s.isActive && s.type == SubscriptionType.monthly)
      .fold(0.0, (sum, s) => sum + s.amount);

  return SubscriptionStats(
    total: total,
    active: active,
    expired: expired,
    pending: pending,
    monthlyRevenue: monthlyRevenue,
  );
});
