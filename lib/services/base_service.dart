import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<DocumentSnapshot?> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  // Delete document from Firestore
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Failed to delete document');
    }
  }

  // Add document to Firestore
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      print('Error adding document: $e');
      throw Exception('Failed to add document');
    }
  }

  // Get document from Firestore
  Future<DocumentSnapshot?> getDocument(
      String collection, String documentId) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  // Get collection from Firestore with query
  Future<QuerySnapshot> getCollection(
    String collection, {
    List<List<dynamic>> whereConditions = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      for (var condition in whereConditions) {
        if (condition.length == 3) {
          query = query.where(
            condition[0] as String,
            isEqualTo: condition[1] == '==' ? condition[2] : null,
            isGreaterThan: condition[1] == '>' ? condition[2] : null,
            isLessThan: condition[1] == '<' ? condition[2] : null,
            isGreaterThanOrEqualTo: condition[1] == '>=' ? condition[2] : null,
            isLessThanOrEqualTo: condition[1] == '<=' ? condition[2] : null,
            arrayContains:
                condition[1] == 'array-contains' ? condition[2] : null,
          );
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting collection: $e');
      throw Exception('Failed to get collection');
    }
  }

  // Stream document changes from Firestore
  Stream<DocumentSnapshot> streamDocument(
      String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  // Stream collection changes from Firestore
  Stream<QuerySnapshot> streamCollection(
    String collection, {
    List<List<dynamic>> whereConditions = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    for (var condition in whereConditions) {
      if (condition.length == 3) {
        query = query.where(
          condition[0] as String,
          isEqualTo: condition[1] == '==' ? condition[2] : null,
          isGreaterThan: condition[1] == '>' ? condition[2] : null,
          isLessThan: condition[1] == '<' ? condition[2] : null,
          isGreaterThanOrEqualTo: condition[1] == '>=' ? condition[2] : null,
          isLessThanOrEqualTo: condition[1] == '<=' ? condition[2] : null,
          arrayContains: condition[1] == 'array-contains' ? condition[2] : null,
        );
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }
}
