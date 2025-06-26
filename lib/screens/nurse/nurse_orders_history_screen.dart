import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/screens/nurse/nurse_order_details_screen.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NurseOrdersHistoryScreen extends StatefulWidget {
  const NurseOrdersHistoryScreen({super.key});

  @override
  State<NurseOrdersHistoryScreen> createState() =>
      _NurseOrdersHistoryScreenState();
}

class _NurseOrdersHistoryScreenState extends State<NurseOrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<NurseProvider>(context, listen: false)
            .fetchMyOrders(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل خدماتي', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<NurseProvider>(
        builder: (context, nurseProvider, child) {
          if (nurseProvider.myOrders.isEmpty && nurseProvider.isLoading) {
            return const LoadingIndicator();
          }
          if (nurseProvider.myOrders.isEmpty) {
            return const EmptyState(
              message: 'ليس لديك أي طلبات في سجلك حتى الآن.',
              icon: Icons.history_toggle_off,
            );
          }
          return ListView.builder(
            itemCount: nurseProvider.myOrders.length,
            itemBuilder: (context, index) {
              final order = nurseProvider.myOrders[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('طلب للمريض: ${order.patientName}'),
                  subtitle: Text('العنوان: ${order.deliveryAddress}'),
                  trailing: Chip(
                    label: Text(
                      order.status,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: order.status == 'accepted'
                        ? Colors.blue
                        : (order.status == 'completed'
                            ? Colors.green
                            : Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // --- The correction is here ---
                        builder: (context) =>
                            NurseOrderDetailsScreen(initialOrder: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
