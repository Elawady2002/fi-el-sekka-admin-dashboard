import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_stats_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/presentation/subscriptions_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final userName = authState.user?.fullName ?? 'Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _WelcomeHeader(userName: userName),
          const SizedBox(height: 24),

          // Stats Cards
          statsAsync.when(
            data: (stats) => _StatsRow(stats: stats),
            loading: () => const _StatsRowLoading(),
            error: (_, _) => const SizedBox(height: 100),
          ),
          const SizedBox(height: 24),

          // Active Subscribers Section
          Text(
            'المشتركين النشطين',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          subscriptionsAsync.when(
            data: (subscriptions) {
              final activeSubscriptions = subscriptions
                  .where((s) => s.isActive)
                  .toList();

              if (activeSubscriptions.isEmpty) {
                return _EmptyState(
                  icon: Icons.person_off_outlined,
                  message: 'لا يوجد مشتركين نشطين حالياً',
                );
              }

              return _SubscribersTable(subscriptions: activeSubscriptions);
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => _EmptyState(
              icon: Icons.error_outline,
              message: 'حدث خطأ في تحميل البيانات',
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.person_add_rounded,
                  title: 'إدارة المستخدمين',
                  subtitle: 'عرض وإدارة جميع المستخدمين',
                  color: AppTheme.accentBlue,
                  onTap: () => context.go('/users'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.card_membership_rounded,
                  title: 'إدارة الاشتراكات',
                  subtitle: 'عرض جميع الاشتراكات والخطط',
                  color: AppTheme.primaryPurple,
                  onTap: () => context.go('/subscriptions'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.directions_bus_rounded,
                  title: 'إدارة الرحلات',
                  subtitle: 'جدولة الرحلات والمسارات',
                  color: AppTheme.accentOrange,
                  onTap: () => context.go('/trips'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.book_online_rounded,
                  title: 'إدارة الحجوزات',
                  subtitle: 'عرض ومتابعة الحجوزات',
                  color: AppTheme.accentGreen,
                  onTap: () => context.go('/bookings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Welcome Header
class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'نظرة عامة على نظام في السكة',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${now.day}/${now.month}/${now.year}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }
}

// Stats Row
class _StatsRow extends StatelessWidget {
  final DashboardStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Row - 3 cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'المستخدمين',
                value: '${stats.totalUsers}',
                icon: Icons.people_rounded,
                color: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'الاشتراكات النشطة',
                value: '${stats.activeSubscriptions}',
                icon: Icons.card_membership_rounded,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'إجمالي الحجوزات',
                value: '${stats.totalBookings}',
                icon: Icons.book_online_rounded,
                color: AppTheme.chartBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second Row - 2 cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'رحلات اليوم',
                value: '${stats.todaysTrips}',
                icon: Icons.directions_bus_rounded,
                color: AppTheme.accentOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'الإيرادات الشهرية',
                value: '${stats.monthlyRevenue.toStringAsFixed(0)} ج.م',
                icon: Icons.payments_rounded,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 16),
            // Empty space to balance the row
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _StatsRowLoading extends StatelessWidget {
  const _StatsRowLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 100,
            margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

// Simple Stat Card
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Subscribers Table
class _SubscribersTable extends StatelessWidget {
  final List<SubscriptionEntity> subscriptions;

  const _SubscribersTable({required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _TableHeaderCell(label: 'المستخدم', flex: 3),
                _TableHeaderCell(label: 'البريد الإلكتروني', flex: 3),
                _TableHeaderCell(label: 'نوع الخطة', flex: 2),
                _TableHeaderCell(label: 'تاريخ الانتهاء', flex: 2),
                _TableHeaderCell(label: 'المبلغ', flex: 2),
                _TableHeaderCell(label: 'الحالة', flex: 2),
              ],
            ),
          ),
          // Rows
          ...subscriptions
              .take(10)
              .map((sub) => _SubscriberRow(subscription: sub)),

          // Show More Button
          if (subscriptions.length > 10)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () => context.go('/subscriptions'),
                child: Text('عرض الكل (${subscriptions.length} مشترك)'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _TableHeaderCell({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _SubscriberRow extends StatelessWidget {
  final SubscriptionEntity subscription;

  const _SubscriberRow({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Row(
        children: [
          // User Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      subscription.userName.isNotEmpty
                          ? subscription.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subscription.userName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Text(
              subscription.userEmail,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Plan Type
          Expanded(flex: 2, child: _PlanBadge(type: subscription.type)),

          // End Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(subscription.endDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (subscription.daysRemaining > 0)
                  Text(
                    '${subscription.daysRemaining} يوم متبقي',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: subscription.daysRemaining < 7
                          ? AppTheme.accentRed
                          : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Amount
          Expanded(
            flex: 2,
            child: Text(
              '${subscription.amount.toStringAsFixed(0)} ج.م',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // Status
          Expanded(flex: 2, child: _StatusBadge(status: subscription.status)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Plan Badge
class _PlanBadge extends StatelessWidget {
  final SubscriptionType type;

  const _PlanBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case SubscriptionType.monthly:
        color = AppTheme.accentBlue;
      case SubscriptionType.semester:
        color = AppTheme.primaryPurple;
      case SubscriptionType.yearly:
        color = AppTheme.accentGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Status Badge
class _StatusBadge extends StatelessWidget {
  final SubscriptionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case SubscriptionStatus.active:
        color = AppTheme.accentGreen;
      case SubscriptionStatus.expired:
        color = AppTheme.accentRed;
      case SubscriptionStatus.pending:
        color = AppTheme.accentOrange;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status.displayName,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Quick Action Card
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.05)
                : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.3)
                  : AppTheme.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _isHovered ? widget.color : AppTheme.textSecondary,
              ),
            ],
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
