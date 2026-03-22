# Mindful Load Development Task List

## Core Refactoring: Firebase & Analytics
- [x] Fix `journal_list_screen.dart` index error (Local sorting)
- [x] Mood Check-in Grid (`mood_check_in_screen.dart`) layout optimization
- [x] Notification creation logic in `add_factor_screen.dart`
- [x] Isolated `notification_screen.dart` with local stream sorting
- [x] Notification integration in `main.dart`, `dashboard_screen.dart`, `profile_screen.dart`
- [x] `JournalAnalytics` utility for statistical processing
- [x] Real-time data binding for Dashboard, Analysis, and Profile screens
- [x] Calendar upgrades (Emotion Emojis, Day numbers, Navigation)
- [x] Firestore system notifications for Export and Backup actions

## HTML to Flutter Conversions (Completed)
- [x] `export_report_screen.dart` (HTML 1)
- [x] `backup_restore_screen.dart` (HTML 2)
- [x] `theme_settings_screen.dart` (HTML 3)
- [x] `user_info_screen.dart` (HTML 4)
- [x] `change_password_screen.dart` (HTML 5)

## Theming & User Experience (Interaction & Auth Flow)
- [x] Implement swipe-to-dismiss for Top Notifications (`NotificationHelper`)
- [x] Simplify Theme Settings to 2 options (Dark/Light)
- [x] **Comprehensive Theming Audit & Refactor**:
    - [x] `mood_check_in_screen.dart`
    - [x] `custom_tag_screen.dart`
    - [x] `add_detail_screen.dart`
    - [x] `add_factor_screen.dart`
    - [x] `welcome_screen.dart` (Interaction)
    - [x] `auth_welcome_screen.dart`
    - [x] `register_screen.dart`
    - [x] `login_screen.dart`
    - [x] `dashboard_screen.dart`
    - [x] `analysis_screen.dart`
    - [x] `profile_screen.dart`
    - [x] `main_screen.dart`
    - [x] `journal_calendar_screen.dart`
    - [x] `journal_list_screen.dart`
    - [x] `journal_detail_screen.dart`
    - [x] `notification_screen.dart`
    - [x] `reminder_screen.dart`

## Final Verification
- [ ] Run `flutter analyze` and fix any issues (In Progress)
- [ ] Manual smoke test of theme switching logic
- [ ] Verify Firestore permissions and data flow for all new screens
