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

  // --- This is the new method to convert a Service object to a Map ---
  // It will be used when saving an Order to Firestore.
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

  // --- This method allows creating a Service from a Map ---
  // We use this when reading an Order from Firestore.
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

  // This factory converts a Firestore document into a Service object
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

  // This method converts a Service object to be saved as a main document in Firestore
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
