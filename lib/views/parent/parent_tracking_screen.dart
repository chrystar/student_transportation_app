import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/trip_model.dart';

class ParentTrackingScreen extends StatefulWidget {
  final String tripId;
  final String studentName;
  final String pickupAddress;
  final String dropoffAddress;

  const ParentTrackingScreen({
    super.key,
    required this.tripId,
    required this.studentName,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  @override
  State<ParentTrackingScreen> createState() => _ParentTrackingScreenState();
}

class _ParentTrackingScreenState extends State<ParentTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Stream<DocumentSnapshot>? _tripStream;
  Stream<QuerySnapshot>? _locationStream;

  // Default camera position (can be set to your city's coordinates)
  static const LatLng _defaultLocation =
      LatLng(3.140853, 101.693207); // KL coordinates

  @override
  void initState() {
    super.initState();
    _initializeStreams();
  }

  void _initializeStreams() {
    // Stream for trip updates
    _tripStream = _firestore.collection('trips').doc(widget.tripId).snapshots();

    // Stream for location updates
    _locationStream = _firestore
        .collection('locations')
        .where('tripId', isEqualTo: widget.tripId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  void _updateMarkers(LatLng driverLocation, TripModel trip) {
    setState(() {
      _markers = {
        // Driver Marker
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow:
              InfoWindow(title: 'Driver: ${trip.driverName ?? "Unknown"}'),
        ),
        // Pickup Marker
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            trip.pickupLocation.latitude,
            trip.pickupLocation.longitude,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
        // Dropoff Marker
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(
              trip.dropoffLocation.latitude,
              trip.dropoffLocation.longitude,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Dropoff Location'),
          )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.studentName}'),
      ),
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

          // Location Updates
          StreamBuilder<QuerySnapshot>(
            stream: _locationStream,
            builder: (context, locationSnapshot) {
              if (locationSnapshot.hasData &&
                  locationSnapshot.data!.docs.isNotEmpty) {
                final locationData = locationSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;
                final GeoPoint location = locationData['location'];
                final LatLng driverLocation = LatLng(
                  location.latitude,
                  location.longitude,
                );

                // Update driver marker and camera position
                StreamBuilder<DocumentSnapshot>(
                  stream: _tripStream,
                  builder: (context, tripSnapshot) {
                    if (tripSnapshot.hasData && tripSnapshot.data!.exists) {
                      final tripData =
                          tripSnapshot.data!.data() as Map<String, dynamic>;
                      final trip =
                          TripModel.fromMap(tripData, tripSnapshot.data!.id);
                      _updateMarkers(driverLocation, trip);

                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(driverLocation, 15),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Trip Info Card
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
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(
                          widget.studentName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'From: ${widget.pickupAddress}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To: ${widget.dropoffAddress}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _tripStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final tripData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final trip =
                              TripModel.fromMap(tripData, snapshot.data!.id);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              if (trip.driverName != null)
                                Text('Driver: ${trip.driverName}'),
                              if (trip.estimatedArrival != null)
                                Text(
                                  'ETA: ${trip.estimatedArrival!.hour}:${trip.estimatedArrival!.minute.toString().padLeft(2, '0')}',
                                ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
