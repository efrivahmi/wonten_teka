import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/company_models.dart';
import '../../../core/repositories/company_repository.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();
  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}
class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<CalendarEventModel> calendarEvents;
  final List<AnnouncementModel> announcements;
  final List<Map<String, dynamic>> attendanceLogs;
  final List<int> workingDays;
  final Map<String, dynamic>? geofence;
  
  const CompanyLoaded({
    this.calendarEvents = const [], 
    this.announcements = const [],
    this.attendanceLogs = const [],
    this.workingDays = const [1,2,3,4,5],
    this.geofence,
  });
  
  @override
  List<Object?> get props => [calendarEvents, announcements, attendanceLogs, workingDays, geofence];
}

class CompanyError extends CompanyState {
  final String message;
  const CompanyError(this.message);
  @override
  List<Object?> get props => [message];
}

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repo;

  CompanyCubit({required CompanyRepository repository})
      : _repo = repository,
        super(CompanyInitial());

  Future<void> loadAll({int? month, int? year}) async {
    emit(CompanyLoading());
    try {
      final results = await Future.wait([
        _repo.getCalendar(month: month, year: year),
        _repo.getAnnouncements(),
        _repo.getGeofence().catchError((_) => <String, dynamic>{}), // Optional fallback
      ]);
      
      final calendarData = results[0] as Map<String, dynamic>;
      final events = (calendarData['events'] as List).map((e) => CalendarEventModel.fromJson(e)).toList();
      final logs = List<Map<String, dynamic>>.from(calendarData['attendance_logs'] ?? []);
      final wDays = List<int>.from(calendarData['working_days'] ?? [1,2,3,4,5]);
      
      emit(CompanyLoaded(
        calendarEvents: events,
        attendanceLogs: logs,
        workingDays: wDays,
        announcements: (results[1] as dynamic).data as List<AnnouncementModel>,
        geofence: (results[2] as Map<String, dynamic>).isNotEmpty ? results[2] as Map<String, dynamic> : null,
      ));
    } on ApiException catch (e) {
      emit(CompanyError(e.message));
    } catch (e) {
      emit(const CompanyError('Gagal memuat data perusahaan.'));
    }
  }

  Future<void> acknowledgeAnnouncement(int announcementId) async {
    final currentState = state;
    if (currentState is CompanyLoaded) {
      try {
        await _repo.acknowledgeAnnouncement(announcementId);
        // Optimistic update
        final updatedAnnouncements = currentState.announcements.map((a) {
          if (a.id == announcementId) {
            return AnnouncementModel(
              id: a.id,
              companyId: a.companyId,
              title: a.title,
              body: a.body,
              priority: a.priority,
              targetType: a.targetType,
              isAcknowledged: true,
              createdAt: a.createdAt,
            );
          }
          return a;
        }).toList();
        
        emit(CompanyLoaded(
          calendarEvents: currentState.calendarEvents, 
          announcements: updatedAnnouncements,
          attendanceLogs: currentState.attendanceLogs,
          workingDays: currentState.workingDays,
        ));
      } catch (_) {
        // Silently fail or emit error, then reload? For now ignore.
      }
    }
  }
}
