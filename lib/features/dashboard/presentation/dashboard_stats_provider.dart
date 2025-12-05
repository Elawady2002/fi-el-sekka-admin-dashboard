import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';

/// Dashboard stats provider
class DashboardStats {
  final int totalUsers;
  final int activeSubscriptions;
  final int todaysTrips;
  final double monthlyRevenue;
  final double userGrowth;
  final double subscriptionGrowth;

  const DashboardStats({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.todaysTrips,
    required this.monthlyRevenue,
    required this.userGrowth,
    required this.subscriptionGrowth,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final supabase = SupabaseConfig.client;

  try {
    // Fetch total users count
    final usersResponse = await supabase.from('users').select('id');
    final totalUsers = (usersResponse as List).length;

    // Fetch active subscriptions count
    final subsResponse = await supabase
        .from('subscriptions')
        .select('id')
        .eq('status', 'active');
    final activeSubscriptions = (subsResponse as List).length;

    // For now, return mock data for trips and revenue
    // TODO: Implement real queries when tables are ready

    return DashboardStats(
      totalUsers: totalUsers,
      activeSubscriptions: activeSubscriptions,
      todaysTrips: 0, // TODO: Query trips table
      monthlyRevenue: 0.0, // TODO: Calculate from subscriptions
      userGrowth: 12.5,
      subscriptionGrowth: 8.3,
    );
  } catch (e) {
    debugPrint('Error fetching dashboard stats: $e');
    // Return default values on error
    return const DashboardStats(
      totalUsers: 0,
      activeSubscriptions: 0,
      todaysTrips: 0,
      monthlyRevenue: 0.0,
      userGrowth: 0.0,
      subscriptionGrowth: 0.0,
    );
  }
});
