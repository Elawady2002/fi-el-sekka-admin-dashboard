import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_stats_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/presentation/subscriptions_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/data/subscription_actions.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/presentation/bookings_provider.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import 'package:dashboard_fi_el_sekka/core/widgets/widgets.dart';
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

          // Quick Actions Bar
          _QuickActionsBar(
            statsAsync: statsAsync,
            subscriptionsAsync: subscriptionsAsync,
          ),
          const SizedBox(height: 24),

          // Compact Stats Grid
          statsAsync.when(
            data: (stats) => CompactStatsGrid(
              stats: [
                CompactStat(
                  label: 'المستخدمين',
                  value: '${stats.totalUsers}',
                  icon: Icons.people_rounded,
                  color: AppTheme.accentBlue,
                  onTap: () => context.go('/users'),
                ),
                CompactStat(
                  label: 'المشتركين النشطين',
                  value: '${stats.activeSubscriptions}',
                  icon: Icons.card_membership_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => context.go('/subscriptions'),
                ),
                CompactStat(
                  label: 'إجمالي الحجوزات',
                  value: '${stats.totalBookings}',
                  icon: Icons.book_online_rounded,
                  color: AppTheme.chartBlue,
                  onTap: () => context.go('/bookings'),
                ),
                CompactStat(
                  label: 'الإيرادات الشهرية',
                  value: '${stats.monthlyRevenue.toStringAsFixed(0)} ج.م',
                  icon: Icons.payments_rounded,
                  color: AppTheme.primaryPurple,
                  onTap: () => context.go('/payments'),
                ),
              ],
            ),
            loading: () => const _StatsLoading(),
            error: (_, __) => const SizedBox(height: 100),
          ),
          const SizedBox(height: 28),

          // Pending Actions Section
          _SectionHeader(
            title: '🔔 محتاج تعمل دلوقتي',
            trailing: TextButton.icon(
              onPressed: () => context.go('/subscriptions'),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('عرض الكل'),
            ),
          ),
          const SizedBox(height: 12),

          subscriptionsAsync.when(
            data: (subscriptions) {
              final pendingSubscriptions = subscriptions
                  .where((s) => s.status == SubscriptionStatus.pending)
                  .toList();

              if (pendingSubscriptions.isEmpty) {
                return _EmptyPendingState();
              }

              return _PendingActionsList(
                subscriptions: pendingSubscriptions,
                onRefresh: () => ref.invalidate(subscriptionsProvider),
              );
            },
            loading: () => const _PendingActionsLoading(),
            error: (_, __) => _ErrorState(),
          ),

          const SizedBox(height: 28),

          // Quick Navigation
          _SectionHeader(title: '⚡ الإجراءات السريعة'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NavigationCard(
                  icon: Icons.people_rounded,
                  title: 'المستخدمين',
                  subtitle: 'عرض وإدارة المستخدمين',
                  color: AppTheme.accentBlue,
                  onTap: () => context.go('/users'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavigationCard(
                  icon: Icons.card_membership_rounded,
                  title: 'الاشتراكات',
                  subtitle: 'إدارة الاشتراكات',
                  color: AppTheme.primaryPurple,
                  onTap: () => context.go('/subscriptions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavigationCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'الحجوزات',
                  subtitle: 'متابعة الحجوزات',
                  color: AppTheme.accentGreen,
                  onTap: () => context.go('/bookings'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavigationCard(
                  icon: Icons.map_rounded,
                  title: 'المواقع',
                  subtitle: 'المدن والمحطات',
                  color: AppTheme.accentOrange,
                  onTap: () => context.go('/routes-locations'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Welcome Header ====================
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
              '$greeting، $userName! 👋',
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
    return 'مساء الخير';
  }
}

// ==================== Quick Actions Bar ====================
class _QuickActionsBar extends StatelessWidget {
  final AsyncValue<DashboardStats> statsAsync;
  final AsyncValue<List<SubscriptionEntity>> subscriptionsAsync;

  const _QuickActionsBar({
    required this.statsAsync,
    required this.subscriptionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = subscriptionsAsync.maybeWhen(
      data: (subs) =>
          subs.where((s) => s.status == SubscriptionStatus.pending).length,
      orElse: () => 0,
    );

    final todaysTrips = statsAsync.maybeWhen(
      data: (stats) => stats.todaysTrips,
      orElse: () => 0,
    );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (pendingCount > 0)
          _QuickActionChip(
            icon: Icons.pending_actions_rounded,
            label: '$pendingCount اشتراكات معلقة',
            color: AppTheme.accentOrange,
            onTap: () => context.go('/subscriptions'),
          ),
        if (todaysTrips > 0)
          _QuickActionChip(
            icon: Icons.directions_bus_rounded,
            label: '$todaysTrips رحلات اليوم',
            color: AppTheme.accentBlue,
            onTap: () => context.go('/trips'),
          ),
        _QuickActionChip(
          icon: Icons.payments_rounded,
          label: 'المدفوعات',
          color: AppTheme.primaryPurple,
          onTap: () => context.go('/payments'),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color
                : widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withValues(alpha: _isHovered ? 1 : 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _isHovered ? Colors.white : widget.color,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? Colors.white : widget.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Section Header ====================
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ==================== Pending Actions List ====================
class _PendingActionsList extends StatelessWidget {
  final List<SubscriptionEntity> subscriptions;
  final VoidCallback onRefresh;

  const _PendingActionsList({
    required this.subscriptions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: subscriptions.take(5).map((sub) {
          return _PendingSubscriptionItem(
            subscription: sub,
            onRefresh: onRefresh,
            isLast:
                subscriptions.indexOf(sub) ==
                (subscriptions.length > 5 ? 4 : subscriptions.length - 1),
          );
        }).toList(),
      ),
    );
  }
}

class _PendingSubscriptionItem extends StatelessWidget {
  final SubscriptionEntity subscription;
  final VoidCallback onRefresh;
  final bool isLast;

  const _PendingSubscriptionItem({
    required this.subscription,
    required this.onRefresh,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: PendingActionItem(
        icon: Icons.card_membership_rounded,
        iconColor: AppTheme.accentOrange,
        title: subscription.userName,
        subtitle:
            '${subscription.type.displayName} - ${subscription.amount.toStringAsFixed(0)} ج.م',
        timeAgo: _getTimeAgo(subscription.createdAt),
        quickActions: [
          QuickAction(
            label: 'موافقة',
            icon: Icons.check_circle_outline,
            color: AppTheme.accentGreen,
            onPressed: () => _approveSubscription(context),
          ),
          QuickAction(
            label: 'رفض',
            icon: Icons.cancel_outlined,
            color: AppTheme.accentRed,
            onPressed: () => _rejectSubscription(context),
          ),
        ],
        onTap: () => context.go('/subscriptions'),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }

  Future<void> _approveSubscription(BuildContext context) async {
    final success = await SubscriptionActions.approveSubscription(
      subscription.id,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تمت الموافقة بنجاح ✓' : 'حدث خطأ'),
          backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
        ),
      );
      if (success) onRefresh();
    }
  }

  Future<void> _rejectSubscription(BuildContext context) async {
    final success = await SubscriptionActions.rejectSubscription(
      subscription.id,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم الرفض' : 'حدث خطأ'),
          backgroundColor: success ? AppTheme.accentOrange : AppTheme.accentRed,
        ),
      );
      if (success) onRefresh();
    }
  }
}

// ==================== Navigation Card ====================
class _NavigationCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_NavigationCard> createState() => _NavigationCardState();
}

class _NavigationCardState extends State<_NavigationCard> {
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.08)
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 12),
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

// ==================== Loading States ====================
class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 100,
            margin: EdgeInsets.only(left: index < 3 ? 12 : 0),
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

class _PendingActionsLoading extends StatelessWidget {
  const _PendingActionsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

// ==================== Empty State ====================
class _EmptyPendingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppTheme.accentGreen,
          ),
          const SizedBox(height: 12),
          Text(
            'مفيش حاجة معلقة! 🎉',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'كل الاشتراكات تم التعامل معها',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ==================== Error State ====================
class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.accentRed),
          const SizedBox(height: 12),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
