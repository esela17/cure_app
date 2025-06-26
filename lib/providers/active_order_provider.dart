import 'dart:async';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveOrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _activeOrderSubscription;

  Order? _activeOrder;
  bool _isLoading = true;

  Order? get activeOrder => _activeOrder;
  bool get isLoading => _isLoading;

  ActiveOrderProvider(this._firestoreService) {
    _loadActiveOrder();
  }

  Future<void> _loadActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final activeOrderId = prefs.getString('activeOrderId');

    if (activeOrderId != null) {
      await loadOrderById(activeOrderId);
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderById(String orderId) async {
    _isLoading = true;
    notifyListeners();

    _activeOrderSubscription?.cancel();
    _activeOrderSubscription =
        _firestoreService.getOrderStream(orderId).listen((order) async {
      _activeOrder = order;

      if (order.status == 'completed' || order.status == 'cancelled') {
        await clearActiveOrder();
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshActiveOrder() async {
    _isLoading = true;
    notifyListeners();
    await _loadActiveOrder();
  }

  Future<void> clearActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeOrderId');
    _activeOrder = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _activeOrderSubscription?.cancel();
    super.dispose();
  }
}
