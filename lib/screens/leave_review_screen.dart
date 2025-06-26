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
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تقييم الخدمة', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ما هو تقييمك للخدمة المقدمة من الممرض "${widget.order.nurseName ?? ''}"؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'أضف تعليقًا (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              Consumer<OrdersProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: provider.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success =
                                        await ordersProvider.submitReview(
                                      order: widget.order,
                                      rating: _rating,
                                      comment: _commentController.text.trim(),
                                    );
                                    if (success && mounted) {
                                      showSnackBar(context, 'شكرًا لتقييمك!');
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    } else if (mounted) {
                                      showSnackBar(
                                        context,
                                        ordersProvider.errorMessage ??
                                            'حدث خطأ',
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                                child: const Text('إرسال التقييم'),
                              ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('العودة إلى الرئيسية بدون تقييم'),
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
    );
  }
}
