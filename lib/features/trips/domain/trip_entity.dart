class TripEntity {
  final String id;
  final String routeId;
  final String? driverId;
  final String? driverName;
  final DateTime tripDate;
  final String? departureTime;
  final String? returnTime;
  final int availableSeats;
  final TripStatus status;
  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.routeId,
    this.driverId,
    this.driverName,
    required this.tripDate,
    this.departureTime,
    this.returnTime,
    required this.availableSeats,
    required this.status,
    required this.createdAt,
  });

  factory TripEntity.fromJson(Map<String, dynamic> json) {
    return TripEntity(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      tripDate: DateTime.parse(json['trip_date'] as String),
      departureTime: json['departure_time'] as String?,
      returnTime: json['return_time'] as String?,
      availableSeats: json['available_seats'] as int,
      status: TripStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

enum TripStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  static TripStatus fromString(String value) {
    switch (value) {
      case 'scheduled':
        return TripStatus.scheduled;
      case 'in_progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.scheduled;
    }
  }

  String get displayName {
    switch (this) {
      case TripStatus.scheduled:
        return 'مجدول';
      case TripStatus.inProgress:
        return 'جاري';
      case TripStatus.completed:
        return 'مكتمل';
      case TripStatus.cancelled:
        return 'ملغي';
    }
  }
}
