import 'package:equatable/equatable.dart';

/// User type enumeration
enum UserType {
  student,
  driver,
  admin;

  String toJson() => name;

  static UserType fromJson(String value) {
    return UserType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => UserType.student,
    );
  }
}

/// User entity - represents a user in the domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String? studentId;
  final String? universityId;
  final UserType userType;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;
  final String? subscriptionType;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String? subscriptionStatus;

  const UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    this.studentId,
    this.universityId,
    required this.userType,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
    this.subscriptionType,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionStatus,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    fullName,
    studentId,
    universityId,
    userType,
    avatarUrl,
    isVerified,
    createdAt,
    subscriptionType,
    subscriptionStartDate,
    subscriptionEndDate,
    subscriptionStatus,
  ];

  /// Check if user is an admin
  bool get isAdmin => userType == UserType.admin;

  /// Check if user has an active subscription
  bool get hasActiveSubscription {
    if (subscriptionStatus != 'active') return false;
    if (subscriptionEndDate == null) return false;
    return subscriptionEndDate!.isAfter(DateTime.now());
  }

  /// Factory from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      studentId: json['student_id'] as String?,
      universityId: json['university_id'] as String?,
      userType: UserType.fromJson(json['user_type'] as String),
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      subscriptionType: json['subscription_type'] as String?,
      subscriptionStartDate: json['subscription_start_date'] != null
          ? DateTime.parse(json['subscription_start_date'] as String)
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
      subscriptionStatus: json['subscription_status'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'student_id': studentId,
      'university_id': universityId,
      'user_type': userType.toJson(),
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'subscription_type': subscriptionType,
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'subscription_status': subscriptionStatus,
    };
  }
}
