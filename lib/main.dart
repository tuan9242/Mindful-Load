import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
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

import 'package:flutter/foundation.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      // Lưu ý: Người dùng cần cung cấp Web App ID thực tế từ Firebase Console
      // để có thể đăng nhập trên trình duyệt/windows.
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyA8UECu38B-UC2XVGaD_0RROI_SxrB8-DE',
          appId: '1:759026003067:android:c99ea62d67bed47a30c6de',
          messagingSenderId: '759026003067',
          projectId: 'btl-1771020719',
          storageBucket: 'btl-1771020719.firebasestorage.app',
        ),
      );
    } else {
      // Android sẽ tự động sử dụng google-services.json
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase Init error: $e");
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TamAnApp());
}

class TamAnApp extends StatelessWidget {
  const TamAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Tâm An',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi', 'VN')],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/main': (context) => const MainScreen(),
            '/dev-menu': (context) => const DevMenuScreen(),
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
          },
        );
      },
    );
  }
}

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Menu')),
      body: ListView(
        children: [
          ListTile(title: const Text('Configured Splash Screen'), onTap: () => Navigator.pushNamed(context, '/splash')),
          ListTile(title: const Text('Welcome Screen'), onTap: () => Navigator.pushNamed(context, '/')),
          ListTile(title: const Text('Login Screen'), onTap: () => Navigator.pushNamed(context, '/login')),
          ListTile(title: const Text('Register Screen'), onTap: () => Navigator.pushNamed(context, '/register')),
          ListTile(title: const Text('Journal List Screen'), onTap: () => Navigator.pushNamed(context, '/journal-list')),
          ListTile(title: const Text('Journal Detail Screen'), onTap: () => Navigator.pushNamed(context, '/journal-detail')),
          ListTile(title: const Text('Profile Screen'), onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }
}
