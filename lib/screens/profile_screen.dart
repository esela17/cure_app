import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/utils/constants.dart'; // لاستخدام الألوان وثوابت المسارات
import 'package:cure_app/utils/helpers.dart'; // لاستخدام showSnackBar (لزر التعديل)
import 'package:cure_app/widgets/loading_indicator.dart'; // لعرض مؤشر التحميل
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer للاستماع إلى تغييرات حالة AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // إذا كان هناك عملية تحميل جارية (مثل تسجيل الخروج)
        if (authProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('الملف الشخصي',
                  style: TextStyle(color: Colors.white)),
              backgroundColor:
                  kPrimaryColor, // استخدام اللون الأساسي من الثوابت
            ),
            body: const LoadingIndicator(), // عرض مؤشر التحميل
          );
        }

        // الحصول على المستخدم الحالي. إذا لم يكن هناك مستخدم، فإنه يعرض رسالة بسيطة.
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('الملف الشخصي',
                style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimaryColor, // استخدام اللون الأساسي من الثوابت
          ),
          body: Center(
            // وضع المحتوى في المنتصف أفقياً وعمودياً
            child: SingleChildScrollView(
              // للسماح بالتمرير إذا كانت الشاشة صغيرة
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // توسيط عمودي
                crossAxisAlignment:
                    CrossAxisAlignment.center, // توسيط أفقي للعناصر داخل العمود
                children: [
                  // أيقونة المستخدم (يمكن استبدالها بصورة ملف شخصي لاحقًا)
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: kPrimaryColor, // استخدام اللون الأساسي
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // عرض البريد الإلكتروني للمستخدم
                  Text(
                    user?.email ??
                        'غير مسجل الدخول', // عرض البريد الإلكتروني أو رسالة
                    textAlign: TextAlign.center, // توسيط النص
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // عرض UID للمستخدم (معرف المستخدم في Firebase)
                  Text(
                    'ID: ${user?.uid ?? 'غير متاح'}',
                    textAlign: TextAlign.center, // توسيط النص
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر سجل الطلبات
                  SizedBox(
                    width: double.infinity, // لجعل الزر يأخذ أقصى عرض متاح
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, ordersRoute); // الانتقال إلى شاشة الطلبات
                      },
                      icon: const Icon(Icons.history,
                          color: Colors.white), // أيقونة التاريخ
                      label: const Text(
                        'سجل الطلبات',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor, // استخدام اللون الأساسي
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // مسافة بين الأزرار

                  // زر تعديل الملف الشخصي
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement Edit Profile Screen
                        showSnackBar(
                            context, 'تعديل الملف الشخصي قيد التطوير!');
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'تعديل الملف الشخصي',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor, // استخدام لون التمييز
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // مسافة قبل زر تسجيل الخروج
                  Divider(
                      color: Colors.grey[
                          300]), // فاصل أنيق (وضعته هنا ليفصل بين الأزرار الرئيسية وزر الخروج)
                  const SizedBox(height: 20),

                  // زر تسجيل الخروج
                  SizedBox(
                    width: double.infinity, // لجعل الزر يأخذ أقصى عرض متاح
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.signOut(context);
                        // AuthCheck ستتعامل مع إعادة التوجيه إلى شاشة تسجيل الدخول
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                            .shade600, // لون أحمر معبر وموحد لزر تسجيل الخروج
                        padding: const EdgeInsets.symmetric(
                            vertical: 15), // زيادة الحجم العمودي
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // رسائل الخطأ من AuthProvider إن وجدت
                  if (authProvider.errorMessage != null &&
                      authProvider.errorMessage!.isNotEmpty)
                    Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
