import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/trips/presentation/trips_provider.dart';
import 'package:dashboard_fi_el_sekka/features/trips/domain/trip_entity.dart';
import 'package:data_table_2/data_table_2.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  String _searchQuery = '';
  TripStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    final statsAsync = ref.watch(tripStatsProvider);

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
                'الرحلات والمواعيد',
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
                      'إدارة الرحلات والمواعيد',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض وإدارة جميع الرحلات والجداول الزمنية',
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
                    const SnackBar(content: Text('قريباً - إضافة رحلة جديدة')),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('إضافة رحلة'),
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
                      hintText: 'بحث بالسائق أو المعرف...',
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
                  child: DropdownButtonFormField<TripStatus?>(
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
                        initialValue: TripStatus.scheduled,
                        child: Text('مجدول'),
                      ),
                      DropdownMenuItem(
                        initialValue: TripStatus.inProgress,
                        child: Text('جاري'),
                      ),
                      DropdownMenuItem(
                        initialValue: TripStatus.completed,
                        child: Text('مكتمل'),
                      ),
                      DropdownMenuItem(
                        initialValue: TripStatus.cancelled,
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
                child: tripsAsync.when(
                  data: (trips) {
                    // Apply filters
                    var filteredTrips = trips.where((trip) {
                      final matchesSearch =
                          (trip.driverName?.toLowerCase().contains(
                                _searchQuery,
                              ) ??
                              false) ||
                          trip.id.toLowerCase().contains(_searchQuery);
                      final matchesStatus =
                          _selectedStatus == null ||
                          trip.status == _selectedStatus;
                      return matchesSearch && matchesStatus;
                    }).toList();

                    if (filteredTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد رحلات',
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
                        DataColumn2(label: Text('التاريخ'), size: ColumnSize.M),
                        DataColumn2(label: Text('السائق')),
                        DataColumn2(label: Text('وقت الذهاب')),
                        DataColumn2(label: Text('وقت العودة')),
                        DataColumn2(label: Text('المقاعد المتاحة')),
                        DataColumn2(label: Text('الحالة')),
                        DataColumn2(label: Text('تحكم'), size: ColumnSize.S),
                      ],
                      rows: filteredTrips.map((trip) {
                        return DataRow2(
                          onTap: () => _showTripDetails(context, trip),
                          cells: [
                            DataCell(
                              Text(
                                '${trip.tripDate.year}-${trip.tripDate.month.toString().padLeft(2, '0')}-${trip.tripDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(Text(trip.driverName ?? 'غير محدد')),
                            DataCell(Text(trip.departureTime ?? '-')),
                            DataCell(Text(trip.returnTime ?? '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: trip.availableSeats > 0
                                      ? const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.08)
                                      : const Color(
                                          0xFFEF5350,
                                        ).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: trip.availableSeats > 0
                                        ? const Color(
                                            0xFF4CAF50,
                                          ).withValues(alpha: 0.2)
                                        : const Color(
                                            0xFFEF5350,
                                          ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  trip.availableSeats.toString(),
                                  style: TextStyle(
                                    color: trip.availableSeats > 0
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFEF5350),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(_buildStatusBadge(context, trip.status)),
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
                                        _showTripDetails(context, trip),
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
                          'حدث خطأ في تحميل الرحلات',
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
                          onPressed: () => ref.invalidate(tripsProvider),
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

  Widget _buildStatsCards(BuildContext context, TripStats stats) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي الرحلات',
              initialValue: stats.total.toString(),
              icon: Icons.directions_bus,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الرحلات المجدولة',
              initialValue: stats.scheduled.toString(),
              icon: Icons.schedule,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'الرحلات الجارية',
              initialValue: stats.inProgress.toString(),
              icon: Icons.play_circle,
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'رحلات اليوم',
              initialValue: stats.todayTrips.toString(),
              icon: Icons.today,
              color: const Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TripStatus status) {
    Color color;
    switch (status) {
      case TripStatus.scheduled:
        color = const Color(0xFF4CAF50);
        break;
      case TripStatus.inProgress:
        color = const Color(0xFFFF9800);
        break;
      case TripStatus.completed:
        color = const Color(0xFF2196F3);
        break;
      case TripStatus.cancelled:
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

  void _showTripDetails(BuildContext context, TripEntity trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الرحلة'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'التاريخ',
                '${trip.tripDate.year}-${trip.tripDate.month.toString().padLeft(2, '0')}-${trip.tripDate.day.toString().padLeft(2, '0')}',
              ),
              _buildDetailRow('السائق', trip.driverName ?? 'غير محدد'),
              _buildDetailRow('وقت الذهاب', trip.departureTime ?? '-'),
              _buildDetailRow('وقت العودة', trip.returnTime ?? '-'),
              _buildDetailRow(
                'المقاعد المتاحة',
                trip.availableSeats.toString(),
              ),
              _buildDetailRow('الحالة', trip.status.displayName),
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
