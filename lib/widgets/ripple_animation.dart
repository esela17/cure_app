import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  final Widget? child;
  final double minRadius;
  final Color color;

  const RippleAnimation({
    super.key,
    this.child,
    this.minRadius = 60,
    this.color = Colors.deepPurple,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RipplePainter(
        controller: _controller,
        color: widget.color,
        minRadius: widget.minRadius,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.minRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.6),
            ),
            child: SizedBox(
              width: widget.minRadius * 2,
              height: widget.minRadius * 2,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> controller;
  final Color color;
  final double minRadius;

  RipplePainter({
    required this.controller,
    required this.color,
    required this.minRadius,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    // نرسم 3 دوائر لعمل تأثير الموجات
    for (int wave = 0; wave < 3; wave++) {
      drawWave(canvas, rect, wave);
    }
  }

  void drawWave(Canvas canvas, Rect rect, int wave) {
    // كل موجة تبدأ بعد الأخرى بقليل
    final animationValue = controller.value;
    final delayedValue = (animationValue - (wave / 3)).clamp(0.0, 1.0);

    if (delayedValue > 0.0) {
      final double opacity = (1.0 - delayedValue).clamp(0.0, 1.0);
      final Color waveColor = color.withOpacity(opacity);

      // حجم الموجة يزداد مع الوقت
      final double radius = minRadius + (rect.width / 2 * delayedValue);

      final Paint paint = Paint()..color = waveColor;
      canvas.drawCircle(rect.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
