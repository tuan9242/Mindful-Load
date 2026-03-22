import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'dart:io';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploading = false;
  JournalAnalytics? _analytics;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAnalytics();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      // Bio would normally come from a separate user document in Firestore
      _fetchBio(user.uid);
    }
  }

  Future<void> _fetchBio(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _bioController.text = doc.data()?['bio'] ?? '';
      });
    }
  }

  Future<void> _fetchAnalytics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('journals')
          .where('userId', isEqualTo: user.uid)
          .get();
      if (mounted) {
        setState(() {
          _analytics = JournalAnalytics(snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList());
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return;

    setState(() => _isUploading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('${user.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        _showTopNotification('Thành công', 'Đã cập nhật ảnh đại diện', false);
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification('Lỗi tải ảnh', e.toString(), true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (_nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        _showTopNotification('Thành công', 'Hồ sơ đã được cập nhật', false);
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification('Lỗi cập nhật', e.toString(), true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTopNotification(String title, String message, bool isError) {
    NotificationHelper.showTopNotification(context, title, message, isError);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textMuted = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final borderColor = theme.dividerColor;
    
    final user = FirebaseAuth.instance.currentUser;
    final levelData = _analytics?.calculateLevel() ?? {'level': 1, 'progress': 0.0};
    final int level = levelData['level'];
    final double xpProgress = levelData['progress'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF135BEC), width: 3),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF135BEC).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: (user?.photoURL == null && !_isUploading) 
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : (_isUploading ? const CircularProgressIndicator() : null),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF135BEC), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'Chưa đặt tên', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Cấp độ $level • Chiến binh Tâm An', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w600)),
            
            const SizedBox(height: 24),
            // XP Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2333) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kinh nghiệm (XP)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${(xpProgress * 100).toInt()}%', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            // Form Fields
            _buildField('Họ và tên', _nameController, Icons.person_outline, isDark),
            _buildField('Email', _emailController, Icons.email_outlined, isDark, enabled: false),
            _buildField('Giới thiệu bản thân', _bioController, Icons.info_outline, isDark, maxLines: 3),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF135BEC),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/change-password'),
              child: const Text('Đổi mật khẩu?', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, bool isDark, {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1C2333) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
