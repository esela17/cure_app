import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/screens/nurse/nurse_orders_history_screen.dart';
import 'package:cure_app/screens/nurse/pending_orders_screen.dart';
import 'package:cure_app/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({Key? key}) : super(key: key);

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nurseProvider = Provider.of<NurseProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        nurseProvider.fetchMyOrders(authProvider.currentUser!.uid);
        nurseProvider.fetchPendingOrders();
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nurseProvider = Provider.of<NurseProvider>(context);

    final userProfile = authProvider.currentUserProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.signOut(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أهلاً بك، ${userProfile?.name ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  icon: Icons.notifications_active,
                  title: 'الطلبات الجديدة',
                  count: nurseProvider.pendingOrdersCount.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PendingOrdersScreen()),
                    );
                  },
                ),
                DashboardCard(
                  icon: Icons.history,
                  title: 'سجل طلباتي',
                  count: nurseProvider.myOrders.length.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const NurseOrdersHistoryScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: SwitchListTile(
                title: const Text('حالة التوفر',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userProfile?.isAvailable ?? true
                    ? 'متاح لاستقبال الطلبات'
                    : 'غير متاح حاليًا'),
                value: userProfile?.isAvailable ?? true,
                onChanged: (bool value) {
                  authProvider.updateAvailability(value);
                },
                secondary: Icon(
                  userProfile?.isAvailable ?? true
                      ? Icons.toggle_on
                      : Icons.toggle_off,
                  color: userProfile?.isAvailable ?? true
                      ? Colors.green
                      : Colors.red,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
