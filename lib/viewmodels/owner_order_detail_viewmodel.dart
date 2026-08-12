import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/trip_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/cloudinary_upload_service.dart';

class OwnerOrderDetailViewModel extends ChangeNotifier {
  OwnerOrderDetailViewModel({
    TripService? tripService,
    CloudinaryUploadService? cloudinaryService,
  })  : _tripService = tripService ?? TripService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryUploadService();

  final TripService _tripService;
  final CloudinaryUploadService _cloudinaryService;
  final ImagePicker _picker = ImagePicker();

  TripModel? _trip;
  bool _isLoading = true;
  String _errorMessage = '';

  // Local pre-trip photos state
  final List<XFile> _selectedPreTripPhotos = [];
  bool _isSubmittingStart = false;

  // Local post-trip photos state
  final List<XFile> _selectedPostTripPhotos = [];
  bool _isSubmittingComplete = false;

  String? _actionError;

  TripModel? get trip => _trip;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<XFile> get selectedPreTripPhotos => List.unmodifiable(_selectedPreTripPhotos);
  bool get isSubmittingStart => _isSubmittingStart;

  List<XFile> get selectedPostTripPhotos => List.unmodifiable(_selectedPostTripPhotos);
  bool get isSubmittingComplete => _isSubmittingComplete;

  String? get actionError => _actionError;

  // Alias for backward compatibility
  List<XFile> get selectedLocalPhotos => selectedPreTripPhotos;

  Future<void> fetchTripDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = '';
    _selectedPreTripPhotos.clear();
    _selectedPostTripPhotos.clear();
    _actionError = null;
    notifyListeners();

    try {
      final trip = await _tripService.getTripDetail(orderId);
      _trip = trip;
      if (_trip == null) {
        _errorMessage = 'Không tìm thấy đơn thuê xe.';
      }
    } catch (_) {
      _errorMessage = 'Không thể tải chi tiết đơn thuê xe. Vui lòng thử lại!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pre-trip photo picking methods
  Future<void> pickPreTripGalleryImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        _selectedPreTripPhotos.addAll(pickedFiles);
        _actionError = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh thư viện trước chuyến: $e');
    }
  }

  Future<void> capturePreTripCameraImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _selectedPreTripPhotos.add(pickedFile);
        _actionError = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi chụp ảnh camera trước chuyến: $e');
    }
  }

  void removePreTripLocalPhoto(int index) {
    if (index >= 0 && index < _selectedPreTripPhotos.length) {
      _selectedPreTripPhotos.removeAt(index);
      notifyListeners();
    }
  }

  // Aliases for compatibility
  Future<void> pickGalleryImages() => pickPreTripGalleryImages();
  Future<void> captureCameraImage() => capturePreTripCameraImage();
  void removeLocalPhoto(int index) => removePreTripLocalPhoto(index);

  // Post-trip photo picking methods
  Future<void> pickPostTripGalleryImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        _selectedPostTripPhotos.addAll(pickedFiles);
        _actionError = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh thư viện sau chuyến: $e');
    }
  }

  Future<void> capturePostTripCameraImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _selectedPostTripPhotos.add(pickedFile);
        _actionError = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi chụp ảnh camera sau chuyến: $e');
    }
  }

  void removePostTripLocalPhoto(int index) {
    if (index >= 0 && index < _selectedPostTripPhotos.length) {
      _selectedPostTripPhotos.removeAt(index);
      notifyListeners();
    }
  }

  // Submit start trip (upload pre-trip images -> API startTrip)
  Future<Map<String, dynamic>> submitStartTrip(int tripId) async {
    if (_selectedPreTripPhotos.isEmpty) {
      _actionError = 'Vui lòng tải lên ít nhất 1 ảnh xe trước khi bắt đầu chuyến đi.';
      notifyListeners();
      return {'success': false, 'message': _actionError!};
    }

    _isSubmittingStart = true;
    _actionError = null;
    notifyListeners();

    try {
      final List<String> imageUrls = [];
      for (var file in _selectedPreTripPhotos) {
        final url = await _cloudinaryService.uploadImage(file, folder: 'trips');
        if (url != null && url.isNotEmpty) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) {
        _actionError = 'Tải ảnh lên hệ thống thất bại. Vui lòng thử lại!';
        _isSubmittingStart = false;
        notifyListeners();
        return {'success': false, 'message': _actionError!};
      }

      final result = await _tripService.startTrip(tripId, imageUrls);

      if (result['success'] == true) {
        _selectedPreTripPhotos.clear();
        await fetchTripDetail(tripId);
        return {'success': true, 'message': 'Bắt đầu chuyến đi thành công!'};
      } else {
        _actionError = result['message'] ?? 'Lỗi khi bắt đầu chuyến đi.';
        notifyListeners();
        return {'success': false, 'message': _actionError!};
      }
    } catch (e) {
      debugPrint('Lỗi khi bắt đầu chuyến đi: $e');
      _actionError = 'Có lỗi xảy ra khi bắt đầu chuyến đi: $e';
      notifyListeners();
      return {'success': false, 'message': _actionError!};
    } finally {
      _isSubmittingStart = false;
      notifyListeners();
    }
  }

  // Submit complete trip (upload post-trip images -> API completeTrip)
  Future<Map<String, dynamic>> submitCompleteTrip(int tripId) async {
    if (_selectedPostTripPhotos.isEmpty) {
      _actionError = 'Vui lòng chụp và chọn ít nhất 1 ảnh xe sau chuyến đi để hoàn tất.';
      notifyListeners();
      return {'success': false, 'message': _actionError!};
    }

    _isSubmittingComplete = true;
    _actionError = null;
    notifyListeners();

    try {
      final List<String> imageUrls = [];
      for (var file in _selectedPostTripPhotos) {
        final url = await _cloudinaryService.uploadImage(file, folder: 'trips');
        if (url != null && url.isNotEmpty) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) {
        _actionError = 'Tải ảnh lên hệ thống thất bại. Vui lòng thử lại!';
        _isSubmittingComplete = false;
        notifyListeners();
        return {'success': false, 'message': _actionError!};
      }

      final result = await _tripService.completeTrip(tripId, imageUrls);

      if (result['success'] == true) {
        _selectedPostTripPhotos.clear();
        await fetchTripDetail(tripId);
        return {'success': true, 'message': 'Xác nhận hoàn thành chuyến đi thành công!'};
      } else {
        _actionError = result['message'] ?? 'Lỗi khi hoàn thành chuyến đi.';
        notifyListeners();
        return {'success': false, 'message': _actionError!};
      }
    } catch (e) {
      debugPrint('Lỗi khi hoàn tất chuyến đi: $e');
      _actionError = 'Có lỗi xảy ra khi hoàn tất chuyến đi: $e';
      notifyListeners();
      return {'success': false, 'message': _actionError!};
    } finally {
      _isSubmittingComplete = false;
      notifyListeners();
    }
  }

  // Confirm trip (Owner approves request)
  Future<Map<String, dynamic>> confirmTrip(int tripId) async {
    try {
      final result = await _tripService.confirmTrip(tripId);
      if (result['success'] == true) {
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Reject trip
  Future<Map<String, dynamic>> rejectTrip(int tripId, {String? reason}) async {
    try {
      final result = await _tripService.rejectTrip(tripId, reason: reason);
      if (result['success'] == true) {
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }

  // Cancel trip
  Future<Map<String, dynamic>> cancelTrip(int tripId, {String? reason}) async {
    try {
      final result = await _tripService.cancelTrip(tripId, reason: reason);
      if (result['success'] == true) {
        await fetchTripDetail(tripId);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Có lỗi xảy ra: $e'};
    }
  }
}
