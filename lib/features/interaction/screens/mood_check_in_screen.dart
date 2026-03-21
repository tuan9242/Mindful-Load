import 'package:flutter/material.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/core/constants/app_constants.dart';
import 'package:mindful_load/features/interaction/screens/add_detail_screen.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  String? _selectedMood;

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm',
      'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
    ];
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.self_improvement,
                      color: AppTheme.primary, size: 24),
                  Column(
                    children: [
                      const Text(
                        'Tâm An',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getFormattedDate(),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceCard,
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: AppTheme.textSecondary, size: 18),
                  ),
                ],
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'Bạn đang cảm thấy\nthế nào?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy lắng nghe cơ thể và tâm trí bạn ngay lúc này.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Mood grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: AppConstants.moods.map((mood) {
                    final isSelected = _selectedMood == mood['label'];
                    return _MoodCard(
                      emoji: mood['emoji'],
                      label: mood['label'],
                      color: mood['color'],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedMood = mood['label']);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            // Angry mood (bottom single)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _MoodCard(
                emoji: AppConstants.angryMood['emoji'],
                label: AppConstants.angryMood['label'],
                color: AppConstants.angryMood['color'],
                isSelected: _selectedMood == AppConstants.angryMood['label'],
                onTap: () {
                  setState(() => _selectedMood = AppConstants.angryMood['label']);
                },
                fullWidth: true,
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedMood != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDetailScreen(
                                selectedMood: _selectedMood!,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor:
                        AppTheme.primary.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primary.withOpacity(0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _MoodCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.6) : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
