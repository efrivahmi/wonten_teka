import 'package:equatable/equatable.dart';

class ShiftAssignmentModel extends Equatable {
  final int id;
  final int employeeId;
  final int shiftTemplateId;
  final DateTime date;
  final ShiftTemplateModel? shiftTemplate;

  const ShiftAssignmentModel({
    required this.id,
    required this.employeeId,
    required this.shiftTemplateId,
    required this.date,
    this.shiftTemplate,
  });

  factory ShiftAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ShiftAssignmentModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      shiftTemplateId: json['shift_template_id'] as int,
      date: DateTime.parse(json['date'] as String),
      shiftTemplate: json['shift_template'] != null
          ? ShiftTemplateModel.fromJson(json['shift_template'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, date];
}

class ShiftTemplateModel extends Equatable {
  final int id;
  final String name;
  final String? startTime;
  final String? endTime;
  final String? color;

  const ShiftTemplateModel({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
    this.color,
  });

  factory ShiftTemplateModel.fromJson(Map<String, dynamic> json) {
    return ShiftTemplateModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      color: json['color'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, startTime, endTime];
}
