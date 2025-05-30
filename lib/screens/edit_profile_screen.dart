// lib/screens/edit_profile_screen.dart

import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // الحصول على البيانات الحالية للمستخدم ووضعها في الحقول عند بدء الشاشة
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(
        text: authProvider.currentUserProfile?.name ?? '');
    _phoneController = TextEditingController(
        text: authProvider.currentUserProfile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // دالة لإرسال التحديثات
  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserProfile({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        if (success) {
          showSnackBar(context, 'تم تحديث البيانات بنجاح!');
          Navigator.of(context).pop(); // العودة إلى شاشة الملف الشخصي
        } else {
          showSnackBar(context, authProvider.errorMessage ?? 'حدث خطأ ما',
              isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي',
            style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person)),
                validator: (value) =>
                    value == null || value.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'رقم الهاتف مطلوب' : null,
              ),
              const SizedBox(height: 40),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return authProvider.isLoading
                      ? const LoadingIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitUpdate,
                            child: const Text('حفظ التعديلات',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
