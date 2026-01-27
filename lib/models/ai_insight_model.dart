import 'package:cloud_firestore/cloud_firestore.dart';

class AiInsightModel {
  final String insightId;
  final String userId;
  final String type;
  final String title;
  final String content;
  final String relatedTagId;
  final DateTime createdAt;

  AiInsightModel({
    required this.insightId,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.relatedTagId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'insight_id': insightId,
      'user_id': userId,
      'type': type,
      'title': title,
      'content': content,
      'related_tag_id': relatedTagId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory AiInsightModel.fromMap(Map<String, dynamic> map) {
    return AiInsightModel(
      insightId: map['insight_id'] ?? '',
      userId: map['user_id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      relatedTagId: map['related_tag_id'] ?? '',
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }
}
