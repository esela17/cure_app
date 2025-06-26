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
            content: Text(
              'كلمات المرور غير متطابقة!',
              textAlign: TextAlign.right,
            ),
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoading) return;

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        context: context,
      );

      if (!context.mounted) return;

      if (success) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(authCheckRoute, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                // استخدام الشعار المحلي
                'lib/assets/2.png',
                height: 250,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "انشاء حساب جديد",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInputField("الاسم الكامل", Icons.person_outline,
                          _nameController, TextInputType.name),
                      const SizedBox(height: 20),
                      _buildInputField("رقم الهاتف", Icons.phone_outlined,
                          _phoneController, TextInputType.phone),
                      const SizedBox(height: 20),
                      _buildInputField(
                          "البريد الإلكتروني",
                          Icons.email_outlined,
                          _emailController,
                          TextInputType.emailAddress),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                          "كلمة المرور", _passwordController, true),
                      const SizedBox(height: 20),
                      _buildPasswordField("تأكيد كلمة المرور",
                          _confirmPasswordController, false),
                      const SizedBox(height: 30),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isLoading) {
                            return const LoadingIndicator();
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _submitRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: kAccentColor.withOpacity(0.4),
                              ),
                              child: const Text(
                                'تسجيل',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Text(
                          'أو',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'لديك حساب بالفعل؟ تسجيل الدخول',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon,
      TextEditingController controller, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        if (keyboardType == TextInputType.emailAddress &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'صيغة البريد الإلكتروني غير صحيحة';
        }
        if (keyboardType == TextInputType.phone &&
            !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'رقم هاتف غير صالح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
      String hint, TextEditingController controller, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            Icon(Icons.lock_outline, color: kPrimaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            (isPassword ? _obscurePassword : _obscureConfirmPassword)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        if (!isPassword && value != _passwordController.text) {
          return 'كلمات المرور غير متطابقة';
        }
        return null;
      },
    );
  }
}
