import 'dart:async';
import 'package:cure_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cure_app/models/order.dart';
import 'package:cure_app/services/firestore_service.dart';

class NurseProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _pendingOrdersSubscription;
  StreamSubscription? _myOrdersSubscription;

  List<Order> _pendingOrders = [];
  List<Order> _myOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAvailable = true;

  NurseProvider(this._firestoreService) {
    fetchPendingOrders();
  }

  // Getters
  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;

  int get pendingOrdersCount => _pendingOrders.length;
  int get acceptedOrdersCount =>
      _myOrders.where((o) => o.status == 'accepted').length;

  void setAvailability(bool available) {
    _isAvailable = available;
    notifyListeners();
  }

  void fetchPendingOrders() {
    _isLoading = true;
    notifyListeners();
    _pendingOrdersSubscription?.cancel();
    _pendingOrdersSubscription =
        _firestoreService.getPendingOrders().listen((orders) {
      _pendingOrders = orders;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      print("!!!!!!!! ERROR fetching pending orders: $error !!!!!!!!");
      _errorMessage = "حدث خطأ في جلب الطلبات المتاحة.";
      _isLoading = false;
      notifyListeners();
    });
  }

  void fetchMyOrders(String nurseId) {
    _myOrdersSubscription?.cancel();
    _myOrdersSubscription =
        _firestoreService.getOrdersForNurse(nurseId).listen((orders) {
      _myOrders = orders;
      notifyListeners();
    }, onError: (error) {
      print("Error fetching nurse's own orders: $error");
    });
  }

  Future<bool> acceptOrder(Order order, UserModel nurse) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateOrderStatus(order.id, {
        'status': 'accepted',
        'nurseId': nurse.id,
        'nurseName': nurse.name,
      });
      fetchPendingOrders();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "فشل قبول الطلب: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(Order order) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService
          .updateOrderStatus(order.id, {'status': 'rejected'});
      fetchPendingOrders();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "فشل رفض الطلب: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeOrder(Order order) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService
          .updateOrderStatus(order.id, {'status': 'completed'});
      fetchPendingOrders();
      fetchMyOrders(order.nurseId!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "فشل إكمال الطلب: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _pendingOrdersSubscription?.cancel();
    _myOrdersSubscription?.cancel();
    super.dispose();
  }
}
