import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider34/features/auth/presentation/screens/splash_screen.dart';
import 'package:rider34/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:rider34/features/auth/presentation/screens/signup_screen.dart';
import 'package:rider34/features/auth/presentation/screens/login_screen.dart';
import 'package:rider34/features/auth/presentation/screens/otp_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rider34/features/driver/presentation/screens/driver_application_screen.dart';
import 'package:rider34/features/home/presentation/screens/home_screen.dart';
import 'package:rider34/features/ride/presentation/screens/offer_fare_screen.dart';
import 'package:rider34/features/ride/presentation/screens/driver_offers_screen.dart';
import 'package:rider34/features/ride/presentation/screens/active_ride_screen.dart';
import 'package:rider34/features/ride/presentation/screens/ride_complete_screen.dart';
import 'package:rider34/features/driver/presentation/screens/driver_dashboard_screen.dart';
import 'package:rider34/features/driver/presentation/screens/driver_ride_request_screen.dart';
import 'package:rider34/features/profile/presentation/screens/profile_screen.dart';
import 'package:rider34/features/profile/presentation/screens/ride_history_screen.dart';
import 'package:rider34/features/profile/presentation/screens/settings_screen.dart';

/// Named routes used throughout the app.
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const driverApplication = '/driver-application';

  // Passenger routes
  static const home = '/home';
  static const offerFare = '/offer-fare';
  static const driverOffers = '/driver-offers';
  static const activeRide = '/active-ride';
  static const rideComplete = '/ride-complete';

  // Driver routes
  static const driverDashboard = '/driver-dashboard';
  static const driverRideRequest = '/driver-ride-request';

  // Profile
  static const profile = '/profile';
  static const rideHistory = '/ride-history';
  static const settings = '/settings';
}

String? _driverRouteRedirect(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return AppRoutes.login;
  final userMeta = session.user.userMetadata;
  final isDriver = userMeta != null && userMeta['role'] == 'driver';
  if (!isDriver) {
    return AppRoutes.home;
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.driverApplication,
        name: 'driver-application',
        builder: (context, state) => const DriverApplicationScreen(),
      ),

      // Passenger routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.offerFare,
        name: 'offer-fare',
        builder: (context, state) => const OfferFareScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverOffers,
        name: 'driver-offers',
        builder: (context, state) => const DriverOffersScreen(),
      ),
      GoRoute(
        path: AppRoutes.activeRide,
        name: 'active-ride',
        builder: (context, state) => const ActiveRideScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideComplete,
        name: 'ride-complete',
        builder: (context, state) => const RideCompleteScreen(),
      ),

      // Driver routes
      GoRoute(
        path: AppRoutes.driverDashboard,
        name: 'driver-dashboard',
        builder: (context, state) => const DriverDashboardScreen(),
        redirect: _driverRouteRedirect,
      ),
      GoRoute(
        path: AppRoutes.driverRideRequest,
        name: 'driver-ride-request',
        builder: (context, state) => const DriverRideRequestScreen(),
        redirect: _driverRouteRedirect,
      ),

      // Profile routes
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideHistory,
        name: 'ride-history',
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});
