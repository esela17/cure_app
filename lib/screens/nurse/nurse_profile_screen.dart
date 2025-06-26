import 'package:cure_app/models/user_model.dart';
import 'package:cure_app/providers/nurse_profile_provider.dart';
import 'package:cure_app/screens/all_reviews_screen.dart'; // <-- New import
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class NurseProfileScreen extends StatefulWidget {
  final String nurseId;
  const NurseProfileScreen({super.key, required this.nurseId});

  @override
  State<NurseProfileScreen> createState() => _NurseProfileScreenState();
}

class _NurseProfileScreenState extends State<NurseProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<NurseProfileProvider>(context, listen: false)
          .fetchNurseProfileAndReviews(widget.nurseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي للممرض',
            style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<NurseProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }
          if (provider.errorMessage != null) {
            return ErrorMessage(message: provider.errorMessage!);
          }
          if (provider.nurseProfile == null) {
            return const EmptyState(message: 'لا توجد بيانات لهذا الممرض.');
          }

          final nurse = provider.nurseProfile!;
          final reviews = provider.reviews;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Nurse profile header
              _buildProfileHeader(context, nurse),
              const Divider(height: 32),

              // Reviews section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقييمات والمراجعات',
                      style: Theme.of(context).textTheme.titleLarge),
                  // --- This is the new button ---
                  if (reviews.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllReviewsScreen(
                              reviews: reviews,
                              nurseName: nurse.name,
                            ),
                          ),
                        );
                      },
                      child: const Text('عرض الكل'),
                    ),
                  // ------------------------------
                ],
              ),
              const SizedBox(height: 16),

              if (reviews.isEmpty)
                const EmptyState(message: 'لا توجد تقييمات لهذا الممرض بعد.')
              else
                // Display the first 1 or 2 reviews as a preview
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length > 2
                      ? 2
                      : reviews.length, // Show max 2 reviews
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(review.patientName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(formatDateTime(review.timestamp.toDate()),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RatingBarIndicator(
                              rating: review.rating,
                              itemBuilder: (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 18.0,
                            ),
                            if (review.comment.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(review.comment,
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel nurse) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: nurse.profileImageUrl != null
              ? NetworkImage(nurse.profileImageUrl!)
              : null,
          child: nurse.profileImageUrl == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          nurse.name,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (nurse.specialization != null && nurse.specialization!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              nurse.specialization!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade700),
            ),
          ),
        const SizedBox(height: 16),
        RatingBarIndicator(
          rating: nurse.averageRating,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 25.0,
        ),
        Text(
            '${nurse.averageRating.toStringAsFixed(1)} (${nurse.ratingCount} تقييم)'),
      ],
    );
  }
}
