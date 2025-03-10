import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'base_service.dart';

class LocationService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isTracking = false;
  Position? _lastPosition;
  Stream<Position>? _positionStream;

  Future<bool> initialize() async {
    try {
      await handleLocationPermission();
      _lastPosition = await getCurrentLocation();
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  // Start real-time location updates for drivers
  Stream<Position> startLocationUpdates() {
    _isTracking = true;
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    return _positionStream!;
  }

  // Update driver's location in Firestore
  Future<void> updateDriverLocation(String driverId, Position position) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
      'heading': position.heading,
      'speed': position.speed,
    });
  }

  // Get driver's location
  Stream<DocumentSnapshot> getDriverLocation(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots();
  }

  // Get nearby drivers
  Future<List<DocumentSnapshot>> getNearbyDrivers(
      LatLng location, double radiusInKm) async {
    // Create a GeoPoint from the location
    final center = GeoPoint(location.latitude, location.longitude);

    // Calculate the bounding box for the query
    final lat = 0.0144927536231884; // approximately 1 degree = 111 kilometers
    final lngDelta = lat / cos(location.latitude * (pi / 180));

    final latDelta = (radiusInKm / 111.0);

    final querySnapshot = await _firestore
        .collection('drivers')
        .where('location.latitude',
            isGreaterThan: center.latitude - latDelta,
            isLessThan: center.latitude + latDelta)
        .where('location.longitude',
            isGreaterThan: center.longitude - lngDelta,
            isLessThan: center.longitude + lngDelta)
        .where('isAvailable', isEqualTo: true)
        .get();

    return querySnapshot.docs;
  }

  // Stop location updates
  void stopLocationUpdates() {
    _isTracking = false;
  }

  // Check and request location permissions
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return true;
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    await handleLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  // Update user location in Firestore
  Future<void> updateUserLocation(Position position) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      await addDocument('locations', {
        'userId': user.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now(),
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'heading': position.heading,
      });
    } catch (e) {
      print('Error updating location: $e');
      throw Exception('Failed to update location');
    }
  }

  // Get user's last known location
  Future<Position?> getLastKnownLocation(String userId) async {
    try {
      final snapshot = await getCollection(
        'locations',
        whereConditions: [
          ['userId', '==', userId],
        ],
        orderBy: 'timestamp',
        descending: true,
        limit: 1,
      );

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return Position.fromMap(data);
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  // Stream user location updates
  Stream<Position?> streamUserLocation(String userId) {
    return streamCollection(
      'locations',
      whereConditions: [
        ['userId', '==', userId],
      ],
      orderBy: 'timestamp',
      descending: true,
      limit: 1,
    ).map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return Position.fromMap(data);
    });
  }

  // Check if user is within radius of a point
  bool isWithinRadius(
      Position userLocation, Position center, double radiusInMeters) {
    return Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          center.latitude,
          center.longitude,
        ) <=
        radiusInMeters;
  }
}
