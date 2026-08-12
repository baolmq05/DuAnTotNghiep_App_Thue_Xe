import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';

class OwnerVehicleViewModel extends ChangeNotifier {
  final CarService _carService = CarService();

  List<Car> _cars = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lọc xe theo trạng thái hoạt động
  List<Car> get activeCars => _cars.where((car) => car.status == 1).toList();
  List<Car> get pendingCars => _cars.where((car) => car.status == 2).toList();
  List<Car> get lockedCars => _cars.where((car) => car.status == 0).toList();
  List<Car> get rejectedCars => _cars.where((car) => car.status == 3).toList();

  /// Lấy danh sách xe của chủ xe theo userId
  Future<void> fetchOwnerCars(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _carService.getCars(queryParameters: {
        'user_id': userId.toString(),
      });
      _cars = data;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách xe: $e';
      debugPrint('Lỗi fetchOwnerCars: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chuyển đổi trạng thái xe (Bật/Tắt chế độ cho thuê)
  /// status 1: Hoạt động / Sẵn sàng
  /// status 3: Tạm khóa / Ngưng hoạt động
  Future<bool> toggleCarStatus(Car car) async {
    final int currentStatus = car.status;
    if (currentStatus != 1 && currentStatus != 3) {
      // Chỉ cho phép chuyển đổi trạng thái giữa Hoạt động (1) và Tạm khóa (3)
      // Ví dụ: trạng thái Đang bận (2) hoặc Chờ duyệt (0) thì không cho phép toggle
      return false;
    }

    final int newStatus = currentStatus == 1 ? 3 : 1;

    try {
      final success = await _carService.updateCarStatus(car.id, newStatus);
      if (success) {
        // Cập nhật trạng thái xe trong danh sách cục bộ
        final index = _cars.indexWhere((c) => c.id == car.id);
        if (index != -1) {
          final updatedCar = Car(
            id: car.id,
            name: car.name,
            licensePlate: car.licensePlate,
            fuelConsumption: car.fuelConsumption,
            unitPrice: car.unitPrice,
            discountValue: car.discountValue,
            description: car.description,
            rentalTerms: car.rentalTerms,
            seatCount: car.seatCount,
            manufactureYear: car.manufactureYear,
            fuelType: car.fuelType,
            transmission: car.transmission,
            status: newStatus,
            userId: car.userId,
            reviewsAvgRating: car.reviewsAvgRating,
            tripsCount: car.tripsCount,
            images: car.images,
            features: car.features,
            carLocation: car.carLocation,
            owner: car.owner,
          );
          _cars[index] = updatedCar;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi khi toggle trạng thái xe: $e');
      return false;
    }
  }

  /// Xóa xe
  Future<bool> deleteCar(int carId) async {
    try {
      final success = await _carService.deleteCar(carId);
      if (success) {
        _cars.removeWhere((c) => c.id == carId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi khi xóa xe: $e');
      return false;
    }
  }
}
