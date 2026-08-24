import '../api/api_client.dart';
import '../models/task_device_models.dart';

class TaskRepository {
  final ApiClient _api;

  TaskRepository({required ApiClient api}) : _api = api;

  Future<List<PersonalTaskModel>> getAll() async {
    final response = await _api.get('/tasks');
    return (response.data as List).map((e) => PersonalTaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PersonalTaskModel> create({
    required String title,
    String? description,
    String? recurrenceRule,
    String? reminderTime,
  }) async {
    final response = await _api.post('/tasks', data: {
      'title': title,
      'description': description,
      'recurrence_rule': recurrenceRule,
      'reminder_time': reminderTime,
    });
    final data = response.data as Map<String, dynamic>;
    return PersonalTaskModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> complete(int taskId) async {
    final response = await _api.post('/tasks/$taskId/complete');
    return response.data as Map<String, dynamic>;
  }
}
