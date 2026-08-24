import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/claim_models.dart';
import '../models/paginated_response.dart';

class ClaimRepository {
  final ApiClient _api;

  ClaimRepository({required ApiClient api}) : _api = api;

  Future<List<ClaimCategoryModel>> getCategories() async {
    final response = await _api.get('/claims/categories');
    return (response.data as List).map((e) => ClaimCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedResponse<ClaimModel>> getHistory({int page = 1}) async {
    final response = await _api.get('/claims/history', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      ClaimModel.fromJson,
    );
  }

  Future<ClaimModel> submit({
    required int claimCategoryId,
    required double amount,
    required String expenseDate,
    required String description,
    String? receiptPath,
  }) async {
    final formData = FormData.fromMap({
      'claim_category_id': claimCategoryId,
      'amount': amount,
      'expense_date': expenseDate,
      'description': description,
      if (receiptPath != null)
        'receipt': await MultipartFile.fromFile(receiptPath, filename: 'receipt.jpg'),
    });

    final response = await _api.upload('/claims/submit', formData: formData);
    final data = response.data as Map<String, dynamic>;
    return ClaimModel.fromJson(data['data'] as Map<String, dynamic>);
  }
}
