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

    final headers = {
      'apikey': serviceKey,
      'Authorization': 'Bearer $serviceKey',
      'Content-Type': 'application/json',
    };

    // Fetch bookings with user info
    final bookingsResponse = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/bookings?select=*,users(full_name,email,phone)&order=created_at.desc',
      ),
      headers: headers,
    );

    if (bookingsResponse.statusCode != 200) {
      throw Exception('Failed to fetch bookings: ${bookingsResponse.body}');
    }

    // Fetch all stations to map IDs to names
    final stationsResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/stations?select=id,name_ar,name_en'),
      headers: headers,
    );

    Map<String, Map<String, String>> stationsMap = {};
    if (stationsResponse.statusCode == 200) {
      final stationsList = json.decode(stationsResponse.body) as List? ?? [];
      for (final station in stationsList) {
        stationsMap[station['id'] as String] = {
          'name_ar': station['name_ar'] as String? ?? '',
          'name_en': station['name_en'] as String? ?? '',
        };
      }
      debugPrint('📍 Loaded ${stationsMap.length} stations');
    }

    // Fetch schedules to get route_id
    final schedulesResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/schedules?select=id,route_id'),
      headers: headers,
    );

    Map<String, String> scheduleToRouteMap = {};
    if (schedulesResponse.statusCode == 200) {
      final schedulesList = json.decode(schedulesResponse.body) as List? ?? [];
      for (final schedule in schedulesList) {
        final id = schedule['id'] as String?;
        final routeId = schedule['route_id'] as String?;
        if (id != null && routeId != null) {
          scheduleToRouteMap[id] = routeId;
        }
      }
      debugPrint('📅 Loaded ${scheduleToRouteMap.length} schedules');
    }

    // Fetch routes to get route names
    final routesResponse = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/routes?select=id,route_name_ar,route_name_en',
      ),
      headers: headers,
    );

    Map<String, String> routesMap = {};
    if (routesResponse.statusCode == 200) {
      final routesList = json.decode(routesResponse.body) as List? ?? [];
      for (final route in routesList) {
        final id = route['id'] as String?;
        final nameAr = route['route_name_ar'] as String?;
        final nameEn = route['route_name_en'] as String?;
        if (id != null) {
          routesMap[id] = nameAr ?? nameEn ?? 'مسار غير معروف';
        }
      }
      debugPrint('🚌 Loaded ${routesMap.length} routes');
    }

    final responseList = json.decode(bookingsResponse.body) as List? ?? [];
    debugPrint('📦 Fetched ${responseList.length} bookings');

    final bookings = responseList.map((json) {
      final booking = Map<String, dynamic>.from(json as Map<String, dynamic>);
      booking['user_name'] = json['users']?['full_name'];
      booking['user_email'] = json['users']?['email'];

      // Map station IDs to station names
      final pickupId = json['pickup_station_id'] as String?;
      final dropoffId = json['dropoff_station_id'] as String?;

      if (pickupId != null && stationsMap.containsKey(pickupId)) {
        booking['pickup_station'] = stationsMap[pickupId];
      }
      if (dropoffId != null && stationsMap.containsKey(dropoffId)) {
        booking['dropoff_station'] = stationsMap[dropoffId];
      }

      // Map schedule_id to route_name
      final scheduleId = json['schedule_id'] as String?;
      if (scheduleId != null && scheduleToRouteMap.containsKey(scheduleId)) {
        final routeId = scheduleToRouteMap[scheduleId];
        if (routeId != null && routesMap.containsKey(routeId)) {
          booking['route_name'] = routesMap[routeId];
        }
      }

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

/// Provider for selected date in calendar
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider for bookings grouped by date (for calendar markers)
final bookingsByDateProvider = Provider<Map<DateTime, List<BookingEntity>>>((
  ref,
) {
  final bookingsAsync = ref.watch(bookingsProvider);
  return bookingsAsync.when(
    data: (bookings) {
      final map = <DateTime, List<BookingEntity>>{};
      for (final booking in bookings) {
        final date = DateTime(
          booking.bookingDate.year,
          booking.bookingDate.month,
          booking.bookingDate.day,
        );
        map.putIfAbsent(date, () => []).add(booking);
      }
      return map;
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Provider for route-grouped bookings for selected date
final routeGroupedBookingsProvider = Provider<Map<String, List<BookingEntity>>>((
  ref,
) {
  final selectedDate = ref.watch(selectedDateProvider);
  final bookingsByDate = ref.watch(bookingsByDateProvider);

  final normalizedDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final dayBookings = bookingsByDate[normalizedDate] ?? [];

  // Group by route name (from schedule -> route)
  final grouped = <String, List<BookingEntity>>{};
  for (final booking in dayBookings) {
    // Use routeName if available, otherwise use station names, otherwise "مسار غير محدد"
    String routeKey;
    if (booking.routeName != null && booking.routeName!.isNotEmpty) {
      routeKey = booking.routeName!;
    } else if (booking.pickupStationName != null ||
        booking.dropoffStationName != null) {
      routeKey =
          '${booking.pickupStationName ?? "غير محدد"} → ${booking.dropoffStationName ?? "غير محدد"}';
    } else {
      routeKey = 'مسار غير محدد';
    }
    grouped.putIfAbsent(routeKey, () => []).add(booking);
  }

  return grouped;
});

/// Provider for bookings count on a specific date
int getBookingsCountForDate(
  DateTime date,
  Map<DateTime, List<BookingEntity>> bookingsByDate,
) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  return bookingsByDate[normalizedDate]?.length ?? 0;
}
