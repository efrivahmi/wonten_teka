import 'package:equatable/equatable.dart';

class PersonalTaskModel extends Equatable {
  final int id;
  final int employeeId;
  final String title;
  final String? description;
  final DateTime? taskDate;
  final String recurrenceRule;
  final String? reminderTime;
  final bool isHabit;
  final bool reminderEnabled;
  final int streakCount;
  final int longestStreak;
  final bool isActive;
  final DateTime? lastCompletedAt;

  const PersonalTaskModel({
    required this.id,
    required this.employeeId,
    required this.title,
    this.description,
    this.taskDate,
    this.recurrenceRule = 'daily',
    this.reminderTime,
    this.isHabit = false,
    this.reminderEnabled = false,
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
      taskDate: json['task_date'] != null
          ? DateTime.parse(json['task_date'] as String)
          : null,
      recurrenceRule: json['recurrence_rule'] as String? ?? 'daily',
      reminderTime: json['reminder_time'] as String?,
      isHabit: json['is_habit'] as bool? ?? false,
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      streakCount: json['streak_count'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.tryParse(json['last_completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'title': title,
        'description': description,
        'task_date': taskDate?.toIso8601String(),
        'recurrence_rule': recurrenceRule,
        'reminder_time': reminderTime,
        'is_habit': isHabit,
        'reminder_enabled': reminderEnabled,
        'streak_count': streakCount,
        'longest_streak': longestStreak,
        'is_active': isActive,
        'last_completed_at': lastCompletedAt?.toIso8601String(),
      };

  PersonalTaskModel copyWith({
    int? id,
    int? employeeId,
    String? title,
    String? description,
    DateTime? taskDate,
    String? recurrenceRule,
    String? reminderTime,
    bool? isHabit,
    bool? reminderEnabled,
    int? streakCount,
    int? longestStreak,
    bool? isActive,
    DateTime? lastCompletedAt,
  }) {
    return PersonalTaskModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskDate: taskDate ?? this.taskDate,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminderTime: reminderTime ?? this.reminderTime,
      isHabit: isHabit ?? this.isHabit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      isActive: isActive ?? this.isActive,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }

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
