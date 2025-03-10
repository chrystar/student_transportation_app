import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'messages';

  // Stream of messages for a student
  Stream<List<MessageModel>> getStudentMessages(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromDocument(doc))
            .toList());
  }

  // Stream of messages for a parent's children
  Stream<List<MessageModel>> getParentMessages(List<String> childrenIds) {
    return _firestore
        .collection(_collection)
        .where('studentId', whereIn: childrenIds)
        .where('recipientType', isEqualTo: 'parent')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromDocument(doc))
            .toList());
  }

  // Send a new message
  Future<void> sendMessage(MessageModel message) async {
    await _firestore.collection(_collection).add(message.toMap());
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _firestore.collection(_collection).doc(messageId).update({
      'status': MessageStatus.read.toString(),
      'read': true,
    });
  }

  // Delete a message (admin only)
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection(_collection).doc(messageId).delete();
  }

  // Get unread messages count
  Stream<int> getUnreadMessagesCount(
      String recipientType, List<String> studentIds) {
    return _firestore
        .collection(_collection)
        .where('recipientType', isEqualTo: recipientType)
        .where('studentId', whereIn: studentIds)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
