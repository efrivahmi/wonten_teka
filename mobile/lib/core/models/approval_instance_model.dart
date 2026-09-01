import 'package:equatable/equatable.dart';

/// Maps the Laravel ApprovalInstance model with polymorphic `approvable` relation.
class ApprovalInstanceModel extends Equatable {
  final int id;
  final int companyId;
  final String approvableType; // e.g. 'App\\Models\\LeaveRequest'
  final int approvableId;
  final String status; // 'pending', 'approved', 'rejected'
  final int currentStep;
  final Map<String, dynamic>? approvable;
  final DateTime? createdAt;

  const ApprovalInstanceModel({
    required this.id,
    required this.companyId,
    required this.approvableType,
    required this.approvableId,
    this.status = 'pending',
    this.currentStep = 1,
    this.approvable,
    this.createdAt,
  });

  /// Friendly name for the type of request.
  String get requestType {
    if (approvableType.contains('LeaveRequest')) return 'Cuti';
    if (approvableType.contains('OvertimeRequest')) return 'Lembur';
    if (approvableType.contains('ShiftExchangeRequest')) return 'Tukar Shift';
    if (approvableType.contains('Claim')) return 'Klaim';
    if (approvableType.contains('AttendanceAdjustmentRequest')) return 'Lupa Absen';
    if (approvableType.contains('BusinessTripRequest')) return 'Dinas Luar';
    return 'Persetujuan';
  }

  bool get isPending => status == 'pending';

  factory ApprovalInstanceModel.fromJson(Map<String, dynamic> json) {
    return ApprovalInstanceModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      approvableType: json['approvable_type'] as String? ?? '',
      approvableId: json['approvable_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      currentStep: json['current_step'] as int? ?? 1,
      approvable: json['approvable'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, approvableType, approvableId, status];
}
