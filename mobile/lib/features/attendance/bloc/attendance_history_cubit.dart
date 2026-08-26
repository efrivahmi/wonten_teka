import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/attendance_log_model.dart';
import '../../../core/repositories/attendance_repository.dart';

// ── States ─────────────────────────────────────────────────────────────────

abstract class AttendanceHistoryState extends Equatable {
  const AttendanceHistoryState();
  @override
  List<Object?> get props => [];
}

class AttendanceHistoryInitial extends AttendanceHistoryState {}

class AttendanceHistoryLoading extends AttendanceHistoryState {
  final bool isFirstFetch;
  const AttendanceHistoryLoading({this.isFirstFetch = false});
  @override
  List<Object?> get props => [isFirstFetch];
}

class AttendanceHistoryLoaded extends AttendanceHistoryState {
  final List<AttendanceLogModel> logs;
  final int currentPage;
  final bool hasNextPage;

  const AttendanceHistoryLoaded(this.logs,
      {this.currentPage = 1, this.hasNextPage = false});

  @override
  List<Object?> get props => [logs, currentPage, hasNextPage];
}

class AttendanceHistoryError extends AttendanceHistoryState {
  final String message;
  const AttendanceHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class AttendanceHistoryCubit extends Cubit<AttendanceHistoryState> {
  final AttendanceRepository _repo;

  AttendanceHistoryCubit({required AttendanceRepository repository})
      : _repo = repository,
        super(AttendanceHistoryInitial());

  Future<void> loadHistory({bool isRefresh = false}) async {
    int page = 1;
    List<AttendanceLogModel> currentLogs = [];

    if (state is AttendanceHistoryLoaded && !isRefresh) {
      final loadedState = state as AttendanceHistoryLoaded;
      if (!loadedState.hasNextPage) return; // No more data
      page = loadedState.currentPage + 1;
      currentLogs = loadedState.logs;
    }

    if (page == 1) {
      emit(const AttendanceHistoryLoading(isFirstFetch: true));
    } else {
      // Background loading for pagination, not full screen loading
      emit(const AttendanceHistoryLoading(isFirstFetch: false)); 
    }

    try {
      final result = await _repo.getHistory(page: page);
      
      final newLogs = result.data;
      final mergedLogs = isRefresh ? newLogs : [...currentLogs, ...newLogs];

      emit(AttendanceHistoryLoaded(
        mergedLogs,
        currentPage: result.currentPage,
        hasNextPage: result.hasNextPage,
      ));
    } on ApiException catch (e) {
      emit(AttendanceHistoryError(e.message));
    } catch (e) {
      emit(const AttendanceHistoryError('Gagal memuat riwayat kehadiran.'));
    }
  }
}
