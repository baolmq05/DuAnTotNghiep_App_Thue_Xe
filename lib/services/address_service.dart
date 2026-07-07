import 'package:duantotnghiep_app_thue_xe/models/address_model.dart';
import 'package:duantotnghiep_app_thue_xe/services/base_service.dart';

class AddressService extends BaseService {
  /// Lấy danh sách địa chỉ của người dùng đang đăng nhập
  Future<List<AddressModel>> fetchAddresses() async {
    final response = await get('api/auth/addresses', requiresAuth: true);
    if (response != null && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => AddressModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Thêm địa chỉ mới
  Future<AddressModel> createAddress({
    required String addressName,
    required int userId,
  }) async {
    final response = await store(
      'api/auth/addresses',
      body: {
        'address_name': addressName,
        'user_id': userId,
      },
      requiresAuth: true,
    );
    if (response != null && response['success'] == true) {
      return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Thêm địa chỉ thất bại.');
  }

  /// Cập nhật địa chỉ
  Future<AddressModel> updateAddress({
    required int addressId,
    required String addressName,
  }) async {
    final response = await update(
      'api/auth/addresses/$addressId',
      body: {
        'address_name': addressName,
      },
      requiresAuth: true,
    );
    if (response != null && response['success'] == true) {
      return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Cập nhật địa chỉ thất bại.');
  }

  /// Xoá địa chỉ
  Future<bool> deleteAddress(int addressId) async {
    final response = await delete(
      'api/auth/addresses/$addressId',
      requiresAuth: true,
    );
    if (response != null && response['success'] == true) {
      return true;
    }
    return false;
  }
}
