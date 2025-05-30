import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ضروري لتهيئة Firebase
import 'package:cure_app/app.dart'; // استيراد ملف MyApp الخاص بك (تأكد من اسم المجلد)
import 'package:cure_app/firebase_options.dart'; // ملف تهيئة Firebase الذي تم إنشاؤه تلقائيًا (تأكد من اسم المجلد)

void main() async {
  // هذا السطر يضمن تهيئة Flutter Widgets قبل أي شيء آخر.
  // وهو ضروري لتشغيل العمليات غير المتزامنة (مثل تهيئة Firebase) قبل تشغيل التطبيق.
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase لتطبيقك.
  // 'DefaultFirebaseOptions.currentPlatform' تقوم تلقائيًا باختيار التهيئة الصحيحة
  // للمنصة التي يعمل عليها تطبيقك (أندرويد، iOS، الويب، إلخ).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // بمجرد تهيئة Firebase، يتم تشغيل الـ Widget الرئيسي لتطبيقك.
  // الـ 'MyApp' (المعرف في lib/app.dart) سيقوم بإعداد التوجيهات (routes)،
  // والسمات (themes)، وجميع الـ Providers لإدارة الحالة.
  runApp(const MyApp());
}
