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
  void _refreshData() {
    ref.invalidate(citiesProvider);
    ref.invalidate(universitiesProvider);
    ref.invalidate(stationsProvider);
    ref.invalidate(routesLocationStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final universitiesAsync = ref.watch(universitiesProvider);
    final stationsAsync = ref.watch(stationsProvider);

    return Container(
      color: const Color(0xFFF8F9FC),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Kanban Board
          Expanded(
            child: citiesAsync.when(
              data: (cities) => universitiesAsync.when(
                data: (universities) => stationsAsync.when(
                  data: (stations) => _buildKanbanBoard(
                    context,
                    cities,
                    universities,
                    stations,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('خطأ: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEF0F5))),
      ),
      child: Row(
        children: [
          // Logo & Title
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.map, color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المواقع والمسارات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'إدارة المدن والجامعات والمحطات',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          // Refresh
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
          // Add City Button
          FilledButton.icon(
            onPressed: () => _showAddCityDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة مدينة'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(
    BuildContext context,
    List<CityEntity> cities,
    List<UniversityEntity> universities,
    List<StationEntity> stations,
  ) {
    if (cities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مدن مسجلة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة أول مدينة',
              style: TextStyle(color: Colors.grey),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...cities.map((city) {
                final cityUniversities = universities
                    .where((u) => u.cityId == city.id)
                    .toList();
                final cityStations = stations
                    .where((s) => s.cityId == city.id)
                    .toList();
                return _KanbanColumn(
                  city: city,
                  universities: cityUniversities,
                  stations: cityStations,
                  onRefresh: _refreshData,
                  maxHeight: constraints.maxHeight - 40, // Account for padding
                );
              }),
              // Add Column Button
              _AddColumnButton(onTap: () => _showAddCityDialog(context)),
            ],
          ),
        );
      },
    );
  }

  void _showAddCityDialog(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_city,
                color: AppTheme.accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('إضافة مدينة جديدة'),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameArController,
                decoration: InputDecoration(
                  labelText: 'الاسم بالعربي',
                  hintText: 'مثال: مدينتي',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(
                  labelText: 'الاسم بالإنجليزي',
                  hintText: 'Example: Madinaty',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameArController.text.isEmpty ||
                  nameEnController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }

              final success = await addCity(
                nameAr: nameArController.text,
                nameEn: nameEnController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة المدينة بنجاح ✅')),
                  );
                  _refreshData();
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

// ==================== Kanban Column ====================
class _KanbanColumn extends StatelessWidget {
  final CityEntity city;
  final List<UniversityEntity> universities;
  final List<StationEntity> stations;
  final VoidCallback onRefresh;
  final double maxHeight;

  const _KanbanColumn({
    required this.city,
    required this.universities,
    required this.stations,
    required this.onRefresh,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = universities.length + stations.length;

    return Container(
      width: 300,
      height: maxHeight,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                city.nameAr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalItems',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const Spacer(),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add Button
          _AddTaskButton(
            label: 'إضافة عنصر جديد',
            onTap: () => _showAddOptions(context),
          ),
          const SizedBox(height: 12),

          // Cards List
          Expanded(
            child: ListView(
              children: [
                // Universities
                for (final uni in universities)
                  _TaskCard(
                    title: uni.nameAr,
                    subtitle: uni.nameEn,
                    tag: 'جامعة',
                    tagColor: AppTheme.primaryPurple,
                    icon: Icons.school,
                  ),

                // Stations
                for (final station in stations)
                  _TaskCard(
                    title: station.nameAr,
                    subtitle: station.nameEn,
                    tag: station.stationType.displayName,
                    tagColor: _getStationColor(station.stationType),
                    icon: Icons.pin_drop,
                  ),

                if (universities.isEmpty && stations.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لا توجد عناصر',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStationColor(StationType type) {
    switch (type) {
      case StationType.pickup:
        return AppTheme.accentGreen;
      case StationType.dropoff:
        return AppTheme.accentOrange;
      case StationType.both:
        return AppTheme.accentBlue;
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة إلى ${city.nameAr}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AddOptionCard(
                    icon: Icons.school,
                    title: 'جامعة',
                    color: AppTheme.primaryPurple,
                    onTap: () {
                      Navigator.pop(context);
                      _showAddUniversityDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AddOptionCard(
                    icon: Icons.pin_drop,
                    title: 'محطة',
                    color: AppTheme.accentOrange,
                    onTap: () {
                      Navigator.pop(context);
                      _showAddStationDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUniversityDialog(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('إضافة جامعة في ${city.nameAr}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameArController,
                decoration: InputDecoration(
                  labelText: 'الاسم بالعربي',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(
                  labelText: 'الاسم بالإنجليزي',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameArController.text.isEmpty ||
                  nameEnController.text.isEmpty)
                return;
              final success = await addUniversity(
                nameAr: nameArController.text,
                nameEn: nameEnController.text,
                cityId: city.id,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة الجامعة ✅')),
                  );
                  onRefresh();
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddStationDialog(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    String selectedType = 'both';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('إضافة محطة في ${city.nameAr}'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameArController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالعربي',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameEnController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالإنجليزي',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'نوع المحطة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                    DropdownMenuItem(
                      value: 'both',
                      child: Text('🔵 صعود ونزول'),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedType = v ?? 'both'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameArController.text.isEmpty ||
                    nameEnController.text.isEmpty)
                  return;
                final success = await addStation(
                  nameAr: nameArController.text,
                  nameEn: nameEnController.text,
                  cityId: city.id,
                  stationType: selectedType,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة المحطة ✅')),
                    );
                    onRefresh();
                  }
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

// ==================== Task Card ====================
class _TaskCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final IconData icon;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.tagColor.withValues(alpha: 0.5)
                : const Color(0xFFEEF0F5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.tagColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.tagColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.tag,
                    style: TextStyle(
                      color: widget.tagColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              widget.subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),

            // Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '1/1',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Add Task Button ====================
class _AddTaskButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AddTaskButton({required this.label, required this.onTap});

  @override
  State<_AddTaskButton> createState() => _AddTaskButtonState();
}

class _AddTaskButtonState extends State<_AddTaskButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryPurple.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: _isHovered
                    ? AppTheme.primaryPurple
                    : AppTheme.accentBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered
                      ? AppTheme.primaryPurple
                      : AppTheme.accentBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Add Column Button ====================
class _AddColumnButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddColumnButton({required this.onTap});

  @override
  State<_AddColumnButton> createState() => _AddColumnButtonState();
}

class _AddColumnButtonState extends State<_AddColumnButton> {
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
          width: 280,
          height: 150,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryPurple.withValues(alpha: 0.05)
                : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? AppTheme.primaryPurple : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppTheme.primaryPurple
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'إضافة مدينة',
                style: TextStyle(
                  color: _isHovered
                      ? AppTheme.primaryPurple
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Add Option Card ====================
class _AddOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AddOptionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
