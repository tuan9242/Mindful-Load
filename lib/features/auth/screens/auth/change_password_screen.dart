import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindful_load/utils/notification_helper.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String _passwordStrength = 'Chưa nhập';
  Color _strengthColor = Colors.grey;
  double _strengthProgress = 0.0;

  void _checkPasswordStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordStrength = 'Chưa nhập';
        _strengthColor = Colors.grey;
        _strengthProgress = 0.0;
      } else if (value.length < 6) {
        _passwordStrength = 'Yếu';
        _strengthColor = Colors.red;
        _strengthProgress = 0.3;
      } else if (value.length < 10) {
        _passwordStrength = 'Trung bình';
        _strengthColor = Colors.orange;
        _strengthProgress = 0.6;
      } else {
        bool hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
        bool hasUpper = value.contains(RegExp(r'[A-Z]'));
        if (hasSpecial && hasUpper) {
          _passwordStrength = 'Mạnh';
          _strengthColor = Colors.green;
          _strengthProgress = 1.0;
        } else {
          _passwordStrength = 'Khá';
          _strengthColor = Colors.blue;
          _strengthProgress = 0.8;
        }
      }
    });
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showTopNotification('Lỗi', 'Mật khẩu xác nhận không khớp', true);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showTopNotification('Lỗi', 'Mật khẩu mới phải từ 6 ký tự', true);
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        if (mounted) {
          _showTopNotification('Thành công', 'Mật khẩu đã được thay đổi', false);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          _showTopNotification('Lỗi xác thực', 'Mật khẩu cũ không chính xác hoặc lỗi hệ thống', true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.white;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bảo mật tài khoản',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới để cập nhật.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            
            _buildPasswordField('Mật khẩu hiện tại', _oldPasswordController, _obscureOld, () {
              setState(() => _obscureOld = !_obscureOld);
            }, isDark),
            
            const SizedBox(height: 24),
            _buildPasswordField('Mật khẩu mới', _newPasswordController, _obscureNew, () {
              setState(() => _obscureNew = !_obscureNew);
            }, isDark, onChanged: _checkPasswordStrength),
            
            const SizedBox(height: 12),
            // Strength Meter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Độ mạnh mật khẩu:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                    Text(_passwordStrength, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _strengthColor)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _strengthProgress,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                  color: _strengthColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildPasswordField('Xác nhận mật khẩu mới', _confirmPasswordController, _obscureConfirm, () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            }, isDark),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleChangePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Cập nhật mật khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle, bool isDark, {Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
