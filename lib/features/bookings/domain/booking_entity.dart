import 'package:equatable/equatable.dart';

enum BookingTripType {
  departureOnly,
  returnOnly,
  roundTrip;

  static BookingTripType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'departure_only':
        return BookingTripType.departureOnly;
      case 'return_only':
        return BookingTripType.returnOnly;
      case 'round_trip':
        return BookingTripType.roundTrip;
      default:
        return BookingTripType.roundTrip;
    }
  }

  String get displayName {
    switch (this) {
      case BookingTripType.departureOnly:
        return 'ذهاب فقط';
      case BookingTripType.returnOnly:
        return 'عودة فقط';
      case BookingTripType.roundTrip:
        return 'ذهاب وعودة';
    }
  }

  String get dbValue {
    switch (this) {
      case BookingTripType.departureOnly:
        return 'departure_only';
      case BookingTripType.returnOnly:
        return 'return_only';
      case BookingTripType.roundTrip:
        return 'round_trip';
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static BookingStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.completed:
        return 'مكتمل';
    }
  }
}

enum PaymentStatus {
  unpaid,
  paid,
  refunded;

  static PaymentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unpaid;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.refunded:
        return 'مسترد';
    }
  }
}

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String? scheduleId;
  final String? subscriptionId;
  final DateTime bookingDate;
  final BookingTripType tripType;
  final String? pickupStationId;
  final String? dropoffStationId;
  final String? pickupStationName;
  final String? dropoffStationName;
  final String? departureTime;
  final String? returnTime;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.scheduleId,
    this.subscriptionId,
    required this.bookingDate,
    required this.tripType,
    this.pickupStationId,
    this.dropoffStationId,
    this.pickupStationName,
    this.dropoffStationName,
    this.departureTime,
    this.returnTime,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingEntity.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return fallback;
      }
    }

    final now = DateTime.now();

    return BookingEntity(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName:
          json['user_name'] as String? ??
          json['users']?['full_name'] as String? ??
          'غير معروف',
      userEmail:
          json['user_email'] as String? ??
          json['users']?['email'] as String? ??
          '',
      userPhone: json['users']?['phone'] as String?,
      scheduleId: json['schedule_id'] as String?,
      subscriptionId: json['subscription_id'] as String?,
      bookingDate: parseDate(json['booking_date'], now),
      tripType: BookingTripType.fromString(json['trip_type'] as String?),
      pickupStationId: json['pickup_station_id'] as String?,
      dropoffStationId: json['dropoff_station_id'] as String?,
      pickupStationName: json['pickup_station']?['name_ar'] as String?,
      dropoffStationName: json['dropoff_station']?['name_ar'] as String?,
      departureTime: json['departure_time'] as String?,
      returnTime: json['return_time'] as String?,
      status: BookingStatus.fromString(json['status'] as String?),
      paymentStatus: PaymentStatus.fromString(
        json['payment_status'] as String?,
      ),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDate(json['created_at'], now),
      updatedAt: json['updated_at'] != null
          ? parseDate(json['updated_at'], now)
          : null,
    );
  }

  // Legacy getter for backwards compatibility
  double get amount => totalPrice;

  // Check if this booking is from a subscription
  bool get isSubscriptionBooking => subscriptionId != null;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userPhone,
    scheduleId,
    subscriptionId,
    bookingDate,
    tripType,
    pickupStationId,
    dropoffStationId,
    pickupStationName,
    dropoffStationName,
    departureTime,
    returnTime,
    status,
    paymentStatus,
    totalPrice,
    createdAt,
    updatedAt,
  ];
}

// Keep old TripType for backwards compatibility
typedef TripType = BookingTripType;
