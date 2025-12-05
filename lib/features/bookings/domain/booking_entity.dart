class BookingEntity {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String scheduleId;
  final TripType tripType;
  final String? departureTime;
  final String? returnTime;
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> dropoffLocation;
  final BookingStatus status;
  final double amount;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.scheduleId,
    required this.tripType,
    this.departureTime,
    this.returnTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory BookingEntity.fromJson(Map<String, dynamic> json) {
    return BookingEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'غير معروف',
      userEmail: json['user_email'] as String? ?? '',
      scheduleId: json['schedule_id'] as String,
      tripType: TripType.fromString(json['trip_type'] as String),
      departureTime: json['departure_time'] as String?,
      returnTime: json['return_time'] as String?,
      pickupLocation: json['pickup_location'] as Map<String, dynamic>,
      dropoffLocation: json['dropoff_location'] as Map<String, dynamic>,
      status: BookingStatus.fromString(json['status'] as String),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

enum TripType {
  departureOnly,
  returnOnly,
  roundTrip;

  static TripType fromString(String value) {
    switch (value) {
      case 'departure_only':
        return TripType.departureOnly;
      case 'return_only':
        return TripType.returnOnly;
      case 'round_trip':
        return TripType.roundTrip;
      default:
        return TripType.roundTrip;
    }
  }

  String get displayName {
    switch (this) {
      case TripType.departureOnly:
        return 'ذهاب فقط';
      case TripType.returnOnly:
        return 'عودة فقط';
      case TripType.roundTrip:
        return 'ذهاب وعودة';
    }
  }
}

enum BookingStatus {
  confirmed,
  cancelled,
  completed;

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.confirmed;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.completed:
        return 'مكتمل';
    }
  }
}
