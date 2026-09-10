import 'package:equatable/equatable.dart';

/// Maps the Laravel User model with loaded `employee` and `roles` relations.
/// Response shape from `/api/login` and `/api/me`.
class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;

  final bool isActive;
  final EmployeeModel? employee;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,

    this.isActive = true,
    this.employee,
    this.roles = const [],
  });

  bool get isAdmin => roles.contains('admin') || roles.contains('super_admin');

  bool get isEmployee => roles.contains('employee') || roles.isEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,

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
        
        'is_active': isActive,
        'employee': employee?.toJson(),
        'roles': roles,
      };

  @override
  List<Object?> get props => [id, name, email, isActive, employee, roles];
}

/// Maps the Laravel Employee model.
class EmployeeModel extends Equatable {
  final int id;
  
  final String? employeeNumber;
  final String fullName;
  final String? department;
  final String? position;
  final String? phone;
  final DateTime? joinDate;
  final bool faceEnrolled;
  final DateTime? faceEnrolledAt;
  final String? gender;
  final String? address;
  
  final String? nik;
  final String? npwp;
  final DateTime? dateOfBirth;
  final String? employmentStatus;
  final String? bpjsKesehatan;
  final String? bpjsKetenagakerjaan;
  final String? ptkpStatus;
  final String? bankName;
  final String? bankAccount;

  const EmployeeModel({
    required this.id,
    
    this.employeeNumber,
    required this.fullName,
    this.department,
    this.position,
    this.phone,
    this.joinDate,
    this.faceEnrolled = false,
    this.faceEnrolledAt,
    this.gender,
    this.address,
    this.nik,
    this.npwp,
    this.dateOfBirth,
    this.employmentStatus,
    this.bpjsKesehatan,
    this.bpjsKetenagakerjaan,
    this.ptkpStatus,
    this.bankName,
    this.bankAccount,
  });

  bool get isProfileCompleted => 
    gender != null && gender!.isNotEmpty &&
    address != null && address!.isNotEmpty;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,

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
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      nik: json['nik'] as String?,
      npwp: json['npwp'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
      employmentStatus: json['employment_status'] as String?,
      bpjsKesehatan: json['bpjs_kesehatan'] as String?,
      bpjsKetenagakerjaan: json['bpjs_ketenagakerjaan'] as String?,
      ptkpStatus: json['ptkp_status'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccount: json['bank_account'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        
        'employee_number': employeeNumber,
        'full_name': fullName,
        'department': department,
        'position': position,
        'phone': phone,
        'join_date': joinDate?.toIso8601String(),
        'face_enrolled': faceEnrolled,
        'face_enrolled_at': faceEnrolledAt?.toIso8601String(),
        'gender': gender,
        'address': address,
        'nik': nik,
        'npwp': npwp,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'employment_status': employmentStatus,
        'bpjs_kesehatan': bpjsKesehatan,
        'bpjs_ketenagakerjaan': bpjsKetenagakerjaan,
        'ptkp_status': ptkpStatus,
        'bank_name': bankName,
        'bank_account': bankAccount,
      };

  @override
  List<Object?> get props => [
        id, employeeNumber, fullName, department, position, gender, address,
        nik, npwp, dateOfBirth, employmentStatus, bpjsKesehatan,
        bpjsKetenagakerjaan, ptkpStatus, bankName, bankAccount,
      ];
}
