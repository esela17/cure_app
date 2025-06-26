import 'package:flutter/material.dart';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/screens/order_tracking_screen.dart';
import 'package:cure_app/utils/constants.dart';

class ActiveOrderBanner extends StatelessWidget {
  final Order order;

  const ActiveOrderBanner({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: order.id),
          ),
        );
      },
      child: Card(
        elevation: 8,
        color: kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.local_hospital_rounded,
                  color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateStatus(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اضغط لتتبع حالة الطلب رقم ${order.id.substring(0, 6)}...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'جاري البحث عن ممرض ';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'onTheWay':
        return 'الممرض في الطريق';
      case 'arrived':
        return 'وصل الممرض';
      case 'completed':
        return 'تم الانتهاء من الطلب';
      case 'cancelled':
        return 'تم إلغاء الطلب';
      default:
        return 'طلب جاري';
    }
  }
}
