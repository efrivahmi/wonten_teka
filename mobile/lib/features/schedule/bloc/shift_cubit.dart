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
  final bool hasNextPage;
  const ShiftLoaded(this.shifts, {this.hasNextPage = false});
  @override
  List<Object?> get props => [shifts];
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
      emit(ShiftLoaded(result.data, hasNextPage: result.hasNextPage));
    } on ApiException catch (e) {
      emit(ShiftError(e.message));
    } catch (e) {
      emit(const ShiftError('Gagal memuat jadwal shift.'));
    }
  }
}
