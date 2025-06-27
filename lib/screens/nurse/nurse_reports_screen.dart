// ------------ بداية الكود لـ nurse_reports_screen.dart ------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NurseReportsScreen extends StatelessWidget {
  final String nurseId;

  const NurseReportsScreen({super.key, required this.nurseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الشكاوى'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('nurseId', isEqualTo: nurseId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          final reports = snapshot.data?.docs ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('لا توجد شكاوى لهذا الممرض.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd – hh:mm a', 'ar')
                      .format(timestamp.toDate())
                  : 'بدون تاريخ';

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.report_problem, color: Colors.red),
                  title: Text(data['message'] ?? 'لا يوجد محتوى'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        'من: ${data['patientName'] ?? 'مستخدم'}\n$formattedDate'),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// ------------ نهاية الكود لـ nurse_reports_screen.dart ------------
