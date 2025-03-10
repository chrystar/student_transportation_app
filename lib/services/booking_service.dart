import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_service.dart';

class BookingService extends BaseService {
  // Create a new booking
  Future<DocumentReference> createBooking({
    required String pickupAddress,
    required String dropoffAddress,
    required DateTime pickupTime,
    required String studentId,
    String? driverId,
    String? vehicleId,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      return await addDocument('bookings', {
        'studentId': studentId,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'pickupTime': pickupTime,
        'status': 'pending',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Failed to create booking');
    }
  }

  // Get bookings for a student
  Stream<QuerySnapshot> getStudentBookings(String studentId) {
    return streamCollection(
      'bookings',
      whereConditions: [
        ['studentId', '==', studentId],
      ],
      orderBy: 'pickupTime',
      descending: true,
    );
  }

  // Get bookings for a driver
  Stream<QuerySnapshot> getDriverBookings(String driverId) {
    return streamCollection(
      'bookings',
      whereConditions: [
        ['driverId', '==', driverId],
        ['status', '!=', 'completed'],
      ],
      orderBy: 'pickupTime',
    );
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await updateUserData(bookingId, {
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status');
    }
  }

  // Assign driver to booking
  Future<void> assignDriver(
      String bookingId, String driverId, String vehicleId) async {
    try {
      await updateUserData(bookingId, {
        'driverId': driverId,
        'vehicleId': vehicleId,
        'status': 'assigned',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error assigning driver: $e');
      throw Exception('Failed to assign driver');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateUserData(bookingId, {
        'status': 'cancelled',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Failed to cancel booking');
    }
  }

  // Complete booking
  Future<void> completeBooking(String bookingId) async {
    try {
      await updateUserData(bookingId, {
        'status': 'completed',
        'completedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error completing booking: $e');
      throw Exception('Failed to complete booking');
    }
  }

  // Get booking details
  Future<DocumentSnapshot?> getBookingDetails(String bookingId) async {
    try {
      return await getDocument('bookings', bookingId);
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }

  // Get upcoming bookings
  Stream<QuerySnapshot> getUpcomingBookings(String studentId) {
    final now = DateTime.now();
    return streamCollection(
      'bookings',
      whereConditions: [
        ['studentId', '==', studentId],
        ['pickupTime', '>=', now],
        ['status', '==', 'pending'],
      ],
      orderBy: 'pickupTime',
    );
  }

  // Get completed bookings
  Stream<QuerySnapshot> getCompletedBookings(String studentId) {
    return streamCollection(
      'bookings',
      whereConditions: [
        ['studentId', '==', studentId],
        ['status', '==', 'completed'],
      ],
      orderBy: 'completedAt',
      descending: true,
    );
  }
}
