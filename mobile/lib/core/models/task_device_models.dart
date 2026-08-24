import 'package:equatable/equatable.dart';

class PersonalTaskModel extends Equatable {
  final int id;
  final int employeeId;
  final String title;
  final String? description;
  final String recurrenceRule;
  final String? reminderTime;
  final int streakCount;
  final int longestStreak;
  final bool isActive;
  final DateTime? lastCompletedAt;

  const PersonalTaskModel({
    required this.id,
    required this.employeeId,
    required this.title,
    this.description,
    this.recurrenceRule = 'daily',
    this.reminderTime,
    this.streakCount = 0,
    this.longestStreak = 0,
    this.isActive = true,
    this.lastCompletedAt,
  });

  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }

  factory PersonalTaskModel.fromJson(Map<String, dynamic> json) {
    return PersonalTaskModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      recurrenceRule: json['recurrence_rule'] as String? ?? 'daily',
      reminderTime: json['reminder_time'] as String?,
      streakCount: json['streak_count'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.tryParse(json['last_completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'recurrence_rule': recurrenceRule,
        'reminder_time': reminderTime,
      };

  @override
  List<Object?> get props => [id, title, streakCount, isActive];
}

class DeviceModel extends Equatable {
  final int id;
  final int employeeId;
  final String deviceFingerprint;
  final String deviceName;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final String status; // 'pending_approval', 'active', 'revoked'

  const DeviceModel({
    required this.id,
    required this.employeeId,
    required this.deviceFingerprint,
    required this.deviceName,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    this.status = 'pending_approval',
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending_approval';

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      deviceFingerprint: json['device_fingerprint'] as String,
      deviceName: json['device_name'] as String,
      deviceModel: json['device_model'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      status: json['status'] as String? ?? 'pending_approval',
    );
  }

  @override
  List<Object?> get props => [id, deviceFingerprint, status];
}
