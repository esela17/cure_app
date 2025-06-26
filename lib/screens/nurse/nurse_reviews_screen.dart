import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cure_app/models/review_model.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class NurseReviewsScreen extends StatelessWidget {
  final String nurseId;
  const NurseReviewsScreen({super.key, required this.nurseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تقييمات المرضى', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: FirestoreService().getReviewsForNurse(nurseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('لا توجد تقييمات حتى الآن.'),
            );
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: review.rating,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 24.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment),
                      const SizedBox(height: 4),
                      Text(
                        formatTimestamp(review.timestamp),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
