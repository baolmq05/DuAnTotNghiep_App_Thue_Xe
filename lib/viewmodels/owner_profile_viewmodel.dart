import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/owner_service.dart';
import 'package:flutter/material.dart';

class OwnerProfileViewModel extends ChangeNotifier {
  final OwnerProfileService _ownerService = OwnerProfileService();

  OwnerProfile? _ownerProfile;
  OwnerProfile? get ownerProfile => _ownerProfile;

  List<OwnerReview> _reviews = [];
  List<OwnerReview> get reviews => _reviews;

  bool _isLoading = false;
  String? _errorMessage;
  int _visibleReviewsCount = 5;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get visibleReviewsCount => _visibleReviewsCount;

  bool get hasMoreReviews {
    return _reviews.length > _visibleReviewsCount;
  }

  Future<void> fetchOwnerProfile({
    required int ownerId,
    required bool isOwner,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _visibleReviewsCount = 5; // Reset số lượng đánh giá hiển thị khi tải mới
    _reviews = [];
    notifyListeners();

    try {
      final data = await _ownerService.fetchProfileReviews(
        targetId: ownerId,
        isOwner: isOwner,
      );
      if (data != null) {
        // gán dữ liệu hồ sơ chủ xe vào biến _ownerProfile
        _ownerProfile = OwnerProfile.fromJson(data);

        // gán danh sách đánh giá vào biến _reviews
        if (data['reviews'] != null) {
          var reviewList = data['reviews'] as List? ?? [];
          _reviews = reviewList.map((r) => OwnerReview.fromJson(r)).toList();
        }
      }
      debugPrint('=== FETCH OWNER PROFILE SUCCESS: $_ownerProfile ===');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('=== FETCH OWNER PROFILE ERROR: $e ===');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMoreReviews() {
    if (_reviews.isEmpty) return;
    // Tăng thêm 5 đánh giá để hiển thị tiếp
    _visibleReviewsCount += 5;
    notifyListeners();
  }
}
