import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImageUrl;
  final bool isAvailable;
  final String? fcmToken; // <-- إضافة جديدة

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'patient',
    this.profileImageUrl,
    this.isAvailable = true,
    this.fcmToken, // <-- إضافة جديدة
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'isAvailable': isAvailable,
      'fcmToken': fcmToken, // <-- إضافة جديدة
    };
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      id: snapshot.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      phone: data?['phone'] ?? '',
      role: data?['role'] ?? 'patient',
      profileImageUrl: data?['profileImageUrl'],
      isAvailable: data?['isAvailable'] ?? true,
      fcmToken: data?['fcmToken'], // <-- إضافة جديدة
    );
  }
}
