import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mindful_load/features/news/screens/alerts/reminder_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/custom_tag_screen.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:mindful_load/features/auth/screens/identity/user_info_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/theme_settings_screen.dart';
import 'package:mindful_load/features/interaction/screens/config/backup_restore_screen.dart';
import 'package:mindful_load/features/news/screens/analytics/export_report_screen.dart';
import 'package:mindful_load/features/auth/screens/identity/about_us_screen.dart';
import 'package:mindful_load/features/auth/screens/identity/security_methods_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final primaryColor = theme.primaryColor;
    final borderColor = theme.dividerColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final labelColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(surfaceColor, borderColor, textColor, context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('journals')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final analytics = JournalAnalytics(docs.map((d) => d.data() as Map<String, dynamic>).toList());

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInfoScreen())),
                            child: _buildProfileCard(surfaceColor, borderColor, primaryColor, textColor, analytics, isDark),
                          ),

                      const SizedBox(height: 32),

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
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomTagScreen()),
                            ),
                            isDark: isDark,
                          ),
                          _buildListTileWithTrailingText(
                            icon: Icons.palette_rounded,
                            title: 'Giao diện & Chủ đề',
                            trailingText: isDark ? 'Tối' : 'Sáng',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
                            ),
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

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
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExportReportScreen()),
                            ),
                            isDark: isDark,
                          ),
                          _buildListTile(
                            icon: Icons.cloud_sync_rounded,
                            title: 'Sao lưu & Khôi phục',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                            ),
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

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
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReminderScreen()),
                            ),
                            isDark: isDark,
                          ),
                          _buildListTile(
                            icon: Icons.info_outline_rounded,
                            title: 'Về chúng tôi',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                            ),
                            isDark: isDark,
                          ),
                          _buildListTile(
                            icon: Icons.verified_user_rounded,
                            title: 'Chính sách bảo mật',
                            textColor: textColor,
                            borderColor: borderColor,
                            iconBgColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                            showBorder: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SecurityMethodsScreen()),
                            ),
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      OutlinedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          side: BorderSide(color: Colors.red.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.logout_rounded, color: Colors.red),
                        label: const Text(
                          'Đăng xuất',
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
                  );
                },
              ),
            ),
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
              const SizedBox(width: 8),
              Text(
                'Cài đặt & Hồ sơ',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_rounded, color: textColor, size: 20),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Color surfaceColor, Color borderColor, Color primaryColor, Color textColor, JournalAnalytics analytics, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? [] : [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
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
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.email?.split('@').first ?? 'Tài khoản',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _user?.email ?? '',
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 12,
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
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: analytics.totalXP == 0 ? 0.0 : (analytics.totalXP % 1000) / 1000,
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
                      'Cấp độ ${analytics.currentLevel}',
                      style: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(analytics.totalXP)} / ${NumberFormat('#,###').format(analytics.nextLevelXP)} XP',
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
          fontSize: 12,
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
    required bool isDark,
    VoidCallback? onTap,
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
            color: isDark ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDark ? const Color(0xFF161E2D) : Colors.black87, size: 20),
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
        onTap: onTap ?? () {},
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
    required bool isDark,
    VoidCallback? onTap,
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
            color: isDark ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDark ? const Color(0xFF161E2D) : Colors.black87, size: 20),
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
        onTap: onTap ?? () {},
      ),
    );
  }
}
