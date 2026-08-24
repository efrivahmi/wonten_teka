import 'package:equatable/equatable.dart';

/// Maps the Laravel LeaveType model.
class LeaveTypeModel extends Equatable {
  final int id;
  final int companyId;
  final String name;
  final int? maxDaysPerYear;
  final bool requiresAttachment;
  final bool isActive;

  const LeaveTypeModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.maxDaysPerYear,
    this.requiresAttachment = false,
    this.isActive = true,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      name: json['name'] as String,
      maxDaysPerYear: json['max_days_per_year'] as int?,
      requiresAttachment: json['requires_attachment'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Maps the Laravel LeaveBalance model.
class LeaveBalanceModel extends Equatable {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final int allocated;
  final int used;
  final LeaveTypeModel? leaveType;

  const LeaveBalanceModel({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.allocated,
    required this.used,
    this.leaveType,
  });

  int get remaining => allocated - used;

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      allocated: json['allocated'] as int? ?? 0,
      used: json['used'] as int? ?? 0,
      leaveType: json['leave_type'] != null
          ? LeaveTypeModel.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, leaveTypeId, allocated, used];
}

/// Maps the Laravel LeaveRequest model.
class LeaveRequestModel extends Equatable {
  final int id;
  final int companyId;
  final int employeeId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String? attachmentUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final LeaveTypeModel? leaveType;
  final DateTime? createdAt;

  const LeaveRequestModel({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.attachmentUrl,
    this.status = 'pending',
    this.leaveType,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      employeeId: json['employee_id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalDays: json['total_days'] as int,
      reason: json['reason'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      leaveType: json['leave_type'] != null
          ? LeaveTypeModel.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, startDate, endDate, status];
}
