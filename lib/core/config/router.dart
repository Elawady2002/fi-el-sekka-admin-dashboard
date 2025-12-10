import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/login_page.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_page.dart';
import 'package:dashboard_fi_el_sekka/features/users/presentation/users_page.dart';
import 'package:dashboard_fi_el_sekka/features/subscriptions/presentation/subscriptions_page.dart';
import 'package:dashboard_fi_el_sekka/features/bookings/presentation/bookings_page.dart';
import 'package:dashboard_fi_el_sekka/features/trips/presentation/trips_page.dart';
import 'package:dashboard_fi_el_sekka/features/routes/presentation/routes_locations_page.dart';
import 'package:dashboard_fi_el_sekka/features/payments/presentation/payments_page.dart';
import 'package:dashboard_fi_el_sekka/core/widgets/dashboard_layout.dart';

// Notifier to trigger router refresh
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
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
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (context, state) => const SubscriptionsPage(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripsPage(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsPage(),
          ),
          GoRoute(
            path: '/routes-locations',
            builder: (context, state) => const RoutesLocationsPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsPage(),
          ),
        ],
      ),
    ],
  );
});
