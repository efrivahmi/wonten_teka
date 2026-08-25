import '../api/api_client.dart';

class DeviceAdminRepository {
  final ApiClient _api;

  DeviceAdminRepository({required ApiClient api}) : _api = api;

  Future<List<Map<String, dynamic>>> getPendingDevices() async {
    final response = await _api.get('/admin/devices/pending');
    final data = response.data['data'] as List; // assuming paginated or wrapped in data
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> reviewDevice(int deviceId, String action) async {
    // action is 'approve' or 'reject'
    await _api.post('/admin/devices/$deviceId/review', data: {
      'action': action,
    });
  }
}
