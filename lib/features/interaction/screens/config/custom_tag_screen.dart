import 'package:flutter/material.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:mindful_load/core/constants/app_constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomTagScreen extends StatefulWidget {
  const CustomTagScreen({super.key});

  @override
  State<CustomTagScreen> createState() => _CustomTagScreenState();
}

class _CustomTagScreenState extends State<CustomTagScreen> {
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _checkAndMigrateTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAndMigrateTags() async {
    if (_userId == null) return;
    
    // Check if context is available for theme
    if (!mounted) return;
    final primaryColorValue = Theme.of(context).primaryColor.toARGB32();

    setState(() => _isMigrating = true);
    try {
      final snapshot = await _firestore
          .collection('user_tags')
          .where('userId', isEqualTo: _userId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty && mounted) {
        // Migrate defaults
        final batch = _firestore.batch();
        
        final allDefaults = [
          ...AppConstants.locations.map((e) => {...e, 'category': 'Địa điểm'}),
          ...AppConstants.activities.map((e) => {...e, 'category': 'Hoạt động'}),
          ...AppConstants.companions.map((e) => {...e, 'category': 'Người'}),
        ];

        for (var tag in allDefaults) {
          final docRef = _firestore.collection('user_tags').doc();
          batch.set(docRef, {
            'userId': _userId,
            'label': tag['label'],
            'category': tag['category'],
            'iconCode': (tag['icon'] as IconData).codePoint,
            'colorValue': primaryColorValue,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint("Error migrating tags: $e");
    } finally {
      if (mounted) setState(() => _isMigrating = false);
    }
  }

  void _showAddEditTagDialog({Map<String, dynamic>? existingTag}) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final tagController = TextEditingController(
      text: existingTag?['label'] ?? '',
    );
    String category =
        existingTag?['category'] ??
        (_selectedCategory == 'Tất cả' ? 'Hoạt động' : _selectedCategory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existingTag == null ? 'Thêm nhãn mới' : 'Sửa nhãn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Danh mục',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Địa điểm', 'Hoạt động', 'Người'].map((cat) {
                  final isSel = category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setModalState(() => category = cat);
                      },
                      selectedColor: primaryColor.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSel ? primaryColor : theme.hintColor,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Tên nhãn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagController,
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhãn...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final label = tagController.text.trim();
                    if (label.isEmpty) {
                      if (context.mounted) {
                        NotificationHelper.showTopNotification(context, 'Lỗi', 'Tên nhãn không được để trống', true);
                      }
                      return;
                    }
                    if (_userId == null) return;
                    
                    final data = {
                      'userId': _userId,
                      'label': label,
                      'category': category,
                      'iconCode': category == 'Địa điểm' 
                          ? Icons.location_on.codePoint 
                          : (category == 'Hoạt động' ? Icons.bolt.codePoint : Icons.people.codePoint),
                      'colorValue': primaryColor.toARGB32(),
                    };

                    if (existingTag == null) {
                      _firestore.collection('user_tags').add(data);
                    } else {
                      _firestore.collection('user_tags').doc(existingTag['id']).update(data);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      NotificationHelper.showTopNotification(context, 'Thành công', 'Đã lưu nhãn', false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Lưu nhãn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestoreConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục nhãn?'),
        content: const Text('Tất cả nhãn mặc định sẽ được thêm lại vào danh sách của bạn. Các nhãn bạn đã thêm vẫn được giữ nguyên.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreDefaults() async {
    if (_userId == null) return;
    
    if (!mounted) return;
    final primaryColorValue = Theme.of(context).primaryColor.toARGB32();

    setState(() => _isMigrating = true);
    try {
      final batch = _firestore.batch();
      final allDefaults = [
        ...AppConstants.locations.map((e) => {...e, 'category': 'Địa điểm'}),
        ...AppConstants.activities.map((e) => {...e, 'category': 'Hoạt động'}),
        ...AppConstants.companions.map((e) => {...e, 'category': 'Người'}),
      ];

      final existingSnapshot = await _firestore
          .collection('user_tags')
          .where('userId', isEqualTo: _userId)
          .get();
      final existingLabels = existingSnapshot.docs.map((d) => (d.data())['label'] as String).toSet();

      int addedCount = 0;
      for (var tag in allDefaults) {
        if (!existingLabels.contains(tag['label'])) {
          final docRef = _firestore.collection('user_tags').doc();
          batch.set(docRef, {
            'userId': _userId,
            'label': tag['label'],
            'category': tag['category'],
            'iconCode': (tag['icon'] as IconData).codePoint,
            'colorValue': primaryColorValue,
          });
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
        if (mounted) {
          NotificationHelper.showTopNotification(context, 'Thành công', 'Đã khôi phục $addedCount nhãn mặc định.', false);
        }
      } else {
        if (mounted) {
          NotificationHelper.showTopNotification(context, 'Thông báo', 'Bạn đã có đầy đủ các nhãn mặc định.', false);
        }
      }
    } catch (e) {
      debugPrint("Error restoring tags: $e");
      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Lỗi', 'Không thể khôi phục nhãn. Vui lòng thử lại.', true);
      }
    } finally {
      if (mounted) setState(() => _isMigrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: theme.cardColor,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(Icons.arrow_back, color: textColor, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tùy chỉnh Tag',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Quản lý danh mục cảm xúc của bạn',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.restore, color: theme.hintColor, size: 20),
                    tooltip: 'Khôi phục mặc định',
                    onPressed: () => _showRestoreConfirmDialog(),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAddEditTagDialog(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Thêm mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nhãn...',
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(Icons.search, color: theme.hintColor, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),

            // Category filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: ['Tất cả', 'Địa điểm', 'Hoạt động', 'Người'].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? primaryColor : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? primaryColor : theme.dividerColor,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSel ? Colors.white : theme.hintColor,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // List of tags
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('user_tags')
                    .where('userId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isMigrating) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.label_off_outlined, color: theme.hintColor, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có nhãn nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final queryText = _searchController.text.toLowerCase();
                  var tags = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {...data, 'id': doc.id};
                  }).toList();

                  if (_selectedCategory != 'Tất cả') {
                    tags = tags.where((t) => t['category'] == _selectedCategory).toList();
                  }
                  if (queryText.isNotEmpty) {
                    tags = tags.where((t) => t['label'].toString().toLowerCase().contains(queryText)).toList();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return _buildTagItem(
                        context: context,
                        tag: tag,
                        onDelete: () {
                          _firestore.collection('user_tags').doc(tag['id']).delete();
                        },
                        onEdit: () => _showAddEditTagDialog(existingTag: tag),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagItem({
    required BuildContext context,
    required Map<String, dynamic> tag,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(tag['iconCode'], fontFamily: 'MaterialIcons'),
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag['label'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  tag['category'],
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.hintColor, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa nhãn?'),
                  content: Text('Bạn có chắc muốn xóa nhãn "${tag['label']}" không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
