import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, parent, driver, admin }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toString(),
      'profileImage': profileImage,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
      ),
      profileImage: map['profileImage'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
}
