import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_stats_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/presentation/subscriptions_provider.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/domain/subscription_entity.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/data/subscription_actions.dart';

import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import 'package:dashboard_fi_el_sekka/core/widgets/widgets.dart';
import 'package:dashboard_fi_el_sekka/features/routes/presentation/routes_provider.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/city_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/station_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/university_entity.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/presentation/bookings_provider.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/domain/booking_entity.dart';
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
            error: (_, _) => const SizedBox(height: 100),
          ),
          const SizedBox(height: 28),

          // Pending Actions (without title)
          subscriptionsAsync.when(
            data: (subscriptions) {
              final pendingSubscriptions = subscriptions
                  .where((s) => s.status == SubscriptionStatus.pending)
                  .toList();

              if (pendingSubscriptions.isEmpty) {
                return const SizedBox.shrink();
              }

              return _PendingActionsList(
                subscriptions: pendingSubscriptions,
                onRefresh: () => ref.invalidate(subscriptionsProvider),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // City-Based Passenger Tracking (without title)
          _CityPassengerSection(ref: ref),
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
        _DateFilterButton(),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'صباح الخير';
    return 'مساء الخير';
  }
}

// ==================== Date Filter Button ====================
class _DateFilterButton extends StatefulWidget {
  @override
  State<_DateFilterButton> createState() => _DateFilterButtonState();
}

class _DateFilterButtonState extends State<_DateFilterButton> {
  DateTime _selectedDate = DateTime.now();
  bool _isHovered = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.backgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                  : AppTheme.borderDark,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: _isHovered
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovered
                      ? AppTheme.primaryGreen
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
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

// ==================== City Passenger Section ====================
class _CityPassengerSection extends StatelessWidget {
  final WidgetRef ref;

  const _CityPassengerSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final stationsAsync = ref.watch(stationsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final universitiesAsync = ref.watch(universitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        // Refresh button only (no title)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                ref.invalidate(citiesProvider);
                ref.invalidate(stationsProvider);
                ref.invalidate(bookingsProvider);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        citiesAsync.when(
          data: (cities) => stationsAsync.when(
            data: (stations) => bookingsAsync.when(
              data: (bookings) => universitiesAsync.when(
                data: (universities) {
                  // Get today's bookings
                  final today = DateTime.now();
                  final todaysBookings = bookings.where((b) {
                    return b.bookingDate.year == today.year &&
                        b.bookingDate.month == today.month &&
                        b.bookingDate.day == today.day;
                  }).toList();

                  if (cities.isEmpty) {
                    return _buildEmptyState(context, 'لا توجد مدن');
                  }

                  return Column(
                    children: cities.map((city) {
                      final cityStations = stations
                          .where((s) => s.cityId == city.id)
                          .toList();
                      return _CityGroup(
                        city: city,
                        stations: cityStations,
                        bookings: todaysBookings,
                        universities: universities
                            .where((u) => u.cityId == city.id)
                            .toList(),
                      );
                    }).toList(),
                  );
                },
                loading: () => _buildLoadingState(),
                error: (_, _) => _buildErrorState(context),
              ),
              loading: () => _buildLoadingState(),
              error: (_, _) => _buildErrorState(context),
            ),
            loading: () => _buildLoadingState(),
            error: (_, _) => _buildErrorState(context),
          ),
          loading: () => _buildLoadingState(),
          error: (_, _) => _buildErrorState(context),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Center(
        child: Text(
          'حدث خطأ في تحميل البيانات',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.accentRed),
        ),
      ),
    );
  }
}

// ==================== City Group (Expandable) ====================
class _CityGroup extends StatefulWidget {
  final CityEntity city;
  final List<StationEntity> stations;
  final List<BookingEntity> bookings;
  final List<UniversityEntity> universities;

  const _CityGroup({
    required this.city,
    required this.stations,
    required this.bookings,
    required this.universities,
  });

  @override
  State<_CityGroup> createState() => _CityGroupState();
}

class _CityGroupState extends State<_CityGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // Count bookings per station for this city
    final stationBookingCounts = <String, int>{};
    final deliveredCounts = <String, int>{};

    for (final station in widget.stations) {
      final stationBookings = widget.bookings.where(
        (b) =>
            b.pickupStationId == station.id || b.dropoffStationId == station.id,
      );
      stationBookingCounts[station.id] = stationBookings.length;
      deliveredCounts[station.id] = stationBookings
          .where((b) => b.status == BookingStatus.completed)
          .length;
    }

    final totalPassengers = stationBookingCounts.values.fold(
      0,
      (a, b) => a + b,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          // City Header (Clickable)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppTheme.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // City Color Bar
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // City Name
                  Text(
                    widget.city.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Badge with count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalPassengers راكب',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Add button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 20),
                    color: AppTheme.primaryPurple,
                    tooltip: 'إضافة',
                  ),
                ],
              ),
            ),
          ),

          // Table Content (Expandable)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildStationsTable(
              context,
              stationBookingCounts,
              deliveredCounts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsTable(
    BuildContext context,
    Map<String, int> stationBookingCounts,
    Map<String, int> deliveredCounts,
  ) {
    if (widget.stations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'لا توجد محطات في هذه المدينة',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    // Create a map of university_id to university name for quick lookup
    final universityMap = <String, String>{};
    for (final uni in widget.universities) {
      universityMap[uni.id] = uni.displayName;
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 32), // Checkbox space
              Expanded(
                flex: 2,
                child: Text(
                  'المحطة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'الجامعة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'عدد الركاب',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'الحالة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Rows
        ...widget.stations.map((station) {
          final passengerCount = stationBookingCounts[station.id] ?? 0;
          final deliveredCount = deliveredCounts[station.id] ?? 0;
          final isDelivered =
              passengerCount > 0 && deliveredCount == passengerCount;

          // Get university names for this city (all stations in a city share the same universities)
          final cityUniversities = widget.universities
              .where((u) => u.cityId == station.cityId)
              .map((u) => u.displayName)
              .toList();
          final universityDisplay = cityUniversities.isNotEmpty
              ? cityUniversities.join('، ')
              : '-';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderLight.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: isDelivered && passengerCount > 0,
                    onChanged: passengerCount > 0 ? (_) {} : null,
                    activeColor: AppTheme.accentGreen,
                  ),
                ),

                // Station Name
                Expanded(
                  flex: 2,
                  child: Text(
                    station.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                // University Name
                Expanded(
                  flex: 2,
                  child: Text(
                    universityDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      color: cityUniversities.isNotEmpty
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Passenger Count
                Expanded(
                  flex: 1,
                  child: Text(
                    '$passengerCount راكب',
                    style: TextStyle(
                      fontSize: 14,
                      color: passengerCount > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),

                // Delivery Status Badge
                Expanded(
                  flex: 1,
                  child: _DeliveryStatusBadge(
                    isDelivered: isDelivered,
                    hasPassengers: passengerCount > 0,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==================== Delivery Status Badge ====================
class _DeliveryStatusBadge extends StatelessWidget {
  final bool isDelivered;
  final bool hasPassengers;

  const _DeliveryStatusBadge({
    required this.isDelivered,
    required this.hasPassengers,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasPassengers) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'لا يوجد',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final color = isDelivered ? AppTheme.accentGreen : AppTheme.accentOrange;
    final text = isDelivered ? 'تم التوصيل' : 'في الطريق';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivered ? Icons.check_circle : Icons.schedule,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
