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

  List<Car> get cars => _cars;
  List<Promotion> get promotions => _promotions;
  bool get isCarsLoading => _isCarsLoading;
  bool get isPromotionsLoading => _isPromotionsLoading;

  /// Fetch tất cả data cho trang Home (xe + khuyến mãi)
  Future<void> fetchHomeData() async {
    await Future.wait([_fetchCars(), _fetchPromotions()]);
  }

  Future<void> _fetchCars() async {
    _isCarsLoading = true;
    notifyListeners();

    try {
      final data = await _carService.getCars(queryParameters: {
        'sort_by': 'featured',
        'limit': '10',
      });
      _cars = data;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isCarsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPromotions() async {
    _isPromotionsLoading = true;
    notifyListeners();

    try {
      final data = await _promotionService.getPromotions();
      _promotions = data;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isPromotionsLoading = false;
      notifyListeners();
    }
  }
}
