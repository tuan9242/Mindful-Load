import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:mindful_load/utils/dummy_data_seeder.dart';
import 'package:provider/provider.dart';
import 'package:mindful_load/core/state/app_state.dart';
import 'dart:io';
import 'package:mindful_load/features/auth/screens/auth/change_password_screen.dart';

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
  String? _localImagePath;
  JournalAnalytics? _analytics;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAnalytics();
    
    // Initialize local image from session state if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _localImagePath = Provider.of<AppState>(context, listen: false).localPhotoUrl;
        });
      }
    });
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _fetchBio(user.uid);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
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
          _analytics = JournalAnalytics(snapshot.docs.map((d) => d.data()).toList());
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) {
      return;
    }

    setState(() {
      _isUploading = true;
      _localImagePath = image.path;
    });
    
    // Persist to AppState for session-wide availability
    if (mounted) {
      Provider.of<AppState>(context, listen: false).setLocalPhotoUrl(image.path);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('${user.uid}.jpg');

      debugPrint('Starting upload for user: ${user.uid}');
      
      if (kIsWeb) {
        debugPrint('Reading image bytes (Web)...');
        final bytes = await image.readAsBytes().timeout(const Duration(seconds: 15), onTimeout: () => throw 'Hết thời gian đọc tệp (Web).');
        debugPrint('Bytes read: ${bytes.length}, starting putData...');
        await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg')).timeout(const Duration(seconds: 60));
      } else {
        debugPrint('Starting putFile (Mobile)...');
        await storageRef.putFile(File(image.path)).timeout(const Duration(seconds: 60));
      }
      
      debugPrint('Upload completed, getting URL...');
      final downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        _showTopNotification('Thành công', 'Đã cập nhật ảnh đại diện', false);
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase Error: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() => _isUploading = false);
        if (e.code == 'permission-denied') {
          debugPrint('Permission denied on upload. Using local preview.');
        }
      }
    } catch (e) {
      debugPrint('Upload Error/Timeout: $e');
      if (mounted) {
        setState(() => _isUploading = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTopNotification(String title, String message, bool isError) {
    if (!mounted) {
      return;
    }
    NotificationHelper.showTopNotification(context, title, message, isError);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
                        BoxShadow(color: const Color(0xFF135BEC).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: context.watch<AppState>().localPhotoUrl != null 
                          ? (kIsWeb ? NetworkImage(context.watch<AppState>().localPhotoUrl!) : FileImage(File(context.watch<AppState>().localPhotoUrl!)) as ImageProvider)
                          : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null),
                      child: (user?.photoURL == null && context.watch<AppState>().localPhotoUrl == null && !_isUploading) 
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : (_isUploading ? const CircularProgressIndicator() : null),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
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
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
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
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/change-password'),
              icon: const Icon(Icons.lock_reset, color: Color(0xFF135BEC)),
              label: const Text('thay đổi mật khẩu', style: TextStyle(fontSize: 16, color: Color(0xFF135BEC))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: Color(0xFF135BEC)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                try {
                  await DummyDataSeeder.seedTestData();
                  await _fetchAnalytics(); // Refresh
                  if (mounted) {
                    _showTopNotification('Thành công', 'Đã nạp dữ liệu mẫu cho tài khoản test này!', false);
                  }
                } catch (e) {
                  if (mounted) {
                    _showTopNotification('Lỗi', e.toString(), true);
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: Color(0xFF135BEC)),
              ),
              child: const Text('Nạp dữ liệu mẫu Test', style: TextStyle(fontSize: 16, color: Color(0xFF135BEC))),
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
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
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
