class TagModel {
  final String tagId;
  final String userId;
  final String name;
  final String category;
  final String colorHex;
  final int priority;
  final bool isActive;
  final String iconName;
  final bool isBaseline;

  TagModel({
    required this.tagId,
    required this.userId,
    required this.name,
    required this.category,
    required this.colorHex,
    required this.priority,
    required this.isActive,
    required this.iconName,
    required this.isBaseline,
  });

  Map<String, dynamic> toMap() {
    return {
      'tag_id': tagId,
      'user_id': userId,
      'name': name,
      'category': category,
      'color_hex': colorHex,
      'priority': priority,
      'is_active': isActive,
      'icon_name': iconName,
      'is_baseline': isBaseline,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      tagId: map['tag_id'] ?? '',
      userId: map['user_id'] ?? 'system',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      colorHex: map['color_hex'] ?? '#000000',
      priority: map['priority']?.toInt() ?? 0,
      isActive: map['is_active'] ?? true,
      iconName: map['icon_name'] ?? '',
      isBaseline: map['is_baseline'] ?? false,
    );
  }
}
