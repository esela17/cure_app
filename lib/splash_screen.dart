import 'package:cure_app/utils/constants.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // بدء الأنيميشن تدريجياً
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // الانتقال التلقائي بعد 3 ثوانٍ
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacementNamed(context, authCheckRoute);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1500),
          opacity: _opacity,
          curve: Curves.easeInOut,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1000),
            scale: _scale,
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ دائرة متناسقة مع الشعار
                Container(
                  width: size.width * 0.45,
                  height: size.width * 0.45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ClipOval(
                    child: Image.network(
                      'https://i.ibb.co/jPSjwg4f/Cure-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Cure',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'أول تطبيق يعمل كوسيط بين الممرض والمريض في مصر',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
