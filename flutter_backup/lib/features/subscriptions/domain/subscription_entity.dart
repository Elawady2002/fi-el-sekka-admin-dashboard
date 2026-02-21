import 'package:equatable/equatable.dart';

enum SubscriptionType {
  monthly,
  semester,
  yearly;

  String get displayName {
    switch (this) {
      case SubscriptionType.monthly:
        return 'شهري';
      case SubscriptionType.semester:
        return 'ترم دراسي';
      case SubscriptionType.yearly:
        return 'سنوي';
    }
  }

  static SubscriptionType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'monthly':
        return SubscriptionType.monthly;
      case 'semester':
        return SubscriptionType.semester;
      case 'yearly':
        return SubscriptionType.yearly;
      default:
        return SubscriptionType.monthly;
    }
  }
}

enum SubscriptionStatus {
  active,
  expired,
  pending;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'نشط';
      case SubscriptionStatus.expired:
        return 'منتهي';
      case SubscriptionStatus.pending:
        return 'قيد الانتظار';
    }
  }

  static SubscriptionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.pending;
    }
  }
}

enum TripType {
  departureOnly,
  returnOnly,
  roundTrip;

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

  static TripType fromString(String? value) {
    switch (value?.toLowerCase()) {
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
}

class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final SubscriptionType type;
  final SubscriptionStatus status;
  final double totalPrice;
  final String? paymentProofUrl;
  final String? transferNumber;
  final DateTime startDate;
  final DateTime endDate;
  final TripType tripType;
  final bool isInstallment;
  final bool allowLocationChange;
  final double? interestRate;
  final DateTime createdAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.type,
    required this.status,
    required this.totalPrice,
    this.paymentProofUrl,
    this.transferNumber,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    required this.isInstallment,
    required this.allowLocationChange,
    this.interestRate,
    required this.createdAt,
  });

  factory SubscriptionEntity.fromJson(Map<String, dynamic> json) {
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
    final startDate = parseDate(json['start_date'], now);

    // Calculate end date based on plan type if not provided
    DateTime endDate;
    if (json['end_date'] != null) {
      endDate = parseDate(
        json['end_date'],
        startDate.add(const Duration(days: 30)),
      );
    } else {
      final planType = SubscriptionType.fromString(
        json['plan_type'] as String?,
      );
      switch (planType) {
        case SubscriptionType.monthly:
          endDate = startDate.add(const Duration(days: 30));
        case SubscriptionType.semester:
          endDate = startDate.add(const Duration(days: 120));
        case SubscriptionType.yearly:
          endDate = startDate.add(const Duration(days: 365));
      }
    }

    return SubscriptionEntity(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['users']?['full_name'] as String? ?? 'غير معروف',
      userEmail: json['users']?['email'] as String? ?? '',
      userPhone: json['users']?['phone'] as String?,
      type: SubscriptionType.fromString(json['plan_type'] as String?),
      status: SubscriptionStatus.fromString(json['status'] as String?),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentProofUrl: json['payment_proof_url'] as String?,
      transferNumber: json['transfer_number'] as String?,
      startDate: startDate,
      endDate: endDate,
      tripType: TripType.fromString(json['trip_type'] as String?),
      isInstallment: json['is_installment'] as bool? ?? false,
      allowLocationChange: json['allow_location_change'] as bool? ?? false,
      interestRate: (json['interest_rate'] as num?)?.toDouble(),
      createdAt: parseDate(json['created_at'], now),
    );
  }

  // Check if subscription is active based on status and dates
  bool get isActive {
    if (status != SubscriptionStatus.active) return false;
    final now = DateTime.now();
    return now.isBefore(endDate) || now.isAtSameMomentAs(endDate);
  }

  bool get isExpired => !isActive && status != SubscriptionStatus.pending;

  bool get isPending => status == SubscriptionStatus.pending;

  int get daysRemaining {
    if (!isActive) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inDays.clamp(0, 365);
  }

  // Legacy getter for backwards compatibility
  double get amount => totalPrice;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userPhone,
    type,
    status,
    totalPrice,
    paymentProofUrl,
    transferNumber,
    startDate,
    endDate,
    tripType,
    isInstallment,
    allowLocationChange,
    interestRate,
    createdAt,
  ];
}
