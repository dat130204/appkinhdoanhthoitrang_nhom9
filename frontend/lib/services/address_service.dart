import 'api_service.dart';

class AddressService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final response = await _api.get('/auth/addresses');
      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addAddress({
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
  }) async {
    try {
      final response = await _api.post('/auth/addresses', {
        'name': name,
        'phone': phone,
        'address': address,
        'is_default': isDefault,
      });

      if (response['success']) {
        return response;
      }

      throw ApiException(message: response['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAddress({
    required int id,
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
  }) async {
    try {
      final response = await _api.put('/auth/addresses/$id', {
        'name': name,
        'phone': phone,
        'address': address,
        'is_default': isDefault,
      });

      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      final response = await _api.delete('/auth/addresses/$id');
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
