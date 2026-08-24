import 'package:equatable/equatable.dart';

/// Maps the Laravel User model with loaded `employee` and `roles` relations.
/// Response shape from `/api/login` and `/api/me`.
class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final int? companyId;
  final bool isActive;
  final EmployeeModel? employee;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.companyId,
    this.isActive = true,
    this.employee,
    this.roles = const [],
  });

  bool get isAdmin => roles.contains('admin') || roles.contains('super_admin');
  bool get isManager => roles.contains('manager');
  bool get isEmployee => roles.contains('employee') || roles.isEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      companyId: json['company_id'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      employee: json['employee'] != null
          ? EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List?)
              ?.map((r) => r is Map ? (r['name'] as String? ?? '') : r.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'company_id': companyId,
        'is_active': isActive,
        'employee': employee?.toJson(),
        'roles': roles,
      };

  @override
  List<Object?> get props => [id, name, email, companyId, isActive, employee, roles];
}

/// Maps the Laravel Employee model.
class EmployeeModel extends Equatable {
  final int id;
  final int companyId;
  final String? employeeNumber;
  final String fullName;
  final String? department;
  final String? position;
  final String? phone;
  final DateTime? joinDate;
  final bool faceEnrolled;
  final DateTime? faceEnrolledAt;

  const EmployeeModel({
    required this.id,
    required this.companyId,
    this.employeeNumber,
    required this.fullName,
    this.department,
    this.position,
    this.phone,
    this.joinDate,
    this.faceEnrolled = false,
    this.faceEnrolledAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      employeeNumber: json['employee_number'] as String?,
      fullName: json['full_name'] as String? ?? '',
      department: json['department'] as String?,
      position: json['position'] as String?,
      phone: json['phone'] as String?,
      joinDate: json['join_date'] != null ? DateTime.tryParse(json['join_date']) : null,
      faceEnrolled: json['face_enrolled'] as bool? ?? false,
      faceEnrolledAt: json['face_enrolled_at'] != null
          ? DateTime.tryParse(json['face_enrolled_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'employee_number': employeeNumber,
        'full_name': fullName,
        'department': department,
        'position': position,
        'phone': phone,
        'join_date': joinDate?.toIso8601String(),
        'face_enrolled': faceEnrolled,
        'face_enrolled_at': faceEnrolledAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, companyId, employeeNumber, fullName, department, position];
}
