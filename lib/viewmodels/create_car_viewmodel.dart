import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/CarDetail/car_brand_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_type_item_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_feature_item_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/create_car_request_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/create_car_response_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/cloudinary_upload_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/goong_map_service.dart';

class CreateCarViewModel extends ChangeNotifier {
  CreateCarViewModel({
    CarService? carService,
    CloudinaryUploadService? cloudinaryService,
    GoongMapService? goongMapService,
  })  : _carService = carService ?? CarService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryUploadService(),
        _goongMapService = goongMapService ?? GoongMapService();

  final CarService _carService;
  final CloudinaryUploadService _cloudinaryService;
  final GoongMapService _goongMapService;

  int? editingCarId;
  bool get isEditMode => editingCarId != null;

  // Master Data
  List<CarBrand> _brands = [];
  List<CarTypeItem> _types = [];
  List<CarFeatureItem> _features = [];

  bool _isLoadingData = true;
  bool _isSubmitting = false;
  bool _isLoadingTypes = false;
  bool _isUploadingImage = false;
  String _errorMessage = '';
  String _successMessage = '';
  final Map<String, String> _fieldErrors = {};

  // Location suggestions from GoongMap
  List<String> _locationSuggestions = [];
  List<String> _addressSuggestions = [];

  // Getters for master data & state
  List<CarBrand> get brands => _brands;
  List<CarTypeItem> get types => _types;
  List<CarFeatureItem> get features => _features;
  bool get isLoadingData => _isLoadingData;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingTypes => _isLoadingTypes;
  bool get isUploadingImage => _isUploadingImage;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  Map<String, String> get fieldErrors => _fieldErrors;

  List<String> get locationSuggestions => _locationSuggestions;
  List<String> get addressSuggestions => _addressSuggestions;

  // Form Field Values
  int? selectedBrandId;
  int? selectedTypeId;

  String licensePlate = '';
  String vin = '';
  String engineNumber = '';

  double fuelConsumption = 6.5;
  double unitPrice = 500000;
  double discountValue = 0;

  String description = '';
  String rentalTerms = '';

  int seatCount = 5;
  int manufactureYear = DateTime.now().year;

  String fuelType = 'gasoline'; // gasoline, diesel, electric, hybrid
  String transmission = 'automatic'; // automatic, manual

  String location = '';
  String address = '';

  bool deliveryEnabled = false;
  double deliveryMaxDistance = 0;
  double deliveryFee = 0;
  double deliveryFreeDistance = 0;

  final List<int> selectedFeatures = [];

  final List<String> images = [];
  final List<XFile> selectedImageFiles = [];
  int thumbnailIndex = 0;

  /// Helper lấy tên Thương hiệu đã chọn
  String get selectedBrandName {
    if (selectedBrandId == null) return '';
    final brand = _brands.firstWhere(
      (b) => b.id == selectedBrandId,
      orElse: () => CarBrand(id: 0, brand_name: '', createdAt: null, updatedAt: null),
    );
    return brand.brand_name;
  }

  /// Helper lấy tên Loại xe đã chọn
  String get selectedTypeName {
    if (selectedTypeId == null) return '';
    final type = _types.firstWhere(
      (t) => t.id == selectedTypeId,
      orElse: () => CarTypeItem(id: 0, typeName: ''),
    );
    return type.typeName;
  }

  /// Tải dữ liệu danh mục ban đầu (Thương hiệu & Tính năng)
  Future<void> fetchInitialData() async {
    _isLoadingData = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _carService.getCarBrands(),
        _carService.getCarFeatures(),
      ]);

      _brands = results[0] as List<CarBrand>;
      _features = results[1] as List<CarFeatureItem>;

      if (_brands.isNotEmpty) {
        selectedBrandId = _brands.first.id;
        await fetchTypesForBrand(selectedBrandId!);
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh mục xe: $e';
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  /// Tải thông tin danh mục và nạp dữ liệu xe cần chỉnh sửa
  Future<void> fetchInitialDataAndLoadCar(int carId) async {
    editingCarId = carId;
    _isLoadingData = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Tải danh mục trước
      final results = await Future.wait([
        _carService.getCarBrands(),
        _carService.getCarFeatures(),
      ]);

      _brands = results[0] as List<CarBrand>;
      _features = results[1] as List<CarFeatureItem>;

      // 2. Tải chi tiết xe cần chỉnh sửa
      final carDetail = await _carService.getCarDetail(id: carId);

      int brandId = carDetail.carType.carBrandId;
      if (brandId == 0) {
        brandId = carDetail.carBrandId;
      }
      if (brandId == 0) {
        brandId = carDetail.carBrand.id;
      }
      selectedBrandId = brandId != 0 ? brandId : null;

      if (selectedBrandId != null) {
        _types = await _carService.getCarTypes(selectedBrandId!);
      } else {
        _types = [];
      }

      int typeId = carDetail.carTypeId;
      if (typeId == 0) {
        typeId = carDetail.carType.id;
      }
      selectedTypeId = typeId != 0 ? typeId : null;

      licensePlate = carDetail.licensePlate;
      vin = carDetail.VIN;
      engineNumber = carDetail.engineNumber;

      fuelConsumption = carDetail.fuelConsumption.toDouble();
      unitPrice = double.tryParse(carDetail.unitPrice) ?? 0.0;
      discountValue = double.tryParse(carDetail.discountValue) ?? 0.0;

      description = carDetail.description ?? '';
      rentalTerms = carDetail.rentalTerms;

      seatCount = int.tryParse(carDetail.seatCount) ?? 5;
      manufactureYear = int.tryParse(carDetail.manufactureYear) ?? DateTime.now().year;

      final fType = carDetail.fuelType.toLowerCase();
      if (fType.contains('xăng') || fType.contains('gasoline')) {
        fuelType = 'gasoline';
      } else if (fType.contains('dầu') || fType.contains('diesel')) {
        fuelType = 'diesel';
      } else if (fType.contains('điện') || fType.contains('electric')) {
        fuelType = 'electric';
      } else if (fType.contains('hybrid')) {
        fuelType = 'hybrid';
      } else {
        fuelType = 'gasoline';
      }

      final trans = carDetail.transmission.toLowerCase();
      if (trans.contains('tự động') || trans.contains('automatic') || trans.contains('auto')) {
        transmission = 'automatic';
      } else if (trans.contains('sàn') || trans.contains('manual')) {
        transmission = 'manual';
      } else {
        transmission = 'automatic';
      }

      address = carDetail.carLocation.address;

      if (address.isNotEmpty) {
        final parts = address.split(',');
        if (parts.isNotEmpty) {
          location = parts.last.trim();
        }
      } else {
        location = '';
      }

      final coords = carDetail.carLocation.location.split(',');
      if (coords.length == 2) {
        selectedLat = double.tryParse(coords[0]) ?? 10.03711;
        selectedLng = double.tryParse(coords[1]) ?? 105.78275;
      } else {
        selectedLat = 10.03711;
        selectedLng = 105.78275;
      }

      deliveryEnabled = carDetail.deliveryOption.status == 1;
      deliveryMaxDistance = carDetail.deliveryOption.maxDistance.toDouble();
      deliveryFee = carDetail.deliveryOption.feeDistance.toDouble();
      deliveryFreeDistance = carDetail.deliveryOption.freeDistance.toDouble();

      selectedFeatures.clear();
      for (final f in carDetail.features) {
        selectedFeatures.add(f.id);
      }

      images.clear();
      for (int i = 0; i < carDetail.images.length; i++) {
        final img = carDetail.images[i];
        images.add(img.imageUrl);
        if (img.isThumbnail == 1) {
          thumbnailIndex = i;
        }
      }
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin xe cần chỉnh sửa: $e';
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  /// Tải danh sách Loại xe khi thay đổi Thương hiệu
  Future<void> fetchTypesForBrand(int brandId) async {
    selectedBrandId = brandId;
    _isLoadingTypes = true;
    selectedTypeId = null;
    notifyListeners();

    try {
      _types = await _carService.getCarTypes(brandId);
      if (_types.isNotEmpty) {
        selectedTypeId = _types.first.id;
      }
    } catch (e) {
      debugPrint('Lỗi fetchTypesForBrand: $e');
      _types = [];
    } finally {
      _isLoadingTypes = false;
      notifyListeners();
    }
  }

  // Address suggestions with PlaceId
  List<Map<String, String>> _addressSuggestionsWithId = [];
  List<Map<String, String>> get addressSuggestionsWithId => _addressSuggestionsWithId;

  double selectedLat = 10.03711;
  double selectedLng = 105.78275;

  /// GoongMap: Lấy gợi ý Địa chỉ chi tiết kèm PlaceId từ Goong API
  Future<void> fetchAddressSuggestions(String query) async {
    address = query;
    if (query.trim().isEmpty) {
      _addressSuggestionsWithId = [];
      notifyListeners();
      return;
    }
    try {
      _addressSuggestionsWithId = await _goongMapService.getSuggestionsWithPlaceId(query);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi fetchAddressSuggestions: $e');
    }
  }

  /// Chọn địa điểm gợi ý & lấy Tọa độ (lat, lng) hiển thị trên bản đồ
  Future<void> selectAddressSuggestionItem(Map<String, String> item) async {
    address = item['description'] ?? '';
    _addressSuggestionsWithId = [];
    notifyListeners();

    final placeId = item['place_id'];
    if (placeId != null && placeId.isNotEmpty) {
      try {
        final latLng = await _goongMapService.getPlaceLatLng(placeId);
        if (latLng != null && latLng['lat'] != 0.0 && latLng['lng'] != 0.0) {
          selectedLat = latLng['lat']!;
          selectedLng = latLng['lng']!;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Lỗi getPlaceLatLng: $e');
      }
    }
  }

  /// Chọn ảnh local từ máy người dùng (xem trước mượt mà, chưa upload)
  Future<void> pickLocalImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFile != null) {
        selectedImageFiles.add(pickedFile);
        _errorMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Lỗi chọn ảnh: $e';
      notifyListeners();
    }
  }

  /// Thêm / Bớt tính năng nổi bật
  void toggleFeature(int featureId) {
    if (selectedFeatures.contains(featureId)) {
      selectedFeatures.remove(featureId);
    } else {
      selectedFeatures.add(featureId);
    }
    notifyListeners();
  }

  /// Thêm URL hình ảnh xe
  void addImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isNotEmpty && !images.contains(trimmed)) {
      images.add(trimmed);
      notifyListeners();
    }
  }

  /// Xóa ảnh local theo index
  void removeImageAt(int index) {
    if (index >= 0 && index < selectedImageFiles.length) {
      selectedImageFiles.removeAt(index);
      if (thumbnailIndex >= selectedImageFiles.length) {
        thumbnailIndex = selectedImageFiles.isEmpty ? 0 : selectedImageFiles.length - 1;
      }
      notifyListeners();
    }
  }

  /// Chọn chỉ số ảnh đại diện (Thumbnail Index)
  void setThumbnailIndex(int index) {
    final totalCount = selectedImageFiles.isNotEmpty ? selectedImageFiles.length : images.length;
    if (index >= 0 && index < totalCount) {
      thumbnailIndex = index;
      notifyListeners();
    }
  }

  /// Setters cho các Switch
  void setDeliveryEnabled(bool val) {
    deliveryEnabled = val;
    if (!val) {
      deliveryMaxDistance = 0;
      deliveryFee = 0;
      deliveryFreeDistance = 0;
    }
    notifyListeners();
  }

  /// Validate form client-side
  bool validateForm() {
    _fieldErrors.clear();

    if (selectedBrandId == null || selectedBrandId == 0) {
      _fieldErrors['car_brand_id'] = 'Vui lòng chọn Thương hiệu xe';
    }
    if (selectedTypeId == null || selectedTypeId == 0) {
      _fieldErrors['car_type_id'] = 'Vui lòng chọn Loại xe';
    }
    if (licensePlate.trim().isEmpty) {
      _fieldErrors['license_plate'] = 'Vui lòng nhập Biển số xe';
    }
    if (vin.trim().isEmpty) {
      _fieldErrors['vin'] = 'Vui lòng nhập Số khung (VIN)';
    }
    if (engineNumber.trim().isEmpty) {
      _fieldErrors['engine_number'] = 'Vui lòng nhập Số máy';
    }
    if (unitPrice <= 0) {
      _fieldErrors['unit_price'] = 'Đơn giá thuê xe phải lớn hơn 0';
    }
    if (seatCount <= 0) {
      _fieldErrors['seat_count'] = 'Số chỗ ngồi phải lớn hơn 0';
    }
    if (manufactureYear < 1990 || manufactureYear > DateTime.now().year + 1) {
      _fieldErrors['manufacture_year'] = 'Năm sản xuất không hợp lệ';
    }
    if (location.trim().isEmpty) {
      _fieldErrors['location'] = 'Vui lòng nhập Tỉnh/Thành phố vị trí xe';
    }
    if (address.trim().isEmpty) {
      _fieldErrors['address'] = 'Vui lòng nhập Địa chỉ chi tiết xe';
    }
    if (selectedImageFiles.isEmpty && images.isEmpty) {
      _fieldErrors['images'] = 'Vui lòng chọn ít nhất 1 hình ảnh xe';
    }
    final totalCount = selectedImageFiles.isNotEmpty ? selectedImageFiles.length : images.length;
    if (thumbnailIndex < 0 || (totalCount > 0 && thumbnailIndex >= totalCount)) {
      _fieldErrors['images'] = 'Chỉ số ảnh đại diện không hợp lệ';
    }

    return _fieldErrors.isEmpty;
  }

  /// Thực hiện đăng ký xe qua API (Upload ảnh lên Cloudinary tại đây)
  Future<CreateCarResponse> submitCarRegistration() async {
    final isValid = validateForm();
    if (!isValid) {
      _errorMessage = _fieldErrors.values.first;
      notifyListeners();
      return CreateCarResponse(success: false, message: _errorMessage);
    }

    _isSubmitting = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final List<String> finalUploadedUrls = List.from(images);

      // Tải tất cả các ảnh chọn từ máy người dùng lên Cloudinary
      if (selectedImageFiles.isNotEmpty) {
        _isUploadingImage = true;
        notifyListeners();

        for (int i = 0; i < selectedImageFiles.length; i++) {
          final url = await _cloudinaryService.uploadImage(selectedImageFiles[i]);
          if (url != null && url.isNotEmpty) {
            finalUploadedUrls.add(url);
          } else {
            _isSubmitting = false;
            _isUploadingImage = false;
            _errorMessage = 'Tải ảnh thứ ${i + 1} lên Cloudinary thất bại. Vui lòng thử lại!';
            _fieldErrors['images'] = _errorMessage;
            notifyListeners();
            return CreateCarResponse(success: false, message: _errorMessage);
          }
        }
        _isUploadingImage = false;
      }

      final req = CreateCarRequest(
        carBrandId: selectedBrandId!,
        carTypeId: selectedTypeId!,
        licensePlate: licensePlate.trim(),
        vin: vin.trim(),
        engineNumber: engineNumber.trim(),
        fuelConsumption: fuelConsumption,
        unitPrice: unitPrice,
        discountValue: discountValue,
        description: description.trim(),
        rentalTerms: rentalTerms.trim(),
        seatCount: seatCount,
        manufactureYear: manufactureYear,
        fuelType: fuelType,
        transmission: transmission,
        location: location.trim(),
        address: address.trim(),
        deliveryEnabled: deliveryEnabled,
        deliveryMaxDistance: deliveryEnabled ? deliveryMaxDistance : 0,
        deliveryFee: deliveryEnabled ? deliveryFee : 0,
        deliveryFreeDistance: deliveryEnabled ? deliveryFreeDistance : 0,
        features: selectedFeatures,
        images: finalUploadedUrls,
        thumbnailIndex: thumbnailIndex,
      );

      final res = isEditMode
          ? await _carService.updateCar(editingCarId!, req)
          : await _carService.createCar(req);
      if (res.success) {
        _successMessage = res.message;
      } else {
        _errorMessage = res.message;
        if (res.errors != null) {
          res.errors!.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              _fieldErrors[key] = value.first.toString();
            } else if (value != null) {
              _fieldErrors[key] = value.toString();
            }
          });
        }
      }
      return res;
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra khi đăng ký xe: $e';
      return CreateCarResponse(success: false, message: _errorMessage);
    } finally {
      _isSubmitting = false;
      _isUploadingImage = false;
      notifyListeners();
    }
  }
}
