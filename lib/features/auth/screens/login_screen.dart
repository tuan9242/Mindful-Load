import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors based on provided Tailwind classes
    final primaryColor = const Color(0xFF135BEC);
    final bgColor = isDarkMode ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    final surfaceColor = isDarkMode ? const Color(0xFF1C1F27) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF3B4354) : const Color(0xFFD1D5DB);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDarkMode ? const Color(0xFF9DA6B9) : const Color(0xFF9CA3AF);
    final inputBgColor = isDarkMode ? const Color(0xFF1C1F27) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Main Content Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Fields
                  _buildForm(primaryColor, inputBgColor, borderColor, textColor, secondaryTextColor),
                  const SizedBox(height: 32),

                  // Social Divider
                  _buildDivider(borderColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // Social Buttons
                  _buildSocialButtons(surfaceColor, borderColor, textColor),
                  const SizedBox(height: 32),

                  // FaceID Hint
                  Center(
                    child: IconButton(
                      iconSize: 40,
                      color: primaryColor,
                      icon: const Icon(Icons.face),
                      onPressed: () {
                        // Face ID action
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  const Color(0xFF101622).withOpacity(0.9),
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
                      color: Color(0xFFD1D5DB), // gray-300 equivalent
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
        // Email Field
        Text(
          'Email',
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(color: secondaryTextColor),
            prefixIcon: Icon(Icons.mail_outline, color: secondaryTextColor),
            filled: true,
            fillColor: inputBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

        // Password Field
        Text(
          'Mật khẩu',
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: secondaryTextColor),
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: inputBgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

        // Forgot Password Link
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
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
        // Submit Button
        ElevatedButton(
          onPressed: () {
            // Navigate to interaction Welcome Screen after successful login
            Navigator.pushReplacementNamed(context, '/interaction-welcome');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
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

  Widget _buildSocialButtons(Color surfaceColor, Color borderColor, Color textColor) {
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
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            // Using a network image for Google Icon as a standard placeholder
            icon: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.g_mobiledata, color: textColor, size: 24),
            ),
            label: Text(
              'Google',
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
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
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
