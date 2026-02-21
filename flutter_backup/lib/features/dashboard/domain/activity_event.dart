import 'package:flutter/material.dart';

enum ActivityType { subscription, booking, trip, user }

class ActivityEvent {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.subscription:
        return Icons.card_membership;
      case ActivityType.booking:
        return Icons.book_online;
      case ActivityType.trip:
        return Icons.directions_bus;
      case ActivityType.user:
        return Icons.person_add;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.subscription:
        return const Color(0xFF4CAF50); // Green
      case ActivityType.booking:
        return const Color(0xFFFF9800); // Orange
      case ActivityType.trip:
        return const Color(0xFF9C27B0); // Purple
      case ActivityType.user:
        return const Color(0xFF2196F3); // Blue
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.subscription:
        return 'اشتراك جديد';
      case ActivityType.booking:
        return 'حجز جديد';
      case ActivityType.trip:
        return 'رحلة جديدة';
      case ActivityType.user:
        return 'مستخدم جديد';
    }
  }
}
