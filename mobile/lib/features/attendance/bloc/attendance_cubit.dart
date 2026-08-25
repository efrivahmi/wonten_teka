import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/attendance_log_model.dart';
import '../../../core/repositories/attendance_repository.dart';

// ── States ─────────────────────────────────────────────────────────────────

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceLogModel> logs;
  final int currentPage;
  final bool hasNextPage;
  const AttendanceLoaded(this.logs,
      {this.currentPage = 1, this.hasNextPage = false});
  @override
  List<Object?> get props => [logs, currentPage];
}

class CheckInSuccess extends AttendanceState {
  final AttendanceLogModel log;
  const CheckInSuccess(this.log);
  @override
  List<Object?> get props => [log];
}

class CheckOutSuccess extends AttendanceState {
  final AttendanceLogModel log;
  const CheckOutSuccess(this.log);
  @override
  List<Object?> get props => [log];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repo;

  AttendanceCubit({required AttendanceRepository repository})
      : _repo = repository,
        super(AttendanceInitial());

  Future<void> loadHistory({int page = 1}) async {
    emit(AttendanceLoading());
    try {
      final result = await _repo.getHistory(page: page);
      emit(AttendanceLoaded(result.data,
          currentPage: result.currentPage, hasNextPage: result.hasNextPage));
    } on ApiException catch (e) {
      emit(AttendanceError(e.message));
    } catch (e) {
      emit(const AttendanceError('Gagal memuat riwayat kehadiran.'));
    }
  }

  Future<void> checkIn({
    required double latitude,
    required double longitude,
    required String deviceId,
    double faceMatchScore = 1.0,
    File? photo,
    Map<String, dynamic>? flags,
  }) async {
    emit(AttendanceLoading());
    try {
      final log = await _repo.checkIn(
        latitude: latitude,
        longitude: longitude,
        faceMatchScore: faceMatchScore,
        deviceId: deviceId,
        photo: photo,
        flags: flags,
      );
      emit(CheckInSuccess(log));
    } on ApiException catch (e) {
      emit(AttendanceError(e.message));
    } catch (e) {
      emit(const AttendanceError('Gagal melakukan check-in.'));
    }
  }

  Future<void> checkOut({
    required double latitude,
    required double longitude,
  }) async {
    emit(AttendanceLoading());
    try {
      final log =
          await _repo.checkOut(latitude: latitude, longitude: longitude);
      emit(CheckOutSuccess(log));
    } on ApiException catch (e) {
      emit(AttendanceError(e.message));
    } catch (e) {
      emit(const AttendanceError('Gagal melakukan check-out.'));
    }
  }
}
