import '../api/api_client.dart';
import '../models/company_models.dart';
import '../models/paginated_response.dart';

class CompanyRepository {
  final ApiClient _api;

  CompanyRepository({required ApiClient api}) : _api = api;

  Future<PaginatedResponse<CalendarEventModel>> getCalendar({int page = 1}) async {
    final response = await _api.get('/calendar', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      CalendarEventModel.fromJson,
    );
  }

  Future<PaginatedResponse<AnnouncementModel>> getAnnouncements({int page = 1}) async {
    final response = await _api.get('/announcements', queryParameters: {'page': page});
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      AnnouncementModel.fromJson,
    );
  }

  Future<void> acknowledgeAnnouncement(int announcementId) async {
    await _api.post('/announcements/$announcementId/acknowledge');
  }
}
