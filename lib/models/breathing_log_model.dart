import 'package:cloud_firestore/cloud_firestore.dart';

class BreathingLogModel {
  final String sessionId;
  final String userId;
  final int durationSeconds;
  final DateTime timestamp;

  BreathingLogModel({
    required this.sessionId,
    required this.userId,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'duration_seconds': durationSeconds,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory BreathingLogModel.fromMap(Map<String, dynamic> map) {
    return BreathingLogModel(
      sessionId: map['session_id'] ?? '',
      userId: map['user_id'] ?? '',
      durationSeconds: map['duration_seconds']?.toInt() ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
