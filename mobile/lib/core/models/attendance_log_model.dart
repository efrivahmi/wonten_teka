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
  final String? checkInPhotoUrl;
  final String? checkOutPhotoUrl;
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
    this.checkInPhotoUrl,
    this.checkOutPhotoUrl,
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
      checkInAt: _parseAndLocalize(json['check_in_at'] as String),
      checkOutAt: json['check_out_at'] != null ? _parseAndLocalize(json['check_out_at'] as String) : null,
      checkInGps: json['check_in_gps'] as Map<String, dynamic>?,
      checkOutGps: json['check_out_gps'] as Map<String, dynamic>?,
      faceMatchScore: json['check_in_face_score'] != null 
          ? double.tryParse(json['check_in_face_score'].toString()) 
          : null,
      checkInPhotoUrl: json['check_in_photo_url'] as String?,
      checkOutPhotoUrl: json['check_out_photo_url'] as String?,
      deviceId: json['device_id']?.toString(),
      flags: json['flags'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'present',
    );
  }

  @override
  List<Object?> get props => [id, employeeId, checkInAt, checkOutAt, status];

  static DateTime _parseAndLocalize(String dateStr) {
    String normalized = dateStr.replaceFirst(' ', 'T');
    if (!normalized.endsWith('Z')) {
      // Check if it has an offset like +07:00 or -05:00 at the end
      final hasOffset = RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(normalized);
      if (!hasOffset) {
        normalized += 'Z';
      }
    }
    return DateTime.parse(normalized).toLocal();
  }
}

