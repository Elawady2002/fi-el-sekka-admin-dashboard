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
                    const SizedBox(height: 4),
                    Text(
                      'عرض وإدارة جميع مستخدمي النظام',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Add user dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('قريباً - إضافة مستخدم جديد')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة مستخدم'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو البريد الإلكتروني...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                  value: _selectedUserType,
                  decoration: InputDecoration(
                    labelText: 'نوع المستخدم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('الكل')),
                    DropdownMenuItem(
                      value: UserType.student,
                      child: Text('طالب'),
                    ),
                    DropdownMenuItem(
                      value: UserType.driver,
                      child: Text('سائق'),
                    ),
                    DropdownMenuItem(
                      value: UserType.admin,
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
          const SizedBox(height: 24),

          // Data Table
          Expanded(
            child: Card(
              child: usersAsync.when(
                data: (users) {
                  // Apply filters
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
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد مستخدمين',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 900,
                    columns: const [
                      DataColumn2(
                        label: Text(
                          'الاسم',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(
                          'البريد الإلكتروني',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(
                          'النوع',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'الحالة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'تاريخ التسجيل',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'إجراءات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        size: ColumnSize.S,
                      ),
                    ],
                    rows: filteredUsers.map((user) {
                      return DataRow2(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Text(
                                    user.fullName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user.fullName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(user.email)),
                          DataCell(_buildUserTypeBadge(context, user.userType)),
                          DataCell(_buildStatusBadge(context, user.isVerified)),
                          DataCell(
                            Text(
                              '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  tooltip: 'عرض التفاصيل',
                                  onPressed: () {
                                    _showUserDetails(context, user);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  tooltip: 'تعديل',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'قريباً - تعديل المستخدم',
                                        ),
                                      ),
                                    );
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
                        'حدث خطأ في تحميل المستخدمين',
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
                        onPressed: () => ref.invalidate(usersProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFF66BB6A).withOpacity(0.1)
            : const Color(0xFFEF5350).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF66BB6A).withOpacity(0.3)
              : const Color(0xFFEF5350).withOpacity(0.3),
        ),
      ),
      child: Text(
        isVerified ? 'مفعّل' : 'غير مفعّل',
        style: TextStyle(
          color: isVerified ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
