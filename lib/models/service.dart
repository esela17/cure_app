import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final int durationMinutes;
  final String? safetyScore;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.durationMinutes,
    this.safetyScore,
  });

  // تحويل بيانات Firestore إلى كائن Service
  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Service(
      id: snapshot.id,
      name: data?['name'] ?? '',
      price: (data?['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data?['imageUrl'] ?? '',
      description: data?['description'] ?? '',
      durationMinutes: data?['durationMinutes'] ?? 0,
      safetyScore: data?['safetyScore'],
    );
  }

  // تحويل كائن Service إلى Map ليتم حفظه في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'durationMinutes': durationMinutes,
      'safetyScore': safetyScore,
    };
  }
}
