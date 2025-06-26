import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart';
import 'package:cure_app/services/firestore_service.dart';

class ServicesProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Service> _availableServices = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _servicesSubscription;

  ServicesProvider(this._firestoreService) {
    fetchServices();
  }

  List<Service> get availableServices => _availableServices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchServices() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _servicesSubscription?.cancel();
    _servicesSubscription = _firestoreService.getServices().listen((services) {
      _availableServices = services;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = "Failed to load services: $error";
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _servicesSubscription?.cancel();
    super.dispose();
  }
}
