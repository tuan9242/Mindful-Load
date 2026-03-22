import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to Onboarding or Home after delay
    Future.delayed(const Duration(seconds: 2), () {
       if (context.mounted) {
         final user = FirebaseAuth.instance.currentUser;
         if (user != null) {
           Navigator.of(context).pushReplacementNamed('/main');
         } else {
           Navigator.of(context).pushReplacementNamed('/');
         }
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
