import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryShortcut {
  final String iconUrl;
  final String label;
  final String targetUrl;

  CategoryShortcut(
      {required this.iconUrl, required this.label, required this.targetUrl});

  factory CategoryShortcut.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return CategoryShortcut(
      iconUrl: data['iconUrl'] ?? '',
      label: data['label'] ?? '',
      targetUrl: data['targetUrl'] ?? '',
    );
  }
}
