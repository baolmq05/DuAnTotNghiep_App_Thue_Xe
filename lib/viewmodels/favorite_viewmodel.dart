import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/favorite_service.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<Car> _favoriteCars = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Car> get favoriteCars => _favoriteCars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Kiểm tra xem xe có nằm trong danh sách yêu thích không
  bool isFavorite(int carId) {
    return _favoriteCars.any((car) => car.id == carId);
  }

  /// Lấy danh sách xe yêu thích từ server
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favoriteCars = await _favoriteService.getFavorites();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetchFavorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm hoặc xóa xe khỏi danh sách yêu thích
  Future<void> toggleFavorite({required int carId, Car? car}) async {
    final currentlyFavorite = isFavorite(carId);

    try {
      if (currentlyFavorite) {
        // Optimistic UI update: Remove locally immediately
        _favoriteCars.removeWhere((c) => c.id == carId);
        notifyListeners();

        // Call API
        final success = await _favoriteService.removeFavorite(carId);
        if (!success) {
          // Rollback if failed
          if (car != null) {
            _favoriteCars.add(car);
            notifyListeners();
          } else {
            await fetchFavorites();
          }
        }
      } else {
        // Call API
        final success = await _favoriteService.addFavorite(carId);
        if (success) {
          if (car != null) {
            // Optimistic UI update: Add locally immediately
            if (!_favoriteCars.any((c) => c.id == carId)) {
              _favoriteCars.add(car);
              notifyListeners();
            }
          } else {
            // If no Car object passed (e.g. from detail screen), fetch from server
            await fetchFavorites();
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggleFavorite: $e');
      // On error, refresh from server to ensure state is correct
      await fetchFavorites();
    }
  }
}
