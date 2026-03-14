import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/features/interaction/screens/welcome_screen.dart';
import 'package:mindful_load/features/interaction/screens/mood_check_in_screen.dart';
import 'package:mindful_load/features/interaction/screens/add_detail_screen.dart';
import 'package:mindful_load/features/interaction/screens/add_factor_screen.dart';
import 'package:mindful_load/features/interaction/screens/custom_tag_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
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
