class BadgeModel {
  final String badgeId;
  final String badgeName;
  final String description;
  final String iconUrl;
  final int requiredCheckins;

  BadgeModel({
    required this.badgeId,
    required this.badgeName,
    required this.description,
    required this.iconUrl,
    required this.requiredCheckins,
  });

  Map<String, dynamic> toMap() {
    return {
      'badge_id': badgeId,
      'badge_name': badgeName,
      'description': description,
      'icon_url': iconUrl,
      'required_checkins': requiredCheckins,
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      badgeId: map['badge_id'] ?? '',
      badgeName: map['badge_name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['icon_url'] ?? '',
      requiredCheckins: map['required_checkins']?.toInt() ?? 0,
    );
  }
}
