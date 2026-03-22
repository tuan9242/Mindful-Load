import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_load/utils/notification_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      NotificationHelper.showTopNotification(context, 'Lưu ý', 'Vui lòng nhập Email và Mật khẩu!', true);
      return;
    }
    if (_passwordController.text.length < 6) {
      NotificationHelper.showTopNotification(context, 'Lưu ý', 'Mật khẩu quá yếu! Hãy nhập tối thiểu 6 ký tự.', true);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      NotificationHelper.showTopNotification(context, 'Lỗi xác nhận', 'Mật khẩu xác nhận không khớp!', true);
      return;
    }
    if (!_agreedToTerms) {
      NotificationHelper.showTopNotification(context, 'Lưu ý', 'Bạn phải đồng ý với Điều khoản và Chính sách!', true);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (cred.user != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'email': cred.user!.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          debugPrint('Lỗi khi lưu thông tin user vào Firestore: $firestoreError');
        }
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/interaction-welcome', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'Đăng ký thất bại';
        if (e.code == 'email-already-in-use') {
          msg = 'Email này đã được sử dụng. Hãy thử đăng nhập!';
        } else if (e.code == 'weak-password') {
          msg = 'Mật khẩu quá yếu.';
        } else if (e.code == 'invalid-email') {
          msg = 'Email không hợp lệ.';
        } else {
          msg = e.message ?? msg;
        }
        NotificationHelper.showTopNotification(context, 'Đăng ký thất bại', msg, true);
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Lỗi hệ thống', 'Đã có lỗi xảy ra: $e', true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final inputBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, bgColor),

            // Main Content Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Form Fields
                  _buildForm(
                    primaryColor,
                    inputBgColor,
                    borderColor,
                    textColor,
                    secondaryTextColor,
                  ),

                  // Divider
                  _buildDivider(borderColor, secondaryTextColor),

                  // Social Buttons
                  _buildSocialButtons(
                    surfaceColor,
                    borderColor,
                    textColor,
                  ),

                  // Login Prompt
                  _buildLoginPrompt(primaryColor, secondaryTextColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color bgColor) {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCwUmiaiE88PPdsTtrl7ClDmfXjkBwiHtH1iTBMMFeoYfWSJWgEKmsYr7Ec-743pz2xnitPI8vDYgfeMHXVkoUpQLnInwK2SBFw6qoy6bLuY1_ung1RY1uRKLlcSk-EuxZE079_M711pcHVHXyvn-3eswswbofsWF0ciri1a-u_a_LlvQ_qiwl4ybsRHA81WAqB7qJPsLMGQx_hqjWpgZuOGTramIhYM6dRo3jh3GLVArqHSQo13Wlv_PW8aiMJ_ZNvdAkj2ruRWw'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF135BEC).withOpacity(0.2),
                  bgColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Container(
                     height: 64,
                     width: 64,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.white.withOpacity(0.1),
                       border: Border.all(color: Colors.white.withOpacity(0.2)),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.1),
                           blurRadius: 10,
                           spreadRadius: 2,
                         ),
                       ],
                     ),
                     child: const Icon(Icons.spa, color: Colors.white, size: 36),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     'Tạo tài khoản',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 30,
                       fontWeight: FontWeight.bold,
                       letterSpacing: -0.5,
                     ),
                   ),
                   const SizedBox(height: 4),
                   const Text(
                     'Bắt đầu hành trình cân bằng cảm xúc của bạn',
                     style: TextStyle(
                       color: Color(0xFFD1D5DB),
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
             padding: const EdgeInsets.only(left: 8.0, top: 8.0),
             child: IconButton(
               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
               onPressed: () {
                 if (Navigator.canPop(context)) {
                   Navigator.pop(context);
                 }
               },
             ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(
    Color primaryColor,
    Color inputBgColor,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputFieldLabel('Email', textColor),
        TextField(
          controller: _emailController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            hintText: 'nhap@email.com',
            surfaceColor: inputBgColor,
            borderColor: borderColor,
            primaryColor: primaryColor,
            secondaryTextColor: secondaryTextColor,
            suffixIcon: Icon(Icons.mail_outline, color: secondaryTextColor),
          ),
        ),
        const SizedBox(height: 16),

        _buildInputFieldLabel('Mật khẩu', textColor),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            hintText: '••••••••',
            surfaceColor: inputBgColor,
            borderColor: borderColor,
            primaryColor: primaryColor,
            secondaryTextColor: secondaryTextColor,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildInputFieldLabel('Xác nhận mật khẩu', textColor),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            hintText: '••••••••',
            surfaceColor: inputBgColor,
            borderColor: borderColor,
            primaryColor: primaryColor,
            secondaryTextColor: secondaryTextColor,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                activeColor: primaryColor,
                side: BorderSide(color: secondaryTextColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreedToTerms = !_agreedToTerms;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Tôi đồng ý với ',
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Điều khoản & Chính sách',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: primaryColor.withOpacity(0.3),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading 
            ? const SizedBox(
                height: 24, width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
            : const Text(
                'Đăng ký',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
        ),
      ],
    );
  }

  Widget _buildInputFieldLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required Color surfaceColor,
    required Color borderColor,
    required Color primaryColor,
    required Color secondaryTextColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: secondaryTextColor),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }

  Widget _buildDivider(Color borderColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: borderColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hoặc đăng ký với',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
          ),
          Expanded(child: Divider(color: borderColor)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: surfaceColor,
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.g_mobiledata, color: textColor, size: 24),
            label: Text(
              'Google',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: surfaceColor,
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.apple, color: textColor, size: 24),
            label: Text(
              'Apple',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(Color primaryColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã có tài khoản? ',
            style: TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
