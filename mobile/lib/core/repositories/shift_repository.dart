import '../api/api_client.dart';
import '../models/shift_models.dart';
import '../models/paginated_response.dart';

class ShiftRepository {
  final ApiClient _api;

  ShiftRepository({required ApiClient api}) : _api = api;

  Future<PaginatedResponse<ShiftAssignmentModel>> getUpcoming({int page = 1}) async {
    final response = await _api.get('/shifts/upcoming', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      ShiftAssignmentModel.fromJson,
    );
  }

  // Admin: Templates
  Future<List<ShiftTemplateModel>> getAdminTemplates() async {
    final response = await _api.get('/admin/shifts');
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List).map((e) => ShiftTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ShiftTemplateModel> createTemplate(Map<String, dynamic> data) async {
    final response = await _api.post('/admin/shifts', data: data);
    final resData = response.data as Map<String, dynamic>;
    return ShiftTemplateModel.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<ShiftTemplateModel> updateTemplate(int id, Map<String, dynamic> data) async {
    final response = await _api.put('/admin/shifts/$id', data: data);
    final resData = response.data as Map<String, dynamic>;
    return ShiftTemplateModel.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTemplate(int id) async {
    await _api.delete('/admin/shifts/$id');
  }

  // Admin: Assignments
  Future<PaginatedResponse<ShiftAssignmentModel>> getAdminAssignments({int page = 1}) async {
    final response = await _api.get('/admin/shift-assignments', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      ShiftAssignmentModel.fromJson,
    );
  }

  Future<void> assignShift(Map<String, dynamic> data) async {
    await _api.post('/admin/shift-assignments', data: data);
  }
}
