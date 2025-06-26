import 'package:flutter/material.dart';
import 'package:cure_app/utils/constants.dart';

class NurseNoteArrivedScreen extends StatelessWidget {
  const NurseNoteArrivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الممرض لم يصل',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'برجاء وصف المشكلة بالتفصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظاتك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('إرسال الشكوى'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
                  );
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
