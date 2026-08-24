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

  Future<Map<String, dynamic>> getGeofence() async {
    final response = await _api.get('/company/geofence');
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateGeofence({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    await _api.put('/company/geofence', data: {
      'latitude': latitude,
      'longitude': longitude,
      'geofence_radius_meters': radius,
    });
  }
}
