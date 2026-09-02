import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/task_device_models.dart';
import '../../../core/repositories/task_repository.dart';

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

  const TaskLoaded(this.tasks, this.dateStr);

  @override
  List<Object?> get props => [tasks, dateStr];
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
    try {
      final tasks = await _repo.getTasksByDate(dateStr);
      emit(TaskLoaded(tasks, dateStr));
    } catch (e) {
      String message = 'Gagal memuat tugas.';
      if (e is ApiException) {
        message = e.message;
      }
      emit(TaskError(message));
    }
  }

  Future<void> toggleTask(int id, bool currentStatus, String dateStr) async {
    try {
      await _repo.toggleTaskCompletion(id, !currentStatus);
      await loadTasksByDate(dateStr); // Reload tasks
    } catch (e) {
      // Ignore errors for now
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

  Future<void> addTask(String title, String? description, String taskDate, String? reminderTime) async {
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
  Future<void> loadTasks() async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    await loadTasksByDate(todayStr);
  }

  Future<void> createTask({required String title, required String recurrenceRule, required String reminderTime}) async {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final timeStr = reminderTime.length > 5 ? reminderTime.substring(0, 5) : reminderTime;
    try {
      await addTask(title, recurrenceRule, todayStr, timeStr);
      emit(const TaskActionSuccess('Habit berhasil ditambahkan'));
      await loadTasksByDate(todayStr);
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
