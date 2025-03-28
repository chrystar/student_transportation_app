import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:student_transportation_app/views/student/payment_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip_model.dart';
import '../auth/register_screen.dart';
import '../widgets/button.dart';
import '../widgets/text_widget.dart';
import '../student/booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

List states = [
  'Abia',
  'Adamawa',
  'Yelo',
  'Lagos',
  "Abuja",
  "Kaduna",
  "Kastina",
  "Enugu",
  "Imo",
  "Calaba",
  "Benue",
];

String _studentName = '';
String _studentEmail = '';

String fromClickedText = '';
String toClickedText = '';

final FirebaseAuth _auth = FirebaseAuth.instance;

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  int _selectedIndex = 0;
  int selectedPassengers = 1; // Default to 1 passenger
  //
  // final TextEditingController _pickupAddressController =
  //     TextEditingController();
  // final TextEditingController _dropoffAddressController =
  //     TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  bool _isLoading = false;

  // @override
  // void dispose() {
  //   _pickupAddressController.dispose();
  //   _dropoffAddressController.dispose();
  //   super.dispose();
  // }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectLocation(bool isPickup) async {
    // Implement location selection using Google Maps
    // This would typically launch a map screen for location selection
    // For now, we'll use dummy coordinates
    if (isPickup) {
      _pickupLocation = const LatLng(37.7749, -122.4194);
    } else {
      _dropoffLocation = const LatLng(37.7749, -122.4194);
    }
  }

  Future<void> loadUserData() async {
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

  // Future<void> _bookTrip() async {
  //   //if (!_formKey.currentState!.validate()) return;
  //   if (fromClickedText.isEmpty || toClickedText.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Please select pickup and dropoff locations')),
  //     );
  //     return;
  //   }
  //
  //   if (_pickupLocation == null || _dropoffLocation == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select valid locations')),
  //     );
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PaymentScreen(
  //         from: fromClickedText,
  //         to: toClickedText,
  //         date: _selectedDate,
  //         time: _selectedTime,
  //         passengers: selectedPassengers,
  //         onPaymentSuccess: () async {
  //           // Save the trip to Firestore after successful payment
  //           await _saveTripToFirestore();
  //         },
  //       ),
  //     ),
  //   );
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final userId = _authController.currentUser?.uid;
  //     if (userId == null) throw Exception('User not logged in');
  //
  //     // Combine date and time
  //     final pickupTime = DateTime(
  //       _selectedDate.year,
  //       _selectedDate.month,
  //       _selectedDate.day,
  //       _selectedTime.hour,
  //       _selectedTime.minute,
  //     );
  //
  //     print('working 1');
  //     // Create new trip document
  //     final tripRef = _firestore.collection('trips').doc();
  //     print('working 2');
  //     final trip = TripModel(
  //       id: tripRef.id,
  //       studentId: userId,
  //       driverId: '',
  //       // Will be assigned later
  //       parentId: '',
  //       //Get parent ID from user profile
  //       pickupTime: pickupTime,
  //       pickupLocation:
  //           GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
  //       dropoffLocation:
  //           GeoPoint(_dropoffLocation!.latitude, _dropoffLocation!.longitude),
  //       pickupAddress: fromClickedText,
  //       dropoffAddress: toClickedText,
  //       status: TripStatus.scheduled,
  //       passenger: selectedPassengers, // Add passengers to the trip
  //     );
  //
  //     print('working 3');
  //     await tripRef.set(trip.toMap());
  //
  //     print('working 4');
  //     if (!mounted) return;
  //     print('working 5');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Trip booked successfully!')),
  //     );
  //     // Navigate to Booking Confirmation Screen
  //     print('working 6');
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BookingConfirmationScreen(
  //           from: fromClickedText,
  //           to: toClickedText,
  //           date: _selectedDate,
  //           time: _selectedTime,
  //           passengers: selectedPassengers,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print('object chris');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error booking trip: ${e.toString()}')),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _bookTrip() async {
    if (fromClickedText.isEmpty || toClickedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and dropoff locations')),
      );
      return;
    }

    if (_pickupLocation == null || _dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid locations')),
      );
      return;
    }

    // Navigate to Payment Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          from: fromClickedText,
          to: toClickedText,
          date: _selectedDate,
          time: _selectedTime,
          passengers: selectedPassengers,
          onPaymentSuccess: () async {
            // Save the trip to Firestore after successful payment
            await _saveTripToFirestore();
          },
        ),
      ),
    );
  }

  Future<void> _saveTripToFirestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Combine date and time
      final pickupTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create new trip document
      final tripRef = _firestore.collection('trips').doc();
      final trip = TripModel(
        id: tripRef.id,
        studentId: userId,
        driverId: '',
        parentId: '',
        pickupTime: pickupTime,
        pickupLocation: GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
        dropoffLocation: GeoPoint(_dropoffLocation!.latitude, _dropoffLocation!.longitude),
        pickupAddress: fromClickedText,
        dropoffAddress: toClickedText,
        status: TripStatus.scheduled,
        passenger: selectedPassengers,
      );

      await tripRef.set(trip.toMap());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip booked successfully!')),
      );

      // Navigate to Booking Confirmation Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            from: fromClickedText,
            to: toClickedText,
            date: _selectedDate,
            time: _selectedTime,
            passengers: selectedPassengers,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking trip: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      // appBar: AppBar(
      //   title: text24Normal(
      //     text: 'Smart Ride',
      //     color: Theme.of(context).colorScheme.secondary,
      //   ),
      //   leading: Builder(
      //     builder: (BuildContext context) {
      //       return IconButton(
      //         icon: Image.asset("assets/images/menubar.png"),
      //         onPressed: () {
      //           Scaffold.of(context).openDrawer();
      //         },
      //       );
      //     },
      //   ),
      //   backgroundColor: Theme.of(context).colorScheme.onSecondary,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 15),
      //       child: Icon(Icons.notifications),
      //     ),
      //   ],
      // ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _studentName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    _studentEmail,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Book Transportation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Check In/Out'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: SingleChildScrollView(
       // padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
        child: Column(
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                height: 300,
              ),
            ),
            //const SizedBox(height: 8),
           Container(
              padding: const EdgeInsets.only(left: 20, right: 20,),
           decoration: BoxDecoration(
             color: Colors.white,
           ),
           child: Positioned(
             bottom: 30,
             child: Column(
                 children: [
                   InkWell(
                     onTap: () => _selectDate(context),
                     child: Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                           const Icon(Icons.calendar_today),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),

                   InkWell(
                     onTap: () => _selectTime(context),
                     child: Container(
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(_selectedTime.format(context)),
                           const Icon(Icons.access_time),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 24),

                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       popUpButtonContainer(
                           text1: 'Pickup Location',
                           text2: toClickedText.toString(),
                           width: 160,
                           context: context,
                           onPressed: () {
                             showModalBottomSheet(
                                 context: context,
                                 backgroundColor: Colors.white,
                                 scrollControlDisabledMaxHeightRatio: 0.6,
                                 builder: (context) {
                                   return Container(
                                     padding: EdgeInsets.only(top: 60),
                                     width: double.infinity,
                                     child: Column(
                                       children: [
                                         Expanded(
                                           child: ListView.builder(
                                             itemCount: states.length,
                                             itemBuilder:
                                                 (BuildContext context, int index) {
                                               return Container(
                                                 padding: EdgeInsets.all(20),
                                                 child: GestureDetector(
                                                   onTap: () {
                                                     setState(() {
                                                       toClickedText =
                                                       states[index];
                                                       _pickupLocation = const LatLng(37.7749, -122.4194); // Example coordinates

                                                     });
                                                     Navigator.pop(context);
                                                   },
                                                   child: text20Normal(
                                                       text: states[index].toString(),
                                                       color: Colors.black),
                                                 ),
                                               );
                                             },
                                           ),
                                         ),
                                       ],
                                     ),
                                   );
                                 });
                           }),
                       popUpButtonContainer(
                           text1: 'Dropoff Location',
                           text2: fromClickedText.toString(),
                           width: 160,
                           context: context,
                           onPressed: () {
                             showModalBottomSheet(
                                 context: context,
                                 backgroundColor: Colors.white,
                                 scrollControlDisabledMaxHeightRatio: 0.6,
                                 builder: (context) {
                                   return Container(
                                     padding: EdgeInsets.only(top: 60),
                                     width: double.infinity,
                                     child: Column(
                                       children: [
                                         Expanded(
                                           child: ListView.builder(
                                             itemCount: states.length,
                                             itemBuilder:
                                                 (BuildContext context, int index) {
                                               return Container(
                                                 padding: EdgeInsets.all(20),
                                                 child: GestureDetector(
                                                   onTap: () {
                                                     setState(() {
                                                       fromClickedText =
                                                       states[index];
                                                       _dropoffLocation = const LatLng(37.7749, -122.4194); // Example coordinates

                                                     });
                                                     Navigator.pop(context);
                                                   },
                                                   child: text20Normal(
                                                       text: states[index].toString(),
                                                       color: Colors.black),
                                                 ),
                                               );
                                             },
                                           ),
                                         ),
                                       ],
                                     ),
                                   );
                                 });
                           }),
                     ],
                   ),
                   const SizedBox(height: 24),

                   // Passenger Selection
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.grey),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: DropdownButton<int>(
                       value: selectedPassengers,
                       isExpanded: true,
                       underline: const SizedBox(),
                       // Remove the default underline
                       items: List.generate(
                           10, (index) => index + 1) // Options: 1 to 10 passengers
                           .map((int value) {
                         return DropdownMenuItem<int>(
                           value: value,
                           child: Text('$value Passenger${value > 1 ? 's' : ''}'),
                         );
                       }).toList(),
                       onChanged: (int? newValue) {
                         setState(() {
                           selectedPassengers = newValue!;
                         });
                       },
                     ),
                   ),

                   const SizedBox(height: 32),

                   // Book Button
                   SizedBox(
                     child: Button(
                       width: double.infinity,
                       color: Color(0xffEC441E),
                       onPressed: _isLoading ? null : _bookTrip,
                       text: 'Book Transportation',
                     ),
                   ),
                 ],
               ),
           ),
           ),
          ],
        ),
      ),
    );
  }
}

Widget popUpButtonContainer({
  String? text1,
  String? text2,
  double? width,
  VoidCallback? onPressed,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 60,
      padding: EdgeInsets.only(left: 20),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          text12Normal(text: text1.toString(), color: Colors.grey),
          text14Normal(text: text2.toString(), color: Colors.black)
        ],
      ),
    ),
  );
}
