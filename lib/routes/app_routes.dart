import 'package:flutter/material.dart';
import 'package:student_transportation_app/views/student/bottom_navigator.dart';
import 'page_transition.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/student/student_home_screen.dart';
import '../views/student/message_screen.dart';
import '../views/parent/parent_home_screen.dart';
import '../views/parent/parent_tracking_screen.dart';
import '../views/driver/driver_home_screen.dart';
import '../views/driver/driver_route_screen.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/admin/message_users.dart';
import '../views/admin/reports_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Student routes
  static const String studentHome = '/student-home';
  static const String studentMessage = '/student/message';

  // Parent routes
  static const String parentHome = '/parent/home';
  static const String parentTracking = '/parent/tracking';

  // Driver routes
  static const String driverHome = '/driver-home';
  static const String driverRoute = '/driver/route';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String adminMessages = '/admin/messages';
  static const String adminReports = '/admin/reports';

  static const String bottomNavigator = '/bottom';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),

        // Student routes
        studentHome: (context) => const StudentHomeScreen(),
        studentMessage: (context) => const MessageScreen(),

        //bottom routes

        // Parent routes
        parentHome: (context) => const ParentHomeScreen(),

        // Driver routes
        driverHome: (context) => const DriverHomeScreen(),
        driverRoute: (context) => const DriverRouteScreen(),

        // Admin routes
        adminDashboard: (context) => const AdminDashboard(),
        adminMessages: (context) => const MessageUsersScreen(),
        adminReports: (context) => const ReportsScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return FadePageTransition(
          page: const SplashScreen(),
          settings: settings,
        );
      case login:
        return FadePageTransition(
          page: const LoginScreen(),
          settings: settings,
        );
      case register:
        return SlidePageTransition(
          page: const RegisterScreen(),
          settings: settings,
        );
      case studentHome:
        return SlidePageTransition(
          page: const StudentHomeScreen(),
          settings: settings,
        );
      case studentMessage:
        return SlidePageTransition(
          page: const MessageScreen(),
          settings: settings,
        );
      case parentHome:
        return SlidePageTransition(
          page: const ParentHomeScreen(),
          settings: settings,
        );
      case parentTracking:
        if (settings.arguments is! Map<String, dynamic>) {
          return null;
        }
        final args = settings.arguments as Map<String, dynamic>;
        return SlidePageTransition(
          page: ParentTrackingScreen(
            tripId: args['tripId'] as String,
            studentName: args['studentName'] as String,
            pickupAddress: args['pickupAddress'] as String,
            dropoffAddress: args['dropoffAddress'] as String,
          ),
          settings: settings,
        );
      case driverHome:
        return SlidePageTransition(
          page: const DriverHomeScreen(),
          settings: settings,
        );
      case driverRoute:
        return SlidePageTransition(
          page: const DriverRouteScreen(),
          settings: settings,
        );
      case adminDashboard:
        return SlidePageTransition(
          page: const AdminDashboard(),
          settings: settings,
        );
      case adminMessages:
        return SlidePageTransition(
          page: const MessageUsersScreen(),
          settings: settings,
        );
      case adminReports:
        return SlidePageTransition(
          page: const ReportsScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
