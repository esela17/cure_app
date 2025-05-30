// lib/app.dart

import 'package:cure_app/providers/servers_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/providers/orders_provider.dart';
import 'package:cure_app/services/auth_service.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/services/storage_service.dart';
import 'package:cure_app/utils/constants.dart';

// استيراد الشاشات
import 'package:cure_app/splash_screen.dart';
import 'package:cure_app/auth/auth_check.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/auth/register_screen.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/screens/cart_screen.dart';
import 'package:cure_app/screens/profile_screen.dart';
import 'package:cure_app/screens/orders_screen.dart';
import 'package:cure_app/screens/edit_profile_screen.dart';

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
        // توفير الخدمات الأساسية
        Provider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => firestoreService),
        Provider<StorageService>(create: (_) => storageService),

        // توفير مديري الحالة (ChangeNotifiers)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ServicesProvider>(
          create: (context) => ServicesProvider(firestoreService),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(
            firestoreService,
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (context) => OrdersProvider(
            firestoreService,
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        // إضافة الـ Provider الخاص بالممرض
      ],
      child: MaterialApp(
        title: 'Cure',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          hintColor: kAccentColor,
          fontFamily: 'Cairo',
          appBarTheme: const AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
        initialRoute: splashRoute,
        routes: {
          splashRoute: (context) => const SplashScreen(),
          authCheckRoute: (context) => const AuthCheck(),
          loginRoute: (context) => const LoginScreen(),
          registerRoute: (context) => const RegisterScreen(),
          homeRoute: (context) => const HomeScreen(),
          cartRoute: (context) => const CartScreen(),
          ordersRoute: (context) => const OrdersScreen(),
          profileRoute: (context) => const ProfileScreen(),
          editProfileRoute: (context) => const EditProfileScreen(),
        },
      ),
    );
  }
}
