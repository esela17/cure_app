import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart'; // تأكد من اسم المجلد هنا (cure_app أو cure)
import 'package:cure_app/services/firestore_service.dart'; // تأكد من اسم المجلد هنا

class ServicesProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Service> _availableServices = [];
  bool _isLoading = false;
  String? _errorMessage;

  ServicesProvider(this._firestoreService) {
    _firestoreService.getServices().listen((services) {
      _availableServices = services;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Service> get availableServices => _availableServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchServices() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }
}
