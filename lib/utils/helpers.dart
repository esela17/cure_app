import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ← ضروري لتنسيق التاريخ

// دالة مساعدة لتنسيق التاريخ والوقت
String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}

// دالة مساعدة لإظهار رسائل SnackBar للمستخدم
void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? Colors.red : Colors.green, // أحمر للأخطاء، أخضر للنجاح
    ),
  );
}
