// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; //  User UID from Firebase Auth
  final String name;
  final String email;
  final String phone;
  final String role; // e.g., 'patient', 'nurse'
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'patient', // Default role
    this.profileImageUrl,
  });

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (email.isNotEmpty) 'email': email,
      if (phone.isNotEmpty) 'phone': phone,
      if (role.isNotEmpty) 'role': role,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  // **** تم تعديل هذه الدالة ****
  // A factory constructor to create a UserModel from a Firestore document
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
    );
  }
}
