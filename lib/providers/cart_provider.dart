import 'package:cure_app/models/order.dart'; // تأكد أن المسار صحيح (cure_app أو cure)
import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart'; // تأكد أن المسار صحيح
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/helpers.dart'; // لاستخدام showSnackBar

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider;

  // المنشئ (Constructor)
  CartProvider(this._firestoreService, this._authProvider);

  // --- متغيرات الحالة ---
  List<Service> _cartItems = [];
  DateTime? _selectedAppointmentDate;
  String _notes = '';
  bool _isPlacingOrder = false;
  String? _orderErrorMessage;

  String _serviceProviderType = 'غير محدد'; // تم إضافة هذا المتغير

  // --- Getters للوصول إلى الحالة من الواجهة ---
  List<Service> get cartItems => _cartItems;
  DateTime? get selectedAppointmentDate => _selectedAppointmentDate;
  String get notes => _notes;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get orderErrorMessage => _orderErrorMessage;
  String get serviceProviderType => _serviceProviderType;

  // حساب السعر الإجمالي
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price);

  // --- طرق إدارة السلة ---
  void addItem(Service service) {
    // تحقق مما إذا كانت الخدمة موجودة بالفعل لتجنب التكرار إذا كان ذلك مطلوبًا
    if (!_cartItems.any((item) => item.id == service.id)) {
      _cartItems.add(service);
      notifyListeners();
    }
  }

  void removeItem(Service service) {
    _cartItems.removeWhere((item) =>
        item.id == service.id); // استخدام removeWhere لضمان إزالة العنصر الصحيح
    notifyListeners();
  }

  // تحقق مما إذا كانت الخدمة محددة في السلة
  bool isServiceSelected(Service service) {
    return _cartItems.any((item) => item.id == service.id);
  }

  // تبديل اختيار الخدمة (إضافة أو إزالة)
  void toggleServiceSelection(Service service) {
    if (isServiceSelected(service)) {
      removeItem(service);
    } else {
      addItem(service);
    }
  }

  void clearCart() {
    _cartItems.clear();
    _selectedAppointmentDate = null;
    _notes = '';
    _orderErrorMessage = null;
    _serviceProviderType = 'غير محدد'; // إعادة تعيين هذا أيضًا
    notifyListeners();
  }

  // --- طرق تفاصيل الموعد ---
  void setAppointmentDate(DateTime? dateTime) {
    _selectedAppointmentDate = dateTime;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  // --- طريقة نوع مقدم الخدمة ---
  void setServiceProviderType(String type) {
    _serviceProviderType = type;
    notifyListeners();
  }

  // --- طريقة إرسال الطلب ---
  // تم تعديل: إضافة 'phoneNumber' و 'deliveryAddress' كـ parameters إجبارية
  Future<void> placeOrder(
      String phoneNumber, String deliveryAddress, BuildContext context,
      {bool requiresAppointment = true}) async {
    // --- تحققات Validation ---
    if (_cartItems.isEmpty) {
      _orderErrorMessage = 'سلة الخدمات فارغة. يرجى إضافة خدمات.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      notifyListeners();
      return;
    }

    if (requiresAppointment && _selectedAppointmentDate == null) {
      _orderErrorMessage = 'الرجاء تحديد تاريخ ووقت الموعد للطلب المحدد.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      notifyListeners();
      return;
    }

    // **تحقق جديد: رقم الهاتف**
    if (phoneNumber.isEmpty) {
      _orderErrorMessage = 'الرجاء إدخال رقم الهاتف للتواصل.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      notifyListeners();
      return;
    }

    // **تحقق جديد: العنوان**
    if (deliveryAddress.isEmpty) {
      _orderErrorMessage = 'الرجاء إدخال عنوان الخدمة.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      notifyListeners();
      return;
    }

    if (_authProvider.currentUser == null) {
      _orderErrorMessage = 'يجب تسجيل الدخول لإتمام الطلب.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      notifyListeners();
      return;
    }

    _isPlacingOrder = true; // بدء عملية الطلب
    _orderErrorMessage = null; // مسح أي أخطاء سابقة
    notifyListeners();

    try {
      // الحصول على معرف المستخدم (UID) من AuthProvider.currentUser
      final userId = _authProvider.currentUser!.uid;

      // بناء كائن الطلب (Order object)
      final order = Order(
        id: '', // Firestore سيعين معرفًا تلقائيًا
        userId: userId,
        services: List.from(_cartItems), // إنشاء نسخة من قائمة الخدمات
        totalPrice: totalPrice,
        status: 'pending', // الحالة الأولية للطلب
        orderDate: DateTime.now(), // وقت وتاريخ إنشاء الطلب
        appointmentDate:
            _selectedAppointmentDate, // سيظل null إذا لم يتم تحديده
        notes: _notes,
        deliveryAddress: deliveryAddress, // <--- تم تضمين العنوان
        phoneNumber: phoneNumber, // <--- تم تضمين رقم الهاتف
        serviceProviderType:
            _serviceProviderType, // <--- تم تضمين نوع مقدم الخدمة
      );

      // إرسال الطلب عبر FirestoreService
      await _firestoreService.addOrder(order);

      clearCart(); // ستعيد هذه الدالة تعيين السلة والnotes والـ serviceProviderType

      showSnackBar(context, 'تم إرسال طلبك بنجاح!'); // رسالة نجاح للمستخدم
    } catch (e) {
      _orderErrorMessage = 'حدث خطأ أثناء إرسال الطلب: ${e.toString()}';
      showSnackBar(context, _orderErrorMessage!, isError: true);
    } finally {
      _isPlacingOrder = false; // إنهاء حالة التحميل
      notifyListeners();
    }
  }
}
