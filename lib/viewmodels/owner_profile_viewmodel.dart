import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/owner_service.dart';
import 'package:flutter/material.dart';

class OwnerProfileViewModel extends ChangeNotifier {
  final OwnerService _ownerService = OwnerService();

  OwnerProfile? _ownerProfile;
  bool _isLoading = false;
  String? _errorMessage;
  int _visibleReviewsCount = 5;

  OwnerProfile? get ownerProfile => _ownerProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get visibleReviewsCount => _visibleReviewsCount;

  bool get hasMoreReviews {
    if (_ownerProfile == null) return false;
    return _ownerProfile!.reviews.length > _visibleReviewsCount;
  }

  Future<void> fetchOwnerProfile(int ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    _visibleReviewsCount = 5; // Reset số lượng đánh giá hiển thị khi tải mới
    notifyListeners();

    try {
      _ownerProfile = await _ownerService.fetchOwnerProfile(ownerId);
      debugPrint('=== FETCH OWNER PROFILE SUCCESS ===');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('=== FETCH OWNER PROFILE ERROR: $e ===');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMoreReviews() {
    if (_ownerProfile == null) return;
    // Tăng thêm 5 đánh giá để hiển thị tiếp
    _visibleReviewsCount += 5;
    notifyListeners();
  }
}
