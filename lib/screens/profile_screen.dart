// lib/screens/profile_screen.dart

import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:cure_app/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.currentUserProfile;

        // متغير لتخزين الواجهة التي سيتم عرضها
        Widget body;

        // إذا كانت بيانات الملف الشخصي لم تصل بعد
        if (authProvider.currentUser != null && userProfile == null) {
          // تحقق أولاً من وجود رسالة خطأ
          if (authProvider.errorMessage != null) {
            body = ErrorMessage(
                message:
                    "فشل تحميل الملف الشخصي: ${authProvider.errorMessage!}",
                onRetry: () => authProvider.fetchCurrentUserProfile());
          } else {
            // إذا لم يكن هناك خطأ، فهي لا تزال قيد التحميل
            body = const LoadingIndicator();
          }
        } else if (userProfile != null) {
          // إذا تم جلب البيانات بنجاح، اعرض محتوى الصفحة
          body = Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: userProfile.profileImageUrl != null
                            ? NetworkImage(userProfile.profileImageUrl!)
                            : null,
                        child: userProfile.profileImageUrl == null
                            ? const Icon(Icons.person,
                                size: 80, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: kPrimaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 22),
                            onPressed: () {
                              authProvider.pickAndUploadProfileImage();
                            },
                          ),
                        ),
                      ),
                      if (authProvider.isLoading &&
                          userProfile.profileImageUrl != null)
                        const CircularProgressIndicator(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProfile.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userProfile.phone,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, editProfileRoute);
                      },
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      label: const Text('تعديل البيانات',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, ordersRoute);
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text('سجل الطلبات',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.signOut(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('تسجيل الخروج',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // حالة غير متوقعة
          body = const Center(child: Text("غير مسجل الدخول."));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('الملف الشخصي',
                style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: body,
        );
      },
    );
  }
}
