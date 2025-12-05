import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/login_page.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_page.dart';
import 'package:dashboard_fi_el_sekka/features/users/presentation/users_page.dart';

// Notifier to trigger router refresh
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      debugPrint(
        '🔄 Router redirect: isLoggedIn=$isLoggedIn, location=${state.matchedLocation}',
      );

      if (!isLoggedIn && !isLoggingIn) {
        debugPrint('➡️ Redirecting to /login');
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        debugPrint('➡️ Redirecting to /');
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(path: '/users', builder: (context, state) => const UsersPage()),
    ],
  );
});
