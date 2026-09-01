import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/shift_models.dart';
import '../../../core/repositories/shift_repository.dart';

abstract class ShiftState extends Equatable {
  const ShiftState();
  @override
  List<Object?> get props => [];
}

class ShiftInitial extends ShiftState {}
class ShiftLoading extends ShiftState {}

class ShiftLoaded extends ShiftState {
  final List<ShiftAssignmentModel> shifts;
  final List<ShiftTemplateModel> adminTemplates;
  final List<ShiftAssignmentModel> adminAssignments;
  final bool hasNextPage;
  
  const ShiftLoaded({
    this.shifts = const [],
    this.adminTemplates = const [],
    this.adminAssignments = const [],
    this.hasNextPage = false,
  });
  
  @override
  List<Object?> get props => [shifts, adminTemplates, adminAssignments];
}

class ShiftError extends ShiftState {
  final String message;
  const ShiftError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShiftCubit extends Cubit<ShiftState> {
  final ShiftRepository _repo;

  ShiftCubit({required ShiftRepository repository})
      : _repo = repository,
        super(ShiftInitial());

  Future<void> loadUpcoming({int page = 1}) async {
    emit(ShiftLoading());
    try {
      final result = await _repo.getUpcoming(page: page);
      if (state is ShiftLoaded) {
        final current = state as ShiftLoaded;
        emit(ShiftLoaded(
          shifts: result.data,
          adminTemplates: current.adminTemplates,
          adminAssignments: current.adminAssignments,
          hasNextPage: result.hasNextPage,
        ));
      } else {
        emit(ShiftLoaded(shifts: result.data, hasNextPage: result.hasNextPage));
      }
    } on ApiException catch (e) {
      emit(ShiftError(e.message));
    } catch (e) {
      emit(const ShiftError('Gagal memuat jadwal shift.'));
    }
  }

  // Admin Methods
  Future<void> loadAdminTemplates() async {
    emit(ShiftLoading());
    try {
      final templates = await _repo.getAdminTemplates();
      emit(ShiftLoaded(adminTemplates: templates));
    } catch (e) {
      emit(const ShiftError('Gagal memuat template shift.'));
    }
  }

  Future<void> createTemplate(Map<String, dynamic> data) async {
    emit(ShiftLoading());
    try {
      await _repo.createTemplate(data);
      await loadAdminTemplates();
    } catch (e) {
      emit(const ShiftError('Gagal membuat template.'));
    }
  }

  Future<void> updateTemplate(int id, Map<String, dynamic> data) async {
    emit(ShiftLoading());
    try {
      await _repo.updateTemplate(id, data);
      await loadAdminTemplates();
    } catch (e) {
      emit(const ShiftError('Gagal memperbarui template.'));
    }
  }

  Future<void> deleteTemplate(int id) async {
    emit(ShiftLoading());
    try {
      await _repo.deleteTemplate(id);
      await loadAdminTemplates();
    } catch (e) {
      emit(const ShiftError('Gagal menghapus template.'));
    }
  }

  Future<void> loadAdminAssignments({int page = 1}) async {
    emit(ShiftLoading());
    try {
      final res = await _repo.getAdminAssignments(page: page);
      emit(ShiftLoaded(adminAssignments: res.data, hasNextPage: res.hasNextPage));
    } catch (e) {
      emit(const ShiftError('Gagal memuat penugasan shift.'));
    }
  }

  Future<void> assignShift(Map<String, dynamic> data) async {
    emit(ShiftLoading());
    try {
      await _repo.assignShift(data);
      await loadAdminAssignments();
    } catch (e) {
      emit(const ShiftError('Gagal menugaskan shift.'));
    }
  }
}
