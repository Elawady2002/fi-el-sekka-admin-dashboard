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

class _RoutesLocationsPageState extends ConsumerState<RoutesLocationsPage>
    with TickerProviderStateMixin {
  int _selectedCityIndex = 0;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
      decoration: const BoxDecoration(color: AppTheme.backgroundDark),
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
              return FadeTransition(
                opacity: _fadeController,
                child: Row(
                  children: [
                    _buildSidebar(
                      context,
                      currentCity,
                      cityUniversities,
                      cities,
                    ),
                    Expanded(
                      child: _buildMainContent(
                        context,
                        currentCity,
                        cityStations,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(e.toString()),
          ),
          loading: () => _buildLoadingState(),
          error: (e, _) => _buildErrorState(e.toString()),
        ),
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(e.toString()),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري التحميل...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                    AppTheme.accentBlue.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_city_rounded,
                size: 64,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'لا توجد مدن بعد',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ بإضافة مدينة جديدة لإدارة المواقع والمسارات',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddCityDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة مدينة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
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
      width: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // City Selector Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple,
                  AppTheme.primaryPurple.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildNavButton(Icons.chevron_right, () {
                      setState(
                        () => _selectedCityIndex =
                            (_selectedCityIndex - 1 + allCities.length) %
                            allCities.length,
                      );
                    }),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'المدينة الحالية',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentCity.nameAr,
                            style: const TextStyle(
                              color: AppTheme.surfaceDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildNavButton(Icons.chevron_left, () {
                      setState(
                        () => _selectedCityIndex =
                            (_selectedCityIndex + 1) % allCities.length,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allCities.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _selectedCityIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _selectedCityIndex
                            ? Colors.white
                            : AppTheme.textMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _showAddCityDialog(context),
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  label: const Text(
                    'إضافة مدينة',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Universities Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppTheme.accentBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الجامعات',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDarkLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${universities.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Universities List
          Expanded(
            child: universities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد جامعات',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: universities.length,
                    itemBuilder: (context, index) =>
                        _UniversityTile(university: universities[index]),
                  ),
          ),

          // Add University Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddUniversityDialog(context, currentCity),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.accentBlue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: AppTheme.accentBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إضافة جامعة',
                        style: TextStyle(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppTheme.borderDark,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppTheme.surfaceDark, size: 22),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    CityEntity city,
    List<StationEntity> stations,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentGreen,
                        AppTheme.accentGreen.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: AppTheme.surfaceDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محطات ${city.nameAr}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${stations.length} محطة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'صعود ونزول',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showAddStationDialog(context, city),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('إضافة محطة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stations Grid
          Expanded(
            child: stations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pin_drop_outlined,
                            size: 56,
                            color: AppTheme.accentGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'لا توجد محطات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط "إضافة محطة" للبدء',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: stations.length,
                    itemBuilder: (context, index) =>
                        _StationTile(station: stations[index], index: index),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddCityDialog(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: 'إضافة مدينة جديدة',
        icon: Icons.location_city_rounded,
        iconColor: AppTheme.primaryPurple,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CustomTextField(
              controller: nameArController,
              label: 'الاسم بالعربي',
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: nameEnController,
              label: 'الاسم بالإنجليزي',
              icon: Icons.translate,
            ),
          ],
        ),
        onConfirm: () async {
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
      ),
    );
  }

  void _showAddUniversityDialog(BuildContext context, CityEntity city) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: 'إضافة جامعة في ${city.nameAr}',
        icon: Icons.school_rounded,
        iconColor: AppTheme.accentBlue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CustomTextField(
              controller: nameArController,
              label: 'الاسم بالعربي',
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: nameEnController,
              label: 'الاسم بالإنجليزي',
              icon: Icons.translate,
            ),
          ],
        ),
        onConfirm: () async {
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
      ),
    );
  }

  void _showAddStationDialog(BuildContext context, CityEntity city) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        title: 'إضافة محطة في ${city.nameAr}',
        icon: Icons.pin_drop_rounded,
        iconColor: AppTheme.accentGreen,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CustomTextField(
              controller: nameArController,
              label: 'الاسم بالعربي',
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: nameEnController,
              label: 'الاسم بالإنجليزي',
              icon: Icons.translate,
            ),
          ],
        ),
        onConfirm: () async {
          if (nameArController.text.isNotEmpty &&
              nameEnController.text.isNotEmpty) {
            await addStation(
              nameAr: nameArController.text,
              nameEn: nameEnController.text,
              cityId: city.id,
              stationType: 'both',
            );
            if (context.mounted) Navigator.pop(context);
            _refreshData();
          }
        },
      ),
    );
  }
}

// ==================== Custom Dialog ====================
class _CustomDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final VoidCallback onConfirm;

  const _CustomDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            content,
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: iconColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إضافة'),
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

// ==================== Custom TextField ====================
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surfaceDarkLighter,
      ),
    );
  }
}

// ==================== University Tile ====================
class _UniversityTile extends StatefulWidget {
  final UniversityEntity university;
  const _UniversityTile({required this.university});

  @override
  State<_UniversityTile> createState() => _UniversityTileState();
}

class _UniversityTileState extends State<_UniversityTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppTheme.accentBlue.withValues(alpha: 0.08)
              : AppTheme.surfaceDarkLighter,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? AppTheme.accentBlue.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentBlue,
                    AppTheme.accentBlue.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppTheme.surfaceDark,
                size: 18,
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.university.nameEn,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: _isHovered ? AppTheme.accentBlue : AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Station Tile ====================
class _StationTile extends StatefulWidget {
  final StationEntity station;
  final int index;
  const _StationTile({required this.station, required this.index});

  @override
  State<_StationTile> createState() => _StationTileState();
}

class _StationTileState extends State<_StationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.accentGreen,
      AppTheme.accentBlue,
      AppTheme.accentOrange,
      AppTheme.primaryPurple,
    ];
    final color = colors[widget.index % colors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? color.withValues(alpha: 0.5)
                : AppTheme.borderDark,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: AppTheme.surfaceDark,
                    size: 20,
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _isHovered ? 1 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              widget.station.nameAr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              widget.station.nameEn,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'صعود ونزول',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
