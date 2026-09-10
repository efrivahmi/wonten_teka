import '../api/api_client.dart';
import '../models/task_device_models.dart';
import '../api/api_exceptions.dart';

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
    return _deviceFrom(response.data);
  }

  Future<DeviceModel> getStatus(String deviceFingerprint) async {
    final response = await _api.get('/device/status', queryParameters: {
      'device_fingerprint': deviceFingerprint,
    });
    return _deviceFrom(response.data);
  }

  DeviceModel _deviceFrom(dynamic body) {
    if (body is! Map || body['device'] is! Map) {
      throw const ApiException(
          message: 'Data perangkat dari server tidak valid.');
    }
    return DeviceModel.fromJson(
      Map<String, dynamic>.from(body['device'] as Map),
    );
  }
}
