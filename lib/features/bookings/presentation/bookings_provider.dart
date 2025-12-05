import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/domain/booking_entity.dart';

/// Provider for fetching all bookings
final bookingsProvider = FutureProvider<List<BookingEntity>>((ref) async {
  final supabase = SupabaseConfig.client;

  try {
    final response = await supabase
        .from('bookings')
        .select('''
          *,
          users!inner(full_name, email)
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      // Merge user data into booking
      final booking = Map<String, dynamic>.from(json);
      booking['user_name'] = json['users']['full_name'];
      booking['user_email'] = json['users']['email'];
      return BookingEntity.fromJson(booking);
    }).toList();
  } catch (e) {
    print('Error fetching bookings: $e');
    rethrow;
  }
});

/// Stats for bookings
class BookingStats {
  final int total;
  final int confirmed;
  final int completed;
  final int cancelled;
  final double totalRevenue;

  const BookingStats({
    required this.total,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.totalRevenue,
  });
}

final bookingStatsProvider = FutureProvider<BookingStats>((ref) async {
  final bookings = await ref.watch(bookingsProvider.future);

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
      .fold(0.0, (sum, b) => sum + b.amount);

  return BookingStats(
    total: bookings.length,
    confirmed: confirmed,
    completed: completed,
    cancelled: cancelled,
    totalRevenue: totalRevenue,
  );
});
