import '../api/api_client.dart';
import '../models/task_device_models.dart';

class TaskRepository {
  final ApiClient _api;

  TaskRepository({required ApiClient api}) : _api = api;

  Future<List<PersonalTaskModel>> getTasksByDate(String dateStr) async {
    final response = await _api.get('/tasks', queryParameters: {'date': dateStr});
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> list = data['data'];
    return list.map((e) => PersonalTaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PersonalTaskModel> create({
    required String title,
    String? description,
    required String taskDate,
    String? reminderTime,
  }) async {
    final response = await _api.post('/tasks', data: {
      'title': title,
      'description': description,
      'task_date': taskDate,
      'reminder_time': reminderTime,
    });
    final data = response.data as Map<String, dynamic>;
    return PersonalTaskModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<PersonalTaskModel> toggleTaskCompletion(int id, bool isActive) async {
    final response = await _api.put('/tasks/$id', data: {
      'is_active': isActive,
    });
    final data = response.data as Map<String, dynamic>;
    return PersonalTaskModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/tasks/$id');
  }
}
