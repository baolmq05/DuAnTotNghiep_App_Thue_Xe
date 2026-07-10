import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:duantotnghiep_app_thue_xe/models/user_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class DriverLicenseService extends BaseService {
  Future<UserModel?> fetchProfile() async {
    final response = await get('api/auth/profile', requiresAuth: true);
    return UserModel.fromJson(response);
  }

  Future<UserModel?> submitDrivingLicense({
    required String number,
    required String fullName,
    required String dob,
    File? image,
    XFile? xfile,
  }) async {
    final response = await uploadMultipart(
      'api/auth/profile/driving-license',
      requiresAuth: true,
      file: image,
      xfile: xfile,
      fields: {
        'driving_license_number': number,
        'full_name': fullName,
        'DOB': dob,
      },
    );

    if (response['success']) {
      return UserModel.fromJson(response['user']);
    }

    return null;
  }
}
