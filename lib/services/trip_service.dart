import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_service.dart';

class TripService extends BaseService {
  // Create a new trip
  Future<DocumentReference> createTrip({
    required String bookingId,
    required String driverId,
    required String vehicleId,
    required String studentId,
    required String pickupAddress,
    required String dropoffAddress,
    required DateTime scheduledTime,
  }) async {
    try {
      return await addDocument('trips', {
        'bookingId': bookingId,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'studentId': studentId,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'scheduledTime': scheduledTime,
        'status': 'scheduled',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'startTime': null,
        'endTime': null,
        'distance': null,
        'duration': null,
      });
    } catch (e) {
      print('Error creating trip: $e');
      throw Exception('Failed to create trip');
    }
  }

  // Start trip
  Future<void> startTrip(String tripId) async {
    try {
      final now = DateTime.now();
      await updateUserData(tripId, {
        'status': 'in_progress',
        'startTime': now,
        'updatedAt': now,
      });
    } catch (e) {
      print('Error starting trip: $e');
      throw Exception('Failed to start trip');
    }
  }

  // End trip
  Future<void> endTrip(
    String tripId, {
    required double distance,
    required int duration,
  }) async {
    try {
      final now = DateTime.now();
      await updateUserData(tripId, {
        'status': 'completed',
        'endTime': now,
        'distance': distance,
        'duration': duration,
        'updatedAt': now,
      });
    } catch (e) {
      print('Error ending trip: $e');
      throw Exception('Failed to end trip');
    }
  }

  // Cancel trip
  Future<void> cancelTrip(String tripId, {String? reason}) async {
    try {
      await updateUserData(tripId, {
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error cancelling trip: $e');
      throw Exception('Failed to cancel trip');
    }
  }

  // Get trip details
  Future<DocumentSnapshot?> getTripDetails(String tripId) async {
    try {
      return await getDocument('trips', tripId);
    } catch (e) {
      print('Error getting trip details: $e');
      return null;
    }
  }

  // Get student's trips
  Stream<QuerySnapshot> getStudentTrips(String studentId) {
    return streamCollection(
      'trips',
      whereConditions: [
        ['studentId', '==', studentId],
      ],
      orderBy: 'scheduledTime',
      descending: true,
    );
  }

  // Get driver's trips
  Stream<QuerySnapshot> getDriverTrips(String driverId) {
    return streamCollection(
      'trips',
      whereConditions: [
        ['driverId', '==', driverId],
      ],
      orderBy: 'scheduledTime',
      descending: true,
    );
  }

  // Get active trips
  Stream<QuerySnapshot> getActiveTrips() {
    return streamCollection(
      'trips',
      whereConditions: [
        ['status', '==', 'in_progress'],
      ],
      orderBy: 'startTime',
      descending: true,
    );
  }

  // Get scheduled trips
  Stream<QuerySnapshot> getScheduledTrips() {
    final now = DateTime.now();
    return streamCollection(
      'trips',
      whereConditions: [
        ['status', '==', 'scheduled'],
        ['scheduledTime', '>=', now],
      ],
      orderBy: 'scheduledTime',
    );
  }

  // Get completed trips
  Stream<QuerySnapshot> getCompletedTrips({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<List<dynamic>> conditions = [
      ['status', '==', 'completed'],
    ];

    if (startDate != null) {
      conditions.add(['endTime', '>=', startDate]);
    }

    if (endDate != null) {
      conditions.add(['endTime', '<=', endDate]);
    }

    return streamCollection(
      'trips',
      whereConditions: conditions,
      orderBy: 'endTime',
      descending: true,
    );
  }

  // Update trip location
  Future<void> updateTripLocation(
    String tripId, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      await updateUserData(tripId, {
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now(),
        },
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating trip location: $e');
      throw Exception('Failed to update trip location');
    }
  }

  // Add trip checkpoint
  Future<void> addTripCheckpoint(
    String tripId, {
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      final checkpoint = {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
        'timestamp': DateTime.now(),
      };

      final trip = await getDocument('trips', tripId);
      if (trip == null) throw Exception('Trip not found');

      List<Map<String, dynamic>> checkpoints =
          List<Map<String, dynamic>>.from(trip.get('checkpoints') ?? []);
      checkpoints.add(checkpoint);

      await updateUserData(tripId, {
        'checkpoints': checkpoints,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error adding trip checkpoint: $e');
      throw Exception('Failed to add trip checkpoint');
    }
  }
}
