import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_fi_el_sekka/features/payments/domain/payment_entity.dart';

/// Provider for fetching all payments using service key to bypass RLS
final paymentsProvider = FutureProvider<List<PaymentEntity>>((ref) async {
  try {
    debugPrint('💳 Fetching payments from database...');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final serviceKey =
        dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || serviceKey == null) {
      throw Exception('Missing Supabase credentials');
    }

    // Use direct REST API call with service key to bypass RLS
    final response = await http.get(
      Uri.parse(
        '$supabaseUrl/rest/v1/payments?select=*,users(full_name,email,phone)&order=created_at.desc',
      ),
      headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch payments: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    debugPrint('💳 Fetched ${responseList.length} payments');

    final payments = responseList
        .map((json) => PaymentEntity.fromJson(json as Map<String, dynamic>))
        .toList();

    return payments;
  } catch (e, stack) {
    debugPrint('❌ Error fetching payments: $e');
    debugPrint('❌ Stack trace: $stack');
    rethrow;
  }
});

/// Stats for payments
class PaymentStats {
  final int total;
  final int pending;
  final int paid;
  final int failed;
  final int refunded;
  final double totalAmount;
  final double paidAmount;

  const PaymentStats({
    required this.total,
    required this.pending,
    required this.paid,
    required this.failed,
    required this.refunded,
    required this.totalAmount,
    required this.paidAmount,
  });
}

final paymentStatsProvider = FutureProvider<PaymentStats>((ref) async {
  final payments = await ref.watch(paymentsProvider.future);

  final pending = payments
      .where((p) => p.paymentStatus == PaymentTransactionStatus.pending)
      .length;
  final paid = payments
      .where((p) => p.paymentStatus == PaymentTransactionStatus.paid)
      .length;
  final failed = payments
      .where((p) => p.paymentStatus == PaymentTransactionStatus.failed)
      .length;
  final refunded = payments
      .where((p) => p.paymentStatus == PaymentTransactionStatus.refunded)
      .length;

  final totalAmount = payments.fold(0.0, (sum, p) => sum + p.amount);
  final paidAmount = payments
      .where((p) => p.paymentStatus == PaymentTransactionStatus.paid)
      .fold(0.0, (sum, p) => sum + p.amount);

  return PaymentStats(
    total: payments.length,
    pending: pending,
    paid: paid,
    failed: failed,
    refunded: refunded,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
  );
});
