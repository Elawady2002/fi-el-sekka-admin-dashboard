import 'package:equatable/equatable.dart';

enum PaymentMethod {
  cash,
  instapay,
  vodafoneCash,
  wallet;

  static PaymentMethod fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'instapay':
        return PaymentMethod.instapay;
      case 'vodafone_cash':
        return PaymentMethod.vodafoneCash;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.cash;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'كاش';
      case PaymentMethod.instapay:
        return 'انستاباي';
      case PaymentMethod.vodafoneCash:
        return 'فودافون كاش';
      case PaymentMethod.wallet:
        return 'محفظة';
    }
  }
}

enum PaymentTransactionStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentTransactionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return PaymentTransactionStatus.pending;
      case 'paid':
        return PaymentTransactionStatus.paid;
      case 'failed':
        return PaymentTransactionStatus.failed;
      case 'refunded':
        return PaymentTransactionStatus.refunded;
      default:
        return PaymentTransactionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentTransactionStatus.pending:
        return 'قيد الانتظار';
      case PaymentTransactionStatus.paid:
        return 'مدفوع';
      case PaymentTransactionStatus.failed:
        return 'فشل';
      case PaymentTransactionStatus.refunded:
        return 'مسترد';
    }
  }
}

/// Payment entity matching the payments table
class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? bookingId;
  final String? subscriptionId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentTransactionStatus paymentStatus;
  final String? transactionId;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.bookingId,
    this.subscriptionId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    required this.createdAt,
  });

  factory PaymentEntity.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return fallback;
      }
    }

    return PaymentEntity(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['users']?['full_name'] as String?,
      userEmail: json['users']?['email'] as String?,
      userPhone: json['users']?['phone'] as String?,
      bookingId: json['booking_id'] as String?,
      subscriptionId: json['subscription_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.fromString(
        json['payment_method'] as String?,
      ),
      paymentStatus: PaymentTransactionStatus.fromString(
        json['payment_status'] as String?,
      ),
      transactionId: json['transaction_id'] as String?,
      createdAt: parseDate(json['created_at'], DateTime.now()),
    );
  }

  // Check if payment is for a booking or subscription
  bool get isForBooking => bookingId != null;
  bool get isForSubscription => subscriptionId != null;

  String get paymentType {
    if (isForSubscription) return 'اشتراك';
    if (isForBooking) return 'حجز';
    return 'غير محدد';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userPhone,
    bookingId,
    subscriptionId,
    amount,
    paymentMethod,
    paymentStatus,
    transactionId,
    createdAt,
  ];
}
