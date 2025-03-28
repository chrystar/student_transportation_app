import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_transportation_app/views/student/tracking_screen.dart';
import 'package:student_transportation_app/views/widgets/text_widget.dart';
import '../auth/register_screen.dart';
import '../shared/trip_history_screen.dart';
import 'booking_screen.dart';
import 'check_in_out_screen.dart';
import 'message_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;



class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _studentName = '';
  String _studentEmail = '';
  int _selectedIndex = 0;

  final List _getPage = [
   // StudentHomeScreen(),
    BookingScreen(),
    CheckInOutScreen(),
    MessageScreen(),
    TrackingScreen(),
    // TripHistoryScreen(userId: _auth.currentUser?.uid, isParent: false),
  ];


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }



  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            _studentName = userData.get('name') ?? 'Student';
            _studentEmail = user.email ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,


      body: _getPage[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xffEC441E),
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Tracking',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
