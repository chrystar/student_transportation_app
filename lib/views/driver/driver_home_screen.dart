import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../services/location_service.dart';
import '../../models/trip_model.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  bool _isOnline = false;
  Set<Marker> _markers = {};
  final List<TripModel> _activeTrips = [];
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final initialized = await _locationService.initialize();
    if (initialized) {
      _locationService.startLocationUpdates().listen((locationData) {
        setState(() {
          _currentLocation = locationData;
          _updateDriverMarker(locationData);
        });

        if (_isOnline) {
          _locationService.updateDriverLocation(
            'current_driver_id', // Replace with actual driver ID
            locationData,
          );
        }
      });
    }
  }

  void _updateDriverMarker(LocationData locationData) {
    if (_mapController != null) {
      final newLatLng = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('driver'),
            position: newLatLng,
            rotation: locationData.heading ?? 0.0,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        };
      });

      _mapController!.animateCamera(
        CameraUpdate.newLatLng(newLatLng),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
              // Update driver's availability status in Firestore
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _markers,
                  ),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${_isOnline ? "Online" : "Offline"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Active Trips:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: _activeTrips.isEmpty
                      ? const Center(
                          child: Text('No active trips'),
                        )
                      : ListView.builder(
                          itemCount: _activeTrips.length,
                          itemBuilder: (context, index) {
                            final trip = _activeTrips[index];
                            return ListTile(
                              title: Text('Trip #${trip.id}'),
                              subtitle: Text(trip.pickupAddress),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Navigate to trip details
                                },
                                child: const Text('View Details'),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
