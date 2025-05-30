import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // لاستخدام حزمة Provider
import 'package:cure_app/providers/auth_provider.dart'; // استيراد AuthProvider
import 'package:cure_app/screens/home_screen.dart'; // استيراد الشاشة الرئيسية (Home Screen)
import 'package:cure_app/auth/login_screen.dart'; // استيراد شاشة تسجيل الدخول (Login Screen)
import 'package:cure_app/widgets/loading_indicator.dart'; // استيراد مؤشر التحميل

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer للاستماع إلى تغييرات حالة AuthProvider.
    // هذا يعني أن هذا الـ Widget سيعيد البناء تلقائيًا عندما تتغير حالة المصادقة.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // إذا كان هناك رسالة خطأ من AuthProvider (على سبيل المثال، مشكلة في تهيئة Firebase)
        if (authProvider.errorMessage != null &&
            authProvider.errorMessage!.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Text(
                'خطأ في المصادقة: ${authProvider.errorMessage}', // عرض رسالة الخطأ
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        // إذا كانت عملية مصادقة جارية (على سبيل المثال، التحقق الأولي من المستخدم المسجل الدخول)
        if (authProvider.isLoading) {
          return const Scaffold(body: LoadingIndicator()); // عرض مؤشر التحميل
        }
        // إذا كان هناك مستخدم مسجل الدخول حاليًا (currentUser ليس null)
        if (authProvider.currentUser != null) {
          return const HomeScreen(); // توجيه المستخدم إلى الشاشة الرئيسية
        } else {
          // إذا لم يكن هناك مستخدم مسجل الدخول
          return const LoginScreen(); // توجيه المستخدم إلى شاشة تسجيل الدخول
        }
      },
    );
  }
}
