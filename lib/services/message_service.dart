import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'base_service.dart';

class MessageService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get user's role
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Get available contacts based on user role
  Stream<QuerySnapshot> getContacts(String userRole) {
    switch (userRole) {
      case 'student':
        return _firestore
            .collection('users')
            .where('role', whereIn: ['driver', 'admin']).snapshots();
      case 'parent':
        return _firestore
            .collection('users')
            .where('role', whereIn: ['driver', 'admin']).snapshots();
      case 'driver':
        return _firestore
            .collection('users')
            .where('role', whereIn: ['admin']).snapshots();
      case 'admin':
        return _firestore.collection('users').snapshots();
      default:
        return const Stream.empty();
    }
  }

  // Get messages for the current user
  Stream<QuerySnapshot> getMessages() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a new message
  Future<void> sendMessage({
    required String content,
    required String recipientId,
    required String recipientRole,
    File? imageFile,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await getUserData(user.uid);
      if (userDoc == null) throw Exception('User data not found');

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      await addDocument('messages', {
        'content': content,
        'imageUrl': imageUrl,
        'senderId': user.uid,
        'senderName': userDoc.get('name'),
        'senderRole': userDoc.get('role'),
        'recipientId': recipientId,
        'recipientRole': recipientRole,
        'timestamp': DateTime.now(),
        'isRead': false,
      });
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      final ref = _storage.ref().child('message_images/${DateTime.now()}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  // Stream messages for a user
  Stream<QuerySnapshot> streamUserMessages({
    required String userId,
    String? recipientId,
    bool unreadOnly = false,
  }) {
    List<List<dynamic>> conditions = [
      ['recipientId', '==', userId],
    ];

    if (recipientId != null) {
      conditions.add(['senderId', '==', recipientId]);
    }

    if (unreadOnly) {
      conditions.add(['isRead', '==', false]);
    }

    return streamCollection(
      'messages',
      whereConditions: conditions,
      orderBy: 'timestamp',
      descending: true,
    );
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await updateUserData(messageId, {'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
      throw Exception('Failed to mark message as read');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      final message = await getDocument('messages', messageId);
      if (message == null) throw Exception('Message not found');

      final imageUrl = message.get('imageUrl') as String?;
      if (imageUrl != null) {
        await _deleteImage(imageUrl);
      }

      await deleteDocument('messages', messageId);
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message');
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw here as the message deletion should still proceed
    }
  }
}
