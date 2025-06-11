import 'package:cure_app/models/order.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NurseOrderDetailsScreen extends StatelessWidget {
  final Order order;

  const NurseOrderDetailsScreen({Key? key, required this.order})
      : super(key: key);

  Widget _buildActionButtons(BuildContext context) {
    final nurseProvider = Provider.of<NurseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (nurseProvider.isLoading) {
      return const LoadingIndicator();
    }

    switch (order.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.check_circle),
                label: Text('قبول الطلب'),
                onPressed: () async {
                  final success = await nurseProvider.acceptOrder(
                      order, authProvider.currentUserProfile!);
                  if (success && context.mounted) {
                    showSnackBar(context, 'تم قبول الطلب بنجاح');
                    Navigator.of(context).pop();
                  } else if (context.mounted) {
                    showSnackBar(
                        context, nurseProvider.errorMessage ?? 'حدث خطأ',
                        isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.cancel),
                label: Text('رفض الطلب'),
                onPressed: () async {
                  final success = await nurseProvider.rejectOrder(order);
                  if (success && context.mounted) {
                    showSnackBar(context, 'تم رفض الطلب');
                    Navigator.of(context).pop();
                  } else if (context.mounted) {
                    showSnackBar(
                        context, nurseProvider.errorMessage ?? 'حدث خطأ',
                        isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        );
      case 'accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.task_alt),
            label: Text('إنهاء الخدمة'),
            onPressed: () async {
              final success = await nurseProvider.completeOrder(order);
              if (success && context.mounted) {
                showSnackBar(context, 'تم إنهاء الخدمة بنجاح');
                Navigator.of(context).pop();
              } else if (context.mounted) {
                showSnackBar(context, nurseProvider.errorMessage ?? 'حدث خطأ',
                    isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        );
      default:
        return Center(
          child: Chip(
            label: Text('حالة الطلب: ${order.status}',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('طلب من: ${order.patientName}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('تاريخ الطلب: ${formatDateTime(order.orderDate)}'),
            const Divider(height: 32),
            _buildDetailRow(Icons.person, 'اسم المريض', order.patientName),
            _buildDetailRow(Icons.phone, 'رقم الهاتف', order.phoneNumber),
            _buildDetailRow(
                Icons.location_on, 'العنوان', order.deliveryAddress),
            const Divider(height: 32),
            Text('الخدمات المطلوبة:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...order.services.map((service) => ListTile(
                  leading: Icon(Icons.medical_services_outlined),
                  title: Text(service.name),
                  trailing: Text('${service.price.toStringAsFixed(2)} جنيه'),
                )),
            const Divider(height: 32),
            _buildDetailRow(Icons.money, 'الإجمالي',
                '${order.totalPrice.toStringAsFixed(2)} جنيه مصري'),
            if (order.notes != null && order.notes!.isNotEmpty)
              _buildDetailRow(Icons.notes, 'ملاحظات', order.notes!),
            const SizedBox(height: 40),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
              child:
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(value)),
        ],
      ),
    );
  }
}
