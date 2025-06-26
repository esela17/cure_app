import 'package:cure_app/models/service.dart';
import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              service.imageUrl,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey.shade300,
                child: Icon(Icons.image_not_supported,
                    size: 50, color: Colors.grey.shade600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${service.price.toStringAsFixed(2)} جنيه مصري',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),
                  Text(
                    'الوصف',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'المدة المتوقعة: ${service.durationMinutes} دقيقة',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text('إضافة إلى السلة',
              style: TextStyle(fontSize: 18, color: Colors.white)),
          onPressed: () {
            cartProvider.addItem(service);
            showSnackBar(
                context, 'تمت إضافة "${service.name}" إلى السلة بنجاح!');
            Navigator.of(context)
                .pop(); // العودة إلى الشاشة الرئيسية بعد الإضافة
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}
