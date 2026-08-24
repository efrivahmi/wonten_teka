import 'package:equatable/equatable.dart';

class CalendarEventModel extends Equatable {
  final int id;
  final int companyId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? type; // 'holiday', 'meeting', etc.
  final String? department;

  const CalendarEventModel({
    required this.id,
    required this.companyId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.type,
    this.department,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      type: json['type'] as String?,
      department: json['department'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, startDate];
}

class AnnouncementModel extends Equatable {
  final int id;
  final int companyId;
  final String title;
  final String body;
  final String priority; // 'low', 'normal', 'high', 'urgent'
  final String targetType; // 'company', 'department', 'employee'
  final bool isAcknowledged;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.body,
    this.priority = 'normal',
    this.targetType = 'company',
    this.isAcknowledged = false,
    this.createdAt,
  });

  bool get isUrgent => priority == 'urgent' || priority == 'high';

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Check acknowledgments array to determine if current user acknowledged
    final acknowledgments = json['acknowledgments'] as List?;
    final acknowledged = acknowledgments != null && acknowledgments.isNotEmpty;

    return AnnouncementModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      targetType: json['target_type'] as String? ?? 'company',
      isAcknowledged: acknowledged,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, priority];
}
