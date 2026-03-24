import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindful_load/utils/notification_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      NotificationHelper.showTopNotification(
        context,
        'Lưu ý',
        'Vui lòng nhập Email và Mật khẩu!',
        true,
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'Đăng nhập thất bại';
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          msg = 'Tài khoản không tồn tại.';
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          msg = 'Sai email hoặc mật khẩu.';
        } else {
          msg = e.message ?? msg;
        }
        NotificationHelper.showTopNotification(
          context,
          'Đăng nhập thất bại',
          msg,
          true,
        );
      }
    } catch (e) {
      debugPrint('Login Error (Platform/Firebase): $e');
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          'Lỗi hệ thống',
          'Đã có lỗi xảy ra: $e',
          true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      const String? webClientId = null; // USER: Paste your Client ID here
      
      if (kIsWeb && webClientId == null) {
        throw 'Vui lòng cấu hình Google Client ID cho Web trong file login_screen.dart (dòng ~90) để sử dụng tính năng này.';
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: webClientId,
      ).signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      debugPrint('Google Login Error: $e');
      if (mounted) {
        NotificationHelper.showTopNotification(
          context,
          'Lỗi',
          'Đăng nhập Google thất bại: $e',
          true,
        );
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
    final inputBgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, bgColor),

            // Main Content Container
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Fields
                  _buildForm(
                    primaryColor,
                    inputBgColor,
                    borderColor,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 32),

                  // Social Divider
                  _buildDivider(borderColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // Social Buttons
                  _buildSocialButtons(surfaceColor, borderColor, textColor),
                  const SizedBox(height: 32),

                  // Sign Up Prompt
                  _buildSignUpPrompt(primaryColor, secondaryTextColor),
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
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCwUmiaiE88PPdsTtrl7ClDmfXjkBwiHtH1iTBMMFeoYfWSJWgEKmsYr7Ec-743pz2xnitPI8vDYgfeMHXVkoUpQLnInwK2SBFw6qoy6bLuY1_ung1RY1uRKLlcSk-EuxZE079_M711pcHVHXyvn-3eswswbofsWF0ciri1a-u_a_LlvQ_qiwl4ybsRHA81WAqB7qJPsLMGQx_hqjWpgZuOGTramIhYM6dRo3jh3GLVArqHSQo13Wlv_PW8aiMJ_ZNvdAkj2ruRWw',
              ),
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
                  const Color(0xFF135BEC).withValues(alpha: 0.2),
                  bgColor.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.spa, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tâm An',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Người bạn đồng hành cảm xúc của bạn',
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
        Text(
          'Email',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(color: secondaryTextColor),
            prefixIcon: Icon(Icons.mail_outline, color: secondaryTextColor),
            filled: true,
            fillColor: inputBgColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Mật khẩu',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: secondaryTextColor),
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: inputBgColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),

        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: primaryColor.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDivider(Color borderColor, Color secondaryTextColor) {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'HOẶC TIẾP TỤC VỚI',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: borderColor)),
      ],
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
            onPressed: _handleGoogleLogin,
            style: OutlinedButton.styleFrom(
              backgroundColor: surfaceColor,
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(Icons.g_mobiledata, color: textColor, size: 24),
            label: Text(
              'Google',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(Icons.apple, color: textColor, size: 24),
            label: Text(
              'Apple',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt(Color primaryColor, Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(color: secondaryTextColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Đăng ký ngay',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
