import 'package:flutter/material.dart';

class JournalDetailScreen extends StatelessWidget {
  const JournalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Fixed color palette inspired by Tailwind config
    final primaryColor = const Color(0xFF135BEC);
    final bgDark = const Color(0xFF101622);
    final bgLight = const Color(0xFFF6F6F8);
    final backgroundColor = isDarkMode ? bgDark : bgLight;
    
    final surfaceDark = const Color(0xFF1C2433);
    final surfaceLight = const Color(0xFFFFFFFF);
    final surfaceColor = isDarkMode ? surfaceDark : surfaceLight;

    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A); // slate-900 equivalent
    final secondaryTextColor = isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF64748B); // slate-400 / slate-500
    final borderColor = isDarkMode ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0); // slate-700/50 / slate-200

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448), // max-w-md equivalent for consistent sizing
            child: Column(
              children: [
                // Header (App Bar Equivalent)
                _buildHeader(textColor, primaryColor, context),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Section: Emotion
                        _buildHeroSection(textColor, secondaryTextColor, surfaceColor, borderColor, primaryColor),

                        // Divider
                        _buildDivider(isDarkMode),

                        // Section: Nguyên nhân (Causes)
                        _buildCausesSection(textColor, surfaceColor, borderColor, primaryColor),

                        // Section: Ghi chú (Notes)
                        _buildNotesSection(textColor, secondaryTextColor, surfaceColor, borderColor, primaryColor),

                        // Insight / Footer Area
                        _buildInsightSection(isDarkMode, primaryColor, textColor, secondaryTextColor),

                        const SizedBox(height: 32), // Bottom Actions Space
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color primaryColor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 24),
            style: IconButton.styleFrom(
              hoverColor: textColor.withOpacity(0.1),
            ),
          ),
          Expanded(
            child: Text(
              'Chi tiết Nhật ký',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit, color: primaryColor, size: 24),
            style: IconButton.styleFrom(
              hoverColor: textColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color textColor, Color secondaryTextColor, Color surfaceColor, Color borderColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          // Emotion Visual
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              // Image
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: surfaceColor.withOpacity(0.1),
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB9PcT3m0DJau3hXwxRjpEKXcJ3QcVYHYuJXB2XE9QTn-OCfH8403LChNaRKJ_wHDBdLi3jKRuTZ2powqoZOSQTpxqhzyLVPXK-xPX9oheeNyGxBafgCX-zNzcyPQlIu65cbY89FrdmXE_g53Nbd84Ua9PI7TaYBePY7IfULV_aMqU1KHMfndLah0sLAStW_KEZMuBdGOxcmPlvjibFfirfwIoh7XmXifFhDzLLhPyOAR1X3nqO2YDrtWxFmDlEaJQXQmSdyLjgvwE'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Text Info
          Text(
            'Lo lắng',
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: secondaryTextColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  '14:30 • 24 Th10, 2023',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), // slate-800 / slate-200
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildCausesSection(Color textColor, Color surfaceColor, Color borderColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Nguyên nhân',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCauseChip('Deadline', Colors.red[400]!, textColor, surfaceColor, borderColor),
              _buildCauseChip('Thiếu ngủ', Colors.indigo[400]!, textColor, surfaceColor, borderColor),
              _buildCauseChip('Giao thông', Colors.orange[400]!, textColor, surfaceColor, borderColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCauseChip(String label, Color dotColor, Color textColor, Color surfaceColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Color textColor, Color secondaryTextColor, Color surfaceColor, Color borderColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -20,
                  top: -20,
                  bottom: -20,
                  child: Container(
                    width: 4,
                    color: primaryColor,
                  ),
                ),
                Text(
                  '"Cảm thấy tim đập nhanh khi nghĩ về buổi thuyết trình ngày mai. Cần hít thở sâu và chuẩn bị lại slide một lần nữa cho yên tâm."',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5, // leading-relaxed equivalent
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(bool isDarkMode, Color primaryColor, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lightbulb_outline, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Góc nhìn',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn thường cảm thấy lo lắng vào các chiều thứ Ba. Hãy thử dành 5 phút thiền vào buổi trưa nhé.',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      height: 1.4, // leading-snug
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
