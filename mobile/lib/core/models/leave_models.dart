import 'package:equatable/equatable.dart';

/// Maps the Laravel LeaveType model.
class LeaveTypeModel extends Equatable {
  final int id;

  final String name;
  final String? code;
  final int? quotaPerYear;
  final bool isPaid;
  final bool requiresAttachment;
  final bool isCarryOverAllowed;
  final int? maxCarryOverDays;
  final bool isActive;

  const LeaveTypeModel({
    required this.id,

    required this.name,
    this.code,
    this.quotaPerYear,
    this.isPaid = true,
    this.requiresAttachment = false,
    this.isCarryOverAllowed = false,
    this.maxCarryOverDays,
    this.isActive = true,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as int,

      name: json['name'] as String,
      code: json['code'] as String?,
      quotaPerYear: json['quota_per_year'] as int?,
      isPaid: json['is_paid'] as bool? ?? true,
      requiresAttachment: json['requires_attachment'] as bool? ?? false,
      isCarryOverAllowed: json['is_carry_over_allowed'] as bool? ?? false,
      maxCarryOverDays: json['max_carry_over_days'] as int?,
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
  final int entitledDays;
  final int usedDays;
  final int carriedOverDays;
  final int remainingDays;
  final LeaveTypeModel? leaveType;

  const LeaveBalanceModel({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.entitledDays,
    required this.usedDays,
    this.carriedOverDays = 0,
    required this.remainingDays,
    this.leaveType,
  });

  int get remaining => remainingDays;

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      entitledDays: json['entitled_days'] as int? ?? 0,
      usedDays: json['used_days'] as int? ?? 0,
      carriedOverDays: json['carried_over_days'] as int? ?? 0,
      remainingDays: json['remaining_days'] as int? ?? 0,
      leaveType: json['leave_type'] != null
          ? LeaveTypeModel.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, leaveTypeId, entitledDays, usedDays];
}

/// Maps the Laravel LeaveRequest model.
class LeaveRequestModel extends Equatable {
  final int id;

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
