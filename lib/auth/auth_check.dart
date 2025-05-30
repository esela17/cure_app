// lib/auth/auth_check.dart

import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/error_message.dart'; // <-- استيراد جديد
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // إذا لم يكن المستخدم مسجل الدخول، اذهب إلى شاشة الدخول
        if (authProvider.currentUser == null) {
          return const LoginScreen();
        }

        // --- المنطق الجديد للتحقق من الخطأ والتحميل ---

        // 1. تحقق من وجود خطأ أولاً
        // إذا فشل جلب الملف الشخصي، اعرض رسالة الخطأ
        if (authProvider.errorMessage != null &&
            authProvider.currentUserProfile == null) {
          return Scaffold(
            body: ErrorMessage(
              message:
                  "خطأ في جلب الملف الشخصي:\n${authProvider.errorMessage!}",
              onRetry: () => authProvider.fetchCurrentUserProfile(),
            ),
          );
        }

        // 2. إذا لم يكن هناك خطأ، تحقق مما إذا كان الملف الشخصي لا يزال قيد التحميل
        if (authProvider.currentUserProfile == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        // --- نهاية المنطق الجديد ---

        // 3. إذا تم كل شيء بنجاح، اذهب إلى الشاشة الرئيسية للمستخدم العادي
        return const HomeScreen();
      },
    );
  }
}
