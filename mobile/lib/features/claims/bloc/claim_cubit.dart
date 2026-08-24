import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/claim_models.dart';
import '../../../core/repositories/claim_repository.dart';

abstract class ClaimState extends Equatable {
  const ClaimState();
  @override
  List<Object?> get props => [];
}

class ClaimInitial extends ClaimState {}
class ClaimLoading extends ClaimState {}

class ClaimLoaded extends ClaimState {
  final List<ClaimCategoryModel> categories;
  final List<ClaimModel> history;
  final bool hasNextPage;
  const ClaimLoaded({this.categories = const [], this.history = const [], this.hasNextPage = false});
  @override
  List<Object?> get props => [categories, history];
}

class ClaimSubmitted extends ClaimState {
  final ClaimModel claim;
  const ClaimSubmitted(this.claim);
  @override
  List<Object?> get props => [claim];
}

class ClaimError extends ClaimState {
  final String message;
  const ClaimError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClaimCubit extends Cubit<ClaimState> {
  final ClaimRepository _repo;

  ClaimCubit({required ClaimRepository repository})
      : _repo = repository,
        super(ClaimInitial());

  Future<void> loadAll() async {
    emit(ClaimLoading());
    try {
      final results = await Future.wait([_repo.getCategories(), _repo.getHistory()]);
      emit(ClaimLoaded(
        categories: results[0] as List<ClaimCategoryModel>,
        history: (results[1] as dynamic).data as List<ClaimModel>,
        hasNextPage: (results[1] as dynamic).hasNextPage as bool,
      ));
    } on ApiException catch (e) {
      emit(ClaimError(e.message));
    } catch (e) {
      emit(const ClaimError('Gagal memuat data klaim.'));
    }
  }

  Future<void> submit({
    required int categoryId,
    required double amount,
    required String expenseDate,
    required String description,
    String? receiptPath,
  }) async {
    emit(ClaimLoading());
    try {
      final claim = await _repo.submit(
        claimCategoryId: categoryId,
        amount: amount,
        expenseDate: expenseDate,
        description: description,
        receiptPath: receiptPath,
      );
      emit(ClaimSubmitted(claim));
    } on ValidationException catch (e) {
      emit(ClaimError(e.allErrors.join('\n')));
    } on ApiException catch (e) {
      emit(ClaimError(e.message));
    } catch (e) {
      emit(const ClaimError('Gagal mengajukan klaim.'));
    }
  }
}
