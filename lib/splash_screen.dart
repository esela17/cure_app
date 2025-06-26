import 'package:flutter/material.dart';
import 'package:cure_app/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // تحول الخلفية من الأبيض للون الأساسي
    _backgroundAnimation = ColorTween(
      begin: Colors.white,
      end: kPrimaryColor,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    // تلاشي الشاشة في النهاية
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // تحميل الصورة مسبقاً
        await precacheImage(
          const AssetImage('lib/assets/2.png'),
          context,
        );

        if (mounted) {
          // بدء الأنيميشن
          await _animationController.forward();

          // انتظار قصير ثم الانتقال للشاشة التالية
          await Future.delayed(const Duration(milliseconds: 100));

          if (mounted) {
            Navigator.pushReplacementNamed(context, authCheckRoute);
          }
        }
      } catch (e) {
        debugPrint('Error loading splash image: $e');
        // في حالة فشل تحميل الصورة، الانتقال مباشرة
        if (mounted) {
          Navigator.pushReplacementNamed(context, authCheckRoute);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * .8;

    return PopScope(
      canPop: false,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeOutAnimation,
            child: Scaffold(
              backgroundColor: _backgroundAnimation.value ?? Colors.white,
              body: Center(
                child: Container(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'lib/assets/2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
