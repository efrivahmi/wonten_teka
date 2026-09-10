import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/attendance_log_model.dart';
import '../models/paginated_response.dart';

class AttendanceRepository {
  final ApiClient _api;

  AttendanceRepository({required ApiClient api}) : _api = api;

  Future<void> enrollFace({
    required List<File> faceImages,
    required List<List<double>> faceEmbeddings,
    required String deviceId,
  }) async {
    final formData = FormData.fromMap({
      'device_id': deviceId,
    });
    for (int i = 0; i < faceEmbeddings.length; i++) {
      formData.fields.add(MapEntry('embeddings[$i]', jsonEncode(faceEmbeddings[i])));
    }
    for (int i = 0; i < faceImages.length; i++) {
      formData.files.add(MapEntry(
        'face_images[]',
        await MultipartFile.fromFile(faceImages[i].path, filename: 'face_$i.jpg'),
      ));
    }
    await _api.post('/biometrics/enroll', data: formData);
  }

  Future<List<List<double>>?> syncFace() async {
    final response = await _api.get('/biometrics/sync');
    final data = response.data as Map<String, dynamic>;
    if (data['embeddings'] is List) {
      final List<dynamic> raw = data['embeddings'];
      return raw.whereType<List>().map((e) => e.map((n) => (n as num).toDouble()).toList()).toList();
    }
    return null;
  }

  Future<AttendanceLogModel> checkIn({
    required double latitude,
    required double longitude,
    required double faceMatchScore,
    required String deviceId,
    File? photo,
    Map<String, dynamic>? flags,
    int? shiftAssignmentId,
    int? shiftTemplateId,
  }) async {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'face_match_score': faceMatchScore,
      'device_id': deviceId,
      'client_time': DateTime.now().toUtc().toIso8601String(),
      if (shiftAssignmentId != null) 'shift_assignment_id': shiftAssignmentId,
      if (shiftTemplateId != null) 'shift_template_id': shiftTemplateId,
    };
    
    if (flags != null) {
      data['flags'] = flags;
      data['address'] = flags['address'];
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
    required double faceMatchScore,
    required String deviceId,
    File? photo,
    Map<String, dynamic>? flags,
    int? shiftAssignmentId,
  }) async {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'face_match_score': faceMatchScore,
      'device_id': deviceId,
      'client_time': DateTime.now().toUtc().toIso8601String(),
      if (shiftAssignmentId != null) 'shift_assignment_id': shiftAssignmentId,
    };
    
    if (flags != null) {
      data['flags'] = flags;
      data['address'] = flags['address'];
    }

    dynamic requestData;

    if (photo != null) {
      final formData = FormData.fromMap(data);
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(photo.path, filename: 'checkout.jpg'),
      ));
      requestData = formData;
    } else {
      requestData = data;
    }

    final response = await _api.post('/attendance/check-out', data: requestData);
    final responseData = response.data as Map<String, dynamic>;
    return AttendanceLogModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<PaginatedResponse<AttendanceLogModel>> getHistory({int page = 1}) async {
    final response = await _api.get('/attendance/history', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      AttendanceLogModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> getTodayInfo() async {
    final response = await _api.get('/attendance/today-info');
    return response.data as Map<String, dynamic>;
  }
}
