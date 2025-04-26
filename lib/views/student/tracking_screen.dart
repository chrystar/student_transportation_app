import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(37.42796133580664, -122.085749655962);
  static const LatLng destination =
      LatLng(37.43296265331129, -122.08832357078792);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 13,
  );

  void getPolyPoints() async {}

  LocationData? currentLocation;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track you Location'),
        automaticallyImplyLeading: false,
      ),
      body: currentLocation == null
          ? Center(child: Text('loading'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!)),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                Marker(
                  markerId: MarkerId('source'),
                  position: sourceLocation,
                ),
                Marker(
                  markerId: MarkerId('currentlocation'),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: destination,
                ),
              },
            ),
    );
  }
}
