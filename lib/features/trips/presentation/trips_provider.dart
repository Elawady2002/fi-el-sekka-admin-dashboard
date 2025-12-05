import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/trips/domain/trip_entity.dart';

/// Provider for fetching all trips/schedules
final tripsProvider = FutureProvider<List<TripEntity>>((ref) async {
  final supabase = SupabaseConfig.client;

  try {
    final response = await supabase
        .from('schedules')
        .select('''
          *,
          users!schedules_driver_id_fkey(full_name)
        ''')
        .order('trip_date', ascending: false);

    return (response as List).map((json) {
      // Merge driver data into trip
      final trip = Map<String, dynamic>.from(json);
      if (json['users'] != null) {
        trip['driver_name'] = json['users']['full_name'];
      }
      return TripEntity.fromJson(trip);
    }).toList();
  } catch (e) {
    debugPrint('Error fetching trips: $e');
    rethrow;
  }
});

/// Stats for trips
class TripStats {
  final int total;
  final int scheduled;
  final int inProgress;
  final int completed;
  final int todayTrips;

  const TripStats({
    required this.total,
    required this.scheduled,
    required this.inProgress,
    required this.completed,
    required this.todayTrips,
  });
}

final tripStatsProvider = FutureProvider<TripStats>((ref) async {
  final trips = await ref.watch(tripsProvider.future);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  final scheduled = trips.where((t) => t.status == TripStatus.scheduled).length;
  final inProgress = trips
      .where((t) => t.status == TripStatus.inProgress)
      .length;
  final completed = trips.where((t) => t.status == TripStatus.completed).length;
  final todayTrips = trips.where((t) {
    return t.tripDate.isAfter(todayStart) && t.tripDate.isBefore(todayEnd);
  }).length;

  return TripStats(
    total: trips.length,
    scheduled: scheduled,
    inProgress: inProgress,
    completed: completed,
    todayTrips: todayTrips,
  );
});
