import '../api/api_client.dart';
import '../models/task_device_models.dart';

class DeviceRepository {
  final ApiClient _api;

  DeviceRepository({required ApiClient api}) : _api = api;

  Future<DeviceModel> register({
    required String deviceFingerprint,
    required String deviceName,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
  }) async {
    final response = await _api.post('/device/register', data: {
      'device_fingerprint': deviceFingerprint,
      'device_name': deviceName,
      'device_model': deviceModel,
      'os_version': osVersion,
      'app_version': appVersion,
    });
    final data = response.data as Map<String, dynamic>;
    return DeviceModel.fromJson(data['device'] as Map<String, dynamic>);
  }

  Future<DeviceModel> getStatus(String deviceFingerprint) async {
    final response = await _api.get('/device/status', queryParameters: {
      'device_fingerprint': deviceFingerprint,
    });
    final data = response.data as Map<String, dynamic>;
    return DeviceModel.fromJson(data['device'] as Map<String, dynamic>);
  }
}
