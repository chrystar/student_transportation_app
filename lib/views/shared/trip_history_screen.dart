import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/trip_model.dart';

class TripHistoryScreen extends StatefulWidget {
  final List<String>? studentIds; // For parents viewing multiple children
  final String? userId; // For students viewing their own trips
  final bool isParent;

  const TripHistoryScreen({
    super.key,
    this.studentIds,
    this.userId,
    required this.isParent,
   }) : assert(studentIds != null || userId != null);

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedMonth;
  String? _selectedStatus;
  List<String> _months = [];
  final List<String> _statusFilters = ['All', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _initializeMonths();
    _selectedStatus = 'All';
  }

  void _initializeMonths() {
    final DateFormat monthFormat = DateFormat('MMMM yyyy');
    final now = DateTime.now();
    _months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - index);
      return monthFormat.format(month);
    });
    _selectedMonth = _months.first;
  }

  Query<Map<String, dynamic>> _getTripsQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('trips');

    // Filter by student(s)
    if (widget.isParent) {
      query = query.where('studentId', whereIn: widget.studentIds);
    } else {
      query = query.where('studentId', isEqualTo: widget.userId);
    }

    // Filter by status if not 'All'
    if (_selectedStatus != 'All') {
      query = query.where('status', isEqualTo: _selectedStatus?.toLowerCase());
    } else {
      query = query.where('status', whereIn: ['completed', 'cancelled']);
    }

    // Order by timestamp
    query = query.orderBy('pickupTime', descending: true);

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMonth,
                    items: _months.map((String month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: _statusFilters.map((String status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Trip List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTripsQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No trips found'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final tripData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final trip = TripModel.fromMap(
                        tripData, snapshot.data!.docs[index].id);

                    // Filter by selected month
                    final tripMonth =
                        DateFormat('MMMM yyyy').format(trip.pickupTime);
                    if (_selectedMonth != null && tripMonth != _selectedMonth) {
                      return const SizedBox.shrink();
                    }

                    return _buildTripCard(trip);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final bool isCompleted = trip.status == TripStatus.completed;
    final statusColor = isCompleted ? Colors.green : Colors.red;
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.cancel,
          color: statusColor,
        ),
        title: Text(
          dateFormat.format(trip.pickupTime),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${timeFormat.format(trip.pickupTime)} - ${timeFormat.format(trip.checkOutTime ?? trip.pickupTime)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isParent) ...[
                  Text(
                    'Student: ${trip.studentName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                Text('From: ${trip.pickupAddress}'),
                const SizedBox(height: 4),
                Text('To: ${trip.dropoffAddress}'),
                const SizedBox(height: 8),
                Text('Driver: ${trip.driverName ?? 'Not assigned'}'),
                if (trip.checkInTime != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Check-in: ${timeFormat.format(trip.checkInTime!)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
                if (trip.checkOutTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Check-out: ${timeFormat.format(trip.checkOutTime!)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
