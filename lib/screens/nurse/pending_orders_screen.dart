import 'package:cure_app/models/order.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/screens/nurse/nurse_order_details_screen.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingOrdersScreen extends StatelessWidget {
  const PendingOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الطلبات الجديدة المتاحة',
            style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<NurseProvider>(
        builder: (context, nurseProvider, child) {
          if (nurseProvider.isLoading && nurseProvider.pendingOrders.isEmpty) {
            return const LoadingIndicator();
          }
          if (nurseProvider.errorMessage != null &&
              nurseProvider.pendingOrders.isEmpty) {
            return ErrorMessage(
              message: nurseProvider.errorMessage!,
              onRetry: () => nurseProvider.fetchPendingOrders(),
            );
          }
          if (nurseProvider.pendingOrders.isEmpty) {
            return const EmptyState(
              message: 'لا توجد طلبات معلقة حاليًا.',
              icon: Icons.notifications_off_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => nurseProvider.fetchPendingOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: nurseProvider.pendingOrders.length,
              itemBuilder: (context, index) {
                final order = nurseProvider.pendingOrders[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined,
                        color: kPrimaryColor),
                    title: Text(
                        'طلب جديد بتاريخ: ${formatDateTime(order.orderDate)}'),
                    subtitle: Text(
                        'العنوان: ${order.deliveryAddress}\nالخدمات: ${order.services.length} خدمة'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NurseOrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
