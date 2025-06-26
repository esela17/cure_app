import 'package:cure_app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart';
import 'package:cure_app/providers/auth_provider.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  AuthProvider _authProvider;

  CartProvider(this._firestoreService, this._authProvider);

  final List<Service> _cartItems = [];
  DateTime? _selectedAppointmentDate;
  String _notes = '';
  bool _isPlacingOrder = false;
  String? _orderErrorMessage;
  String _serviceProviderType = 'غير محدد';

  // الموقع الجغرافي
  double? _selectedLat;
  double? _selectedLng;

  // Getters
  List<Service> get cartItems => _cartItems;
  DateTime? get selectedAppointmentDate => _selectedAppointmentDate;
  String get notes => _notes;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get orderErrorMessage => _orderErrorMessage;
  String get serviceProviderType => _serviceProviderType;
  double? get selectedLat => _selectedLat;
  double? get selectedLng => _selectedLng;

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price);

  // Cart operations
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

  void removeFromCart(Service service) {
    removeItem(service);
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
    _selectedLat = null;
    _selectedLng = null;
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

  void updateAuth(AuthProvider newAuth) {
    _authProvider = newAuth;
  }

  void setServiceProviderType(String type) {
    _serviceProviderType = type;
    notifyListeners();
  }

  void setSelectedLocation(double lat, double lng) {
    _selectedLat = lat;
    _selectedLng = lng;
    notifyListeners();
  }

  Future<String?> placeOrder(
      String phoneNumber, String deliveryAddress, BuildContext context,
      {bool requiresAppointment = true}) async {
    if (_cartItems.isEmpty || _authProvider.currentUser == null) {
      _orderErrorMessage = 'خطأ! تأكد من وجود خدمات في السلة وأنك مسجل دخول.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      return null;
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
        locationLat: _selectedLat,
        locationLng: _selectedLng,
      );

      final docRef = await _firestoreService.addOrder(order);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('activeOrderId', docRef.id);

      clearCart();
      showSnackBar(context, 'تم إرسال طلبك بنجاح!');
      return docRef.id;
    } catch (e) {
      print("!!!!!!!! ERROR PLACING ORDER: $e !!!!!!!!");
      _orderErrorMessage = 'حدث خطأ أثناء إرسال الطلب.';
      showSnackBar(context, _orderErrorMessage!, isError: true);
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
