import 'package:cure_app/models/order.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NurseOrderDetailsScreen extends StatelessWidget {
  final Order initialOrder;

  const NurseOrderDetailsScreen({super.key, required this.initialOrder});

  // دالة فتح تطبيق الخرائط
  Future<void> _launchMapFromOrder(Order order, BuildContext context) async {
    try {
      Uri? mapUri;

      if (order.locationLat != null && order.locationLng != null) {
        mapUri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${order.locationLat},${order.locationLng}');
      } else {
        final String query = Uri.encodeComponent(order.deliveryAddress);
        mapUri =
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      }

      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri);
      } else {
        throw 'Could not launch map';
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'لا يمكن فتح تطبيق الخرائط', isError: true);
      }
    }
  }

  // دالة الاتصال
  Future<void> _launchPhone(String phoneNumber, BuildContext context) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } else {
        throw 'Could not launch $phoneUrl';
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'لا يمكن فتح تطبيق الهاتف', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تفاصيل الطلب', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<Order>(
        stream: firestoreService.getOrderStream(initialOrder.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('لا يمكن تحميل تفاصيل الطلب.'));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('معلومات الطلب',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              )),
                    ),
                    const SizedBox(height: 16),

                    // عرض جميع التفاصيل
                    _buildDetailRow(
                        Icons.person, 'اسم المريض', order.patientName),
                    _buildDetailRow(
                        Icons.phone, 'رقم الهاتف', order.phoneNumber,
                        trailing: IconButton(
                          icon: const Icon(Icons.phone_in_talk,
                              color: Colors.green),
                          onPressed: () =>
                              _launchPhone(order.phoneNumber, context),
                        )),
                    _buildDetailRow(
                        Icons.location_on, 'العنوان', order.deliveryAddress,
                        trailing: IconButton(
                          icon: const Icon(Icons.map_outlined,
                              color: Colors.blue),
                          onPressed: () => _launchMapFromOrder(order, context),
                        )),
                    _buildDetailRow(Icons.date_range, 'تاريخ الطلب',
                        formatDateTime(order.orderDate)),
                    if (order.appointmentDate != null)
                      _buildDetailRow(Icons.access_time_filled, 'موعد الخدمة',
                          formatDateTime(order.appointmentDate!)),
                    if (order.serviceProviderType != 'غير محدد' &&
                        order.serviceProviderType != null)
                      _buildDetailRow(
                          Icons.wc, 'تفضيل المريض', order.serviceProviderType!),

                    const Divider(height: 32),
                    Text('الخدمات المطلوبة:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            )),
                    const SizedBox(height: 8),
                    ...order.services.map((service) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.medical_services_outlined,
                                color: Colors.teal),
                            title: Text(service.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing:
                                Text('${service.price.toStringAsFixed(2)} ج.م'),
                          ),
                        )),
                    const Divider(height: 32),
                    _buildDetailRow(Icons.money, 'الإجمالي',
                        '${order.totalPrice.toStringAsFixed(2)} ج.م'),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _buildDetailRow(Icons.notes, 'ملاحظات', order.notes!),

                    const SizedBox(height: 30),
                    _buildActionButtons(context, order),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
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
                icon: const Icon(Icons.check_circle),
                label: const Text('قبول الطلب'),
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
                icon: const Icon(Icons.cancel),
                label: const Text('رفض الطلب'),
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
            icon: const Icon(Icons.location_on_sharp),
            label: const Text('لقد وصلت'),
            onPressed: () => nurseProvider.markAsArrived(order),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
          ),
        );
      case 'arrived':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.task_alt),
            label: const Text('إنهاء الخدمة'),
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
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey,
          ),
        );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(value,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87))),
                  if (trailing != null) trailing,
                ],
              )),
        ],
      ),
    );
  }
}
