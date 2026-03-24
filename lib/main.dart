import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:mindful_load/core/config/firebase_options.dart';
import 'package:mindful_load/core/state/app_state.dart';
import 'package:mindful_load/features/auth/screens/auth/auth_welcome_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/welcome_screen.dart' as interaction_welcome;
import 'package:mindful_load/features/interaction/screens/input/mood_check_in_screen.dart';
import 'package:mindful_load/features/interaction/screens/input/add_detail_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/custom_tag_screen.dart';
import 'package:mindful_load/features/auth/screens/auth/login_screen.dart';
import 'package:mindful_load/features/auth/screens/auth/register_screen.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_list_screen.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_detail_screen.dart';
import 'package:mindful_load/features/auth/screens/identity/profile_screen.dart';
import 'package:mindful_load/features/auth/screens/auth/splash_screen.dart';
import 'package:mindful_load/features/news/screens/shell/main_screen.dart';
import 'package:mindful_load/features/news/screens/alerts/reminder_screen.dart';
import 'package:mindful_load/features/news/screens/shell/notification_screen.dart';
import 'package:mindful_load/features/news/screens/analytics/export_report_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/backup_restore_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/theme_settings_screen.dart';
import 'package:mindful_load/features/auth/screens/identity/user_info_screen.dart';
import 'package:mindful_load/features/auth/screens/auth/change_password_screen.dart';
import 'package:mindful_load/features/news/screens/analytics/analysis_screen.dart';
import 'package:mindful_load/features/auth/screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationHelper.init();
  } catch (e) {
    debugPrint("Firebase/Notification Init error: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final appState = AppState();
  await appState.loadFromPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
      ],
      child: const TamAnApp(),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  const TamAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Mindful Load',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi', 'VN')],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/main': (context) => const MainScreen(),
            '/': (context) => const AuthWelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/journal-list': (context) => const JournalListScreen(),
            '/journal-detail': (context) => const JournalDetailScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/interaction-welcome': (context) => const interaction_welcome.WelcomeScreen(),
            '/mood-check-in': (context) => const MoodCheckInScreen(),
            '/add-detail': (context) =>
                const AddDetailScreen(selectedMood: 'Bình thường'),
            '/custom-tags': (context) => const CustomTagScreen(),
            '/reminder': (context) => const ReminderScreen(),
            '/notifications': (context) => const NotificationScreen(),
            '/export-report': (context) => const ExportReportScreen(),
            '/analysis': (context) => const AnalysisScreen(),
            '/backup-restore': (context) => const BackupRestoreScreen(),
            '/theme-settings': (context) => const ThemeSettingsScreen(),
            '/user-info': (context) => const UserInfoScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }
}
