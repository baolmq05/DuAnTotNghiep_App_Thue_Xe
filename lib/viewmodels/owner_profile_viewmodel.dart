import 'package:duantotnghiep_app_thue_xe/models/owner_profile_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/owner_service.dart';
import 'package:flutter/material.dart';

class OwnerProfileViewModel extends ChangeNotifier {
  final OwnerProfileService _ownerService = OwnerProfileService();

  // Dữ liệu hồ sơ theo 2 vai trò
  OwnerProfile? _ownerProfile;       // Vai trò Chủ xe (isOwner = true)
  OwnerProfile? _customerProfile;    // Vai trò Người thuê (isOwner = false)

  List<OwnerReview> _ownerReviews = [];
  List<OwnerReview> _customerReviews = [];

  bool _isLoading = false;
  String? _errorMessage;
  int _visibleReviewsCount = 5;

  // 0: Tab Chủ xe, 1: Tab Người thuê
  int _currentTab = 0;

  OwnerProfile? get ownerProfile => _currentTab == 0 ? _ownerProfile : _customerProfile;
  OwnerProfile? get ownerRoleProfile => _ownerProfile;
  OwnerProfile? get customerRoleProfile => _customerProfile;

  List<OwnerReview> get reviews => _currentTab == 0 ? _ownerReviews : _customerReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get visibleReviewsCount => _visibleReviewsCount;
  int get currentTab => _currentTab;

  bool get hasMoreReviews {
    return reviews.length > _visibleReviewsCount;
  }

  void switchTab(int tabIndex, {required int targetId}) {
    if (_currentTab == tabIndex) return;
    _currentTab = tabIndex;
    _visibleReviewsCount = 5;
    notifyListeners();

    // Nếu tab chưa có dữ liệu thì tải
    if (_currentTab == 0 && _ownerProfile == null) {
      _loadRoleData(targetId: targetId, isOwner: true);
    } else if (_currentTab == 1 && _customerProfile == null) {
      _loadRoleData(targetId: targetId, isOwner: false);
    }
  }

  Future<void> fetchOwnerProfile({
    required int ownerId,
    required bool isOwner,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _visibleReviewsCount = 5;
    _currentTab = isOwner ? 0 : 1;
    _ownerProfile = null;
    _customerProfile = null;
    _ownerReviews = [];
    _customerReviews = [];
    notifyListeners();

    try {
      // Tải dữ liệu cho tab hiện tại trước
      await _loadRoleData(targetId: ownerId, isOwner: isOwner);

      // Tải ngầm dữ liệu cho tab còn lại để chuyển tab mượt mà
      _loadRoleData(targetId: ownerId, isOwner: !isOwner, silent: true);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('=== FETCH OWNER PROFILE ERROR: $e ===');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRoleData({
    required int targetId,
    required bool isOwner,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _ownerService.fetchProfileReviews(
        targetId: targetId,
        isOwner: isOwner,
      );

      if (data != null) {
        final profile = OwnerProfile.fromJson(data);
        var reviewList = data['reviews'] as List? ?? [];
        final parsedReviews = reviewList
            .where((r) => r != null)
            .map((r) => OwnerReview.fromJson(r as Map<String, dynamic>))
            .toList();

        if (isOwner) {
          _ownerProfile = profile;
          _ownerReviews = parsedReviews;
        } else {
          _customerProfile = profile;
          _customerReviews = parsedReviews;
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải profile role (isOwner=$isOwner): $e');
      if (!silent) {
        _errorMessage = e.toString();
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  void loadMoreReviews() {
    if (reviews.isEmpty) return;
    _visibleReviewsCount += 5;
    notifyListeners();
  }
}
