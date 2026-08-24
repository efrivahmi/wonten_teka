import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/payslip_model.dart';
import '../../../core/repositories/payslip_repository.dart';

abstract class PayslipState extends Equatable {
  const PayslipState();
  @override
  List<Object?> get props => [];
}

class PayslipInitial extends PayslipState {}
class PayslipLoading extends PayslipState {}

class PayslipLoaded extends PayslipState {
  final List<PayslipModel> payslips;
  final bool hasNextPage;
  const PayslipLoaded(this.payslips, {this.hasNextPage = false});
  @override
  List<Object?> get props => [payslips];
}

class PayslipDetailLoaded extends PayslipState {
  final PayslipModel payslip;
  const PayslipDetailLoaded(this.payslip);
  @override
  List<Object?> get props => [payslip];
}

class PayslipDownloaded extends PayslipState {
  final String path;
  const PayslipDownloaded(this.path);
  @override
  List<Object?> get props => [path];
}

class PayslipError extends PayslipState {
  final String message;
  const PayslipError(this.message);
  @override
  List<Object?> get props => [message];
}

class PayslipCubit extends Cubit<PayslipState> {
  final PayslipRepository _repo;

  PayslipCubit({required PayslipRepository repository})
      : _repo = repository,
        super(PayslipInitial());

  Future<void> loadHistory({int page = 1}) async {
    emit(PayslipLoading());
    try {
      final result = await _repo.getHistory(page: page);
      emit(PayslipLoaded(result.data, hasNextPage: result.hasNextPage));
    } on ApiException catch (e) {
      emit(PayslipError(e.message));
    } catch (e) {
      emit(const PayslipError('Gagal memuat daftar slip gaji.'));
    }
  }

  Future<void> loadDetail(int payslipId) async {
    emit(PayslipLoading());
    try {
      final result = await _repo.getDetail(payslipId);
      emit(PayslipDetailLoaded(result));
    } on ApiException catch (e) {
      emit(PayslipError(e.message));
    } catch (e) {
      emit(const PayslipError('Gagal memuat detail slip gaji.'));
    }
  }

  Future<void> downloadPdf(int payslipId, String savePath) async {
    emit(PayslipLoading());
    try {
      await _repo.downloadPdf(payslipId, savePath);
      emit(PayslipDownloaded(savePath));
    } on ApiException catch (e) {
      emit(PayslipError(e.message));
    } catch (e) {
      emit(const PayslipError('Gagal mengunduh slip gaji.'));
    }
  }
}
