import '../api/api_client.dart';
import '../models/company_models.dart';
import '../models/paginated_response.dart';

class CompanyRepository {
  final ApiClient _api;

  CompanyRepository({required ApiClient api}) : _api = api;

  Future<Map<String, dynamic>> getCalendar({int? month, int? year}) async {
    final query = <String, dynamic>{};
    if (month != null) query['month'] = month;
    if (year != null) query['year'] = year;
    
    final response = await _api.get('/calendar', queryParameters: query);
    return response.data as Map<String, dynamic>;
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

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    await _api.post('/admin/announcements', data: data);
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    await _api.post('/admin/events', data: data);
  }

  Future<void> updateEvent(int id, Map<String, dynamic> data) async {
    await _api.put('/admin/events/$id', data: data);
  }

  Future<void> deleteEvent(int id) async {
    await _api.delete('/admin/events/$id');
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

  Future<List<int>> getWorkingDays() async {
    final response = await _api.get('/company/working-days');
    final data = response.data['working_days'] as List;
    return data.map((e) => e as int).toList();
  }

  Future<void> updateWorkingDays(List<int> workingDays) async {
    await _api.put('/company/working-days', data: {
      'working_days': workingDays,
    });
  }
}
