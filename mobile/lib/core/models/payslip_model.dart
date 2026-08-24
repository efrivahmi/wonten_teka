import 'package:equatable/equatable.dart';

class PayslipModel extends Equatable {
  final int id;
  final int employeeId;
  final int payrollRunId;
  final double grossSalary;
  final double totalDeductions;
  final double netSalary;
  final Map<String, dynamic>? earningsBreakdown;
  final Map<String, dynamic>? deductionsBreakdown;
  final PayrollRunModel? payrollRun;
  final DateTime? createdAt;

  const PayslipModel({
    required this.id,
    required this.employeeId,
    required this.payrollRunId,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netSalary,
    this.earningsBreakdown,
    this.deductionsBreakdown,
    this.payrollRun,
    this.createdAt,
  });

  String get periodLabel {
    if (payrollRun != null) {
      return '${payrollRun!.periodMonth}/${payrollRun!.periodYear}';
    }
    return '-';
  }

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      payrollRunId: json['payroll_run_id'] as int,
      grossSalary: (json['gross_salary'] as num).toDouble(),
      totalDeductions: (json['total_deductions'] as num).toDouble(),
      netSalary: (json['net_salary'] as num).toDouble(),
      earningsBreakdown: json['earnings_breakdown'] as Map<String, dynamic>?,
      deductionsBreakdown: json['deductions_breakdown'] as Map<String, dynamic>?,
      payrollRun: json['payroll_run'] != null
          ? PayrollRunModel.fromJson(json['payroll_run'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, netSalary];
}

class PayrollRunModel extends Equatable {
  final int id;
  final int periodMonth;
  final int periodYear;
  final String status;

  const PayrollRunModel({
    required this.id,
    required this.periodMonth,
    required this.periodYear,
    required this.status,
  });

  factory PayrollRunModel.fromJson(Map<String, dynamic> json) {
    return PayrollRunModel(
      id: json['id'] as int,
      periodMonth: json['period_month'] as int,
      periodYear: json['period_year'] as int,
      status: json['status'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, periodMonth, periodYear];
}
