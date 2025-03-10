import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';

class DriverRouteScreen extends StatefulWidget {
  const DriverRouteScreen({super.key});

  @override
  State<DriverRouteScreen> createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends State<DriverRouteScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    // TODO: Load route data from backend
    // This is where you would fetch the route information
    // and update the markers and polylines
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRouteData,
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          final currentPosition = locationProvider.currentPosition;

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: currentPosition != null
                      ? LatLng(
                          currentPosition.latitude,
                          currentPosition.longitude,
                        )
                      : const LatLng(0, 0), // Default position
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: _polylines,
              ),
              if (locationProvider.error != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: Text(
                      locationProvider.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final locationProvider = Provider.of<LocationProvider>(
            context,
            listen: false,
          );
          if (locationProvider.isTracking) {
            locationProvider.stopTracking();
          } else {
            locationProvider.startTracking();
          }
        },
        child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return Icon(
              locationProvider.isTracking ? Icons.stop : Icons.play_arrow,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
