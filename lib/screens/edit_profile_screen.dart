import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

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
    final profile =
        Provider.of<AuthProvider>(context, listen: false).currentUserProfile!;
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            const Text("تعديل البيانات", style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor.withOpacity(0.8),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kAccentColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildGlassField(
                              label: "الاسم",
                              icon: Icons.person,
                              controller: _nameController,
                              validator: (value) =>
                                  value!.isEmpty ? 'يرجى إدخال الاسم' : null,
                            ),
                            const SizedBox(height: 20),
                            _buildGlassField(
                              label: "رقم الهاتف",
                              icon: Icons.phone,
                              controller: _phoneController,
                              validator: (value) => value!.isEmpty
                                  ? 'يرجى إدخال رقم الهاتف'
                                  : null,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text("حفظ التغييرات"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                  shadowColor: kAccentColor.withOpacity(0.5),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success =
                                        await authProvider.updateUserProfile({
                                      'name': _nameController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                    });

                                    if (success && context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
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

  Widget _buildGlassField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
