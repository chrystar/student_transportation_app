import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_transportation_app/models/trip_model.dart';

class BookingProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  Stream<List<TripModel>> getTrip() async* { // Changed to async*
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      print('User not logged in.');
      yield []; // Emit an empty list
      return;
    }

    try {
      yield* _fireStore.collection('trips')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id)) // Pass QueryDocumentSnapshot
          .toList()); // toList() is now outside the inner map
    } catch (e) {
      print('Error fetching trip: $e');
      yield []; // Emit an empty list on error, or handle differently
    }
  }
}