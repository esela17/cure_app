import 'package:cure_app/models/review_model.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AllReviewsScreen extends StatelessWidget {
  final List<ReviewModel> reviews;
  final String nurseName;

  const AllReviewsScreen({
    super.key,
    required this.reviews,
    required this.nurseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('تقييمات $nurseName', style: TextStyle(color: Colors.white)),
      ),
      body: reviews.isEmpty
          ? const EmptyState(message: 'لا توجد تقييمات لهذا الممرض بعد.')
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.patientName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatDateTime(review.timestamp.toDate()),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: review.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        if (review.comment.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              '"${review.comment}"',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
