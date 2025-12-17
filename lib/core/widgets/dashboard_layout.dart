import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentLocation = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Row(
        children: [
          // Sidebar
          _FifaSidebar(
            currentLocation: currentLocation,
            userName: authState.user?.fullName ?? 'Admin',
            onLogout: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          // Main Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: AppTheme.backgroundDark),
              child: Column(
                children: [
                  // Top Bar
                  _FifaTopBar(
                    userName: authState.user?.fullName ?? 'Admin',
                    currentLocation: currentLocation,
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: AppTheme.backgroundDark),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FIFA-Style Sidebar
// ═══════════════════════════════════════════════════════════════
class _FifaSidebar extends StatelessWidget {
  final String currentLocation;
  final String userName;
  final VoidCallback onLogout;

  const _FifaSidebar({
    required this.currentLocation,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          left: BorderSide(
            color: AppTheme.borderDark.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          _LogoSection(),

          Divider(height: 1, color: AppTheme.borderDark.withValues(alpha: 0.5)),

          // Navigation
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NavGroup(
                    title: 'عام',
                    items: [
                      _NavItemData(
                        icon: Icons.dashboard_rounded,
                        label: 'الرئيسية',
                        route: '/',
                      ),
                      _NavItemData(
                        icon: Icons.people_rounded,
                        label: 'المستخدمين',
                        route: '/users',
                      ),
                    ],
                    currentLocation: currentLocation,
                  ),
                  _NavGroup(
                    title: 'العمليات',
                    items: [
                      _NavItemData(
                        icon: Icons.card_membership_rounded,
                        label: 'الاشتراكات',
                        route: '/subscriptions',
                      ),
                      _NavItemData(
                        icon: Icons.directions_bus_rounded,
                        label: 'الرحلات',
                        route: '/trips',
                      ),
                      _NavItemData(
                        icon: Icons.calendar_month_rounded,
                        label: 'الحجوزات',
                        route: '/bookings',
                      ),
                    ],
                    currentLocation: currentLocation,
                  ),
                  _NavGroup(
                    title: 'الإعدادات',
                    items: [
                      _NavItemData(
                        icon: Icons.location_on_rounded,
                        label: 'المواقع والمسارات',
                        route: '/routes-locations',
                      ),
                      _NavItemData(
                        icon: Icons.payments_rounded,
                        label: 'المدفوعات',
                        route: '/payments',
                      ),
                    ],
                    currentLocation: currentLocation,
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: AppTheme.borderDark.withValues(alpha: 0.5)),

          // User Profile Section
          _UserProfileSection(userName: userName, onLogout: onLogout),
        ],
      ),
    );
  }
}

// Logo Section
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo - Plain image without background
          Image.asset(
            'assets/image/logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.directions_bus_rounded,
                color: AppTheme.textPrimary,
                size: 40,
              );
            },
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'في السكة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'لوحة التحكم',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Navigation Group
class _NavGroup extends StatelessWidget {
  final String title;
  final List<_NavItemData> items;
  final String currentLocation;

  const _NavGroup({
    required this.title,
    required this.items,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map(
          (item) => _NavButton(
            icon: item.icon,
            label: item.label,
            route: item.route,
            isSelected: currentLocation == item.route,
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// Nav Button - FIFA Pill Style
class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryGreen
                : _isHovered
                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected || _isHovered ? null : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? Colors.white
                    : _isHovered
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white
                        : _isHovered
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// User Profile Section
class _UserProfileSection extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const _UserProfileSection({required this.userName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.accentPurple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'مدير النظام',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          _IconBtn(
            icon: Icons.logout_rounded,
            onTap: onLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FIFA-Style Top Bar
// ═══════════════════════════════════════════════════════════════
class _FifaTopBar extends StatelessWidget {
  final String userName;
  final String currentLocation;

  const _FifaTopBar({required this.userName, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderDark.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Page Title
          Text(
            _getPageTitle(currentLocation),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Search Bar - Clean design
          Container(
            width: 240,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'ابحث...',
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Icon Buttons
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}, badge: 3),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.settings_outlined, onTap: () {}),

          const SizedBox(width: 16),

          // User Avatar with border - Circular
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/image/IMG_0052.JPG',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryGreen,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String location) {
    switch (location) {
      case '/':
        return 'الرئيسية';
      case '/users':
        return 'المستخدمين';
      case '/subscriptions':
        return 'الاشتراكات';
      case '/trips':
        return 'الرحلات';
      case '/bookings':
        return 'الحجوزات';
      case '/routes-locations':
        return 'المواقع والمسارات';
      case '/payments':
        return 'المدفوعات';
      default:
        return 'لوحة التحكم';
    }
  }
}

// Icon Button with optional badge
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  final String? tooltip;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.tooltip,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isHovered
                    ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: _isHovered
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            if (widget.badge > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.badge}',
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
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
