import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/features/auth/screens/auth_welcome_screen.dart';
import 'package:mindful_load/features/interaction/screens/welcome_screen.dart' as interaction_welcome;
import 'package:mindful_load/features/interaction/screens/mood_check_in_screen.dart';
import 'package:mindful_load/features/interaction/screens/add_detail_screen.dart';
import 'package:mindful_load/features/interaction/screens/add_factor_screen.dart';
import 'package:mindful_load/features/interaction/screens/custom_tag_screen.dart';
import 'package:mindful_load/features/auth/screens/login_screen.dart';
import 'package:mindful_load/features/auth/screens/register_screen.dart';
import 'package:mindful_load/features/auth/screens/journal_list_screen.dart';
import 'package:mindful_load/features/auth/screens/journal_detail_screen.dart';
import 'package:mindful_load/features/auth/screens/profile_screen.dart';
import 'package:mindful_load/features/auth/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
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
        '/add-factor': (context) =>
            const AddFactorScreen(selectedMood: 'Bình thường'),
        '/custom-tags': (context) => const CustomTagScreen(),
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
