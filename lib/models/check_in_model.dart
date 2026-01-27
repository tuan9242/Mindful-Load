import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String checkinId;
  final String userId;
  final int moodScore;
  final String moodName;
  final List<String> tags;
  final String note;
  final DateTime timestamp;
  final String contextLocation;
  final String contextEvent;
  final String triggerType;
  final bool isAnalyzed;

  CheckInModel({
    required this.checkinId,
    required this.userId,
    required this.moodScore,
    required this.moodName,
    required this.tags,
    required this.note,
    required this.timestamp,
    required this.contextLocation,
    required this.contextEvent,
    required this.triggerType,
    this.isAnalyzed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkin_id': checkinId,
      'user_id': userId,
      'mood_score': moodScore,
      'mood_name': moodName,
      'tags': tags,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'context_location': contextLocation,
      'context_event': contextEvent,
      'trigger_type': triggerType,
      'is_analyzed': isAnalyzed,
    };
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map) {
    return CheckInModel(
      checkinId: map['checkin_id'] ?? '',
      userId: map['user_id'] ?? '',
      moodScore: map['mood_score']?.toInt() ?? 0,
      moodName: map['mood_name'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      note: map['note'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      contextLocation: map['context_location'] ?? '',
      contextEvent: map['context_event'] ?? '',
      triggerType: map['trigger_type'] ?? 'manual',
      isAnalyzed: map['is_analyzed'] ?? false,
    );
  }
}
