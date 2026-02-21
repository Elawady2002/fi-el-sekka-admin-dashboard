import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Subscription Actions - Functions to manage subscriptions
class SubscriptionActions {
  static String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get _serviceKey =>
      dotenv.env['SUPABASE_SERVICE_KEY'] ??
      dotenv.env['SUPABASE_ANON_KEY'] ??
      '';

  static Map<String, String> get _headers => {
    'apikey': _serviceKey,
    'Authorization': 'Bearer $_serviceKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  /// Approve a pending subscription - changes status to 'active'
  static Future<bool> approveSubscription(String subscriptionId) async {
    try {
      debugPrint('✅ Approving subscription: $subscriptionId');

      final now = DateTime.now();

      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/subscriptions?id=eq.$subscriptionId'),
        headers: _headers,
        body: json.encode({
          'status': 'active',
          'start_date': now.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Subscription approved successfully');
        return true;
      } else {
        debugPrint('❌ Failed to approve subscription: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error approving subscription: $e');
      return false;
    }
  }

  /// Reject a subscription - changes status to 'expired' with rejection reason
  static Future<bool> rejectSubscription(
    String subscriptionId, {
    String? reason,
  }) async {
    try {
      debugPrint('❌ Rejecting subscription: $subscriptionId');

      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/subscriptions?id=eq.$subscriptionId'),
        headers: _headers,
        body: json.encode({'status': 'expired'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Subscription rejected successfully');
        return true;
      } else {
        debugPrint('❌ Failed to reject subscription: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error rejecting subscription: $e');
      return false;
    }
  }

  /// Cancel an active subscription
  static Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      debugPrint('🚫 Cancelling subscription: $subscriptionId');

      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/subscriptions?id=eq.$subscriptionId'),
        headers: _headers,
        body: json.encode({
          'status': 'expired',
          'end_date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Subscription cancelled successfully');
        return true;
      } else {
        debugPrint('❌ Failed to cancel subscription: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error cancelling subscription: $e');
      return false;
    }
  }

  /// Create a new subscription for a user
  static Future<bool> createSubscription({
    required String userId,
    required String planType, // 'monthly', 'semester', 'yearly'
    required String tripType, // 'departure_only', 'return_only', 'round_trip'
    required double totalPrice,
    bool isInstallment = false,
    bool allowLocationChange = false,
    String status = 'active', // Create as active if admin creates it
  }) async {
    try {
      debugPrint('📝 Creating subscription for user: $userId');

      final now = DateTime.now();
      DateTime endDate;

      // Calculate end date based on plan type
      switch (planType) {
        case 'monthly':
          endDate = now.add(const Duration(days: 30));
          break;
        case 'semester':
          endDate = now.add(const Duration(days: 120));
          break;
        case 'yearly':
          endDate = now.add(const Duration(days: 365));
          break;
        default:
          endDate = now.add(const Duration(days: 30));
      }

      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/subscriptions'),
        headers: _headers,
        body: json.encode({
          'user_id': userId,
          'plan_type': planType,
          'trip_type': tripType,
          'total_price': totalPrice,
          'status': status,
          'start_date': now.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'is_installment': isInstallment,
          'allow_location_change': allowLocationChange,
          'created_at': now.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Subscription created successfully');
        return true;
      } else {
        debugPrint('❌ Failed to create subscription: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error creating subscription: $e');
      return false;
    }
  }

  /// Get subscriptions for a specific user
  static Future<List<Map<String, dynamic>>> getUserSubscriptions(
    String userId,
  ) async {
    try {
      debugPrint('📦 Fetching subscriptions for user: $userId');

      final response = await http.get(
        Uri.parse(
          '$_supabaseUrl/rest/v1/subscriptions?user_id=eq.$userId&order=created_at.desc',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        debugPrint('📦 Fetched ${data.length} subscriptions for user');
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ Failed to fetch user subscriptions: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching user subscriptions: $e');
      return [];
    }
  }
}
