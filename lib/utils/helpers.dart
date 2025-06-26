import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}
