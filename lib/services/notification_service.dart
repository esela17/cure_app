// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // تهيئة الإشعارات
  Future<void> initialize() async {
    await requestPermission();

    // إعداد إشعارات flutter_local_notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    // الاستماع للإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 رسالة أثناء foreground');
      if (message.notification != null) {
        _showNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    // التعامل مع الإشعارات عند فتح التطبيق منها
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 المستخدم ضغط على إشعار');
      // يمكنك توجيه المستخدم إلى شاشة معينة هنا
    });
  }

  // طلب صلاحية الإشعارات
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('🚫 تم رفض الإذن');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      print('❓ لم يتم تحديد الإذن');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('✅ تم منح إذن الإشعارات');
    }
  }

  // عرض إشعار باستخدام flutter_local_notifications
  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // جلب FCM Token
  Future<String?> getFcmToken() async {
    final token = await _firebaseMessaging.getToken();
    print("🔐 FCM Token: $token");
    return token;
  }
}
