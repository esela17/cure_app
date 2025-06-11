import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cure_app/app.dart';
import 'package:cure_app/firebase_options.dart';
import 'package:cure_app/services/notification_service.dart'; // <-- استيراد جديد

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- الإضافة الجديدة ---
  // تهيئة خدمة الإشعارات والاستماع للرسائل القادمة
  await NotificationService().initialize();
  // ----------------------

  runApp(const MyApp());
}
