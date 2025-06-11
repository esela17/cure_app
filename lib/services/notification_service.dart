// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // دالة لتهيئة كل ما يتعلق بالإشعارات
  Future<void> initialize() async {
    // طلب صلاحية إرسال الإشعارات من المستخدم
    await requestPermission();

    // التعامل مع الإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // لاحقًا: يمكنك هنا عرض إشعار محلي أو حوار للمستخدم
      }
    });

    // التعامل مع الضغط على الإشعار عندما يكون التطبيق في الخلفية أو مغلق
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // لاحقًا: يمكنك هنا توجيه المستخدم إلى شاشة معينة بناءً على بيانات الإشعار
    });
  }

  // دالة لطلب الصلاحية
  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // دالة للحصول على الـ Token الفريد للجهاز
  Future<String?> getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token"); // لغرض التجربة
    return token;
  }
}
