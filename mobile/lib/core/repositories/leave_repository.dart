import '../api/api_client.dart';
import '../models/leave_models.dart';
import '../models/paginated_response.dart';

class LeaveRepository {
  final ApiClient _api;

  LeaveRepository({required ApiClient api}) : _api = api;

  Future<List<LeaveTypeModel>> getTypes() async {
    final response = await _api.get('/leave/types');
    return (response.data as List).map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LeaveBalanceModel>> getBalances() async {
    final response = await _api.get('/leave/balances');
    return (response.data as List).map((e) => LeaveBalanceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedResponse<LeaveRequestModel>> getHistory({int page = 1}) async {
    final response = await _api.get('/leave/history', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      LeaveRequestModel.fromJson,
    );
  }

  Future<LeaveRequestModel> submitRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    final response = await _api.post('/leave/request', data: {
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'attachment_url': attachmentUrl,
    });
    final data = response.data as Map<String, dynamic>;
    return LeaveRequestModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  // Admin Methods
  Future<List<LeaveTypeModel>> getAdminLeaveTypes() async {
    final response = await _api.get('/admin/leave-types');
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List).map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LeaveTypeModel> createLeaveType(Map<String, dynamic> data) async {
    final response = await _api.post('/admin/leave-types', data: data);
    final resData = response.data as Map<String, dynamic>;
    return LeaveTypeModel.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<LeaveTypeModel> updateLeaveType(int id, Map<String, dynamic> data) async {
    final response = await _api.put('/admin/leave-types/$id', data: data);
    final resData = response.data as Map<String, dynamic>;
    return LeaveTypeModel.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<void> deleteLeaveType(int id) async {
    await _api.delete('/admin/leave-types/$id');
  }
}
