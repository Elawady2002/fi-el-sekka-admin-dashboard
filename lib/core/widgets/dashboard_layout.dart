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
      body: Row(
        children: [
          // Sidebar
          _ModernSidebar(
            currentLocation: currentLocation,
            userName: authState.user?.fullName ?? 'Admin',
            userEmail: authState.user?.email ?? '',
            onLogout: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _ModernTopBar(userName: authState.user?.fullName ?? 'Admin'),

                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSidebar extends StatelessWidget {
  final String currentLocation;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const _ModernSidebar({
    required this.currentLocation,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          right: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'في السكة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'لوحة التحكم',
                  isSelected: currentLocation == '/',
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: 'المستخدمين',
                  isSelected: currentLocation == '/users',
                  onTap: () => context.go('/users'),
                ),
                _NavItem(
                  icon: Icons.card_membership_outlined,
                  selectedIcon: Icons.card_membership,
                  label: 'الاشتراكات',
                  isSelected: currentLocation == '/subscriptions',
                  onTap: () => context.go('/subscriptions'),
                ),
                _NavItem(
                  icon: Icons.directions_bus_outlined,
                  selectedIcon: Icons.directions_bus,
                  label: 'الرحلات',
                  isSelected: currentLocation == '/trips',
                  onTap: () => context.go('/trips'),
                ),
                _NavItem(
                  icon: Icons.book_online_outlined,
                  selectedIcon: Icons.book_online,
                  label: 'الحجوزات',
                  isSelected: currentLocation == '/bookings',
                  onTap: () => context.go('/bookings'),
                ),
                _NavItem(
                  icon: Icons.attach_money_outlined,
                  selectedIcon: Icons.attach_money,
                  label: 'المالية',
                  isSelected: currentLocation == '/finance',
                  onTap: () => context.go('/finance'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // User Profile & Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'مدير النظام',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: BorderSide(
                        color: AppTheme.errorRed.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 22,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernTopBar extends StatelessWidget {
  final String userName;

  const _ModernTopBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Notifications
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'الإشعارات',
          ),

          const SizedBox(width: 8),

          // User Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
