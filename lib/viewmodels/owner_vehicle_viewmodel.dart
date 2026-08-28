import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/car_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/car_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/trip_service.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

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
  /// status 0: Dừng hoạt động
  Future<String?> toggleCarStatus(Car car, {String? reason}) async {
    final int currentStatus = car.status;
    if (currentStatus != 1 && currentStatus != 0) {
      // Chỉ cho phép chuyển đổi trạng thái giữa Hoạt động (1) và Dừng hoạt động (0)
      return 'Trạng thái xe không hợp lệ để thay đổi';
    }

    final int newStatus = currentStatus == 1 ? 0 : 1;

    try {
      final success = await _carService.updateCarStatus(car.id, newStatus, reason: reason);
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
          return null; // Thành công
        }
      }
      return 'Không thể cập nhật trạng thái xe';
    } catch (e) {
      debugPrint('Lỗi khi toggle trạng thái xe: $e');
      if (e is ApiException) {
        return e.message;
      }
      return 'Lỗi: $e';
    }
  }

  /// Kiểm tra xem xe có đang trong quá trình đặt hay không (có chuyến đi chưa hoàn thành)
  Future<bool> hasActiveBookings(int carId) async {
    try {
      final TripService tripService = TripService();
      final trips = await tripService.getOwnerTrips();
      // Lọc các chuyến đi của xe này có trạng thái hoạt động (chưa hoàn tất và chưa hủy)
      final activeTrips = trips.where((trip) =>
          trip.carId == carId &&
          trip.status != 4 && // Hoàn tất
          trip.status != 5 && // Người thuê hủy
          trip.status != 6 // Chủ xe hủy
          );
      return activeTrips.isNotEmpty;
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra chuyến đi đang hoạt động của xe $carId: $e');
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
