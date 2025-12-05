import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/users/presentation/users_provider.dart';
import 'package:dashboard_fi_el_sekka/features/auth/domain/user_entity.dart';
import 'package:data_table_2/data_table_2.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';
  UserType? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

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
                'المستخدمين',
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
                      'إدارة المستخدمين',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('قريباً - إضافة مستخدم جديد')),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('إضافة مستخدم'),
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
                      fillColor: const Color(0xFFF8F9FA), // Very light gray
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
                  child: DropdownButtonFormField<UserType?>(
                    initialValue: _selectedUserType,
                    decoration: InputDecoration(
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
                      DropdownMenuItem(
                        initialValue: null,
                        child: Text('جميع الأنواع'),
                      ),
                      DropdownMenuItem(
                        initialValue: UserType.student,
                        child: Text('طالب'),
                      ),
                      DropdownMenuItem(
                        initialValue: UserType.driver,
                        child: Text('سائق'),
                      ),
                      DropdownMenuItem(
                        initialValue: UserType.admin,
                        child: Text('مسؤول'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value;
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
                child: usersAsync.when(
                  data: (users) {
                    var filteredUsers = users.where((user) {
                      final matchesSearch =
                          user.fullName.toLowerCase().contains(_searchQuery) ||
                          user.email.toLowerCase().contains(_searchQuery);
                      final matchesType =
                          _selectedUserType == null ||
                          user.userType == _selectedUserType;
                      return matchesSearch && matchesType;
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد نتائج',
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
                      minWidth: 900,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF8F9FA),
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                      columns: const [
                        DataColumn2(label: Text('الاسم'), size: ColumnSize.L),
                        DataColumn2(
                          label: Text('البريد الإلكتروني'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(label: Text('النوع')),
                        DataColumn2(label: Text('الحالة')),
                        DataColumn2(label: Text('التاريخ')),
                        DataColumn2(
                          label: Text('تحكم'), // Changed from "Actions"
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: filteredUsers.map((user) {
                        return DataRow2(
                          onTap: () => _showUserDetails(context, user),
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      user.fullName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(user.email)),
                            DataCell(
                              _buildUserTypeBadge(context, user.userType),
                            ),
                            DataCell(
                              _buildStatusBadge(context, user.isVerified),
                            ),
                            DataCell(
                              Text(
                                '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
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
                                        _showUserDetails(context, user),
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
                  error: (error, stack) => Center(child: Text('خطأ: $error')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets remain largely the same style but can be tweaked if needed
  Widget _buildUserTypeBadge(BuildContext context, UserType type) {
    Color color;
    String label;

    switch (type) {
      case UserType.student:
        color = const Color(0xFF1976D2);
        label = 'طالب';
        break;
      case UserType.driver:
        color = const Color(0xFFFFA726);
        label = 'سائق';
        break;
      case UserType.admin:
        color = const Color(0xFFAB47BC);
        label = 'مسؤول';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ), // Slimmer
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), // Lighter background
        borderRadius: BorderRadius.circular(
          6,
        ), // Less rounded - more square like reference
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isVerified) {
    // Similar slim style
    final color = isVerified
        ? const Color(0xFF28A745)
        : const Color(0xFFDC3545);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isVerified ? 'مفعّل' : 'غير مفعّل',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // _showUserDetails & _buildDetailRow methods can remain as they are or be updated if needed.
  // For now I'm leaving them but ensuring the build method closes correctly.

  void _showUserDetails(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل المستخدم'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الاسم', user.fullName),
              _buildDetailRow('البريد الإلكتروني', user.email),
              _buildDetailRow('الهاتف', user.phone),
              _buildDetailRow('النوع', _getUserTypeLabel(user.userType)),
              _buildDetailRow(
                'الحالة',
                user.isVerified ? 'مفعّل' : 'غير مفعّل',
              ),
              _buildDetailRow(
                'تاريخ التسجيل',
                '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')} ${user.createdAt.hour.toString().padLeft(2, '0')}:${user.createdAt.minute.toString().padLeft(2, '0')}',
              ),
              if (user.studentId != null)
                _buildDetailRow('الرقم الجامعي', user.studentId!),
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

  String _getUserTypeLabel(UserType type) {
    switch (type) {
      case UserType.student:
        return 'طالب';
      case UserType.driver:
        return 'سائق';
      case UserType.admin:
        return 'مسؤول';
    }
  }
}
