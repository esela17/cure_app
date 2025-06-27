// ------------ بداية الكود الكامل لملف order_tracking_screen.dart ------------

import 'dart:async';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/providers/active_order_provider.dart';
import 'package:cure_app/screens/home_screen.dart';
import 'package:cure_app/screens/leave_review_screen.dart';
import 'package:cure_app/screens/report.dart'; // تأكد من أن اسم ملف الشكوى صحيح
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/ripple_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _lastStatus;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playStatusChangeSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/0.mp3'));
    } catch (e) {
      debugPrint('خطأ في تشغيل الصوت: $e');
    }
  }

  Future<void> _clearActiveOrderAndExit({bool clearActiveOrder = true}) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _timer?.cancel();

    if (clearActiveOrder) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('activeOrderId');
      final activeOrderProvider =
          Provider.of<ActiveOrderProvider>(context, listen: false);
      activeOrderProvider.clearActiveOrder();
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _cancelOrder() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      try {
        final firestoreService =
            Provider.of<FirestoreService>(context, listen: false);
        await firestoreService
            .updateOrderStatus(widget.orderId, {'status': 'cancelled'});
        await _clearActiveOrderAndExit();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في إلغاء الطلب: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- (تم تعديل هذه الدالة) ---
  void _navigateToReport(Order order) {
    if (order.nurseId == null || order.nurseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن الإبلاغ عن مشكلة لطلب بدون ممرض.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          nurseId: order.nurseId!,
          orderId: order.id,
        ),
      ),
    );
  }

  bool _isArabicName(String name) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(name);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('تتبع الطلب',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          backgroundColor: kPrimaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: StreamBuilder<Order?>(
          // تم التعديل إلى Order? للتعامل مع عدم وجود الطلب
          stream: firestoreService.getOrderStream(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('الطلب غير موجود أو تم حذفه.'));
            }

            final order = snapshot.data!;

            if (_lastStatus != null && _lastStatus != order.status) {
              _playStatusChangeSound();
              _animationController.reset();
              _animationController.forward();
            }
            _lastStatus = order.status;

            return _buildOrderStatusView(order, firestoreService);
          },
        ),
      ),
    );
  }

  // --- (تم تعديل هذه الدالة) ---
  Widget _buildOrderStatusView(Order order, FirestoreService firestoreService) {
    switch (order.status) {
      case 'pending':
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          customWidget: const RippleAnimation(
            color: kPrimaryColor,
            child: Icon(Icons.search, color: Colors.white, size: 50),
          ),
          title: 'جاري البحث عن ممرض...',
          subtitle: Text('طلبك قيد المراجعة'),
          message: 'تم إرسال طلبك بنجاح، وسنبلغك عند قبول أحد مقدمي الخدمة.',
          progress: 0.2,
          progressColor: kPrimaryColor,
          statusBadge: 'قيد الانتظار',
          statusBadgeColor: Colors.orange,
          showCancelButton: true,
          actions: [
            _styledButton('العودة إلى الرئيسية',
                () => _clearActiveOrderAndExit(clearActiveOrder: false),
                color: kPrimaryColor, icon: Icons.home)
          ],
        );

      case 'accepted':
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          icon: Icons.directions_car_outlined,
          color: const Color(0xFF4CAF50),
          title: 'الممرض في الطريق إليك',
          subtitle: _buildNurseNameWidget(order.nurseName),
          message: 'تم قبول طلبك والممرض في طريقه إليك الآن. يرجى الاستعداد.',
          progress: 0.6,
          progressColor: const Color(0xFF4CAF50),
          statusBadge: 'في الطريق',
          statusBadgeColor: const Color(0xFF4CAF50),
          showCancelButton: true,
          isReportCancel: true,
          actions: [
            _outlinedButton('العودة إلى الرئيسية',
                () => _clearActiveOrderAndExit(clearActiveOrder: false),
                icon: Icons.home_outlined)
          ],
        );

      case 'arrived':
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          icon: Icons.location_on,
          color: Colors.blue,
          title: 'الممرض وصل إلى موقعك',
          subtitle: _buildNurseNameWidget(order.nurseName),
          message: 'وصل الممرض إلى عنوانك وسيبدأ في تقديم الخدمة الطبية.',
          progress: 1.0,
          progressColor: Colors.blue,
          statusBadge: 'وصل الممرض',
          statusBadgeColor: Colors.blue,
          actions: [
            _outlinedButton('العودة إلى الرئيسية',
                () => _clearActiveOrderAndExit(clearActiveOrder: false),
                icon: Icons.home_outlined)
          ],
        );

      case 'completed':
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'تم إكمال الخدمة بنجاح',
          subtitle: Text('شكراً لاستخدامك خدماتنا'),
          message: 'تم إكمال الخدمة الطبية بنجاح. نتمنى لك الشفاء العاجل.',
          progress: 1.0,
          progressColor: Colors.green,
          statusBadge: 'مكتمل',
          statusBadgeColor: Colors.green,
          actions: [
            _styledButton('تقييم الخدمة', () => _navigateToReview(order),
                color: kPrimaryColor, icon: Icons.star_outline),
            const SizedBox(height: 12),
            _outlinedButton(
                'العودة إلى الرئيسية', () => _clearActiveOrderAndExit(),
                icon: Icons.home_outlined),
          ],
        );

      case 'cancelled':
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          icon: Icons.cancel_outlined,
          color: Colors.red,
          title: 'تم إلغاء الطلب',
          subtitle: Text('الطلب ملغي'),
          message: 'تم إلغاء طلبك. يمكنك إنشاء طلب جديد في أي وقت.',
          progress: 0.0,
          progressColor: Colors.red,
          statusBadge: 'ملغي',
          statusBadgeColor: Colors.red,
          actions: [
            _styledButton('طلب جديد', () => _clearActiveOrderAndExit(),
                color: kPrimaryColor, icon: Icons.add)
          ],
        );

      default:
        return _buildStatusView(
          order: order, // <-- تم تمرير الطلب هنا
          icon: Icons.info_outline,
          color: Colors.grey,
          title: 'حالة الطلب: ${order.status}',
          subtitle: Text('حالة غير معروفة'),
          message:
              'يوجد مشكلة في تحديد حالة الطلب. يرجى التواصل مع الدعم الفني.',
          progress: 0.5,
          progressColor: Colors.grey,
          statusBadge: order.status,
          statusBadgeColor: Colors.grey,
          actions: [
            _outlinedButton(
                'العودة إلى الرئيسية', () => _clearActiveOrderAndExit(),
                icon: Icons.home_outlined)
          ],
        );
    }
  }

  Widget? _buildNurseNameWidget(String? nurseName) {
    if (nurseName == null || nurseName.isEmpty) return null;
    final isArabic = _isArabicName(nurseName);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (isArabic) ...[
        Text('الممرض: ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        Text(nurseName,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor)),
      ] else ...[
        Text(nurseName,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor)),
        Text(' :الممرض',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      ],
    ]);
  }

  void _navigateToReview(Order order) {
    Navigator.of(context)
        .push(
            MaterialPageRoute(builder: (_) => LeaveReviewScreen(order: order)))
        .then((_) {
      _clearActiveOrderAndExit();
    });
  }

  Widget _styledButton(String label, VoidCallback onPressed,
      {Color? color, IconData? icon}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: (color ?? kPrimaryColor).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? kPrimaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check, size: 20),
        label: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onPressed,
      {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          side: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_back, size: 18),
        label: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  // --- (تم تعديل هذه الدالة) ---
  Widget _buildStatusView({
    required Order order, // <-- تمت إضافة الطلب هنا كمتطلب
    Widget? customWidget,
    IconData? icon,
    required String title,
    Widget? subtitle,
    required String message,
    Color? color,
    double progress = 0.0,
    Color? progressColor,
    String? statusBadge,
    Color? statusBadgeColor,
    List<Widget>? actions,
    bool showCancelButton = false,
    bool isReportCancel = false,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Progress Bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: Stack(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    width: MediaQuery.of(context).size.width * 0.9 * progress,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        progressColor ?? kPrimaryColor,
                        (progressColor ?? kPrimaryColor).withOpacity(0.7),
                      ]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Main Content
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        if (statusBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: statusBadgeColor?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: statusBadgeColor?.withOpacity(0.3) ??
                                      Colors.grey,
                                  width: 1),
                            ),
                            child: Text(statusBadge,
                                style: TextStyle(
                                    color: statusBadgeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        const SizedBox(height: 24),
                        customWidget ??
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    (color ?? kPrimaryColor).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(icon ?? Icons.info,
                                  size: 40, color: color ?? kPrimaryColor),
                            ),
                        const SizedBox(height: 24),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: Colors.black87),
                            textAlign: TextAlign.center),
                        if (subtitle != null) ...[
                          const SizedBox(height: 12),
                          subtitle,
                        ],
                        const SizedBox(height: 16),
                        Text(message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5)),
                      ],
                    ),
                  ),

                  // Cancel/Report Button
                  if (showCancelButton)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3), width: 1),
                        ),
                        child: IconButton(
                          // --- (وهنا يتم استدعاء الدالة المعدلة بشكل صحيح) ---
                          onPressed: isReportCancel
                              ? () => _navigateToReport(order)
                              : _cancelOrder,
                          icon: Icon(
                              isReportCancel
                                  ? Icons.report_outlined
                                  : Icons.close,
                              color: Colors.red,
                              size: 18),
                          padding: EdgeInsets.zero,
                          tooltip:
                              isReportCancel ? 'إبلاغ عن مشكلة' : 'إلغاء الطلب',
                        ),
                      ),
                    ),
                ],
              ),

              // Action Buttons
              if (actions != null) ...[
                const SizedBox(height: 24),
                ...actions,
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ------------ نهاية الكود الكامل لملف order_tracking_screen.dart ------------
