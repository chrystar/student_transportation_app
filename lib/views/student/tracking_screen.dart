import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../models/trip_model.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  TripModel? _activeTrip;
  bool _isLoading = true;

  // Default camera position (can be set to your city's coordinates)
  static const LatLng _defaultLocation =
      LatLng(3.140853, 101.693207); // KL coordinates

  @override
  void initState() {
    super.initState();
    _loadActiveTrip();
  }

  Future<void> _loadActiveTrip() async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) return;

      final tripSnapshot = await _firestore
          .collection('trips')
          .where('studentId', isEqualTo: userId)
          .where('status', isEqualTo: TripStatus.inProgress.toString())
          .get();

      if (tripSnapshot.docs.isNotEmpty) {
        setState(() {
          _activeTrip = TripModel.fromMap(
            tripSnapshot.docs.first.data(),
            tripSnapshot.docs.first.id,
          );
        });
        _startLocationTracking();
      }
    } catch (e) {
      print('Error loading active trip: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startLocationTracking() {
    if (_activeTrip == null) return;

    // Listen to driver location updates
    _firestore
        .collection('locations')
        .where('tripId', isEqualTo: _activeTrip!.id)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final locationData = snapshot.docs.first.data();
        final GeoPoint location = locationData['location'];
        final LatLng driverLocation = LatLng(
          location.latitude,
          location.longitude,
        );

        _updateDriverMarker(driverLocation);
      }
    });
  }

  void _updateDriverMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('driver'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
      };

      // Add pickup location marker
      if (_activeTrip?.pickupLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(
              _activeTrip!.pickupLocation.latitude,
              _activeTrip!.pickupLocation.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Pickup Location'),
          ),
        );
      }

      // Add dropoff location marker
      if (_activeTrip?.dropoffLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: LatLng(
              _activeTrip!.dropoffLocation.latitude,
              _activeTrip!.dropoffLocation.longitude,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Dropoff Location'),
          ),
        );
      }

      // Move camera to driver's location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Trip Info Card
          if (_activeTrip != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Active Trip',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('From: ${_activeTrip!.pickupAddress}'),
                      Text('To: ${_activeTrip!.dropoffAddress}'),
                      if (_activeTrip!.estimatedArrival != null)
                        Text(
                          'ETA: ${_activeTrip!.estimatedArrival!.hour}:${_activeTrip!.estimatedArrival!.minute.toString().padLeft(2, '0')}',
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // No Active Trip Message
          if (!_isLoading && _activeTrip == null)
            Center(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Active Trip',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Book a trip to start tracking',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
