import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/approval_instance_model.dart';
import '../../../core/repositories/approval_repository.dart';

abstract class ApprovalState extends Equatable {
  const ApprovalState();
  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {}
class ApprovalLoading extends ApprovalState {}

class ApprovalLoaded extends ApprovalState {
  final List<ApprovalInstanceModel> pending;
  final bool hasNextPage;
  const ApprovalLoaded(this.pending, {this.hasNextPage = false});
  @override
  List<Object?> get props => [pending];
}

class ApprovalActioned extends ApprovalState {
  final String message;
  const ApprovalActioned(this.message);
  @override
  List<Object?> get props => [message];
}

class ApprovalError extends ApprovalState {
  final String message;
  const ApprovalError(this.message);
  @override
  List<Object?> get props => [message];
}

class ApprovalCubit extends Cubit<ApprovalState> {
  final ApprovalRepository _repo;

  ApprovalCubit({required ApprovalRepository repository})
      : _repo = repository,
        super(ApprovalInitial());

  Future<void> loadPending({int page = 1}) async {
    emit(ApprovalLoading());
    try {
      final result = await _repo.getPending(page: page);
      emit(ApprovalLoaded(result.data, hasNextPage: result.hasNextPage));
    } on ApiException catch (e) {
      emit(ApprovalError(e.message));
    } catch (e) {
      emit(const ApprovalError('Gagal memuat data persetujuan.'));
    }
  }

  Future<void> approve(int instanceId, {String? comment}) async {
    emit(ApprovalLoading());
    try {
      await _repo.submitAction(instanceId: instanceId, decision: 'approve', comment: comment);
      emit(const ApprovalActioned('Permintaan disetujui.'));
    } on ApiException catch (e) {
      emit(ApprovalError(e.message));
    }
  }

  Future<void> reject(int instanceId, {String? comment}) async {
    emit(ApprovalLoading());
    try {
      await _repo.submitAction(instanceId: instanceId, decision: 'reject', comment: comment);
      emit(const ApprovalActioned('Permintaan ditolak.'));
    } on ApiException catch (e) {
      emit(ApprovalError(e.message));
    }
  }
}
