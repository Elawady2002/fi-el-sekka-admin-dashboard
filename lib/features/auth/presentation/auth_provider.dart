import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/core/config/supabase_config.dart';
import 'package:dashboard_fi_el_sekka/features/auth/domain/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserEntity? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  final _supabase = SupabaseConfig.client;

  Future<void> _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUser(session.user.id);
    }
  }

  Future<void> _loadUser(String userId) async {
    try {
      print('📥 Loading user data for ID: $userId');

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      print('📦 User data received: $response');

      final user = UserEntity.fromJson(response);

      print('👤 User entity created: ${user.email}, type: ${user.userType}');

      // Only allow admin users
      if (!user.isAdmin) {
        print('⛔ Access denied: User is not an admin');
        await signOut();
        state = state.copyWith(
          error: 'Access denied. Admin privileges required.',
        );
        return;
      }

      print('✅ Admin user verified, updating state');
      state = state.copyWith(user: user);
    } catch (e) {
      print('❌ Error loading user: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔐 Attempting login for: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Auth successful, user ID: ${response.user?.id}');

      if (response.user != null) {
        await _loadUser(response.user!.id);
        print(
          '👤 User loaded: ${state.user?.email}, isAdmin: ${state.user?.isAdmin}',
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState();
  }
}

/// Auth provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
