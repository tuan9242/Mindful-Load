import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DummyDataSeeder {
  static Future<void> seedTestData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    // Helper to create timestamp at specific offset
    Timestamp ts(int days, int hours) {
      return Timestamp.fromDate(now.subtract(Duration(days: days, hours: hours)));
    }

    final List<Map<String, dynamic>> testEntries = [
      // --- TODAY (24/03) - Time-based Trend ---
      {
        'userId': user.uid,
        'mood': 'Hạnh phúc',
        'timestamp': ts(0, 0), // Now
        'activities': ['Ăn uống'],
        'locations': ['Nhà'],
        'sleepHours': 8.0,
      },
      {
        'userId': user.uid,
        'mood': 'Vui vẻ',
        'timestamp': ts(0, 2), // 2h ago
        'activities': ['Vui chơi'],
        'sleepHours': 8.0,
      },
      {
        'userId': user.uid,
        'mood': 'Căng thẳng',
        'timestamp': ts(0, 5), // 5h ago
        'activities': ['Làm việc'],
        'note': 'Hơi mệt chút.',
        'sleepHours': 8.0,
      },
      {
        'userId': user.uid,
        'mood': 'Giận dữ',
        'timestamp': ts(0, 8), // 8h ago
        'activities': ['Làm việc'],
        'note': 'Áp lực cao độ!',
        'sleepHours': 8.0,
      },
      {
        'userId': user.uid,
        'mood': 'Bình thường',
        'timestamp': ts(0, 12), // 12h ago
        'activities': ['Nghỉ ngơi'],
        'sleepHours': 8.0,
      },

      // --- YESTERDAY (23/03) ---
      {
        'userId': user.uid,
        'mood': 'Hạnh phúc',
        'timestamp': ts(1, 0),
        'activities': ['Gia đình'],
        'locations': ['Nhà'],
        'sleepHours': 7.0,
      },
      {
        'userId': user.uid,
        'mood': 'Hạnh phúc',
        'timestamp': ts(1, 4),
        'activities': ['Gia đình'],
        'sleepHours': 7.0,
      },

      // --- 2 DAYS AGO (22/03) ---
      {
        'userId': user.uid,
        'mood': 'Lo lắng',
        'timestamp': ts(2, 0),
        'activities': ['Trường học'],
        'sleepHours': 6.0,
      },

      // --- 3 DAYS AGO (21/03) ---
      {
        'userId': user.uid,
        'mood': 'Hạnh phúc',
        'timestamp': ts(3, 0),
        'activities': ['Bạn bè'],
        'sleepHours': 8.5,
      },

      // --- 4 DAYS AGO (20/03) ---
      {
        'userId': user.uid,
        'mood': 'Buồn',
        'timestamp': ts(4, 0),
        'activities': ['Cô đơn'],
        'sleepHours': 5.0,
      },

      // --- 5-7 DAYS AGO (Consistency) ---
      {
        'userId': user.uid,
        'mood': 'Bình thường',
        'timestamp': ts(5, 0),
        'activities': ['Vận động'],
        'sleepHours': 7.5,
      },
      {
        'userId': user.uid,
        'mood': 'Vui vẻ',
        'timestamp': ts(6, 0),
        'activities': ['Gia đình'],
        'sleepHours': 7.0,
      },
      {
        'userId': user.uid,
        'mood': 'Hạnh phúc',
        'timestamp': ts(7, 0),
        'activities': ['Thành công'],
        'sleepHours': 9.0,
      },
    ];

    print('Seeding rich test data for user: ${user.uid}');
    final batch = db.batch();
    for (var entry in testEntries) {
      final docRef = db.collection('journals').doc();
      batch.set(docRef, entry);
    }
    await batch.commit();
    print('Rich seeding complete!');
  }
}
