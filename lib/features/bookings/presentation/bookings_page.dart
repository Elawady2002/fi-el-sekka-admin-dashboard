import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/presentation/bookings_provider.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/domain/booking_entity.dart';
import 'package:data_table_2/data_table_2.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  String _searchQuery = '';
  TripType? _selectedTripType;
  BookingStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final statsAsync = ref.watch(bookingStatsProvider);

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
                      'عرض وإدارة جميع حجوزات الرحلات',
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
                    const SnackBar(content: Text('قريباً - إضافة حجز جديد')),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('إضافة حجز'),
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
            loading: () => const SizedBox(height: 120),
            error: (_, _) => const SizedBox(height: 120),
          ),

          const SizedBox(height: 24),

          // Filters & Actions Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو البريد...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
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
                  child: DropdownButtonFormField<TripType?>(
                    initialValue: _selectedTripType,
                    decoration: InputDecoration(
                      labelText: 'نوع الرحلة',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
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
                      DropdownMenuItem(initialValue: null, child: Text('الكل')),
                      DropdownMenuItem(
                        initialValue: TripType.departureOnly,
                        child: Text('ذهاب فقط'),
                      ),
                      DropdownMenuItem(
                        initialValue: TripType.returnOnly,
                        child: Text('عودة فقط'),
                      ),
                      DropdownMenuItem(
                        initialValue: TripType.roundTrip,
                        child: Text('ذهاب وعودة'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTripType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<BookingStatus?>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
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
                      DropdownMenuItem(initialValue: null, child: Text('الكل')),
                      DropdownMenuItem(
                        initialValue: BookingStatus.confirmed,
                        child: Text('مؤكد'),
                      ),
                      DropdownMenuItem(
                        initialValue: BookingStatus.completed,
                        child: Text('مكتمل'),
                      ),
                      DropdownMenuItem(
                        initialValue: BookingStatus.cancelled,
                        child: Text('ملغي'),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: bookingsAsync.when(
                  data: (bookings) {
                    // Apply filters
                    var filteredBookings = bookings.where((booking) {
                      final matchesSearch =
                          booking.userName.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          booking.userEmail.toLowerCase().contains(
                            _searchQuery,
                          );
                      final matchesType =
                          _selectedTripType == null ||
                          booking.tripType == _selectedTripType;
                      final matchesStatus =
                          _selectedStatus == null ||
                          booking.status == _selectedStatus;
                      return matchesSearch && matchesType && matchesStatus;
                    }).toList();

                    if (filteredBookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد حجوزات',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
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
                        const Color(0xFFF8F9FA),
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                      columns: const [
                        DataColumn2(
                          label: Text('المستخدم'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(label: Text('نوع الرحلة')),
                        DataColumn2(label: Text('الحالة')),
                        DataColumn2(label: Text('وقت الذهاب')),
                        DataColumn2(label: Text('وقت العودة')),
                        DataColumn2(label: Text('المبلغ')),
                        DataColumn2(label: Text('التاريخ')),
                        DataColumn2(label: Text('تحكم'), size: ColumnSize.S),
                      ],
                      rows: filteredBookings.map((booking) {
                        return DataRow2(
                          onTap: () => _showBookingDetails(context, booking),
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    booking.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    booking.userEmail,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              _buildTripTypeBadge(context, booking.tripType),
                            ),
                            DataCell(
                              _buildStatusBadge(context, booking.status),
                            ),
                            DataCell(Text(booking.departureTime ?? '-')),
                            DataCell(Text(booking.returnTime ?? '-')),
                            DataCell(
                              Text('${booking.amount.toStringAsFixed(0)} ج.م'),
                            ),
                            DataCell(
                              Text(
                                '${booking.createdAt.year}-${booking.createdAt.month.toString().padLeft(2, '0')}-${booking.createdAt.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'عرض',
                                    onPressed: () =>
                                        _showBookingDetails(context, booking),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'المزيد',
                                    onPressed: () {
                                    },
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, BookingStats stats) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي الحجوزات',
              initialValue: stats.total.toString(),
              icon: Icons.event_note,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الحجوزات المؤكدة',
              initialValue: stats.confirmed.toString(),
              icon: Icons.check_circle,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الحجوزات المكتملة',
              initialValue: stats.completed.toString(),
              icon: Icons.done_all,
              color: const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'إجمالي الإيرادات',
              initialValue: '${stats.totalRevenue.toStringAsFixed(0)} ج.م',
              icon: Icons.attach_money,
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeBadge(BuildContext context, TripType type) {
    Color color;
    switch (type) {
      case TripType.departureOnly:
        color = const Color(0xFF2196F3);
        break;
      case TripType.returnOnly:
        color = const Color(0xFFFF9800);
        break;
      case TripType.roundTrip:
        color = const Color(0xFF9C27B0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

  Widget _buildStatusBadge(BuildContext context, BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.confirmed:
        color = const Color(0xFF4CAF50);
        break;
      case BookingStatus.completed:
        color = const Color(0xFF2196F3);
        break;
      case BookingStatus.cancelled:
        color = const Color(0xFFEF5350);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

  void _showBookingDetails(BuildContext context, BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الحجز'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('المستخدم', booking.userName),
              _buildDetailRow('البريد الإلكتروني', booking.userEmail),
              _buildDetailRow('نوع الرحلة', booking.tripType.displayName),
              _buildDetailRow('الحالة', booking.status.displayName),
              _buildDetailRow('وقت الذهاب', booking.departureTime ?? '-'),
              _buildDetailRow('وقت العودة', booking.returnTime ?? '-'),
              _buildDetailRow(
                'المبلغ',
                '${booking.amount.toStringAsFixed(2)} ج.م',
              ),
              _buildDetailRow(
                'تاريخ الحجز',
                '${booking.createdAt.year}-${booking.createdAt.month.toString().padLeft(2, '0')}-${booking.createdAt.day.toString().padLeft(2, '0')}',
              ),
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
