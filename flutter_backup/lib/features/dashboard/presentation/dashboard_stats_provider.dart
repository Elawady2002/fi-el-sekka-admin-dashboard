import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Dashboard statistics model
class DashboardStats {
  final int totalUsers;
  final int activeSubscriptions;
  final int pendingSubscriptions;
  final int totalBookings;
  final int todaysTrips;
  final int todaysBookings;
  final double monthlyRevenue;
  final double totalRevenue;
  final double userGrowth;
  final double subscriptionGrowth;

  const DashboardStats({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.pendingSubscriptions,
    required this.totalBookings,
    required this.todaysTrips,
    required this.todaysBookings,
    required this.monthlyRevenue,
    required this.totalRevenue,
    required this.userGrowth,
    required this.subscriptionGrowth,
  });
}

/// Dashboard stats provider using direct REST API with service key
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final serviceKey =
      dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || serviceKey == null) {
    throw Exception('Missing Supabase credentials');
  }

  final headers = {
    'apikey': serviceKey,
    'Authorization': 'Bearer $serviceKey',
    'Content-Type': 'application/json',
  };

  try {
    // Fetch total users count (excluding admins)
    final usersResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=id,user_type'),
      headers: headers,
    );
    final usersData = json.decode(usersResponse.body) as List? ?? [];
    final totalUsers = usersData.where((u) => u['user_type'] != 'admin').length;

    // Fetch subscriptions for active/pending counts and revenue
    final subsResponse = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/subscriptions?select=id,status,total_price,created_at',
      ),
      headers: headers,
    );
    final subsData = json.decode(subsResponse.body) as List? ?? [];

    final activeSubscriptions = subsData
        .where((s) => s['status'] == 'active')
        .length;
    final pendingSubscriptions = subsData
        .where((s) => s['status'] == 'pending')
        .length;

    // Calculate revenue
    final totalRevenue = subsData
        .where((s) => s['status'] == 'active')
        .fold(
          0.0,
          (sum, s) => sum + ((s['total_price'] as num?)?.toDouble() ?? 0.0),
        );

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyRevenue = subsData
        .where((s) {
          if (s['status'] != 'active') return false;
          final createdAt = DateTime.tryParse(s['created_at'] ?? '');
          return createdAt != null && createdAt.isAfter(monthStart);
        })
        .fold(
          0.0,
          (sum, s) => sum + ((s['total_price'] as num?)?.toDouble() ?? 0.0),
        );

    // Fetch total bookings count
    final bookingsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/bookings?select=id,booking_date,status'),
      headers: headers,
    );
    final bookingsData = json.decode(bookingsResponse.body) as List? ?? [];
    final totalBookings = bookingsData.length;

    // Calculate today's trips (confirmed/pending bookings for today)
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todaysTrips = bookingsData.where((b) {
      final bookingDate = b['booking_date']?.toString().split('T').first;
      final status = b['status'];
      return bookingDate == todayStr &&
          (status == 'confirmed' || status == 'pending');
    }).length;

    final todaysBookings = bookingsData.where((b) {
      final bookingDate = b['booking_date']?.toString().split('T').first;
      return bookingDate == todayStr;
    }).length;

    debugPrint(
      '📊 Dashboard Stats: Users=$totalUsers, ActiveSubs=$activeSubscriptions, '
      'PendingSubs=$pendingSubscriptions, Bookings=$totalBookings, '
      'TodaysTrips=$todaysTrips, MonthlyRevenue=$monthlyRevenue, TotalRevenue=$totalRevenue',
    );

    return DashboardStats(
      totalUsers: totalUsers,
      activeSubscriptions: activeSubscriptions,
      pendingSubscriptions: pendingSubscriptions,
      totalBookings: totalBookings,
      todaysTrips: todaysTrips,
      todaysBookings: todaysBookings,
      monthlyRevenue: monthlyRevenue,
      totalRevenue: totalRevenue,
      userGrowth: 0.0,
      subscriptionGrowth: 0.0,
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching dashboard stats: $e');
    debugPrint('Stack trace: $stackTrace');
    return const DashboardStats(
      totalUsers: 0,
      activeSubscriptions: 0,
      pendingSubscriptions: 0,
      totalBookings: 0,
      todaysTrips: 0,
      todaysBookings: 0,
      monthlyRevenue: 0.0,
      totalRevenue: 0.0,
      userGrowth: 0.0,
      subscriptionGrowth: 0.0,
    );
  }
});
