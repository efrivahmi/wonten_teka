import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/task_device_models.dart';
import '../../../core/repositories/task_repository.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<PersonalTaskModel> tasks;
  const TaskLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskActionSuccess extends TaskState {
  final String message;
  const TaskActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repo;

  TaskCubit({required TaskRepository repository})
      : _repo = repository,
        super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await _repo.getAll();
      emit(TaskLoaded(tasks));
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(const TaskError('Gagal memuat task pribadi.'));
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    String? recurrenceRule,
    String? reminderTime,
  }) async {
    emit(TaskLoading());
    try {
      await _repo.create(
        title: title,
        description: description,
        recurrenceRule: recurrenceRule,
        reminderTime: reminderTime,
      );
      emit(const TaskActionSuccess('Task berhasil dibuat.'));
      loadTasks(); // Reload the list
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(const TaskError('Gagal membuat task.'));
    }
  }

  Future<void> completeTask(int taskId) async {
    emit(TaskLoading());
    try {
      final result = await _repo.complete(taskId);
      emit(TaskActionSuccess(result['message'] as String? ?? 'Task selesai!'));
      loadTasks(); // Reload to get updated streaks
    } on ApiException catch (e) {
      emit(TaskError(e.message));
    } catch (e) {
      emit(const TaskError('Gagal menyelesaikan task.'));
    }
  }
}
