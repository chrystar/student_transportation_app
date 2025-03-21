import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../student/student_home_screen.dart';
import '../parent/parent_home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Show splash for 2 seconds
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      _navigateToLogin();
      return;
    }

    _navigateBasedOnRole(authProvider.userRole);
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateBasedOnRole(String? role) {
    Widget destination;
    switch (role) {
      case 'student':
        destination = const StudentHomeScreen();
        break;
      case 'parent':
        destination = const ParentHomeScreen();
        break;
      case 'driver':
        destination = const DriverHomeScreen();
        break;
      case 'admin':
        destination = const AdminDashboard();
        break;
      default:
        destination = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEC441E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            const Text(
              'Student Transportation App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
