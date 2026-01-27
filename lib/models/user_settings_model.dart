class UserSettingsModel {
  final String userId;
  final List<String> reminderTimes;
  final bool isNotificationEnabled;
  final bool isCalendarSync;
  final bool isLocationEnabled;
  final String currentTheme;
  final bool appLockEnabled;

  UserSettingsModel({
    required this.userId,
    required this.reminderTimes,
    required this.isNotificationEnabled,
    required this.isCalendarSync,
    required this.isLocationEnabled,
    required this.currentTheme,
    required this.appLockEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'reminder_times': reminderTimes,
      'is_notification_enabled': isNotificationEnabled,
      'is_calendar_sync': isCalendarSync,
      'is_location_enabled': isLocationEnabled,
      'current_theme': currentTheme,
      'app_lock_enabled': appLockEnabled,
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      userId: map['user_id'] ?? '',
      reminderTimes: List<String>.from(map['reminder_times'] ?? []),
      isNotificationEnabled: map['is_notification_enabled'] ?? false,
      isCalendarSync: map['is_calendar_sync'] ?? false,
      isLocationEnabled: map['is_location_enabled'] ?? false,
      currentTheme: map['current_theme'] ?? 'Light',
      appLockEnabled: map['app_lock_enabled'] ?? false,
    );
  }
}
