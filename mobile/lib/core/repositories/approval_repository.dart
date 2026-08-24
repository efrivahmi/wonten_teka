import '../api/api_client.dart';
import '../models/approval_instance_model.dart';
import '../models/paginated_response.dart';

class ApprovalRepository {
  final ApiClient _api;

  ApprovalRepository({required ApiClient api}) : _api = api;

  Future<PaginatedResponse<ApprovalInstanceModel>> getPending({int page = 1}) async {
    final response = await _api.get('/approvals/pending', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      ApprovalInstanceModel.fromJson,
    );
  }

  Future<ApprovalInstanceModel> submitAction({
    required int instanceId,
    required String decision, // 'approve' or 'reject'
    String? comment,
  }) async {
    final response = await _api.post('/approvals/$instanceId/action', data: {
      'decision': decision,
      'comment': comment,
    });
    final data = response.data as Map<String, dynamic>;
    return ApprovalInstanceModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
