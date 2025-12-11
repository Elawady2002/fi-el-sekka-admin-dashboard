import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/routes/presentation/routes_provider.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/city_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/university_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/station_entity.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

class RoutesLocationsPage extends ConsumerStatefulWidget {
  const RoutesLocationsPage({super.key});

  @override
  ConsumerState<RoutesLocationsPage> createState() =>
      _RoutesLocationsPageState();
}

class _RoutesLocationsPageState extends ConsumerState<RoutesLocationsPage> {
  int _selectedCityIndex = 0;

  void _refreshData() {
    ref.invalidate(citiesProvider);
    ref.invalidate(universitiesProvider);
    ref.invalidate(stationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final universitiesAsync = ref.watch(universitiesProvider);
    final stationsAsync = ref.watch(stationsProvider);

    return Container(
      color: const Color(0xFFF5F6FA),
      child: citiesAsync.when(
        data: (cities) => universitiesAsync.when(
          data: (universities) => stationsAsync.when(
            data: (stations) {
              if (cities.isEmpty) return _buildEmptyState();
              final currentCity = cities[_selectedCityIndex % cities.length];
              final cityUniversities = universities
                  .where((u) => u.cityId == currentCity.id)
                  .toList();
              final cityStations = stations
                  .where((s) => s.cityId == currentCity.id)
                  .toList();
              return Row(
                children: [
                  // Sidebar with Universities
                  _buildSidebar(context, currentCity, cityUniversities, cities),
                  // Main Kanban Board
                  Expanded(
                    child: _buildKanbanBoard(
                      context,
                      currentCity,
                      cityStations,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_city, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مدن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddCityDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة مدينة'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    CityEntity currentCity,
    List<UniversityEntity> universities,
    List<CityEntity> allCities,
  ) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEEF0F5))),
      ),
      child: Column(
        children: [
          // City Selector
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEF0F5))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedCityIndex =
                            (_selectedCityIndex - 1 + allCities.length) %
                            allCities.length;
                      }),
                      icon: const Icon(Icons.chevron_right, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6FA),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentCity.nameAr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedCityIndex =
                            (_selectedCityIndex + 1) % allCities.length;
                      }),
                      icon: const Icon(Icons.chevron_left, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6FA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allCities.length,
                    (i) => Container(
                      width: i == _selectedCityIndex ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _selectedCityIndex
                            ? AppTheme.primaryPurple
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Universities Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text(
                  'الجامعات',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${universities.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          // Universities List
          Expanded(
            child: universities.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد جامعات',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: universities.length,
                    itemBuilder: (context, index) =>
                        _UniversityItem(university: universities[index]),
                  ),
          ),
          // Add University Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _showAddUniversityDialog(context, currentCity),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة جامعة'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    CityEntity city,
    List<StationEntity> stations,
  ) {
    // Group stations by type
    final pickupStations = stations
        .where((s) => s.stationType == StationType.pickup)
        .toList();
    final dropoffStations = stations
        .where((s) => s.stationType == StationType.dropoff)
        .toList();
    final bothStations = stations
        .where((s) => s.stationType == StationType.both)
        .toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: AppTheme.accentBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'المواقع والمسارات - ${city.nameAr}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showAddStationDialog(context, city),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة محطة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Kanban Columns
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KanbanColumn(
                  title: 'نقطة صعود',
                  count: pickupStations.length,
                  color: AppTheme.accentGreen,
                  stations: pickupStations,
                  targetType: 'pickup',
                  onRefresh: _refreshData,
                ),
                const SizedBox(width: 20),
                _KanbanColumn(
                  title: 'نقطة نزول',
                  count: dropoffStations.length,
                  color: AppTheme.accentOrange,
                  stations: dropoffStations,
                  targetType: 'dropoff',
                  onRefresh: _refreshData,
                ),
                const SizedBox(width: 20),
                _KanbanColumn(
                  title: 'صعود ونزول',
                  count: bothStations.length,
                  color: AppTheme.accentBlue,
                  stations: bothStations,
                  targetType: 'both',
                  onRefresh: _refreshData,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCityDialog(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة مدينة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameArController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالعربي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameEnController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالإنجليزي',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameArController.text.isNotEmpty &&
                  nameEnController.text.isNotEmpty) {
                await addCity(
                  nameAr: nameArController.text,
                  nameEn: nameEnController.text,
                );
                if (context.mounted) Navigator.pop(context);
                _refreshData();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddUniversityDialog(BuildContext context, CityEntity city) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('إضافة جامعة في ${city.nameAr}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameArController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالعربي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameEnController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالإنجليزي',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameArController.text.isNotEmpty &&
                  nameEnController.text.isNotEmpty) {
                await addUniversity(
                  nameAr: nameArController.text,
                  nameEn: nameEnController.text,
                  cityId: city.id,
                );
                if (context.mounted) Navigator.pop(context);
                _refreshData();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddStationDialog(BuildContext context, CityEntity city) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    String selectedType = 'both';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('إضافة محطة في ${city.nameAr}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameArController,
                decoration: const InputDecoration(
                  labelText: 'الاسم بالعربي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  labelText: 'الاسم بالإنجليزي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع المحطة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'pickup',
                    child: Text('🟢 نقطة صعود'),
                  ),
                  DropdownMenuItem(
                    value: 'dropoff',
                    child: Text('🟠 نقطة نزول'),
                  ),
                  DropdownMenuItem(value: 'both', child: Text('🔵 صعود ونزول')),
                ],
                onChanged: (v) =>
                    setDialogState(() => selectedType = v ?? 'both'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameArController.text.isNotEmpty &&
                    nameEnController.text.isNotEmpty) {
                  await addStation(
                    nameAr: nameArController.text,
                    nameEn: nameEnController.text,
                    cityId: city.id,
                    stationType: selectedType,
                  );
                  if (context.mounted) Navigator.pop(context);
                  _refreshData();
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== University Item ====================
class _UniversityItem extends StatefulWidget {
  final UniversityEntity university;
  const _UniversityItem({required this.university});

  @override
  State<_UniversityItem> createState() => _UniversityItemState();
}

class _UniversityItemState extends State<_UniversityItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF5F6FA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                : const Color(0xFFEEF0F5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.university.nameAr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    widget.university.nameEn,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== Kanban Column ====================
class _KanbanColumn extends StatefulWidget {
  final String title;
  final int count;
  final Color color;
  final List<StationEntity> stations;
  final String targetType; // 'pickup', 'dropoff', or 'both'
  final VoidCallback onRefresh;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.stations,
    required this.targetType,
    required this.onRefresh,
  });

  @override
  State<_KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<_KanbanColumn> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DragTarget<StationEntity>(
        onWillAcceptWithDetails: (details) {
          // Accept if different type
          final station = details.data;
          final currentType = station.stationType.name;
          return currentType != widget.targetType;
        },
        onAcceptWithDetails: (details) async {
          final station = details.data;
          await updateStationType(
            stationId: station.id,
            newType: widget.targetType,
          );
          widget.onRefresh();
        },
        onMove: (_) => setState(() => _isDragOver = true),
        onLeave: (_) => setState(() => _isDragOver = false),
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isDragOver
                  ? widget.color.withValues(alpha: 0.1)
                  : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(16),
              border: _isDragOver
                  ? Border.all(color: widget.color, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                // Column Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.count}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                // Cards
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: widget.stations.length,
                    itemBuilder: (context, index) => _DraggableStationCard(
                      station: widget.stations[index],
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== Draggable Station Card ====================
class _DraggableStationCard extends StatelessWidget {
  final StationEntity station;
  final Color color;

  const _DraggableStationCard({required this.station, required this.color});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<StationEntity>(
      data: station,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 220,
          child: _StationCard(station: station, color: color),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: color.withValues(alpha: 0.05),
        ),
        child: Center(child: Icon(Icons.swap_horiz, color: color, size: 32)),
      ),
      child: _StationCard(station: station, color: color),
    );
  }
}

// ==================== Station Card ====================
class _StationCard extends StatefulWidget {
  final StationEntity station;
  final Color color;

  const _StationCard({required this.station, required this.color});

  @override
  State<_StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<_StationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.4)
                : const Color(0xFFEEF0F5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag + Menu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.station.stationType.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.grey.shade400, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              widget.station.nameAr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              widget.station.nameEn,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '1/1',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Footer
            Row(
              children: [
                // Avatar Stack
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Stack(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Positioned(
                          left: i * 16.0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: [
                                const Color(0xFFFF6B6B),
                                const Color(0xFF4ECDC4),
                              ][i],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                ['ع', 'م'][i],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  '2',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.attach_file_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
