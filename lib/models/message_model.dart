import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus {
  sent,
  delivered,
  read;

  @override
  String toString() => name;

  static MessageStatus fromString(String status) {
    return MessageStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => MessageStatus.sent,
    );
  }
}

class MessageModel {
  final String? id;
  final String studentId;
  final String studentName;
  final String message;
  final DateTime timestamp;
  final bool isEmergency;
  final String recipientType;
  final MessageStatus status;
  final bool read;

  MessageModel({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.message,
    required this.timestamp,
    required this.isEmergency,
    required this.recipientType,
    required this.status,
    required this.read,
  });

  // Create a MessageModel from a Map (usually from Firestore)
  factory MessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MessageModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isEmergency: map['isEmergency'] ?? false,
      recipientType: map['recipientType'] ?? 'admin',
      status: MessageStatus.fromString(map['status'] ?? ''),
      read: map['read'] ?? false,
    );
  }

  // Create a MessageModel from a DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel.fromMap(
      doc.data() as Map<String, dynamic>,
      id: doc.id,
    );
  }

  // Convert MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEmergency': isEmergency,
      'recipientType': recipientType,
      'status': status.toString(),
      'read': read,
    };
  }

  // Create a copy of MessageModel with some updated fields
  MessageModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? message,
    DateTime? timestamp,
    bool? isEmergency,
    String? recipientType,
    MessageStatus? status,
    bool? read,
  }) {
    return MessageModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isEmergency: isEmergency ?? this.isEmergency,
      recipientType: recipientType ?? this.recipientType,
      status: status ?? this.status,
      read: read ?? this.read,
    );
  }

  // Helper method to mark message as read
  MessageModel markAsRead() {
    return copyWith(
      status: MessageStatus.read,
      read: true,
    );
  }

  // Helper method to mark message as delivered
  MessageModel markAsDelivered() {
    return copyWith(
      status: MessageStatus.delivered,
    );
  }

  // Helper method to check if message is to admin
  bool get isToAdmin => recipientType.toLowerCase() == 'admin';

  // Helper method to check if message is to parent
  bool get isToParent => recipientType.toLowerCase() == 'parent';

  // Format timestamp for display
  String get formattedTime {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Format date for display
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, studentId: $studentId, studentName: $studentName, '
        'message: $message, timestamp: $timestamp, isEmergency: $isEmergency, '
        'recipientType: $recipientType, status: $status, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.id == id &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.isEmergency == isEmergency &&
        other.recipientType == recipientType &&
        other.status == status &&
        other.read == read;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        studentName.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        isEmergency.hashCode ^
        recipientType.hashCode ^
        status.hashCode ^
        read.hashCode;
  }
}
