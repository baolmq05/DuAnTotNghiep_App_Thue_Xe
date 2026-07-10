import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/driver_license_service.dart';

class DriverLicenseViewModel extends ChangeNotifier {
  final DriverLicenseService _service = DriverLicenseService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy profile và giấy phép lái xe
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _service.fetchProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi GPLX
  Future<void> submitDrivingLicense({
    required String number,
    required String fullName,
    required String dob,
    File? image,
    XFile? xfile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _service.submitDrivingLicense(
        number: number,
        fullName: fullName,
        dob: dob,
        image: image,
        xfile: xfile,
      );

      if (updatedUser != null) {
        _user = updatedUser;
      } else {
        _errorMessage = "Gửi thông tin giấy phép lái xe thất bại.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
