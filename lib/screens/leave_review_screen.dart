import 'package:cure_app/models/order.dart';
import 'package:cure_app/providers/orders_provider.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cure_app/screens/home_screen.dart';

class LeaveReviewScreen extends StatefulWidget {
  final Order order;
  const LeaveReviewScreen({super.key, required this.order});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  double _rating = 0.0; // Start with no rating to encourage user selection
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasUserRated = false; // Track if user has interacted with rating

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'ممتاز';
    if (rating >= 3.5) return 'جيد جداً';
    if (rating >= 2.5) return 'جيد';
    if (rating >= 1.5) return 'مقبول';
    if (rating >= 1.0) return 'ضعيف';
    return 'اختر تقييمك';
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تقييم الخدمة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'التقييم',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ما هو تقييمك للخدمة المقدمة من الممرض "${widget.order.nurseName ?? ''}"؟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Rating section with enhanced UI
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 40,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: _rating > index
                                  ? Colors.amber
                                  : Colors.grey[300],
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                                _hasUserRated = true;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getRatingText(_rating),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _hasUserRated
                                  ? theme.primaryColor
                                  : Colors.grey,
                            ),
                          ),
                          if (!_hasUserRated)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'اضغط على النجوم لإعطاء تقييمك',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Comment section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.comment,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'اكتب رأيك في الخدمة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'شاركنا تجربتك مع الخدمة المقدمة...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: theme.primaryColor),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 4,
                            maxLength: 500,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Consumer<OrdersProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: provider.isLoading
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color:
                                            theme.primaryColor.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _hasUserRated
                                          ? () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final success =
                                                    await ordersProvider
                                                        .submitReview(
                                                  order: widget.order,
                                                  rating: _rating,
                                                  comment: _commentController
                                                      .text
                                                      .trim(),
                                                );
                                                if (success && mounted) {
                                                  showSnackBar(context,
                                                      'شكرًا لتقييمك!');
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomeScreen(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                } else if (mounted) {
                                                  showSnackBar(
                                                    context,
                                                    ordersProvider
                                                            .errorMessage ??
                                                        'حدث خطأ',
                                                    isError: true,
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'إرسال التقيم',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.primaryColor,
                                  side: BorderSide(color: theme.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  "العودة للرئيسة بدون تقيم",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
