import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:mindful_load/core/constants/app_constants.dart';

class AddDetailScreen extends StatefulWidget {
  final String selectedMood;
  final VoidCallback? onCloseAction;
  final VoidCallback? onCompletedAction;
  
  final bool isOnboarding;
  
  const AddDetailScreen({
    super.key, 
    required this.selectedMood,
    this.onCloseAction,
    this.onCompletedAction,
    this.isOnboarding = false,
  });

  @override
  State<AddDetailScreen> createState() => _AddDetailScreenState();
}

class _AddDetailScreenState extends State<AddDetailScreen> {
  final Set<String> _selectedLocations = {};
  final Set<String> _selectedActivities = {};
  final Set<String> _selectedCompanions = {};
  
  final TextEditingController _noteController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _userTags = [];
  double _sleepHours = 7.0;

  @override
  void initState() {
    super.initState();
    _fetchUserTags();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserTags() async {
    if (_userId == null) {
      return;
    }
    try {
      final snapshot = await _firestore.collection('user_tags').where('userId', isEqualTo: _userId).get();
      if (mounted) {
        setState(() {
          _userTags = snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching tags: $e");
    }
  }

  Future<void> _saveEntry() async {
    if (_userId == null) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('journals').add({
        'userId': _userId,
        'mood': widget.selectedMood,
        'locations': _selectedLocations.toList(),
        'activities': _selectedActivities.toList(),
        'companions': _selectedCompanions.toList(),
        'note': _noteController.text.trim(),
        'sleepHours': _sleepHours,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': _userId,
        'title': 'Ghi chép thành công',
        'message': 'Cảm ơn bạn đã chia sẻ cảm xúc: ${widget.selectedMood}. Chúc bạn có những phút giây bình an!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Thành công', 'Đã lưu cảm xúc của bạn', false);
        if (widget.onCompletedAction != null) {
          widget.onCompletedAction!();
        } else {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Lỗi', 'Không thể lưu: $e', true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredTags(String category, List<Map<String, dynamic>> defaults) {
    final List<Map<String, dynamic>> results = [];
    final Set<String> addedLabels = {};
    
    for (var item in defaults) {
      if (addedLabels.add(item['label'])) {
        results.add(item);
      }
    }
    
    for (var tag in _userTags) {
      if (tag['category'] == category) {
        final String label = tag['label'];
        if (addedLabels.add(label)) {
          results.add({
            'label': label,
            'icon': tag.containsKey('iconCode') ? IconData(tag['iconCode'], fontFamily: 'MaterialIcons') : Icons.label_outline,
          });
        }
      }
    }
    return results;
  }

  void _showAddTagDialog(String category) {
    String newTagText = "";
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Thêm $category mới', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: TextField(
            autofocus: true,
            onChanged: (val) => newTagText = val,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Nhập tên $category...',
              hintStyle: TextStyle(color: theme.hintColor),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: theme.hintColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              onPressed: () async {
                final tagLabel = newTagText.trim();
                if (tagLabel.length < 2) {
                  NotificationHelper.showTopNotification(context, 'Nhãn quá ngắn', 'Tên nhãn phải có ít nhất 2 ký tự', true);
                  return;
                }
                if (RegExp(r'^(.)\1+$').hasMatch(tagLabel)) {
                   NotificationHelper.showTopNotification(context, 'Nhãn không hợp lệ', 'Vui lòng nhập tên nhãn có ý nghĩa', true);
                   return;
                }

                if (_userId == null) {
                  return;
                }
                try {
                  await _firestore.collection('user_tags').add({
                    'userId': _userId,
                    'label': tagLabel,
                    'category': category,
                    'iconCode': category == 'Địa điểm' 
                        ? Icons.location_on.codePoint 
                        : (category == 'Hoạt động' ? Icons.bolt.codePoint : Icons.people.codePoint),
                    'colorValue': theme.primaryColor.toARGB32(),
                   });
                  
                  if (mounted) {
                    setState(() {
                      if (category == 'Địa điểm') {
                        _selectedLocations.add(tagLabel);
                      } else if (category == 'Hoạt động') {
                        _selectedActivities.add(tagLabel);
                      } else if (category == 'Người') {
                        _selectedCompanions.add(tagLabel);
                      }
                    });
                    _fetchUserTags();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                } catch (e) {
                  debugPrint("Error adding tag: $e");
                  if (context.mounted) {
                    NotificationHelper.showTopNotification(context, 'Lỗi', 'Không thể thêm nhãn: $e', true);
                  }
                }
              },
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      }
    );
  }

  Widget _buildWellnessSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bedtime_outlined, color: theme.primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              'Giấc ngủ & Năng lượng',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Số giờ ngủ: ${_sleepHours.toStringAsFixed(1)} giờ',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        Slider(
          value: _sleepHours,
          min: 0,
          max: 12,
          divisions: 24,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withValues(alpha: 0.3),
          onChanged: (value) {
            setState(() {
              _sleepHours = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> customItems,
    required Set<String> selected,
    required Function(String) onToggle,
    required VoidCallback onAdd,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
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
            ...[...items, ...customItems].map((item) {
              final isSelected = selected.contains(item['label']);
              return _TagChip(
                label: item['label'],
                icon: item['icon'],
                isSelected: isSelected,
                onTap: () => onToggle(item['label']),
              );
            }),
            _AddChip(onTap: onAdd),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                        color: theme.cardColor,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(Icons.arrow_back, color: textColor, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Thêm chi tiết',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Container(height: 1, color: theme.dividerColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điều gì đang ảnh hưởng\nđến bạn?',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chọn nhiều yếu tố liên quan đến cảm xúc hiện tại.',
                      style: TextStyle(color: secondaryTextColor, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      context: context,
                      title: 'Đang ở đâu?',
                      icon: Icons.location_on_outlined,
                      items: _getFilteredTags('Địa điểm', AppConstants.locations),
                      customItems: [],
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
                      onAdd: () => _showAddTagDialog('Địa điểm'),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context: context,
                      title: 'Đang làm gì?',
                      icon: Icons.bolt_outlined,
                      items: _getFilteredTags('Hoạt động', AppConstants.activities),
                      customItems: [],
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
                      onAdd: () => _showAddTagDialog('Hoạt động'),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context: context,
                      title: 'Đang với ai?',
                      icon: Icons.people_outline,
                      items: _getFilteredTags('Người', AppConstants.companions),
                      customItems: [],
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
                      onAdd: () => _showAddTagDialog('Người'),
                    ),
                    const SizedBox(height: 24),
                    _buildWellnessSection(theme),
                    const SizedBox(height: 32),
                    Text(
                      'Ghi chú thêm',
                      style: TextStyle(color: theme.primaryColor, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Hôm nay bạn thấy thế nào? Hãy viết ra vài dòng nhé...',
                        hintStyle: TextStyle(color: theme.hintColor),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hoàn tất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  const _TagChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? theme.primaryColor.withValues(alpha: 0.8) : theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(Icons.add, size: 14, color: theme.hintColor),
      ),
    );
  }
}
