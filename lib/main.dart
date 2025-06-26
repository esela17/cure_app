import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cure_app/app.dart';
import 'package:cure_app/firebase_options.dart';
import 'package:cure_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- استيراد جديد

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    await Permission.notification.request();
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission(); // 🔔 طلب الإذن

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initialize();
  runApp(const MyApp());
}
