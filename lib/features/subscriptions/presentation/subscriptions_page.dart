import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/presentation/subscriptions_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/data/subscription_actions.dart';
import 'package:data_table_2/data_table_2.dart';

class SubscriptionsPage extends ConsumerStatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage> {
  String _searchQuery = '';
  SubscriptionType? _selectedType;
  SubscriptionStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final statsAsync = ref.watch(subscriptionStatsProvider);

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
                'الاشتراكات',
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
                      'إدارة الاشتراكات',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض وإدارة جميع اشتراكات الطلاب',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('قريباً - إضافة اشتراك جديد')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة اشتراك'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          statsAsync.when(
            data: (stats) => _buildStatsCards(context, stats),
            loading: () => const SizedBox(height: 120),
            error: (_, _) => const SizedBox(height: 120),
          ),

          const SizedBox(height: 24),

          // Filters & Actions Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو البريد الإلكتروني...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
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
                  child: DropdownButtonFormField<SubscriptionType?>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'نوع الاشتراك',
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
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
                        value: SubscriptionType.monthly,
                        child: Text('شهري'),
                      ),
                      DropdownMenuItem(
                        value: SubscriptionType.semester,
                        child: Text('ترم دراسي'),
                      ),
                      DropdownMenuItem(
                        value: SubscriptionType.yearly,
                        child: Text('سنوي'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<SubscriptionStatus?>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
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
                        value: SubscriptionStatus.active,
                        child: Text('نشط'),
                      ),
                      DropdownMenuItem(
                        value: SubscriptionStatus.expired,
                        child: Text('منتهي'),
                      ),
                      DropdownMenuItem(
                        value: SubscriptionStatus.pending,
                        child: Text('قيد الانتظار'),
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
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: subscriptionsAsync.when(
                  data: (subscriptions) {
                    // Apply filters
                    var filteredSubs = subscriptions.where((sub) {
                      final matchesSearch =
                          sub.userName.toLowerCase().contains(_searchQuery) ||
                          sub.userEmail.toLowerCase().contains(_searchQuery);
                      final matchesType =
                          _selectedType == null || sub.type == _selectedType;
                      final matchesStatus =
                          _selectedStatus == null ||
                          sub.status == _selectedStatus;
                      return matchesSearch && matchesType && matchesStatus;
                    }).toList();

                    if (filteredSubs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_membership_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد اشتراكات',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return DataTable2(
                      columnSpacing: 24,
                      horizontalMargin: 24,
                      minWidth: 1000,
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.surfaceDarkLighter,
                      ),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      columns: const [
                        DataColumn2(
                          label: Text(
                            'المستخدم',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Text(
                            'النوع',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            'الحالة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            'تاريخ البدء',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            'تاريخ الانتهاء',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            'المبلغ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            'إجراءات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: filteredSubs.map((sub) {
                        return DataRow2(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    sub.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    sub.userEmail,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            DataCell(_buildTypeBadge(context, sub.type)),
                            DataCell(_buildStatusBadge(context, sub.status)),
                            DataCell(
                              Text(
                                '${sub.startDate.year}-${sub.startDate.month.toString().padLeft(2, '0')}-${sub.startDate.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '${sub.endDate.year}-${sub.endDate.month.toString().padLeft(2, '0')}-${sub.endDate.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                            DataCell(
                              Text('${sub.amount.toStringAsFixed(0)} ج.م'),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    tooltip: 'عرض التفاصيل',
                                    onPressed: () {
                                      _showSubscriptionDetails(context, sub);
                                    },
                                  ),
                                  if (sub.status ==
                                      SubscriptionStatus.pending) ...[
                                    IconButton(
                                      icon: Icon(
                                        Icons.check_circle_outline,
                                        size: 20,
                                        color: AppTheme.accentGreen,
                                      ),
                                      tooltip: 'موافقة',
                                      onPressed: () =>
                                          _approveSubscription(context, sub),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        size: 20,
                                        color: Colors.red.shade400,
                                      ),
                                      tooltip: 'رفض',
                                      onPressed: () =>
                                          _rejectSubscription(context, sub),
                                    ),
                                  ] else if (sub.status ==
                                      SubscriptionStatus.active)
                                    IconButton(
                                      icon: Icon(
                                        Icons.block,
                                        size: 20,
                                        color: Colors.orange.shade400,
                                      ),
                                      tooltip: 'إلغاء الاشتراك',
                                      onPressed: () =>
                                          _cancelSubscription(context, sub),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ في تحميل الاشتراكات',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.invalidate(subscriptionsProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, SubscriptionStats stats) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي الاشتراكات',
              value: stats.total.toString(),
              icon: Icons.card_membership,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الاشتراكات النشطة',
              value: stats.active.toString(),
              icon: Icons.check_circle,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الاشتراكات المنتهية',
              value: stats.expired.toString(),
              icon: Icons.cancel,
              color: const Color(0xFFEF5350),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الإيرادات الشهرية',
              value: '${stats.monthlyRevenue.toStringAsFixed(0)} ج.م',
              icon: Icons.attach_money,
              color: const Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, SubscriptionType type) {
    Color color;
    switch (type) {
      case SubscriptionType.monthly:
        color = const Color(0xFF2196F3);
        break;
      case SubscriptionType.semester:
        color = const Color(0xFFFF9800);
        break;
      case SubscriptionType.yearly:
        color = const Color(0xFF9C27B0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, SubscriptionStatus status) {
    Color color;
    switch (status) {
      case SubscriptionStatus.active:
        color = const Color(0xFF4CAF50);
        break;
      case SubscriptionStatus.expired:
        color = const Color(0xFFEF5350);
        break;
      case SubscriptionStatus.pending:
        color = const Color(0xFFFF9800);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSubscriptionDetails(BuildContext context, SubscriptionEntity sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الاشتراك'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('المستخدم', sub.userName),
              _buildDetailRow('البريد الإلكتروني', sub.userEmail),
              _buildDetailRow('نوع الاشتراك', sub.type.displayName),
              _buildDetailRow('الحالة', sub.status.displayName),
              _buildDetailRow(
                'تاريخ البدء',
                '${sub.startDate.year}-${sub.startDate.month.toString().padLeft(2, '0')}-${sub.startDate.day.toString().padLeft(2, '0')}',
              ),
              _buildDetailRow(
                'تاريخ الانتهاء',
                '${sub.endDate.year}-${sub.endDate.month.toString().padLeft(2, '0')}-${sub.endDate.day.toString().padLeft(2, '0')}',
              ),
              _buildDetailRow('المبلغ', '${sub.amount.toStringAsFixed(2)} ج.م'),
              _buildDetailRow('أقساط', sub.isInstallment ? 'نعم' : 'لا'),
              if (sub.isActive)
                _buildDetailRow('الأيام المتبقية', '${sub.daysRemaining} يوم'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Approve a pending subscription
  Future<void> _approveSubscription(
    BuildContext context,
    SubscriptionEntity sub,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد الموافقة على اشتراك ${sub.userName}؟'),
            const SizedBox(height: 16),
            Text('نوع الاشتراك: ${sub.type.displayName}'),
            Text('المبلغ: ${sub.amount.toStringAsFixed(0)} ج.م'),
            if (sub.paymentProofUrl != null) ...[
              const SizedBox(height: 16),
              const Text(
                'إثبات الدفع:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    sub.paymentProofUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Text('تعذر تحميل الصورة')),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SubscriptionActions.approveSubscription(sub.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الموافقة على الاشتراك بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(subscriptionsProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء الموافقة على الاشتراك'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Reject a pending subscription
  Future<void> _rejectSubscription(
    BuildContext context,
    SubscriptionEntity sub,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد رفض اشتراك ${sub.userName}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'سبب الرفض (اختياري)',
                hintText: 'أدخل سبب الرفض...',
                filled: true,
                fillColor: AppTheme.surfaceDarkLighter,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SubscriptionActions.rejectSubscription(
        sub.id,
        reason: reasonController.text.isNotEmpty ? reasonController.text : null,
      );
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض الاشتراك'),
              backgroundColor: Colors.orange,
            ),
          );
          ref.invalidate(subscriptionsProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء رفض الاشتراك'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Cancel an active subscription
  Future<void> _cancelSubscription(
    BuildContext context,
    SubscriptionEntity sub,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إلغاء الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد إلغاء اشتراك ${sub.userName}؟'),
            const SizedBox(height: 8),
            Text(
              'هذا الإجراء سيلغي الاشتراك فوراً',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SubscriptionActions.cancelSubscription(sub.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الاشتراك بنجاح'),
              backgroundColor: Colors.orange,
            ),
          );
          ref.invalidate(subscriptionsProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء إلغاء الاشتراك'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
