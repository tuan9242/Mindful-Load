import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to Onboarding or Home after delay
    Future.delayed(const Duration(seconds: 2), () {
       if (context.mounted) {
         Navigator.of(context).pushReplacementNamed('/');
       }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text('Tâm An', style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
