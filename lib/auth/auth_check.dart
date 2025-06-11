import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/auth/login_screen.dart';
import 'package:cure_app/screens/nurse/nurse_home_screen.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser == null) {
          return const LoginScreen();
        }

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

        if (authProvider.currentUserProfile == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        if (authProvider.currentUserProfile!.role == 'nurse') {
          return const NurseHomeScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
