import 'package:cure_app/providers/servers_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // لاستخدام حزمة Provider لإدارة الحالة

// تم تصحيح: استيراد ServicesProvider بدلاً من ServersProvider
import 'package:cure_app/providers/cart_provider.dart'; // استيراد CartProvider
import 'package:cure_app/widgets/servers_card.dart'; // استيراد ServiceCard Widget
import 'package:cure_app/widgets/loading_indicator.dart'; // استيراد مؤشر التحميل
import 'package:cure_app/widgets/error_message.dart'; // استيراد رسالة الخطأ
import 'package:cure_app/widgets/empty_state.dart'; // استيراد حالة الشاشة الفارغة
import 'package:cure_app/utils/constants.dart'; // استيراد الثوابت للألوان وأسماء المسارات

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // هنا لا نحتاج لاستدعاء fetchServices() بشكل صريح
    // لأن ServicesProvider يستمع لـ Stream من FirestoreService في الـ constructor الخاص به،
    // وبالتالي يتم جلب الخدمات تلقائيًا عند إنشاء الـ Provider.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخدمات المتاحة',
            style: TextStyle(color: Colors.white)), // عنوان شريط التطبيق
        backgroundColor: kPrimaryColor, // لون شريط التطبيق الأساسي
        actions: [
          // أيقونة عربة التسوق مع شارة (badge) لعرض عدد العناصر في السلة
          Consumer<CartProvider>(
            // نستخدم Consumer هنا للاستماع إلى CartProvider فقط لهذا الجزء
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      // عند النقر، انتقل إلى شاشة عربة التسوق
                      Navigator.pushNamed(context, cartRoute);
                    },
                  ),
                  if (cart.cartItems
                      .isNotEmpty) // عرض الشارة فقط إذا كانت السلة غير فارغة
                    Positioned(
                      right: 5, // موضع الشارة من اليمين
                      top: 5, // موضع الشارة من الأعلى
                      child: Container(
                        padding: const EdgeInsets.all(2), // مسافة داخلية للشارة
                        decoration: BoxDecoration(
                          color: kAccentColor, // لون الشارة (لون التمييز)
                          borderRadius:
                              BorderRadius.circular(10), // حواف دائرية للشارة
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16, // الحد الأدنى لعرض الشارة
                          minHeight: 16, // الحد الأدنى لارتفاع الشارة
                        ),
                        child: Text(
                          '${cart.cartItems.length}', // عدد العناصر في السلة
                          style: const TextStyle(
                            color: Colors.black, // لون النص داخل الشارة
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // أيقونة الملف الشخصي
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // عند النقر، انتقل إلى شاشة الملف الشخصي
              Navigator.pushNamed(context, profileRoute);
            },
          ),
        ],
      ),
      body: Consumer2<ServicesProvider, CartProvider>(
        // تم تصحيح: استخدام ServicesProvider هنا
        builder: (context, servicesProvider, cartProvider, child) {
          // تم تصحيح: استخدام servicesProvider كاسم للمتغير
          if (servicesProvider.isLoading) {
            return const LoadingIndicator(); // عرض مؤشر التحميل أثناء جلب الخدمات
          } else if (servicesProvider.errorMessage != null) {
            return ErrorMessage(
              message:
                  servicesProvider.errorMessage!, // عرض رسالة الخطأ إذا حدثت
              // onRetry: () => servicesProvider.fetchServices(), // يمكن إضافة زر لإعادة المحاولة هنا
            );
          } else if (servicesProvider.availableServices.isEmpty) {
            return const EmptyState(
              message:
                  'لا توجد خدمات متاحة حالياً.', // عرض رسالة عند عدم وجود خدمات
              icon: Icons
                  .medical_services_outlined, // أيقونة مناسبة للحالة الفارغة
            );
          } else {
            // عرض قائمة الخدمات باستخدام ListView.builder
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: servicesProvider.availableServices.length,
              itemBuilder: (context, index) {
                final service = servicesProvider.availableServices[index];
                return ServiceCard(
                  service: service, // تمرير كائن الخدمة إلى ServiceCard
                  isSelected: cartProvider.isServiceSelected(
                      service), // التحقق مما إذا كانت الخدمة محددة في السلة
                  onCheckboxChanged: (bool? selected) {
                    // عند تغيير حالة مربع الاختيار، قم بتبديل الخدمة في CartProvider
                    cartProvider.toggleServiceSelection(service);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
