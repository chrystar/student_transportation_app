import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_transportation_app/views/widgets/text_widget.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip_model.dart';
import 'student_qr_screen.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _checkRecordsStream;
  late Stream<QuerySnapshot> _activeTripsStream;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    final userId = _authController.currentUser?.uid;
    if (userId != null) {
      // Get active trips
      print('userId: $userId');
      _activeTripsStream = _firestore
          .collection('trips')
          .where('studentId', isEqualTo: userId)
          .where('status', isEqualTo: TripStatus.scheduled)
          .snapshots();

      // Get check records
      _checkRecordsStream = _firestore
          .collection('check_records')
          .where('studentId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: text24Normal(
          text: "Check In/Out",
          color: Theme.of(context).colorScheme.secondary,
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _initializeStreams();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Trip Section
                _buildActiveTripSection(),
                const SizedBox(height: 24),

                // Check Records Section
                Text(
                  'Recent Check Records',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildCheckRecordsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTripSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _activeTripsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No active trips'),
            ),
          );
        }

        final activeTrip = TripModel.fromMap(
          snapshot.data!.docs.first.data() as Map<String, dynamic>,
          snapshot.data!.docs.first.id,
        );

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Trip',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Trip ID: ${activeTrip.id}'),
                Text('From: ${activeTrip.pickupAddress}'),
                Text('To: ${activeTrip.dropoffAddress}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCheckButton(
                      context: context,
                      tripId: activeTrip.id,
                      type: 'check_in',
                      isCheckedIn: activeTrip.checkInTime != null,
                    ),
                    _buildCheckButton(
                      context: context,
                      tripId: activeTrip.id,
                      type: 'check_out',
                      isCheckedIn: activeTrip.checkInTime != null,
                      isEnabled: activeTrip.checkInTime != null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckRecordsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _checkRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No check records found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final record = snapshot.data!.docs[index];
            final data = record.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final type = data['type'] as String;

            return Card(
              child: ListTile(
                leading: Icon(
                  type == 'check_in' ? Icons.login : Icons.logout,
                  color: type == 'check_in' ? Colors.green : Colors.red,
                ),
                title: Text(
                  type == 'check_in' ? 'Checked In' : 'Checked Out',
                ),
                subtitle: Text(
                  'Trip ID: ${data['tripId']}\n'
                      '${DateFormat('MMM dd, yyyy - HH:mm').format(timestamp)}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCheckButton({
    required BuildContext context,
    required String tripId,
    required String type,
    required bool isCheckedIn,
    bool isEnabled = true,
  }) {
    final isCheckIn = type == 'check_in';
    final buttonText = isCheckIn ? 'Check In' : 'Check Out';
    final buttonIcon = isCheckIn ? Icons.login : Icons.logout;
    final buttonColor = isCheckIn ? Colors.green : Colors.red;

    return ElevatedButton.icon(
      onPressed: !isEnabled
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentQRScreen(
              tripId: tripId,
              studentId: _authController.currentUser!.uid,
              type: type,
            ),
          ),
        );
      },
      icon: Icon(buttonIcon),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
      ),
    );
  }
}