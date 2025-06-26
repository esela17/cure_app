import 'package:flutter/material.dart';

class MainBackground extends StatelessWidget {
  final Widget child;
  const MainBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // استخدام تدرج لوني جميل كخلفية
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(
                255, 109, 115, 255), // اللون الأساسي من ملف constants.dart
            Color.fromARGB(255, 65, 80, 214), // لون بنفسجي مكمل
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
