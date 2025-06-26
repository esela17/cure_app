import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/screens/nurse/nurse_home_screen.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:cure_app/screens/order_tracking_screen.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Future<String?> _getActiveOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeOrderId');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // في حالة عدم تسجيل الدخول، ارجع لصفحة تسجيل الدخول
    if (authProvider.currentUser == null) {
      return const LoginScreen();
    }

    // تحقق من وجود طلب نشط في SharedPreferences
    return FutureBuilder<String?>(
      future: _getActiveOrderId(),
      builder: (context, activeOrderSnapshot) {
        if (activeOrderSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingIndicator());
        }

        final activeOrderId = activeOrderSnapshot.data;
        if (activeOrderId != null) {
          return OrderTrackingScreen(orderId: activeOrderId);
        }

        // استمر في فحص الملف الشخصي للمستخدم
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.currentUserProfile == null) {
              if (authProvider.errorMessage != null) {
                return Scaffold(
                  body: ErrorMessage(
                    message: authProvider.errorMessage!,
                    onRetry: () => authProvider.fetchCurrentUserProfile(),
                  ),
                );
              }
              return const Scaffold(body: LoadingIndicator());
            }

            // التوجيه حسب دور المستخدم
            if (authProvider.currentUserProfile!.role == 'nurse') {
              return const NurseHomeScreen();
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}
