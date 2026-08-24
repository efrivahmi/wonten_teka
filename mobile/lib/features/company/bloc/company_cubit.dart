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
  const CompanyLoaded({this.calendarEvents = const [], this.announcements = const []});
  @override
  List<Object?> get props => [calendarEvents, announcements];
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

  Future<void> loadAll() async {
    emit(CompanyLoading());
    try {
      final results = await Future.wait([
        _repo.getCalendar(),
        _repo.getAnnouncements(),
      ]);
      emit(CompanyLoaded(
        calendarEvents: (results[0] as dynamic).data as List<CalendarEventModel>,
        announcements: (results[1] as dynamic).data as List<AnnouncementModel>,
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
        emit(CompanyLoaded(calendarEvents: currentState.calendarEvents, announcements: updatedAnnouncements));
      } catch (_) {
        // Silently fail or emit error, then reload? For now ignore.
      }
    }
  }
}
