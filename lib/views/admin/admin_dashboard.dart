import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_users.dart';
import 'reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'totalDrivers': 0,
    'activeRoutes': 0,
    'pendingRequests': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    try {
      // Get total students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      // Get total drivers
      final driversSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();

      // Get active routes
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final routesSnapshot = await _firestore
          .collection('routes')
          .where('date', isGreaterThanOrEqualTo: today)
          .where('status', isEqualTo: 'in_progress')
          .get();

      // Get pending requests
      final requestsSnapshot = await _firestore
          .collection('transportation_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _stats = {
          'totalStudents': studentsSnapshot.docs.length,
          'totalDrivers': driversSnapshot.docs.length,
          'activeRoutes': routesSnapshot.docs.length,
          'pendingRequests': requestsSnapshot.docs.length,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'Total Students',
                        _stats['totalStudents'],
                        Icons.school,
                      ),
                      _buildStatCard(
                        'Total Drivers',
                        _stats['totalDrivers'],
                        Icons.drive_eta,
                      ),
                      _buildStatCard(
                        'Active Routes',
                        _stats['activeRoutes'],
                        Icons.route,
                      ),
                      _buildStatCard(
                        'Pending Requests',
                        _stats['pendingRequests'],
                        Icons.pending_actions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionButton(
                        'Send Message',
                        Icons.message,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MessageUsersScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        'View Reports',
                        Icons.assessment,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        'Manage Routes',
                        Icons.route,
                        () {
                          // tODO: Implement route management
                        },
                      ),
                      _buildActionButton(
                        'User Management',
                        Icons.people,
                        () {
                          // tODO: Implement user management
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
