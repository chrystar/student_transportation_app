import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> _reportData = {};
  String _selectedPeriod = 'week';
  String _selectedReport = 'usage';

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final DateTime startDate;

      // Calculate start date based on selected period
      switch (_selectedPeriod) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Load data based on selected report type
      switch (_selectedReport) {
        case 'usage':
          await _loadUsageReport(startDate);
          break;
        case 'routes':
          await _loadRoutesReport(startDate);
          break;
        case 'requests':
          await _loadRequestsReport(startDate);
          break;
      }
    } catch (e) {
      print('Error loading report data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsageReport(DateTime startDate) async {
    final usageSnapshot = await _firestore
        .collection('transportation_requests')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .get();

    final Map<String, int> dailyUsage = {};
    int totalRequests = 0;
    int completedRequests = 0;

    for (var doc in usageSnapshot.docs) {
      final data = doc.data();
      final date = DateFormat('yyyy-MM-dd')
          .format((data['timestamp'] as Timestamp).toDate());

      dailyUsage[date] = (dailyUsage[date] ?? 0) + 1;
      totalRequests++;

      if (data['status'] == 'completed') {
        completedRequests++;
      }
    }

    setState(() {
      _reportData = {
        'dailyUsage': dailyUsage,
        'totalRequests': totalRequests,
        'completedRequests': completedRequests,
        'completionRate': totalRequests > 0
            ? (completedRequests / totalRequests * 100).toStringAsFixed(1)
            : '0',
      };
    });
  }

  Future<void> _loadRoutesReport(DateTime startDate) async {
    final routesSnapshot = await _firestore
        .collection('routes')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .get();

    int totalRoutes = 0;
    int activeRoutes = 0;
    int completedRoutes = 0;
    Map<String, int> routesByDriver = {};

    for (var doc in routesSnapshot.docs) {
      final data = doc.data();
      totalRoutes++;

      switch (data['status']) {
        case 'in_progress':
          activeRoutes++;
          break;
        case 'completed':
          completedRoutes++;
          break;
      }

      final driverId = data['driverId'] as String;
      routesByDriver[driverId] = (routesByDriver[driverId] ?? 0) + 1;
    }

    setState(() {
      _reportData = {
        'totalRoutes': totalRoutes,
        'activeRoutes': activeRoutes,
        'completedRoutes': completedRoutes,
        'routesByDriver': routesByDriver,
      };
    });
  }

  Future<void> _loadRequestsReport(DateTime startDate) async {
    final requestsSnapshot = await _firestore
        .collection('transportation_requests')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .get();

    Map<String, int> requestsByStatus = {
      'pending': 0,
      'approved': 0,
      'rejected': 0,
      'completed': 0,
      'cancelled': 0,
    };

    Map<String, int> requestsByType = {};

    for (var doc in requestsSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String;
      final type = data['type'] as String;

      requestsByStatus[status] = (requestsByStatus[status] ?? 0) + 1;
      requestsByType[type] = (requestsByType[type] ?? 0) + 1;
    }

    setState(() {
      _reportData = {
        'requestsByStatus': requestsByStatus,
        'requestsByType': requestsByType,
        'totalRequests': requestsSnapshot.docs.length,
      };
    });
  }

  Widget _buildReportContent() {
    switch (_selectedReport) {
      case 'usage':
        return _buildUsageReport();
      case 'routes':
        return _buildRoutesReport();
      case 'requests':
        return _buildRequestsReport();
      default:
        return const Center(child: Text('Select a report type'));
    }
  }

  Widget _buildUsageReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Requests: ${_reportData['totalRequests']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed Requests: ${_reportData['completedRequests']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completion Rate: ${_reportData['completionRate']}%',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Daily Usage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportData['dailyUsage']?.length ?? 0,
            itemBuilder: (context, index) {
              final date = _reportData['dailyUsage'].keys.elementAt(index);
              final count = _reportData['dailyUsage'][date];
              return ListTile(
                title: Text(date),
                trailing: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoutesReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Routes: ${_reportData['totalRoutes']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Active Routes: ${_reportData['activeRoutes']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed Routes: ${_reportData['completedRoutes']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Routes by Driver',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('users')
                .where('role', isEqualTo: 'driver')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final driver = snapshot.data!.docs[index];
                  final driverId = driver.id;
                  final driverName = driver['name'];
                  final routeCount =
                      _reportData['routesByDriver'][driverId] ?? 0;

                  return ListTile(
                    title: Text(driverName),
                    trailing: Text(
                      routeCount.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Requests: ${_reportData['totalRequests']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Requests by Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._reportData['requestsByStatus']?.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${entry.key.toUpperCase()}: ${entry.value}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ) ??
                    [],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Requests by Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportData['requestsByType']?.length ?? 0,
            itemBuilder: (context, index) {
              final type = _reportData['requestsByType'].keys.elementAt(index);
              final count = _reportData['requestsByType'][type];
              return ListTile(
                title: Text(type),
                trailing: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedReport,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'usage',
                        child: Text('Usage Report'),
                      ),
                      DropdownMenuItem(
                        value: 'routes',
                        child: Text('Routes Report'),
                      ),
                      DropdownMenuItem(
                        value: 'requests',
                        child: Text('Requests Report'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedReport = value!;
                        _loadReportData();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'week',
                        child: Text('Last Week'),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Last Month'),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text('Last Year'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                        _loadReportData();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: _buildReportContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
