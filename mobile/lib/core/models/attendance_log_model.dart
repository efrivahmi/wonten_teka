import 'package:equatable/equatable.dart';

/// Maps the Laravel AttendanceLog model.
class AttendanceLogModel extends Equatable {
  final int id;
  final int employeeId;
  final int companyId;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final Map<String, dynamic>? checkInGps;
  final Map<String, dynamic>? checkOutGps;
  final double? faceMatchScore;
  final String? deviceId;
  final Map<String, dynamic>? flags;
  final String status; // 'present', 'flagged', 'late'

  const AttendanceLogModel({
    required this.id,
    required this.employeeId,
    required this.companyId,
    required this.checkInAt,
    this.checkOutAt,
    this.checkInGps,
    this.checkOutGps,
    this.faceMatchScore,
    this.deviceId,
    this.flags,
    this.status = 'present',
  });

  bool get isFlagged => status == 'flagged';
  bool get hasCheckedOut => checkOutAt != null;

  Duration? get workDuration {
    if (checkOutAt == null) return null;
    return checkOutAt!.difference(checkInAt);
  }

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLogModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      companyId: json['company_id'] as int,
      checkInAt: DateTime.parse(json['check_in_at'] as String),
      checkOutAt: json['check_out_at'] != null ? DateTime.tryParse(json['check_out_at']) : null,
      checkInGps: json['check_in_gps'] as Map<String, dynamic>?,
      checkOutGps: json['check_out_gps'] as Map<String, dynamic>?,
      faceMatchScore: (json['face_match_score'] as num?)?.toDouble(),
      deviceId: json['device_id'] as String?,
      flags: json['flags'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'present',
    );
  }

  @override
  List<Object?> get props => [id, employeeId, checkInAt, checkOutAt, status];
}
