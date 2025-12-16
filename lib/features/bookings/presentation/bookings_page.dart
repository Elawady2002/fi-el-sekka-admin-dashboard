import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/presentation/bookings_provider.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/domain/booking_entity.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  // Track expanded routes
  final Set<String> _expandedRoutes = {};

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final bookingsByDate = ref.watch(bookingsByDateProvider);
    final routeGroupedBookings = ref.watch(routeGroupedBookingsProvider);
    final statsAsync = ref.watch(bookingStatsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);

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
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'الحجوزات',
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
                      'إدارة الحجوزات',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض الحجوزات حسب التاريخ والمسار',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => ref.invalidate(bookingsProvider),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('تحديث'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          statsAsync.when(
            data: (stats) => _buildStatsCards(context, stats),
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(height: 100),
          ),

          const SizedBox(height: 24),

          // Main Content - Calendar and Route Cards
          Expanded(
            child: bookingsAsync.when(
              data: (_) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Section
                  Container(
                    width: 380,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderDark),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Calendar Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: AppTheme.primaryGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'تقويم الحجوزات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Calendar Widget
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: TableCalendar(
                              locale: 'ar',
                              firstDay: DateTime.utc(2024, 1, 1),
                              lastDay: DateTime.utc(2026, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (day) =>
                                  isSameDay(selectedDate, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                ref.read(selectedDateProvider.notifier).state =
                                    selectedDay;
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              eventLoader: (day) {
                                final normalizedDay = DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                );
                                return bookingsByDate[normalizedDay] ?? [];
                              },
                              calendarStyle: CalendarStyle(
                                selectedDecoration: const BoxDecoration(
                                  color: AppTheme.primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withValues(
                                    alpha: 0.3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: const BoxDecoration(
                                  color: AppTheme.accentOrange,
                                  shape: BoxShape.circle,
                                ),
                                markersMaxCount: 3,
                                markerSize: 6,
                                markerMargin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: true,
                                titleCentered: true,
                                formatButtonDecoration: BoxDecoration(
                                  color: AppTheme.primaryPurple,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                formatButtonTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left,
                                  color: AppTheme.primaryPurple,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Route Cards Section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Routes Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.route,
                                    color: AppTheme.accentGreen,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'حجوزات اليوم المحدد',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat(
                                          'EEEE، d MMMM yyyy',
                                          'ar',
                                        ).format(selectedDate),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${routeGroupedBookings.values.fold(0, (sum, list) => sum + list.length)} حجز',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Route Cards List
                          Expanded(
                            child: routeGroupedBookings.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: routeGroupedBookings.length,
                                    itemBuilder: (context, index) {
                                      final routeKey = routeGroupedBookings.keys
                                          .elementAt(index);
                                      final bookings =
                                          routeGroupedBookings[routeKey]!;
                                      return _buildRouteCard(
                                        routeKey,
                                        bookings,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
                      'حدث خطأ في تحميل الحجوزات',
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
                      onPressed: () => ref.invalidate(bookingsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, BookingStats stats) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي الحجوزات',
              value: stats.total.toString(),
              icon: Icons.event_note,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الحجوزات المؤكدة',
              value: stats.confirmed.toString(),
              icon: Icons.check_circle,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الحجوزات المكتملة',
              value: stats.completed.toString(),
              icon: Icons.done_all,
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'إجمالي الإيرادات',
              value: '${stats.totalRevenue.toStringAsFixed(0)} ج.م',
              icon: Icons.attach_money,
              color: AppTheme.accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDarkLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد حجوزات لهذا اليوم',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر يوماً آخر من التقويم',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String routeKey, List<BookingEntity> bookings) {
    final isExpanded = _expandedRoutes.contains(routeKey);

    // Check if route info is available
    final hasRouteInfo =
        routeKey != 'مسار غير محدد' && !routeKey.contains('غير محدد');

    // Parse route parts for display
    final routeParts = routeKey.split(' → ');
    final pickupStation = routeParts.isNotEmpty ? routeParts[0] : '';
    final dropoffStation = routeParts.length > 1 ? routeParts[1] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? AppTheme.primaryPurple.withValues(alpha: 0.3)
              : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Route Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedRoutes.remove(routeKey);
                } else {
                  _expandedRoutes.add(routeKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Route Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withValues(alpha: 0.1),
                          AppTheme.accentBlue.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: AppTheme.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Route Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hasRouteInfo
                            ? Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      pickupStation,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (dropoffStation.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        dropoffStation,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : Text(
                                'حجوزات اليوم',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                        const SizedBox(height: 4),
                        Text(
                          '${bookings.length} ${bookings.length == 1 ? 'حجز' : 'حجوزات'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand Arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Bookings List
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDarkLighter,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  ...bookings.map((booking) => _buildBookingItem(booking)),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BookingEntity booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1),
            child: Text(
              booking.userName.isNotEmpty
                  ? booking.userName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  booking.userEmail,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          // Trip Type Badge
          _buildTripTypeBadge(booking.tripType),
          const SizedBox(width: 8),

          // Status Badge
          _buildStatusBadge(booking.status),
          const SizedBox(width: 8),

          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (booking.departureTime != null)
                Text(
                  'ذهاب: ${booking.departureTime}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              if (booking.returnTime != null)
                Text(
                  'عودة: ${booking.returnTime}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeBadge(BookingTripType type) {
    Color color;
    switch (type) {
      case BookingTripType.departureOnly:
        color = AppTheme.accentBlue;
      case BookingTripType.returnOnly:
        color = AppTheme.accentOrange;
      case BookingTripType.roundTrip:
        color = AppTheme.primaryPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.pending:
        color = AppTheme.accentOrange;
      case BookingStatus.confirmed:
        color = AppTheme.accentGreen;
      case BookingStatus.completed:
        color = AppTheme.accentBlue;
      case BookingStatus.cancelled:
        color = AppTheme.accentRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
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
    );
  }
}
