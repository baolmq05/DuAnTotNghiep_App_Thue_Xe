import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/models/promotion_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/promotion_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({CarService? carService, PromotionService? promotionService})
    : _carService = carService ?? CarService(),
      _promotionService = promotionService ?? PromotionService();

  final CarService _carService;
  final PromotionService _promotionService;

  List<Car> _cars = [];
  List<Promotion> _promotions = [];
  bool _isCarsLoading = true;
  bool _isPromotionsLoading = true;

  // Lưu lỗi riêng biệt cho từng phần để UI biết hiển thị gì
  String? _carsError;
  String? _promotionsError;

  List<Car> get cars => _cars;
  List<Promotion> get promotions => _promotions;
  bool get isCarsLoading => _isCarsLoading;
  bool get isPromotionsLoading => _isPromotionsLoading;

  /// Lỗi khi tải danh sách xe (null = không có lỗi)
  String? get carsError => _carsError;

  /// Lỗi khi tải khuyến mãi (null = không có lỗi)
  String? get promotionsError => _promotionsError;

  /// Có lỗi nào không — tiện dùng để hiện banner thông báo chung
  bool get hasError => _carsError != null || _promotionsError != null;

  /// Fetch tất cả data cho trang Home (xe + khuyến mãi) — chạy song song
  Future<void> fetchHomeData() async {
    await Future.wait([_fetchCars(), _fetchPromotions()]);
  }

  Future<void> _fetchCars() async {
    _isCarsLoading = true;
    _carsError = null;
    notifyListeners();

    try {
      final data = await _carService.getCars(queryParameters: {
        'sort_by': 'featured',
        'limit': '10',
      });
      _cars = data;
    } catch (e) {
      _carsError = 'Không thể tải danh sách xe. Vui lòng thử lại!';
      debugPrint('HomeViewModel - lỗi tải xe: $e');
    } finally {
      _isCarsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPromotions() async {
    _isPromotionsLoading = true;
    _promotionsError = null;
    notifyListeners();

    try {
      final data = await _promotionService.getPromotions();
      _promotions = data;
    } catch (e) {
      _promotionsError = 'Không thể tải khuyến mãi.';
      debugPrint('HomeViewModel - lỗi tải khuyến mãi: $e');
    } finally {
      _isPromotionsLoading = false;
      notifyListeners();
    }
  }
}
