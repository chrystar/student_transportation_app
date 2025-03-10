import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? driverId = _auth.currentUser?.uid;
      if (driverId == null) return;

      // Get today's date at midnight for comparison
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final routesSnapshot = await _firestore
          .collection('routes')
          .where('driverId', isEqualTo: driverId)
          .where('date', isGreaterThanOrEqualTo: today)
          .orderBy('date')
          .get();

      final List<Map<String, dynamic>> routes = [];
      for (var doc in routesSnapshot.docs) {
        final data = doc.data();
        final studentsSnapshot = await _firestore
            .collection('routes')
            .doc(doc.id)
            .collection('students')
            .get();

        routes.add({
          'id': doc.id,
          'startLocation': data['startLocation'],
          'endLocation': data['endLocation'],
          'date': (data['date'] as Timestamp).toDate(),
          'startTime': data['startTime'],
          'status': data['status'],
          'studentCount': studentsSnapshot.docs.length,
        });
      }

      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading routes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(route['date']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(route['status']),
              ],
            ),
            const SizedBox(height: 12),
            _buildRouteDetail(
                Icons.location_on, 'From: ${route['startLocation']}'),
            const SizedBox(height: 8),
            _buildRouteDetail(
                Icons.location_on_outlined, 'To: ${route['endLocation']}'),
            const SizedBox(height: 8),
            _buildRouteDetail(
                Icons.access_time, 'Start Time: ${route['startTime']}'),
            const SizedBox(height: 8),
            _buildRouteDetail(
                Icons.people, 'Students: ${route['studentCount']} assigned'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // tODO: Implement view details navigation
                  },
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // tODO: Implement start route functionality
                  },
                  child: const Text('Start Route'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'in_progress':
        backgroundColor = Colors.blue;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routes'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _routes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routes assigned yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) =>
                      _buildRouteCard(_routes[index]),
                ),
    );
  }
}
