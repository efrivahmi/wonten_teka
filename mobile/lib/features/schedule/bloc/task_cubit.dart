import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/task_device_models.dart';
import '../../../core/repositories/task_repository.dart';
import '../../../core/services/task_cache_service.dart';
import '../../tasks/notification_service.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<PersonalTaskModel> tasks;
  final String dateStr;
  final Map<String, dynamic>? trackingData;

  const TaskLoaded(this.tasks, this.dateStr, {this.trackingData});

  @override
  List<Object?> get props => [tasks, dateStr, trackingData];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskActionSuccess extends TaskState {
  final String message;
  const TaskActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repo;

  TaskCubit({required TaskRepository repository})
      : _repo = repository,
        super(TaskInitial());

  Future<void> loadTasksByDate(String dateStr) async {
    emit(TaskLoading());
    
    // First yield cached data for instant UI
    final cachedData = TaskCacheService.getCachedTasksPayload();
    if (cachedData != null) {
       try {
         final cachedTasks = (cachedData['tasks'] as List)
             .map((e) => PersonalTaskModel.fromJson(e))
             .toList();
         emit(TaskLoaded(cachedTasks, dateStr, trackingData: cachedData['tracking']));
       } catch (_) {}
    }

    try {
      final tasks = await _repo.getTasksByDate(dateStr);
      Map<String, dynamic>? trackingData;
      try {
        trackingData = await _repo.getTrackingHistory();
      } catch (_) {}
      
      // Save to cache
      final payloadToCache = {
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'tracking': trackingData,
      };
      await TaskCacheService.cacheTasksPayload(payloadToCache);

      // Process offline queue
      final queue = TaskCacheService.getOfflineToggleQueue();
      for (final queuedId in queue) {
         try {
           final t = tasks.firstWhere((element) => element.id == queuedId);
           await _repo.toggleTaskCompletion(queuedId, !t.isActive);
           await TaskCacheService.removeTaskFromQueue(queuedId);
         } catch (_) {}
      }

      // Re-fetch if queue was processed
      final freshTasks = queue.isNotEmpty ? await _repo.getTasksByDate(dateStr) : tasks;
      
      // Schedule local notifications for active tasks
      for (final t in freshTasks) {
        if (t.isActive && t.reminderEnabled && t.reminderTime != null) {
          final timeParts = t.reminderTime!.split(':');
          final dateParts = dateStr.split('-');
          final scheduledDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (scheduledDate.isAfter(DateTime.now())) {
            await NotificationService().scheduleAlarm(
              id: t.id,
              title: t.isHabit ? 'Pengingat Habit: ${t.title}' : 'Pengingat Tugas: ${t.title}',
              body: t.description ?? 'Waktunya menyelesaikan tugas Anda!',
              scheduledDate: scheduledDate,
              repeatDaily: t.recurrenceRule == 'daily',
            );
          }
        }
      }

      emit(TaskLoaded(freshTasks, dateStr, trackingData: trackingData));
    } catch (e) {
      if (cachedData == null) {
        String message = 'Gagal memuat tugas. Anda sedang offline.';
        if (e is ApiException) {
          message = e.message;
        }
        emit(TaskError(message));
      }
    }
  }

  Future<void> toggleTask(int id, bool currentStatus, String dateStr) async {
    try {
      await _repo.toggleTaskCompletion(id, currentStatus);
      await loadTasksByDate(dateStr); // Reload tasks
    } catch (e) {
      // Offline fallback
      await TaskCacheService.queueTaskToggle(id);
      
      // Update UI optimistically
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final updatedTasks = current.tasks.map((t) {
          if (t.id == id) {
            return t.copyWith(isActive: !t.isActive);
          }
          return t;
        }).toList();
        emit(TaskLoaded(updatedTasks, current.dateStr, trackingData: current.trackingData));
      }
    }
  }

  Future<void> deleteTask(int id, String dateStr) async {
    try {
      await _repo.delete(id);
      NotificationService().cancelAlarm(id);
      await loadTasksByDate(dateStr);
    } catch (e) {
      // Ignore errors for now
    }
  }

  Future<void> addTask(String title, String? description, String taskDate,
      String? reminderTime) async {
    try {
      final task = await _repo.create(
        title: title,
        description: description,
        taskDate: taskDate,
        reminderTime: reminderTime,
      );

      if (reminderTime != null) {
        final timeParts = reminderTime.split(':');
        final dateParts = taskDate.split('-');
        final scheduledDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        await NotificationService().scheduleAlarm(
          id: task.id,
          title: 'Pengingat Tugas: $title',
          body: description ?? 'Waktunya mengerjakan tugas Anda!',
          scheduledDate: scheduledDate,
        );
      }
      emit(const TaskActionSuccess('Daily task berhasil ditambahkan'));
      await loadTasksByDate(taskDate);
    } catch (e) {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        emit(TaskError(e is ApiException ? e.message : 'Gagal menambah tugas'));
        emit(TaskLoaded(current.tasks, current.dateStr));
      } else {
        emit(TaskError(e is ApiException ? e.message : 'Gagal menambah tugas'));
      }
    }
  }

  // Compatibility methods for schedule_habit feature
  Future<void> loadTasks({bool habitsOnly = true}) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    emit(TaskLoading());
    try {
      final tasks = await _repo.getTasksByDate(todayStr, habitsOnly: habitsOnly);
      Map<String, dynamic>? trackingData;
      try {
        trackingData = await _repo.getTrackingHistory();
      } catch (_) {}
      emit(TaskLoaded(tasks, todayStr, trackingData: trackingData));
    } catch (e) {
      emit(TaskError(e is ApiException
          ? e.message
          : habitsOnly
              ? 'Gagal memuat habit.'
              : 'Gagal memuat daily task.'));
    }
  }

  Future<void> createTask(
      {required String title,
      String? description,
      required String recurrenceRule,
      required String reminderTime}) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final timeStr =
        reminderTime.length > 5 ? reminderTime.substring(0, 5) : reminderTime;
    try {
      final task = await _repo.create(
        title: title,
        description: description,
        taskDate: todayStr,
        reminderTime: timeStr,
        isHabit: true,
        recurrenceRule: recurrenceRule,
        reminderEnabled: true,
      );
      final parts = timeStr.split(':');
      var scheduled = DateTime.now().copyWith(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
      if (!scheduled.isAfter(DateTime.now())) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await NotificationService().scheduleAlarm(
        id: task.id,
        title: 'Pengingat Habit: $title',
        body: 'Waktunya menjaga rutinitas Anda.',
        scheduledDate: scheduled,
        repeatDaily: recurrenceRule == 'daily',
      );
      emit(const TaskActionSuccess('Habit berhasil ditambahkan'));
      await loadTasks();
    } catch (e) {
      emit(TaskError('Gagal menambahkan habit: $e'));
    }
  }

  Future<void> completeTask(int id) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    try {
      await toggleTask(id, false, todayStr);
      emit(const TaskActionSuccess('Habit diselesaikan'));
      await loadTasksByDate(todayStr);
    } catch (e) {
      emit(TaskError('Gagal menyelesaikan habit: $e'));
    }
  }
}
