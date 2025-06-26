import 'package:cloud_firestore/cloud_firestore.dart';

class AdBanner {
  final String imageUrl;
  final String targetUrl;

  AdBanner({required this.imageUrl, required this.targetUrl});

  factory AdBanner.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return AdBanner(
      imageUrl: data['imageUrl'] ?? '',
      targetUrl: data['targetUrl'] ?? '',
    );
  }
}
