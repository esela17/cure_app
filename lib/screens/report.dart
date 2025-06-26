import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cure_app/utils/constants.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportController = TextEditingController();
  bool _isSending = false;

  Future<void> _submitReport() async {
    final text = _reportController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة الشكوى أولًا')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الإرسال: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم شكوى'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اكتب تفاصيل الشكوى أو المشكلة التي واجهتك',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reportController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'مثال: الممرض لم يصل في الوقت المحدد...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _submitReport,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                _isSending ? 'جاري الإرسال...' : 'إرسال الشكوى',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
