import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dashboard_fi_el_sekka/features/payments/presentation/payments_provider.dart';
import 'package:dashboard_fi_el_sekka/features/payments/domain/payment_entity.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  String _searchQuery = '';
  PaymentTransactionStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final statsAsync = ref.watch(paymentStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Row(
            children: [
              Text(
                'لوحة التحكم',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
              Text(
                'المدفوعات',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة المدفوعات',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض ومتابعة جميع المدفوعات والمعاملات المالية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          statsAsync.when(
            data: (stats) => _buildStatsCards(context, stats),
            loading: () => const SizedBox(height: 100),
            error: (_, _) => const SizedBox(height: 100),
          ),

          const SizedBox(height: 24),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو رقم المعاملة...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: AppTheme.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PaymentTransactionStatus?>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      filled: true,
                      fillColor: AppTheme.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('الكل')),
                      DropdownMenuItem(
                        value: PaymentTransactionStatus.pending,
                        child: Text('قيد الانتظار'),
                      ),
                      DropdownMenuItem(
                        value: PaymentTransactionStatus.paid,
                        child: Text('مدفوع'),
                      ),
                      DropdownMenuItem(
                        value: PaymentTransactionStatus.failed,
                        child: Text('فشل'),
                      ),
                      DropdownMenuItem(
                        value: PaymentTransactionStatus.refunded,
                        child: Text('مسترد'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: paymentsAsync.when(
                  data: (payments) {
                    // Apply filters
                    var filteredPayments = payments.where((payment) {
                      final matchesSearch =
                          (payment.userName?.toLowerCase().contains(
                                _searchQuery,
                              ) ??
                              false) ||
                          (payment.transactionId?.toLowerCase().contains(
                                _searchQuery,
                              ) ??
                              false);
                      final matchesStatus =
                          _selectedStatus == null ||
                          payment.paymentStatus == _selectedStatus;
                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredPayments.isEmpty) {
                      return _EmptyState(
                        icon: Icons.payments_outlined,
                        message: 'لا توجد مدفوعات',
                      );
                    }

                    return DataTable2(
                      columnSpacing: 24,
                      horizontalMargin: 24,
                      minWidth: 1200,
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.backgroundLight,
                      ),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                      columns: const [
                        DataColumn2(label: Text('التاريخ')),
                        DataColumn2(label: Text('المستخدم')),
                        DataColumn2(label: Text('المبلغ')),
                        DataColumn2(label: Text('طريقة الدفع')),
                        DataColumn2(label: Text('النوع')),
                        DataColumn2(label: Text('رقم المعاملة')),
                        DataColumn2(label: Text('الحالة'), size: ColumnSize.S),
                      ],
                      rows: filteredPayments.map((payment) {
                        return DataRow2(
                          cells: [
                            DataCell(
                              Text(
                                _formatDate(payment.createdAt),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    payment.userName ?? 'غير معروف',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (payment.userEmail != null)
                                    Text(
                                      payment.userEmail!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                '${payment.amount.toStringAsFixed(0)} ج.م',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                            ),
                            DataCell(
                              _PaymentMethodBadge(
                                method: payment.paymentMethod,
                              ),
                            ),
                            DataCell(Text(payment.paymentType)),
                            DataCell(Text(payment.transactionId ?? '-')),
                            DataCell(
                              _PaymentStatusBadge(
                                status: payment.paymentStatus,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _ErrorState(error: error.toString()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, PaymentStats stats) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي المدفوعات',
              value: '${stats.total}',
              icon: Icons.payments,
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'المدفوع',
              value: '${stats.paidAmount.toStringAsFixed(0)} ج.م',
              icon: Icons.check_circle,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'قيد الانتظار',
              value: '${stats.pending}',
              icon: Icons.pending,
              color: AppTheme.accentOrange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'المسترد',
              value: '${stats.refunded}',
              icon: Icons.refresh,
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Stats Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Method Badge
class _PaymentMethodBadge extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentMethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (method) {
      case PaymentMethod.cash:
        color = AppTheme.accentGreen;
        icon = Icons.money;
      case PaymentMethod.instapay:
        color = AppTheme.accentBlue;
        icon = Icons.phone_android;
      case PaymentMethod.vodafoneCash:
        color = AppTheme.accentRed;
        icon = Icons.phone_android;
      case PaymentMethod.wallet:
        color = AppTheme.primaryPurple;
        icon = Icons.account_balance_wallet;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            method.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Status Badge
class _PaymentStatusBadge extends StatelessWidget {
  final PaymentTransactionStatus status;

  const _PaymentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case PaymentTransactionStatus.pending:
        color = AppTheme.accentOrange;
      case PaymentTransactionStatus.paid:
        color = AppTheme.accentGreen;
      case PaymentTransactionStatus.failed:
        color = AppTheme.accentRed;
      case PaymentTransactionStatus.refunded:
        color = AppTheme.primaryPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Error State
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.accentRed.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
