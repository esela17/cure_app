import 'package:flutter/material.dart';
import 'package:cure_app/models/order.dart'; // استيراد نموذج الطلب
import 'package:cure_app/services/firestore_service.dart'; // استيراد FirestoreService
import 'package:cure_app/providers/auth_provider.dart'; // لاستخدام معرف المستخدم

class OrdersProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider; // نحتاجه للحصول على userId
  List<Order> _userOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  Stream<List<Order>>? _ordersStream; // لتخزين الـ stream والتعامل معه

  OrdersProvider(this._firestoreService, this._authProvider) {
    // ابدأ بالاستماع للطلبات بمجرد تهيئة الـ AuthProvider والمستخدم
    _authProvider.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    if (_authProvider.currentUser != null) {
      // إذا كان المستخدم مسجل الدخول، ابدأ في الاستماع لطلباته
      _startListeningToOrders(_authProvider.currentUser!.uid);
    } else {
      // إذا لم يكن هناك مستخدم مسجل الدخول، أوقف الاستماع ومسح الطلبات
      _stopListeningToOrders();
    }
  }

  void _startListeningToOrders(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // إعلام المستمعين بحالة التحميل

    // إلغاء الاشتراك في الـ stream القديم لتجنب الاستماع المتعدد
    _ordersStream?.listen(null).cancel();

    _ordersStream = _firestoreService.getUserOrders(userId).asBroadcastStream();
    _ordersStream!.listen((orders) {
      _userOrders = orders;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'حدث خطأ أثناء جلب الطلبات: ${error.toString()}';
      _isLoading = false;
      notifyListeners();
    }, onDone: () {
      _isLoading = false; // قد يكون Stream قد انتهى
      notifyListeners();
    });
  }

  void _stopListeningToOrders() {
    _ordersStream?.listen(null).cancel(); // إلغاء الاشتراك
    _userOrders = []; // مسح الطلبات
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<Order> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // لتحديث الطلبات يدويا (اختياري، Stream يكفي عادة)
  void fetchUserOrders() {
    if (_authProvider.currentUser != null) {
      _startListeningToOrders(_authProvider.currentUser!.uid);
    } else {
      _errorMessage = 'لا يوجد مستخدم مسجل الدخول لعرض الطلبات.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange); // مهم: إزالة المستمع
    _stopListeningToOrders(); // إيقاف Stream عند التخلص من الـ Provider
    super.dispose();
  }
}
