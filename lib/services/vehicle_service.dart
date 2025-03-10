import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_service.dart';

class VehicleService extends BaseService {
  // Add a new vehicle
  Future<DocumentReference> addVehicle({
    required String registrationNumber,
    required String model,
    required int capacity,
    required String driverId,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
  }) async {
    try {
      return await addDocument('vehicles', {
        'registrationNumber': registrationNumber,
        'model': model,
        'capacity': capacity,
        'driverId': driverId,
        'insuranceNumber': insuranceNumber,
        'insuranceExpiry': insuranceExpiry,
        'status': 'active',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error adding vehicle: $e');
      throw Exception('Failed to add vehicle');
    }
  }

  // Update vehicle details
  Future<void> updateVehicle(
      String vehicleId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await updateUserData(vehicleId, data);
    } catch (e) {
      print('Error updating vehicle: $e');
      throw Exception('Failed to update vehicle');
    }
  }

  // Get vehicle details
  Future<DocumentSnapshot?> getVehicleDetails(String vehicleId) async {
    try {
      return await getDocument('vehicles', vehicleId);
    } catch (e) {
      print('Error getting vehicle details: $e');
      return null;
    }
  }

  // Get vehicles by driver
  Stream<QuerySnapshot> getDriverVehicles(String driverId) {
    return streamCollection(
      'vehicles',
      whereConditions: [
        ['driverId', '==', driverId],
        ['status', '==', 'active'],
      ],
    );
  }

  // Get all active vehicles
  Stream<QuerySnapshot> getActiveVehicles() {
    return streamCollection(
      'vehicles',
      whereConditions: [
        ['status', '==', 'active'],
      ],
    );
  }

  // Deactivate vehicle
  Future<void> deactivateVehicle(String vehicleId) async {
    try {
      await updateUserData(vehicleId, {
        'status': 'inactive',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error deactivating vehicle: $e');
      throw Exception('Failed to deactivate vehicle');
    }
  }

  // Activate vehicle
  Future<void> activateVehicle(String vehicleId) async {
    try {
      await updateUserData(vehicleId, {
        'status': 'active',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error activating vehicle: $e');
      throw Exception('Failed to activate vehicle');
    }
  }

  // Check if vehicle exists
  Future<bool> checkVehicleExists(String registrationNumber) async {
    try {
      final snapshot = await getCollection(
        'vehicles',
        whereConditions: [
          ['registrationNumber', '==', registrationNumber],
        ],
      );
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking vehicle existence: $e');
      return false;
    }
  }

  // Get vehicles with expired insurance
  Stream<QuerySnapshot> getVehiclesWithExpiredInsurance() {
    final now = DateTime.now();
    return streamCollection(
      'vehicles',
      whereConditions: [
        ['insuranceExpiry', '<=', now],
        ['status', '==', 'active'],
      ],
      orderBy: 'insuranceExpiry',
    );
  }

  // Get vehicles by capacity range
  Stream<QuerySnapshot> getVehiclesByCapacityRange(
      int minCapacity, int maxCapacity) {
    return streamCollection(
      'vehicles',
      whereConditions: [
        ['capacity', '>=', minCapacity],
        ['capacity', '<=', maxCapacity],
        ['status', '==', 'active'],
      ],
      orderBy: 'capacity',
    );
  }
}
