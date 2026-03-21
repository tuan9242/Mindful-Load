import 'package:flutter/material.dart';
import 'package:mindful_load/core/theme/app_theme.dart';
import 'package:mindful_load/core/constants/app_constants.dart';
import 'package:mindful_load/features/interaction/screens/add_factor_screen.dart';

class AddDetailScreen extends StatefulWidget {
  final String selectedMood;
  const AddDetailScreen({super.key, required this.selectedMood});

  @override
  State<AddDetailScreen> createState() => _AddDetailScreenState();
}

class _AddDetailScreenState extends State<AddDetailScreen> {
  // Location selections
  final Set<String> _selectedLocations = {'Nhà'};

  // Activity selections
  final Set<String> _selectedActivities = {'Nghỉ ngơi'};

  // Companion selections
  final Set<String> _selectedCompanions = {'Bạn bè'};

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required Set<String> selected,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items.map((item) {
              final isSelected = selected.contains(item['label']);
              return _TagChip(
                label: item['label'],
                icon: item['icon'],
                isSelected: isSelected,
                onTap: () => onToggle(item['label']),
              );
            }),
            _AddChip(onTap: () {}),
          ],
        ),
      ],
    );
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
                      'Thêm chi tiết',
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điều gì đang ảnh hưởng\nđến bạn?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn nhiều yếu tố liên quan đến cảm xúc hiện tại.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildSection(
                      title: 'Đang ở đâu?',
                      icon: Icons.location_on_outlined,
                      items: AppConstants.locations,
                      selected: _selectedLocations,
                      onToggle: (label) {
                        setState(() {
                          if (_selectedLocations.contains(label)) {
                            _selectedLocations.remove(label);
                          } else {
                            _selectedLocations.add(label);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'Đang làm gì?',
                      icon: Icons.bolt_outlined,
                      items: AppConstants.activities,
                      selected: _selectedActivities,
                      onToggle: (label) {
                        setState(() {
                          if (_selectedActivities.contains(label)) {
                            _selectedActivities.remove(label);
                          } else {
                            _selectedActivities.add(label);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'Đang với ai?',
                      icon: Icons.people_outline,
                      items: AppConstants.companions,
                      selected: _selectedCompanions,
                      onToggle: (label) {
                        setState(() {
                          if (_selectedCompanions.contains(label)) {
                            _selectedCompanions.remove(label);
                          } else {
                            _selectedCompanions.add(label);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddFactorScreen(
                          selectedMood: widget.selectedMood,
                        ),
                      ),
                    );
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
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : AppTheme.textSecondary,
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

class _AddChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
