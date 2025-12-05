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
}

class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final SubscriptionType type;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final bool isInstallment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.isInstallment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionEntity.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['users']?['full_name'] as String? ?? 'Unknown',
      userEmail: json['users']?['email'] as String? ?? '',
      type: _parseSubscriptionType(json['type'] as String?),
      status: _parseSubscriptionStatus(json['status'] as String?),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isInstallment: json['is_installment'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static SubscriptionType _parseSubscriptionType(String? type) {
    switch (type?.toLowerCase()) {
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

  static SubscriptionStatus _parseSubscriptionStatus(String? status) {
    switch (status?.toLowerCase()) {
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

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;

  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    type,
    status,
    startDate,
    endDate,
    amount,
    isInstallment,
    createdAt,
    updatedAt,
  ];
}
