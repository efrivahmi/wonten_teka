import '../api/api_client.dart';
import '../models/payslip_model.dart';
import '../models/paginated_response.dart';

class PayslipRepository {
  final ApiClient _api;

  PayslipRepository({required ApiClient api}) : _api = api;

  Future<PaginatedResponse<PayslipModel>> getHistory({int page = 1}) async {
    final response = await _api.get('/payslips', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      PayslipModel.fromJson,
    );
  }

  Future<PayslipModel> getDetail(int payslipId) async {
    final response = await _api.get('/payslips/$payslipId');
    return PayslipModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> downloadPdf(int payslipId, String savePath) async {
    await _api.download('/payslips/$payslipId/download', savePath);
  }
}
