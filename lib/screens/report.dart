// ------------ بداية الكود لـ report.dart ------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cure_app/utils/constants.dart'; // افترض أن kPrimaryColor موجود هنا

class ReportScreen extends StatefulWidget {
  final String nurseId;
  final String orderId;

  const ReportScreen({
    super.key,
    required this.nurseId,
    required this.orderId,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("المستخدم غير مسجل.");

      await FirebaseFirestore.instance.collection('reports').add({
        'message': _reportController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'nurseId': widget.nurseId,
        'orderId': widget.orderId,
        'patientId': user.uid,
        'patientName': user.displayName ?? 'مستخدم',
        'status': 'new',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إرسال الشكوى بنجاح'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
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
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('صف المشكلة التي واجهتها بالتفصيل:',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reportController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'اكتب هنا...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'هذا الحقل إجباري.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSending ? null : _submitReport,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// ------------ نهاية الكود لـ report.dart ------------
