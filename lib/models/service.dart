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

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      safetyScore: map['safetyScore'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'durationMinutes': durationMinutes,
      'safetyScore': safetyScore,
    };
  }

  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    // --- تم التعديل هنا ليصبح أكثر أمانًا ---
    final data = snapshot.data();
    if (data == null) {
      throw StateError("Missing data for serviceId: ${snapshot.id}");
    }
    // ------------------------------------

    return Service(
      id: snapshot.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      safetyScore: data['safetyScore'],
    );
  }

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
