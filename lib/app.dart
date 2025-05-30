import 'package:cure_app/providers/servers_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // استيراد حزمة Provider
import 'package:cure_app/providers/auth_provider.dart';
// تم حذف: import 'package:cure_app/providers/servers_provider.dart'; // هذا كان استيراد خاطئ
import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/providers/orders_provider.dart'; // استيراد OrdersProvider (جديد)
import 'package:cure_app/services/auth_service.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/services/storage_service.dart';
import 'package:cure_app/utils/constants.dart'; // للألوان وأسماء المسارات

// استيراد جميع الشاشات هنا
import 'package:cure_app/splash_screen.dart';
import 'package:cure_app/auth/auth_check.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/auth/register_screen.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/screens/cart_screen.dart';
import 'package:cure_app/screens/profile_screen.dart';
import 'package:cure_app/screens/orders_screen.dart'; // <--- استيراد شاشة الطلبات الجديدة

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إنشاء مثيلات لخدماتك الأساسية هنا.
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        // توفير مثيلات الخدمة نفسها
        Provider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => firestoreService),
        Provider<StorageService>(create: (_) => storageService),

        // توفير ChangeNotifiers (Providers) التي تدير الحالة وتعتمد على الخدمات
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(authService),
        ),
        ChangeNotifierProvider<ServicesProvider>(
          // <--- تم تصحيح: استخدام ServicesProvider
          create: (context) => ServicesProvider(firestoreService),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(
            firestoreService,
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          // <--- إضافة OrdersProvider
          create: (context) => OrdersProvider(
            firestoreService,
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cure', // اسم التطبيق
        debugShowCheckedModeBanner: false, // تعيين إلى false لإصدارات الإنتاج
        theme: ThemeData(
          primaryColor: kPrimaryColor, // لون التطبيق الأساسي
          hintColor: kAccentColor, // لون التمييز
          fontFamily:
              'Cairo', // مثال لخط عربي. يجب إضافته إلى pubspec.yaml إذا كنت تستخدمه.
          appBarTheme: const AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor:
                Colors.white, // لون النص/الأيقونات على شريط التطبيق
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: kPrimaryColor,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.black54),
          ),
        ),
        // تعريف المسارات المسماة لتطبيقك للتنقل
        initialRoute: splashRoute, // البدء بشاشة البداية
        routes: {
          splashRoute: (context) => const SplashScreen(),
          authCheckRoute: (context) => const AuthCheck(),
          loginRoute: (context) => const LoginScreen(),
          registerRoute: (context) => const RegisterScreen(),
          homeRoute: (context) => const HomeScreen(),
          cartRoute: (context) => const CartScreen(),
          ordersRoute: (context) =>
              const OrdersScreen(), // <--- إضافة مسار شاشة الطلبات الجديدة
          profileRoute: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
