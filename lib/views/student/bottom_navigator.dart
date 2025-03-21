import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_transportation_app/views/student/booking_screen.dart';
import 'package:student_transportation_app/views/student/student_home_screen.dart';
import 'package:student_transportation_app/views/student/tracking_screen.dart';

import '../shared/trip_history_screen.dart';
import 'check_in_out_screen.dart';
import 'message_screen.dart';

int _selectedIndex = 0;
final FirebaseAuth _auth = FirebaseAuth.instance;



class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _getPage = [
    StudentHomeScreen(),
    CheckInOutScreen(),
    StudentMessageScreen(),
    //TrackingScreen(),
    TripHistoryScreen(userId: _auth.currentUser?.uid, isParent: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
