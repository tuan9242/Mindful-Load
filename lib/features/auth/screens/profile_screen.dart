import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors matching the provided image and Tailwind config
    final bgColor = const Color(0xFF0A0F18); // background-dark
    final surfaceColor = const Color(0xFF161E2D); // surface-dark
    final primaryColor = const Color(0xFF135BEC);
    final borderColor = Colors.white.withOpacity(0.05);
    final textColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.4);
    final labelColor = Colors.white.withOpacity(0.3);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(surfaceColor, borderColor, textColor, context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Card
                      _buildProfileCard(surfaceColor, borderColor, primaryColor, textColor),

                      const SizedBox(height: 32),

                      // Section: Cá nhân hóa
                      _buildSectionLabel('Cá nhân hóa', labelColor),
                      _buildSectionContainer(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildListTile(
                            icon: Icons.label_important_rounded,
                            title: 'Quản lý Nhãn',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTile(
                            icon: Icons.hub_rounded,
                            title: 'Liên kết Ngữ cảnh',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTileWithTrailingText(
                            icon: Icons.palette_rounded,
                            title: 'Giao diện & Chủ đề',
                            trailingText: 'Tối',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Section: Dữ liệu & Hệ thống
                      _buildSectionLabel('Dữ liệu & Hệ thống', labelColor),
                      _buildSectionContainer(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildListTile(
                            icon: Icons.summarize_rounded,
                            title: 'Xuất Báo cáo',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTile(
                            icon: Icons.cloud_sync_rounded,
                            title: 'Sao lưu & Khôi phục',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildSwitchTile(
                            icon: Icons.face_rounded,
                            title: 'Bảo mật (FaceID)',
                            value: true,
                            onChanged: (val) {},
                            textColor: textColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Section: Cấu hình chung
                      _buildSectionLabel('Cấu hình chung', labelColor),
                      _buildSectionContainer(
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        children: [
                          _buildListTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Cài đặt thông báo',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTile(
                            icon: Icons.error_outline_rounded,
                            title: 'Cấu hình SOS',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTile(
                            icon: Icons.info_outline_rounded,
                            title: 'Về chúng tôi',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: true,
                          ),
                          _buildListTile(
                            icon: Icons.verified_user_rounded,
                            title: 'Chính sách bảo mật',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: Colors.white.withOpacity(0.05),
                            showBorder: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Delete Button
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          side: BorderSide(color: Colors.red.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                        label: const Text(
                          'Xóa toàn bộ dữ liệu',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNav(surfaceColor, borderColor, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color surfaceColor, Color borderColor, Color textColor, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Cài đặt Tâm An',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(Icons.notifications_rounded, color: textColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Color surfaceColor, Color borderColor, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.account_circle, color: textColor, size: 40),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Minh Tâm',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.military_tech, color: primaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Chiến binh Tâm An',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.65,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cấp độ 12',
                      style: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '1,250 / 2,000 XP',
                      style: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: labelColor,
          fontSize: 12, // bumped up slightly from 10px in html for readability in mobile
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Color surfaceColor, required Color borderColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color borderColor,
    required Color iconBgColor,
    required bool showBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder ? Border(bottom: BorderSide(color: borderColor)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white, // In screenshot, icons have a white shape behind them
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF161E2D), size: 20), // Dark icon color to contrast with white bg
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
        onTap: () {},
      ),
    );
  }

  Widget _buildListTileWithTrailingText({
    required IconData icon,
    required String title,
    required String trailingText,
    required Color textColor,
    required Color borderColor,
    required Color iconBgColor,
    required bool showBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder ? Border(bottom: BorderSide(color: borderColor)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
           width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF161E2D), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailingText,
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
         width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        child: Icon(icon, color: const Color(0xFF161E2D), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white, // The thumb dot
        activeTrackColor: const Color(0xFF135BEC), // primary color track
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

   Widget _buildBottomNav(Color surfaceColor, Color borderColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.check_circle_outline, 'Check-in', false, primaryColor),
          _buildBottomNavItem(Icons.book, 'Nhật ký', false, primaryColor),
          _buildBottomNavItem(Icons.analytics_outlined, 'Phân tích', false, primaryColor),
          _buildBottomNavItem(Icons.settings, 'Cài đặt', true, primaryColor),
        ],
      ),
    );
  }

   Widget _buildBottomNavItem(IconData icon, String label, bool isActive, Color primaryColor) {
    final color = isActive ? primaryColor : Colors.white.withOpacity(0.4);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
