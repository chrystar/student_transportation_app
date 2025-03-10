import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInOutController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordCheckInOut({
    required String tripId,
    required String studentId,
    required String type,
  }) async {
    await _firestore.collection('check_records').add({
      'tripId': tripId,
      'studentId': studentId,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (type == 'check_in') {
      await _firestore.collection('trips').doc(tripId).update({
        'checkInTime': FieldValue.serverTimestamp(),
      });
    } else {
      await _firestore.collection('trips').doc(tripId).update({
        'checkOutTime': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
    }
  }
}
