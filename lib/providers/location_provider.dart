import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Position? _currentPosition;
  bool _isTracking = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get error => _error;

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled';
      notifyListeners();
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permissions are denied';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> startTracking() async {
    if (!await _handlePermission()) return;

    _isTracking = true;
    _error = null;
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      _currentPosition = position;
      await _updateLocation(position);
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isTracking = false;
      notifyListeners();
    });
  }

  Future<void> _updateLocation(Position position) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('locations').doc(user.uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      _error = 'Failed to update location: $e';
      notifyListeners();
    }
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  Future<Position?> getCurrentLocation() async {
    if (!await _handlePermission()) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      _error = null;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
