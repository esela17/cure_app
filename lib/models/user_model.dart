import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImageUrl;
  final bool isAvailable;
  final String? fcmToken;
  final double averageRating; // <-- إضافة جديدة
  final int ratingCount; // <-- إضافة جديدة
  final String? specialization;
  final int jobCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'patient',
    this.profileImageUrl,
    this.isAvailable = true,
    this.fcmToken,
    this.averageRating = 0.0, // <-- قيمة افتراضية
    this.ratingCount = 0, // <-- قيمة افتراضية
    this.specialization,
    this.jobCount = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'isAvailable': isAvailable,
      'fcmToken': fcmToken,
      'averageRating': averageRating, // <-- إضافة جديدة
      'ratingCount': ratingCount, // <-- إضافة جديدة
      'specialization': specialization,
      'jobCount': jobCount,
    };
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError("Missing data for userId: ${snapshot.id}");
    }
    return UserModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'patient',
      profileImageUrl: data['profileImageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      fcmToken: data['fcmToken'],
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] ?? 0,
      specialization: data['specialization'],
      jobCount: data['jobCount'] ?? 0,
    );
  }
}
