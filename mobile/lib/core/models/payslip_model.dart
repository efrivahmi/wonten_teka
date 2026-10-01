import 'package:equatable/equatable.dart';

class PayslipModel extends Equatable {
  final int id;
  final int employeeId;
  final int payrollRunId;
  final double grossSalary;
  final double totalDeductions;
  final double netSalary;
  final double basicSalary;
  final double pph21Amount;
  final int attendanceAbsenceDays;
  final double attendanceDeductionAmount;
  final String? periodStart;
  final String? periodEnd;
  final List<Map<String, dynamic>> components;
  final PayrollRunModel? payrollRun;
  final DateTime? createdAt;
  final String paymentStatus;
  final DateTime? collectedAt;

  const PayslipModel({
    required this.id,
    required this.employeeId,
    required this.payrollRunId,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netSalary,
    this.basicSalary = 0,
    this.pph21Amount = 0,
    this.attendanceAbsenceDays = 0,
    this.attendanceDeductionAmount = 0,
    this.periodStart,
    this.periodEnd,
    this.components = const [],
    this.payrollRun,
    this.createdAt,
    this.paymentStatus = 'pending',
    this.collectedAt,
  });

  String get periodLabel {
    if (payrollRun != null)
      return '${payrollRun!.periodMonth}/${payrollRun!.periodYear}';
    if (periodStart != null && periodStart!.length >= 7)
      return periodStart!.substring(0, 7);
    return '-';
  }

  List<Map<String, dynamic>> get earnings => components
      .where((item) => item['type'] == 'earning')
      .toList(growable: false);

  List<Map<String, dynamic>> get deductions => components
      .where((item) => item['type'] == 'deduction')
      .toList(growable: false);

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: int.tryParse('${json['id']}') ?? 0,
      employeeId: int.tryParse('${json['employee_id']}') ?? 0,
      payrollRunId: int.tryParse('${json['payroll_run_id']}') ?? 0,
      grossSalary: _number(json['gross_salary']),
      totalDeductions: _number(json['total_deductions']),
      netSalary: _number(json['net_salary']),
      basicSalary: _number(json['basic_salary']),
      pph21Amount: _number(json['pph21_amount']),
      attendanceAbsenceDays:
          int.tryParse('${json['attendance_absence_days']}') ?? 0,
      attendanceDeductionAmount: _number(json['attendance_deduction_amount']),
      periodStart: json['period_start']?.toString() ??
          json['payroll_run']?['period_start']?.toString(),
      periodEnd: json['period_end']?.toString() ??
          json['payroll_run']?['period_end']?.toString(),
      components: (json['components_detail'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false),
      payrollRun: json['payroll_run'] != null
          ? PayrollRunModel.fromJson(
              json['payroll_run'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      collectedAt: json['collected_at'] != null
          ? DateTime.tryParse('${json['collected_at']}')
          : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, netSalary];
}

double _number(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

class PayrollRunModel extends Equatable {
  final int id;
  final int periodMonth;
  final int periodYear;
  final String status;
  final String? scheduledPaymentDate;

  const PayrollRunModel({
    required this.id,
    required this.periodMonth,
    required this.periodYear,
    required this.status,
    this.scheduledPaymentDate,
  });

  factory PayrollRunModel.fromJson(Map<String, dynamic> json) {
    return PayrollRunModel(
      id: int.tryParse('${json['id']}') ?? 0,
      periodMonth: int.tryParse('${json['period_month']}') ?? 0,
      periodYear: int.tryParse('${json['period_year']}') ?? 0,
      status: json['status'] as String? ?? '',
      scheduledPaymentDate: json['scheduled_payment_date']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, periodMonth, periodYear];
}
