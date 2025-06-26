import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/providers/auth_provider.dart';

class OrdersProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  AuthProvider _authProvider;
  List<Order> _userOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _ordersStreamSubscription;

  OrdersProvider(this._firestoreService, this._authProvider) {
    _authProvider.addListener(_onAuthChange);
    _onAuthChange(); // Initial check
  }
  void updateAuth(AuthProvider newAuth) {
    _authProvider = newAuth;
  }

  void _onAuthChange() {
    if (_authProvider.currentUser != null) {
      fetchUserOrders(_authProvider.currentUser!.uid);
    } else {
      _stopListeningToOrders();
    }
  }

  void fetchUserOrders([String? userId]) {
    final id = userId ?? _authProvider.currentUser?.uid;
    if (id == null) {
      _errorMessage = 'لا يوجد مستخدم مسجل الدخول لعرض الطلبات.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _ordersStreamSubscription?.cancel();
    _ordersStreamSubscription =
        _firestoreService.getUserOrders(id).listen((orders) {
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
    _ordersStreamSubscription?.cancel();
    _userOrders = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<Order> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- This is the new function that was missing ---
  Future<bool> submitReview({
    required Order order,
    required double rating,
    required String comment,
  }) async {
    if (order.nurseId == null || _authProvider.currentUserProfile == null) {
      _errorMessage = "Cannot submit review without nurse or patient info.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.submitReview(
        orderId: order.id,
        nurseId: order.nurseId!,
        rating: rating,
        reviewText: comment,
        patientName: _authProvider.currentUserProfile!.name,
      );

      // Refresh the orders list to update the 'isRated' status
      fetchUserOrders(order.userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to submit review: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // ----------------------------------------------

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange);
    _ordersStreamSubscription?.cancel();
    super.dispose();
  }
}
