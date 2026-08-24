import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/attendance_log_model.dart';
import '../models/paginated_response.dart';

class AttendanceRepository {
  final ApiClient _api;

  AttendanceRepository({required ApiClient api}) : _api = api;

  Future<void> enrollFace({
    required List<double> faceEmbedding,
    required String deviceId,
  }) async {
    await _api.post('/attendance/enroll-face', data: {
      'face_embedding': faceEmbedding,
      'device_id': deviceId,
    });
  }

  Future<AttendanceLogModel> checkIn({
    required double latitude,
    required double longitude,
    required double faceMatchScore,
    required String deviceId,
    File? photo,
    Map<String, dynamic>? flags,
  }) async {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'face_match_score': faceMatchScore,
      'device_id': deviceId,
    };
    
    if (flags != null) {
      data['flags'] = flags;
    }

    dynamic requestData;

    if (photo != null) {
      final formData = FormData.fromMap(data);
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(photo.path, filename: 'checkin.jpg'),
      ));
      requestData = formData;
    } else {
      requestData = data;
    }

    final response = await _api.post('/attendance/check-in', data: requestData);
    final responseData = response.data as Map<String, dynamic>;
    return AttendanceLogModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<AttendanceLogModel> checkOut({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.post('/attendance/check-out', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    final data = response.data as Map<String, dynamic>;
    return AttendanceLogModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<PaginatedResponse<AttendanceLogModel>> getHistory({int page = 1}) async {
    final response = await _api.get('/attendance/history', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      AttendanceLogModel.fromJson,
    );
  }
}
