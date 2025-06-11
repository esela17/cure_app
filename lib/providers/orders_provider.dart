import 'package:flutter/material.dart';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/providers/auth_provider.dart';

class OrdersProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider;
  List<Order> _userOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  Stream<List<Order>>? _ordersStream;

  OrdersProvider(this._firestoreService, this._authProvider) {
    _authProvider.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    if (_authProvider.currentUser != null) {
      _startListeningToOrders(_authProvider.currentUser!.uid);
    } else {
      _stopListeningToOrders();
    }
  }

  void _startListeningToOrders(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _ordersStream?.listen(null).cancel();
    _ordersStream = _firestoreService.getUserOrders(userId).asBroadcastStream();
    _ordersStream!.listen((orders) {
      _userOrders = orders;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("!!!!!!!! ERROR fetching user orders: $error !!!!!!!!");
      _errorMessage = 'حدث خطأ أثناء جلب الطلبات: ${error.toString()}';
      _isLoading = false;
      notifyListeners();
    });
  }

  void _stopListeningToOrders() {
    _ordersStream?.listen(null).cancel();
    _userOrders = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<Order> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    _authProvider.removeListener(_onAuthChange);
    _stopListeningToOrders();
    super.dispose();
  }
}
