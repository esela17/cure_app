import 'package:cure_app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/helpers.dart';

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider;

  CartProvider(this._firestoreService, this._authProvider);

  List<Service> _cartItems = [];
  DateTime? _selectedAppointmentDate;
  String _notes = '';
  bool _isPlacingOrder = false;
  String? _orderErrorMessage;
  String _serviceProviderType = 'غير محدد';

  List<Service> get cartItems => _cartItems;
  DateTime? get selectedAppointmentDate => _selectedAppointmentDate;
  String get notes => _notes;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get orderErrorMessage => _orderErrorMessage;
  String get serviceProviderType => _serviceProviderType;

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price);

  void addItem(Service service) {
    if (!_cartItems.any((item) => item.id == service.id)) {
      _cartItems.add(service);
      notifyListeners();
    }
  }

  void removeItem(Service service) {
    _cartItems.removeWhere((item) => item.id == service.id);
    notifyListeners();
  }

  bool isServiceSelected(Service service) {
    return _cartItems.any((item) => item.id == service.id);
  }

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
    _serviceProviderType = 'غير محدد';
    notifyListeners();
  }

  void setAppointmentDate(DateTime? dateTime) {
    _selectedAppointmentDate = dateTime;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void setServiceProviderType(String type) {
    _serviceProviderType = type;
    notifyListeners();
  }

  Future<void> placeOrder(
      String phoneNumber, String deliveryAddress, BuildContext context,
      {bool requiresAppointment = true}) async {
    if (_cartItems.isEmpty) {
      _orderErrorMessage = 'سلة الخدمات فارغة. يرجى إضافة خدمات.';
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

    _isPlacingOrder = true;
    _orderErrorMessage = null;
    notifyListeners();

    try {
      final userId = _authProvider.currentUser!.uid;
      final patientName =
          _authProvider.currentUserProfile?.name ?? 'مستخدم غير معروف';

      final order = Order(
        id: '',
        userId: userId,
        patientName: patientName,
        services: List.from(_cartItems),
        totalPrice: totalPrice,
        status: 'pending',
        orderDate: DateTime.now(),
        appointmentDate: _selectedAppointmentDate,
        notes: _notes,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        serviceProviderType: _serviceProviderType,
        isRated: false,
      );

      await _firestoreService.addOrder(order);
      clearCart();
      showSnackBar(context, 'تم إرسال طلبك بنجاح!');
    } catch (e) {
      _orderErrorMessage = 'حدث خطأ أثناء إرسال الطلب: ${e.toString()}';
      showSnackBar(context, _orderErrorMessage!, isError: true);
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
