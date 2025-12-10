import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_fi_el_sekka/features/bookings/domain/booking_entity.dart';

/// Provider for fetching all bookings using service key to bypass RLS
final bookingsProvider = FutureProvider<List<BookingEntity>>((ref) async {
  try {
    debugPrint('📦 Fetching bookings from database...');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final serviceKey =
        dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || serviceKey == null) {
      throw Exception('Missing Supabase credentials');
    }

    // Use direct REST API call with service key to bypass RLS
    final response = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/bookings?select=*,users(full_name,email,phone)&order=created_at.desc',
      ),
      headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch bookings: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    debugPrint('📦 Fetched ${responseList.length} bookings');

    final bookings = responseList.map((json) {
      final booking = Map<String, dynamic>.from(json as Map<String, dynamic>);
      booking['user_name'] = json['users']?['full_name'];
      booking['user_email'] = json['users']?['email'];
      return BookingEntity.fromJson(booking);
    }).toList();

    return bookings;
  } catch (e, stack) {
    debugPrint('❌ Error fetching bookings: $e');
    debugPrint('❌ Stack trace: $stack');
    rethrow;
  }
});

/// Stats for bookings
class BookingStats {
  final int total;
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final double totalRevenue;

  const BookingStats({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.totalRevenue,
  });
}

final bookingStatsProvider = FutureProvider<BookingStats>((ref) async {
  final bookings = await ref.watch(bookingsProvider.future);

  final pending = bookings
      .where((b) => b.status == BookingStatus.pending)
      .length;
  final confirmed = bookings
      .where((b) => b.status == BookingStatus.confirmed)
      .length;
  final completed = bookings
      .where((b) => b.status == BookingStatus.completed)
      .length;
  final cancelled = bookings
      .where((b) => b.status == BookingStatus.cancelled)
      .length;
  final totalRevenue = bookings
      .where((b) => b.status != BookingStatus.cancelled)
      .fold(0.0, (sum, b) => sum + b.totalPrice);

  return BookingStats(
    total: bookings.length,
    pending: pending,
    confirmed: confirmed,
    completed: completed,
    cancelled: cancelled,
    totalRevenue: totalRevenue,
  );
});
