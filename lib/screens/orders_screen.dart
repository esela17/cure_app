import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cure_app/providers/orders_provider.dart';
import 'package:cure_app/models/order.dart'; // تأكد من استيراد نموذج الطلب
import 'package:cure_app/utils/constants.dart'; // لاستخدام الألوان
import 'package:cure_app/utils/helpers.dart'; // لاستخدام formatDateTime
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:cure_app/widgets/empty_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // بما أن OrdersProvider يستمع لتغييرات المصادقة، فإنه سيبدأ جلب الطلبات تلقائياً
    // بمجرد أن يصبح المستخدم متاحاً.
  }

  // دالة مساعدة لتحديد لون حالة الطلب
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.green.shade700;
      case 'completed':
        return Colors.blue.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // دالة مساعدة لتحديد أيقونة حالة الطلب
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.watch_later_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الطلبات', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading) {
            return const LoadingIndicator();
          } else if (ordersProvider.errorMessage != null) {
            return ErrorMessage(
              message: ordersProvider.errorMessage!,
              onRetry: () => ordersProvider.fetchUserOrders(),
            );
          } else if (ordersProvider.userOrders.isEmpty) {
            return const EmptyState(
              message: 'لا توجد طلبات سابقة.',
              icon: Icons.assignment_outlined,
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: ordersProvider.userOrders.length,
              itemBuilder: (context, index) {
                final order = ordersProvider.userOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'الطلب رقم: ${order.id.substring(0, 8)}...',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(order.status),
                                    color: _getStatusColor(order.status),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(order.status),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'تاريخ الطلب:',
                          formatDateTime(order.orderDate),
                        ),
                        if (order.appointmentDate != null)
                          _buildInfoRow(
                            Icons.access_time,
                            'تاريخ الموعد:',
                            formatDateTime(order.appointmentDate!),
                          ),
                        _buildInfoRow(
                          Icons.money,
                          'الإجمالي:',
                          '${order.totalPrice.toStringAsFixed(2)} جنيه مصري',
                          valueColor: kAccentColor,
                          isBoldValue: true,
                        ),
                        if (order.phoneNumber != null &&
                            order.phoneNumber!.isNotEmpty)
                          _buildInfoRow(
                            Icons.phone,
                            'رقم الهاتف:',
                            order.phoneNumber!,
                          ),
                        if (order.deliveryAddress.isNotEmpty)
                          _buildInfoRow(
                            Icons.location_on,
                            'العنوان:',
                            order.deliveryAddress,
                          ),
                        if (order.serviceProviderType != null &&
                            order.serviceProviderType!.isNotEmpty)
                          _buildInfoRow(
                            Icons.person_outline,
                            'نوع المقدم:',
                            order.serviceProviderType!,
                          ),
                        const SizedBox(height: 15),
                        const Text(
                          'الخدمات المطلوبة:',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        ...order.services
                            .map((service) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${service.name} (${service.price.toStringAsFixed(2)} جنيه مصري)',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        if (order.notes != null && order.notes!.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          const Text(
                            'ملاحظات إضافية:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(order.notes!,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor, bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
