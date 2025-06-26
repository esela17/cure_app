import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final double rating;
  final String comment;
  final String patientName;
  final Timestamp timestamp;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.patientName,
    required this.timestamp,
  });

  factory ReviewModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReviewModel(
      id: doc.id,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      patientName: data['patientName'] ?? 'مريض',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
