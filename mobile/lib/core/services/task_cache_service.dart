import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class TaskCacheService {
  static const String boxName = 'tasks_box';
  static const String cacheKey = 'cached_tasks_data';
  static const String offlineQueueKey = 'offline_task_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  // --- Read/Write full payload for display ---
  static Future<void> cacheTasksPayload(Map<String, dynamic> data) async {
    await _box.put(cacheKey, jsonEncode(data));
  }

  static Map<String, dynamic>? getCachedTasksPayload() {
    final str = _box.get(cacheKey);
    if (str != null) {
      try {
        return jsonDecode(str) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // --- Offline Queue for Toggling Task ---
  // When internet is off, we queue the IDs to toggle later.
  static Future<void> queueTaskToggle(int taskId) async {
    final queue = getOfflineToggleQueue();
    if (!queue.contains(taskId)) {
      queue.add(taskId);
      await _box.put(offlineQueueKey, queue);
    }
  }

  static Future<void> removeTaskFromQueue(int taskId) async {
    final queue = getOfflineToggleQueue();
    if (queue.contains(taskId)) {
      queue.remove(taskId);
      await _box.put(offlineQueueKey, queue);
    }
  }

  static List<int> getOfflineToggleQueue() {
    final queueData = _box.get(offlineQueueKey);
    if (queueData is List) {
      return queueData.cast<int>();
    }
    return [];
  }

  static Future<void> clearOfflineQueue() async {
    await _box.delete(offlineQueueKey);
  }
}
