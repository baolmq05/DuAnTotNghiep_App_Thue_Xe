import 'package:flutter/material.dart';
import 'package:duantotnghiep_app_thue_xe/models/address_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/address_service.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải danh sách địa chỉ từ server
  Future<void> loadAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _addressService.fetchAddresses();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm địa chỉ mới
  Future<bool> addAddress(String name, int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAddress = await _addressService.createAddress(
        addressName: name,
        userId: userId,
      );
      _addresses.add(newAddress);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật địa chỉ
  Future<bool> editAddress(int id, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedAddress = await _addressService.updateAddress(
        addressId: id,
        addressName: name,
      );
      final index = _addresses.indexWhere((element) => element.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xoá địa chỉ
  Future<bool> removeAddress(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _addressService.deleteAddress(id);
      if (success) {
        _addresses.removeWhere((element) => element.id == id);
        _errorMessage = null;
        return true;
      }
      _errorMessage = 'Xoá địa chỉ thất bại.';
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
