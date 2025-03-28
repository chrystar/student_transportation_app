import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus { scheduled, inProgress, completed, cancelled }

class TripModel {
  final String id;
  final String studentId;
  final String driverId;
  final String parentId;
  final DateTime pickupTime;
  final GeoPoint pickupLocation;
  final GeoPoint dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final TripStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? rating;
  final String? ratingComment;
  final String? driverName;
  final DateTime? estimatedArrival;
  final String? studentName;
  final int? passenger;

  TripModel({
    required this.id,
    required this.studentId,
    required this.driverId,
    required this.parentId,
    required this.pickupTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.passenger,
    this.checkInTime,
    this.checkOutTime,
    this.rating,
    this.ratingComment,
    this.driverName,
    this.estimatedArrival,
    this.studentName,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'studentId': studentId,
  //     'driverId': driverId,
  //     'parentId': parentId,
  //     'pickupTime': pickupTime,
  //     'pickupLocation': pickupLocation,
  //     'dropoffLocation': dropoffLocation,
  //     'pickupAddress': pickupAddress,
  //     'dropoffAddress': dropoffAddress,
  //     'status': status.toString(),
  //     'checkInTime': checkInTime,
  //     'checkOutTime': checkOutTime,
  //     'rating': rating,
  //     'ratingComment': ratingComment,
  //     'driverName': driverName,
  //     'estimatedArrival': estimatedArrival,
  //     'studentName': studentName,
  //     'passengers': passenger,
  //   };
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'driverId': driverId,
      'parentId': parentId,
      'pickupTime': pickupTime.toIso8601String(), // Convert DateTime to String
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      }, // Serialize GeoPoint
      'dropoffLocation': {
        'latitude': dropoffLocation.latitude,
        'longitude': dropoffLocation.longitude,
      }, // Serialize GeoPoint
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'status': status.toString(), // Convert enum to String
      'passengers': passenger, // Ensure passengers is included
      'checkInTime': checkInTime?.toIso8601String(), // Nullable DateTime
      'checkOutTime': checkOutTime?.toIso8601String(), // Nullable DateTime
      'rating': rating,
      'ratingComment': ratingComment,
      'driverName': driverName,
      'estimatedArrival': estimatedArrival?.toIso8601String(), // Nullable DateTime
      'studentName': studentName,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map, String id) {
    return TripModel(
      id: id,
      studentId: map['studentId'],
      driverId: map['driverId'],
      parentId: map['parentId'],
      pickupTime: (map['pickupTime'] as Timestamp).toDate(),
      pickupLocation: map['pickupLocation'] as GeoPoint,
      dropoffLocation: map['dropoffLocation'] as GeoPoint,
      pickupAddress: map['pickupAddress'],
      dropoffAddress: map['dropoffAddress'],
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      checkInTime: map['checkInTime'] != null
          ? (map['checkInTime'] as Timestamp).toDate()
          : null,
      checkOutTime: map['checkOutTime'] != null
          ? (map['checkOutTime'] as Timestamp).toDate()
          : null,
      rating: map['rating']?.toDouble(),
      ratingComment: map['ratingComment'],
      driverName: map['driverName'] as String?,
      estimatedArrival: (map['estimatedArrival'] as Timestamp?)?.toDate(),
      studentName: map['studentName'] as String?,
      passenger: map['passenger'] ?? 1,
    );
  }
}
