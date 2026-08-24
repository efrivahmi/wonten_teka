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
}
