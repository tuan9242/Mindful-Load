import 'package:flutter/material.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/core/constants/app_constants.dart';

class AddFactorScreen extends StatefulWidget {
  final String selectedMood;
  const AddFactorScreen({super.key, required this.selectedMood});

  @override
  State<AddFactorScreen> createState() => _AddFactorScreenState();
}

class _AddFactorScreenState extends State<AddFactorScreen> {
  final Set<String> _selected = {'Công việc', 'Tiền bạc'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceCard,
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppTheme.textPrimary, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Thêm Tác nhân',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: AppTheme.borderColor),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điều gì đang diễn ra?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn các tác nhân ảnh hưởng đến tâm trạng của bạn để chúng tôi có thể phân tích chính xác hơn.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tác nhân phổ biến',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppConstants.factors.map((f) {
                        final isSelected = _selected.contains(f['label']);
                        return _FactorChip(
                          label: f['label'],
                          icon: f['icon'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (_selected.contains(f['label'])) {
                                _selected.remove(f['label']);
                              } else {
                                _selected.add(f['label']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Done button
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home or summary
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
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
                            'Hoàn tất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Tâm An sẽ sử dụng thông tin này để cá nhân hoá gợi ý cho bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FactorChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
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
