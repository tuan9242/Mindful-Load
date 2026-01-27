import 'package:flutter/material.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in Cảm xúc')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hôm nay bạn cảm thấy thế nào?'),
            const SizedBox(height: 20),
            // Placeholder for mood selection
            Wrap(
              spacing: 10,
              children: List.generate(7, (index) {
                return CircleAvatar(child: Text('${index + 1}'));
              }),
            ),
          ],
        ),
      ),
    );
  }
}
