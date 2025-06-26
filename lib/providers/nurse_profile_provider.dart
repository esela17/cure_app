import 'package:cure_app/models/review_model.dart';
import 'package:cure_app/models/user_model.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class NurseProfileProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  NurseProfileProvider(this._firestoreService);

  UserModel? _nurseProfile;
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get nurseProfile => _nurseProfile;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNurseProfileAndReviews(String nurseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // جلب بيانات الممرض والمراجعات في نفس الوقت
      final results = await Future.wait([
        _firestoreService.getUser(nurseId),
        _firestoreService.getReviewsForNurse(nurseId),
      ]);

      _nurseProfile = results[0] as UserModel?;
      _reviews = results[1] as List<ReviewModel>;

      if (_nurseProfile == null) {
        _errorMessage = 'لم يتم العثور على الممرض.';
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل بيانات الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
