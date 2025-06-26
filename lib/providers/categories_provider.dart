import 'dart:async';

import 'package:cure_app/models/category_shortcut.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CategoriesProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _categoriesSubscription;
  List<CategoryShortcut> _categories = [];

  CategoriesProvider(this._firestoreService) {
    fetchCategories();
  }

  List<CategoryShortcut> get categories => _categories;

  void fetchCategories() {
    _categoriesSubscription?.cancel();
    _categoriesSubscription =
        _firestoreService.getCategoryShortcuts().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}
