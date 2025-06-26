import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NurseReportsScreen extends StatelessWidget {
  const NurseReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوى', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return const Center(child: Text('لا توجد شكاوى حتى الآن.'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.red),
                  title: Text(data['message'] ?? 'بدون نص'),
                  subtitle: Text(data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                      : 'بدون تاريخ'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
