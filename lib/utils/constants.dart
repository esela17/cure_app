import 'package:flutter/material.dart';

// تعريف ألوان التطبيق الرئيسية
const Color kPrimaryColor = const Color(0xFF6d73ff); // أزرق بنفسجي
const Color kAccentColor = const Color(0xFFadfa7d); // أخضر فاتح/ليموني

// تعريف المسارات المسماة للتنقل بين الشاشات
const String splashRoute = '/';
const String authCheckRoute = '/authCheck';
const String loginRoute = '/login';
const String registerRoute = '/register';
const String homeRoute = '/home';
const String serviceDetailsRoute = '/serviceDetails';
const String cartRoute = '/cart';
const String checkoutRoute = '/checkout';
const String ordersRoute = '/orders';
const String profileRoute = '/profile';

// تعريف التعداد (Enum) لأنواع مقدمي الخدمة المتاحة
enum ServiceProviderType {
  unspecified, // غير محدد
  nurseMale, // ممرض (ذكر)
  nurseFemale, // ممرضة (أنثى)
}

// إضافة امتداد (Extension) لـ ServiceProviderType لتحويل قيم التعداد إلى نصوص عربية
extension ServiceProviderTypeExtension on ServiceProviderType {
  String toArabicString() {
    switch (this) {
      case ServiceProviderType.unspecified:
        return 'غير محدد';
      case ServiceProviderType.nurseMale:
        return 'ممرض';
      case ServiceProviderType.nurseFemale:
        return 'ممرضة';
    }
  }
}
