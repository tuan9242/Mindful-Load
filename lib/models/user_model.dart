import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String avatarUrl;
  final int level;
  final int currentExp;
  final List<String> badges;
  final bool isFirstTime;
  final DateTime createdAt;
  final String sosContact;
  final int streakCount;
  final int totalCheckins;
  final DateTime? lastActive;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.avatarUrl,
    required this.level,
    required this.currentExp,
    required this.badges,
    required this.isFirstTime,
    required this.createdAt,
    required this.sosContact,
    this.streakCount = 0,
    this.totalCheckins = 0,
    this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'level': level,
      'current_exp': currentExp,
      'badges': badges,
      'is_first_time': isFirstTime,
      'created_at': Timestamp.fromDate(createdAt),
      'sos_contact': sosContact,
      'streak_count': streakCount,
      'total_checkins': totalCheckins,
      'last_active': lastActive != null
          ? Timestamp.fromDate(lastActive!)
          : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nickname: map['nickname'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      level: map['level']?.toInt() ?? 1,
      currentExp: map['current_exp']?.toInt() ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      isFirstTime: map['is_first_time'] ?? true,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      sosContact: map['sos_contact'] ?? '',
      streakCount: map['streak_count']?.toInt() ?? 0,
      totalCheckins: map['total_checkins']?.toInt() ?? 0,
      lastActive: map['last_active'] != null
          ? (map['last_active'] as Timestamp).toDate()
          : null,
    );
  }
}
