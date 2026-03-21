import 'package:flutter/material.dart';

class AppConstants {
  // Mood Data
  static const List<Map<String, dynamic>> moods = [
    {'label': 'Hạnh phúc', 'emoji': '😊', 'color': Color(0xFFFFD700)},
    {'label': 'Vui', 'emoji': '😄', 'color': Color(0xFF4CAF50)},
    {'label': 'Bình thường', 'emoji': '😐', 'color': Color(0xFF90A4AE)},
    {'label': 'Buồn', 'emoji': '😢', 'color': Color(0xFF5C6BC0)},
    {'label': 'Lo lắng', 'emoji': '😟', 'color': Color(0xFFFF9800)},
    {'label': 'Căng thẳng', 'emoji': '😤', 'color': Color(0xFFFF5722)},
  ];

  static const Map<String, dynamic> angryMood = {
    'label': 'Giận dữ',
    'emoji': '😡',
    'color': Color(0xFFE53935)
  };

  // Location Data
  static const List<Map<String, dynamic>> locations = [
    {'label': 'Nhà', 'icon': Icons.home_outlined},
    {'label': 'Công ty', 'icon': Icons.business_outlined},
    {'label': 'Trường học', 'icon': Icons.school_outlined},
    {'label': 'Ngoài trời', 'icon': Icons.park_outlined},
  ];

  // Activity Data
  static const List<Map<String, dynamic>> activities = [
    {'label': 'Làm việc', 'icon': Icons.laptop_outlined},
    {'label': 'Nghỉ ngơi', 'icon': Icons.weekend_outlined},
    {'label': 'Ăn uống', 'icon': Icons.restaurant_outlined},
    {'label': 'Di chuyển', 'icon': Icons.directions_car_outlined},
    {'label': 'Tập thể dục', 'icon': Icons.fitness_center_outlined},
  ];

  // Companion Data
  static const List<Map<String, dynamic>> companions = [
    {'label': 'Một mình', 'icon': Icons.person_outline},
    {'label': 'Gia đình', 'icon': Icons.family_restroom_outlined},
    {'label': 'Bạn bè', 'icon': Icons.group_outlined},
    {'label': 'Đồng nghiệp', 'icon': Icons.work_outlined},
  ];

  // Factor Data
  static const List<Map<String, dynamic>> factors = [
    {'label': 'Công việc', 'icon': Icons.laptop_mac_outlined},
    {'label': 'Tiền bạc', 'icon': Icons.attach_money},
    {'label': 'Tình cảm', 'icon': Icons.favorite_outline},
    {'label': 'Sức khỏe', 'icon': Icons.health_and_safety_outlined},
    {'label': 'Gia đình', 'icon': Icons.family_restroom_outlined},
    {'label': 'Học tập', 'icon': Icons.school_outlined},
    {'label': 'Thời tiết', 'icon': Icons.wb_sunny_outlined},
    {'label': 'Giao thông', 'icon': Icons.directions_car_outlined},
    {'label': 'Ăn uống', 'icon': Icons.restaurant_outlined},
    {'label': 'Giấc ngủ', 'icon': Icons.nights_stay_outlined},
    {'label': 'Khác', 'icon': Icons.add_circle_outline},
  ];

  // Custom Tag Categories
  static const List<String> tagCategories = [
    'Tất cả',
    'Hoạt động',
    'Người',
    'Địa điểm'
  ];

  // Initial Custom Tags
  static const List<Map<String, dynamic>> initialCustomTags = [
    {
      'label': 'Công việc',
      'subtitle': 'Hoạt động',
      'icon': Icons.laptop_mac_outlined,
      'color': Color(0xFF2563EB),
      'category': 'Hoạt động',
    },
    {
      'label': 'Tập Gym',
      'subtitle': 'Sức khỏe',
      'icon': Icons.fitness_center_outlined,
      'color': Color(0xFFE67E22),
      'category': 'Hoạt động',
    },
    {
      'label': 'Gia đình',
      'subtitle': 'Người thân',
      'icon': Icons.family_restroom_outlined,
      'color': Color(0xFF27AE60),
      'category': 'Người',
    },
    {
      'label': 'Nhà riêng',
      'subtitle': 'Địa điểm',
      'icon': Icons.home_outlined,
      'color': Color(0xFF8E44AD),
      'category': 'Địa điểm',
    },
    {
      'label': 'Kẹt xe',
      'subtitle': 'Môi trường',
      'icon': Icons.traffic_outlined,
      'color': Color(0xFFE74C3C),
      'category': 'Hoạt động',
    },
    {
      'label': 'Hẹn hò',
      'subtitle': 'Mối quan hệ',
      'icon': Icons.favorite_outline,
      'color': Color(0xFFE91E8C),
      'category': 'Người',
    },
  ];
}
