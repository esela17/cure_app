import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/providers/orders_provider.dart';
import 'package:cure_app/providers/servers_provider.dart';
import 'package:cure_app/screens/nurse/nurse_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/services/storage_service.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/splash_screen.dart';
import 'package:cure_app/auth/auth_check.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/auth/register_screen.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/screens/cart_screen.dart';
import 'package:cure_app/screens/profile_screen.dart';
import 'package:cure_app/screens/orders_screen.dart';
import 'package:cure_app/screens/edit_profile_screen.dart';
import 'package:cure_app/providers/nurse_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ServicesProvider>(
          create: (context) =>
              ServicesProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(
            context.read<FirestoreService>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (context) => OrdersProvider(
            context.read<FirestoreService>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<NurseProvider>(
          create: (context) => NurseProvider(context.read<FirestoreService>()),
        ),
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
          nurseHomeRoute: (context) => const NurseHomeScreen(),
        },
      ),
    );
  }
}
