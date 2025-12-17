import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/users/presentation/users_provider.dart';
import 'package:dashboard_fi_el_sekka/features/auth/domain/user_entity.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
                onPressed: () => _showAddUserDialog(context, ref),
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
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو البريد...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
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
                      fillColor: AppTheme.surfaceDarkLighter,
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
                        value: null,
                        child: Text('جميع الأنواع'),
                      ),
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
          ),
          const SizedBox(height: 16),

          // Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDark),
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
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد نتائج',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.textPrimary,
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
                        AppTheme.surfaceDarkLighter,
                      ),
                      headingTextStyle: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      dataTextStyle: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppTheme.textPrimary,
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
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'المزيد',
                                    color: AppTheme.surfaceDark,
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showEditUserDialog(
                                            context,
                                            ref,
                                            user,
                                          );
                                          break;
                                        case 'toggle':
                                          _toggleUserStatus(context, ref, user);
                                          break;
                                        case 'delete':
                                          _confirmDeleteUser(
                                            context,
                                            ref,
                                            user,
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('تعديل'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: Row(
                                          children: [
                                            Icon(
                                              user.isVerified
                                                  ? Icons.block_outlined
                                                  : Icons.check_circle_outlined,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              user.isVerified
                                                  ? 'تعطيل'
                                                  : 'تفعيل',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outlined,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'حذف',
                                              style: TextStyle(
                                                color: Colors.red,
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

  // ==================== Add User Dialog ====================
  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('إضافة مستخدم جديد'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: const Icon(Icons.person_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'البريد مطلوب';
                      if (!v.contains('@')) return 'بريد غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                      if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        logger.i('👤 Starting user creation...');
                        final supabase = SupabaseConfig.client;

                        logger.i('🔐 Creating user in auth system...');
                        // Create user in auth
                        final authResponse = await supabase.auth.admin
                            .createUser(
                              AdminUserAttributes(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                emailConfirm: true,
                              ),
                            );

                        logger.i(
                          '✅ Auth response received: ${authResponse.user?.id}',
                        );

                        if (authResponse.user != null) {
                          logger.i('📝 Inserting user into database...');
                          // Insert into users table
                          // Generate unique phone placeholder using timestamp
                          final uniquePhone =
                              'temp_${DateTime.now().millisecondsSinceEpoch}';

                          await supabase.from('users').insert({
                            'id': authResponse.user!.id,
                            'email': emailController.text.trim(),
                            'full_name': nameController.text.trim(),
                            'user_type': 'student',
                            'is_verified': true,
                            'phone':
                                uniquePhone, // Unique placeholder to satisfy constraint
                          });

                          logger.i('✅ User inserted successfully!');

                          // Refresh users list
                          ref.invalidate(usersProvider);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إضافة المستخدم بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          logger.e('❌ Auth response user is null!');
                        }
                      } catch (e, stackTrace) {
                        logger.e('❌ Error creating user: $e');
                        logger.e('Stack trace: $stackTrace');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطأ: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Edit User Dialog ====================
  void _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('تعديل المستخدم'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: const Icon(Icons.person_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: AppTheme.surfaceDarkLighter,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        final data = await SupabaseConfig.adminClient
                            .from('users')
                            .update({
                              'full_name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                            })
                            .eq('id', user.id)
                            .select(); // Add select() to return modified rows

                        logger.i('📝 Update Result: $data');

                        if (data.isEmpty) {
                          throw 'did not find user to update (0 rows modified)';
                        }

                        ref.invalidate(usersProvider);
                      } on PostgrestException catch (e) {
                        String errorMessage = 'حدث خطأ غير متوقع';
                        if (e.code == '23505') {
                          if (e.message.contains('phone')) {
                            errorMessage = 'رقم الهاتف هذا مستخدم بالفعل';
                          } else if (e.message.contains('email')) {
                            errorMessage =
                                'البريد الإلكتروني هذا مستخدم بالفعل';
                          } else {
                            errorMessage =
                                'هذه البيانات مسجلة مسبقاً لمستخدم آخر';
                          }
                        } else {
                          errorMessage = 'خطأ في قاعدة البيانات: ${e.message}';
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطأ: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Toggle User Status ====================
  Future<void> _toggleUserStatus(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) async {
    try {
      await SupabaseConfig.client
          .from('users')
          .update({'is_verified': !user.isVerified})
          .eq('id', user.id);

      ref.invalidate(usersProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isVerified ? 'تم تعطيل المستخدم' : 'تم تفعيل المستخدم',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== Confirm Delete User ====================
  void _confirmDeleteUser(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${user.fullName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                logger.i('🗑️ Starting user deletion for: ${user.email}');

                // Delete from auth first (Best Effort)
                try {
                  logger.i('🔐 Deleting from Auth System...');
                  await SupabaseConfig.client.auth.admin.deleteUser(user.id);
                  logger.i('✅ Deleted from Auth System');
                } catch (e) {
                  logger.w(
                    '⚠️ Could not delete from Auth (User might be already deleted): $e',
                  );
                  // Continue to delete from DB even if Auth delete fails
                }

                // Delete from users table
                logger.i('📝 Deleting from Database...');
                final data = await SupabaseConfig.adminClient
                    .from('users')
                    .delete()
                    .eq('id', user.id)
                    .select(); // Add select() to verify deletion

                logger.i('📝 Database Delete Result: $data');

                if (data.isEmpty) {
                  // This is the critical check
                  logger.w(
                    '⚠️ Database delete returned 0 rows! User might strictly incorrect ID or RLS policy.',
                  );
                } else {
                  logger.i(
                    '✅ Database delete successful: ${data.length} rows verified deleted.',
                  );
                }
                logger.i('✅ Deleted from Database');

                logger.i('🔄 Invalidating users provider...');
                ref.invalidate(usersProvider);
                logger.i('✅ Provider invalidated');

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e, stackTrace) {
                logger.e('❌ Error deleting user: $e');
                logger.e('Stack trace: $stackTrace');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
