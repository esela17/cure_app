import 'dart:async';

import 'package:cure_app/models/ad_banner.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AdsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _adsSubscription;
  List<AdBanner> _ads = [];

  AdsProvider(this._firestoreService) {
    fetchAds();
  }

  List<AdBanner> get ads => _ads;

  void fetchAds() {
    _adsSubscription?.cancel();
    _adsSubscription = _firestoreService.getAdvertisements().listen((ads) {
      _ads = ads;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _adsSubscription?.cancel();
    super.dispose();
  }
}
