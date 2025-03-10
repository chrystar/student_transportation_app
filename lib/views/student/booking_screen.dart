import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

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
    if (!_formKey.currentState!.validate()) return;
    if (_pickupLocation == null || _dropoffLocation == null) {
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
        driverId: '', // Will be assigned later
        parentId: '', //Get parent ID from user profile
        pickupTime: pickupTime,
        pickupLocation:
            GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
        dropoffLocation:
            GeoPoint(_dropoffLocation!.latitude, _dropoffLocation!.longitude),
        pickupAddress: _pickupAddressController.text,
        dropoffAddress: _dropoffAddressController.text,
        status: TripStatus.scheduled,
      );

      await tripRef.set(trip.toMap());

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
      appBar: AppBar(
        title: const Text('Book Transportation'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
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
              TextFormField(
                controller: _pickupAddressController,
                decoration: InputDecoration(
                  hintText: 'Enter pickup address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () => _selectLocation(true),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Dropoff Location
              Text(
                'Dropoff Location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dropoffAddressController,
                decoration: InputDecoration(
                  hintText: 'Enter dropoff address',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () => _selectLocation(false),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dropoff address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Book Transportation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
