import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors based on provided Tailwind classes
    final primaryColor = const Color(0xFF135BEC);
    final bgColor = isDarkMode
        ? const Color(0xFF101622)
        : const Color(0xFFF6F6F8);
    final surfaceColor = isDarkMode ? const Color(0xFF192233) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0xFF324467)
        : const Color(0xFFCBD5E1); // slate-300
    final dividerColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1); // slate-700 / slate-300
    final textColor = isDarkMode
        ? Colors.white
        : const Color(0xFF0F172A); // slate-900
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B); // slate-400 / slate-500
    final buttonHoverColor = isDarkMode
        ? const Color(0xFF232D42)
        : const Color(0xFFF8FAFC); // slate-50

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Bar
                    _buildCustomAppBar(textColor),

                    // Header Image
                    _buildHeaderImage(),

                    // Headline Section
                    _buildHeadline(textColor, secondaryTextColor),
                    const SizedBox(height: 24),

                    // Form Fields
                    _buildForm(
                      primaryColor,
                      surfaceColor,
                      borderColor,
                      textColor,
                      secondaryTextColor,
                    ),

                    // Divider
                    _buildDivider(dividerColor, secondaryTextColor),

                    // Social Buttons
                    _buildSocialButtons(
                      surfaceColor,
                      borderColor,
                      buttonHoverColor,
                      textColor,
                    ),

                    // Login Prompt
                    _buildLoginPrompt(primaryColor, secondaryTextColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: textColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              hoverColor: textColor.withOpacity(0.1),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline, color: textColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              hoverColor: textColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCIQedoUf8DXdDl3NcXGjCkPjDM4VRBmmT-l1l5A2uH5pEAa1050sxEsa4yoBUaI14b5PoRxBPYi7kCFv_vcTVUp0GOHEkQYbv1tT1Wt-_lOIAdTaUNrSexUHgmdxARhZhL6BGVJg4IQgraVCg378Z27Xnbfj3Wlx0vl76rxX_3imZafzFYMUlA_3YYXo2YWxTwmXDdrzTmB897PqVYON6hV5z7JvPOGcZ2gelRDux9zEHV1Be-e1Zum_KEkrbyFCr0vv1loaELgA',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.spa, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'TÂM AN',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Bắt đầu hành trình cân bằng cảm xúc của bạn',
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(
    Color primaryColor,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        _buildInputFieldLabel('Email', textColor),
        TextField(
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            hintText: 'nhap@email.com',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            primaryColor: primaryColor,
            secondaryTextColor: secondaryTextColor,
            suffixIcon: Icon(Icons.mail_outline, color: secondaryTextColor),
          ),
        ),
        const SizedBox(height: 16),

        // Password Field
        _buildInputFieldLabel('Mật khẩu', textColor),
        TextField(
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            hintText: '••••••••',
            surfaceColor: surfaceColor,
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

        // Confirm Password Field
        _buildInputFieldLabel('Xác nhận mật khẩu', textColor),
        TextField(
          obscureText: _obscureConfirmPassword,
          style: TextStyle(color: textColor),
          decoration: _buildInputDecoration(
            hintText: '••••••••',
            surfaceColor: surfaceColor,
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

        // Terms Checkbox
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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

        // Primary Button
        ElevatedButton(
          onPressed: () {
            // Navigate to login screen after successful registration
            Navigator.pushReplacementNamed(context, '/login');
          },
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
          child: const Text(
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

  Widget _buildDivider(Color dividerColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hoặc đăng ký với',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
          ),
          Expanded(child: Divider(color: dividerColor)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(
    Color surfaceColor,
    Color borderColor,
    Color hoverColor,
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
              // Use hoverColor if you are handling hover states (mainly for web/desktop)
            ),
            icon: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.g_mobiledata, color: textColor, size: 24),
            ),
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
              // Navigate to Login
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
