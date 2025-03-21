import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip_model.dart';
import '../widgets/button.dart';
import '../widgets/text_widget.dart';

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

String fromClickedText = states.first;
String toClickedText = states.last;

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final TextEditingController _pickupAddressController =
      TextEditingController();
  final TextEditingController _dropoffAddressController =
      TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    super.dispose();
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

  Future<void> _bookTrip() async {
    //if (!_formKey.currentState!.validate()) return;
    if (fromClickedText == null || toClickedText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select pickup and dropoff locations')),
      );
      return;
    }

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
        // Will be assigned later
        parentId: '',
        //Get parent ID from user profile
        pickupTime: pickupTime,
        pickupLocation:
            GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
        dropoffLocation:
            GeoPoint(_dropoffLocation!.latitude, _dropoffLocation!.longitude),
        pickupAddress: fromClickedText,
        dropoffAddress: toClickedText,
        status: TripStatus.scheduled,
      );

      await tripRef.set(trip.toMap());

      print(toClickedText);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip booked successfully!')),
      );
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //Todo  tabBar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(height: 20),
                  // Date Selection
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
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
                          Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Selection
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
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

                  // Pickup Location
                  Text(
                    'Pickup Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  popUpButtonContainer(
                      // text1: 'From',
                      text2: toClickedText.toString(),
                      width: double.infinity,
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
                                                      states[index].toString();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: text20Normal(
                                                  text:
                                                      states[index].toString(),
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

                  const SizedBox(height: 24),

                  // Dropoff Location
                  Text(
                    'Dropoff Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  popUpButtonContainer(
                      text2: fromClickedText.toString(),
                      width: double.infinity,
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
                                                      states[index].toString();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: text20Normal(
                                                  text:
                                                      states[index].toString(),
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

                  const SizedBox(height: 32),

                  // Book Button
                  SizedBox(
                    child: Button(
                      width: double.infinity,
                      color: Color(0xffEC441E),
                      onPressed: () {
                        _isLoading ? null : _bookTrip;
                        print("booking button clicked");
                      },
                      text: 'Book Transportation',
                    ),
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: _isLoading ? null : _bookTrip,
                  //     style: ElevatedButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                  //     ),
                  //     child: _isLoading
                  //         ? const CircularProgressIndicator()
                  //         : const Text('Book Transportation'),
                  //   ),
                  // ),
                ],
              ),
            ])));
  }
}

Widget popUpButtonContainer({
  String? text2,
  double? width,
  VoidCallback? onPressed,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 60,
      padding: EdgeInsets.only(left: 10),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [text14Normal(text: text2.toString(), color: Colors.black)],
      ),
    ),
  );
}
