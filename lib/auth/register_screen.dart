// lib/auth/register_screen.dart

import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمات المرور غير متطابقة!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // انتظر نتيجة الدالة register
      bool success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        context: context,
      );

      // التحقق من نجاح العملية قبل التوجيه
      // نستخدم context.mounted للتأكد من أن الـ Widget ما زال موجودًا
      if (success && context.mounted) {
        // استخدم pushNamedAndRemoveUntil للانتقال إلى الشاشة الرئيسية
        // وإزالة جميع الشاشات السابقة (مثل شاشة التسجيل والدخول) من المكدس
        Navigator.of(context)
            .pushNamedAndRemoveUntil(homeRoute, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('إنشاء حساب جديد',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    // حقل الاسم الكامل
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                          prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال الاسم'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // حقل رقم الهاتف
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال رقم الهاتف'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // حقل البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'صيغة البريد الإلكتروني غير صحيحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // حقل كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // حقل تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'كلمات المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isLoading) {
                          return const LoadingIndicator();
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitRegister,
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15)),
                            child: const Text('تسجيل',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('لديك حساب بالفعل؟ تسجيل الدخول',
                          style:
                              TextStyle(color: kPrimaryColor.withOpacity(0.8))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
