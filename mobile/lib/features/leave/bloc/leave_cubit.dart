import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/leave_models.dart';
import '../../../core/repositories/leave_repository.dart';

// ── States ─────────────────────────────────────────────────────────────────

abstract class LeaveState extends Equatable {
  const LeaveState();
  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}
class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<LeaveTypeModel> types;
  final List<LeaveBalanceModel> balances;
  final List<LeaveRequestModel> history;
  final bool hasNextPage;
  const LeaveLoaded({this.types = const [], this.balances = const [], this.history = const [], this.hasNextPage = false});
  @override
  List<Object?> get props => [types, balances, history];
}

class LeaveSubmitted extends LeaveState {
  final LeaveRequestModel request;
  const LeaveSubmitted(this.request);
  @override
  List<Object?> get props => [request];
}

class LeaveError extends LeaveState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const LeaveError(this.message, {this.fieldErrors});
  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class LeaveCubit extends Cubit<LeaveState> {
  final LeaveRepository _repo;

  LeaveCubit({required LeaveRepository repository})
      : _repo = repository,
        super(LeaveInitial());

  Future<void> loadAll() async {
    emit(LeaveLoading());
    try {
      final results = await Future.wait([
        _repo.getTypes(),
        _repo.getBalances(),
        _repo.getHistory(),
      ]);
      emit(LeaveLoaded(
        types: results[0] as List<LeaveTypeModel>,
        balances: results[1] as List<LeaveBalanceModel>,
        history: (results[2] as dynamic).data as List<LeaveRequestModel>,
        hasNextPage: (results[2] as dynamic).hasNextPage as bool,
      ));
    } on ApiException catch (e) {
      emit(LeaveError(e.message));
    } catch (e) {
      emit(const LeaveError('Gagal memuat data cuti.'));
    }
  }

  Future<void> submitRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    emit(LeaveLoading());
    try {
      final request = await _repo.submitRequest(
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      emit(LeaveSubmitted(request));
    } on ValidationException catch (e) {
      emit(LeaveError(e.allErrors.join('\n'), fieldErrors: e.errors));
    } on ApiException catch (e) {
      emit(LeaveError(e.message));
    } catch (e) {
      emit(const LeaveError('Gagal mengajukan cuti.'));
    }
  }
}
