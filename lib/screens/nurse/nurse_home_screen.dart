// ------------ بداية الكود الكامل لملف NurseHomeScreen.dart ------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/nurse_provider.dart';
import 'package:cure_app/screens/nurse/nurse_orders_history_screen.dart';
import 'package:cure_app/screens/nurse/pending_orders_screen.dart';
import 'package:cure_app/screens/nurse/nurse_reviews_screen.dart';
import 'package:cure_app/screens/nurse/nurse_reports_screen.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  @override
  void initState() {
    super.initState();
    // تأجيل التنفيذ لضمان أن context متاح
    Future.delayed(Duration.zero, () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nurseProvider = Provider.of<NurseProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        nurseProvider.fetchMyOrders(authProvider.currentUser!.uid);
        nurseProvider.fetchPendingOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NurseProvider>(
      builder: (context, authProvider, nurseProvider, child) {
        final userProfile = authProvider.currentUserProfile;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('مركز العمليات',
                style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => authProvider.signOut(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. بطاقة الحالة والترحيب
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بك، ${userProfile?.name ?? ''}!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('حالة التوفر',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            userProfile?.isAvailable ?? true
                                ? 'متاح لاستقبال الطلبات'
                                : 'غير متاح حاليًا',
                          ),
                          value: userProfile?.isAvailable ?? true,
                          onChanged: (bool value) =>
                              authProvider.updateAvailability(value),
                          secondary: Icon(
                            userProfile?.isAvailable ?? true
                                ? Icons.online_prediction
                                : Icons.power_settings_new,
                            color: userProfile?.isAvailable ?? true
                                ? Colors.green
                                : Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. بطاقات الأداء مع إضافة بطاقة الشكاوي
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    DashboardCard(
                      icon: Icons.notifications_active_outlined,
                      title: 'الطلبات الجديدة',
                      count: nurseProvider.pendingOrdersCount.toString(),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PendingOrdersScreen()));
                      },
                    ),
                    DashboardCard(
                      icon: Icons.directions_run_outlined,
                      title: 'قيد التنفيذ',
                      count: nurseProvider.acceptedOrdersCount.toString(),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NurseOrdersHistoryScreen()));
                      },
                    ),
                    DashboardCard(
                      icon: Icons.star_half_outlined,
                      title: 'متوسط التقييم',
                      count: userProfile?.averageRating.toStringAsFixed(1) ??
                          '0.0',
                      onTap: () {
                        if (authProvider.currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NurseReviewsScreen(
                                  nurseId: authProvider.currentUser!.uid),
                            ),
                          );
                        }
                      },
                    ),
                    DashboardCard(
                      icon: Icons.task_alt_outlined,
                      title: 'الطلبات المكتملة',
                      count: nurseProvider.completedOrdersCount.toString(),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NurseOrdersHistoryScreen()));
                      },
                    ),

                    // --- (هذا هو الجزء الذي تم إصلاحه بالكامل) ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reports')
                          .where('nurseId',
                              isEqualTo: authProvider.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String reportCount = '...';
                        if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.hasData) {
                          reportCount = snapshot.data!.docs.length.toString();
                        } else if (snapshot.hasError) {
                          reportCount = '!';
                        }

                        return DashboardCard(
                          icon: Icons.report_outlined,
                          title: 'الشكاوى',
                          count: reportCount,
                          onTap: () {
                            if (authProvider.currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NurseReportsScreen(
                                    nurseId: authProvider.currentUser!.uid,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. الإجراءات السريعة
                _buildQuickActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.history, color: kPrimaryColor),
                title: const Text('عرض سجل الطلبات الكامل'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NurseOrdersHistoryScreen()),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined,
                    color: kPrimaryColor),
                title: const Text('تعديل الملف الشخصي'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, profileRoute);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ------------ نهاية الكود الكامل لملف NurseHomeScreen.dart ------------
