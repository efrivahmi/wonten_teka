import '../api/api_client.dart';
import '../api/api_exceptions.dart';

class DeviceAdminRepository {
  final ApiClient _api;

  DeviceAdminRepository({required ApiClient api}) : _api = api;

  Future<List<Map<String, dynamic>>> getPendingDevices() async {
    final response = await _api.get('/admin/devices/pending');
    final body = response.data;
    if (body is! Map) {
      throw const ApiException(message: 'Format daftar perangkat tidak valid.');
    }
    final data = body['data'];
    if (data is! List) {
      throw const ApiException(
          message: 'Daftar pengajuan perangkat tidak tersedia.');
    }
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Future<void> reviewDevice(int deviceId, String action) async {
    // action is 'approve' or 'reject'
    await _api.post('/admin/devices/$deviceId/review', data: {
      'action': action,
    });
  }

  Future<List<Map<String, dynamic>>> getActiveDevices() async {
    final response = await _api.get('/admin/devices/active');
    final body = response.data;
    if (body is! Map) {
      throw const ApiException(message: 'Format daftar perangkat tidak valid.');
    }
    final data = body['data'];
    if (data is! List) {
      throw const ApiException(
          message: 'Daftar perangkat aktif tidak tersedia.');
    }
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Future<void> revokeDevice(int deviceId) async {
    await _api.post('/admin/devices/$deviceId/revoke');
  }
}
