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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
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
      await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(156, 143, 255, 118),
              Color.fromARGB(255, 108, 135, 255)
            ], // ألوان تتناسب مع اللون الأساسي (نفس عائلة اللون الأخضر)
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Card(
              elevation: 14,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              shadowColor: Colors.black.withOpacity(0.3),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_add,
                          size: 110, color: kPrimaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'انضم إلينا لربط المرضى بالممرضين في مصر',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'you@example.com',
                          prefixIcon:
                              const Icon(Icons.email, color: kPrimaryColor),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: kPrimaryColor, width: 2),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'يرجى إدخال البريد الإلكتروني';
                          if (!value.contains('@'))
                            return 'صيغة البريد الإلكتروني غير صحيحة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          hintText: '6 أحرف على الأقل',
                          prefixIcon:
                              const Icon(Icons.lock, color: kPrimaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: kPrimaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: kPrimaryColor, width: 2),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'يرجى إدخال كلمة المرور';
                          if (value.length < 6)
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          hintText: 'أعد إدخال كلمة المرور',
                          prefixIcon:
                              const Icon(Icons.lock_open, color: kPrimaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: kPrimaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: kPrimaryColor, width: 2),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'يرجى تأكيد كلمة المرور';
                          if (value != _passwordController.text)
                            return 'كلمات المرور غير متطابقة';
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
                            width: screenWidth * 0.7,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 8,
                                shadowColor: Colors.black45,
                              ),
                              child: const Text(
                                'تسجيل',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'لديك حساب بالفعل؟ تسجيل الدخول',
                          style: TextStyle(
                            color: kPrimaryColor.withOpacity(0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
