import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Về chúng tôi",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(Icons.groups_rounded, color: theme.primaryColor, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                "Đội ngũ Phát triển",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Dự án Mindful Load",
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              
              // Team Info Card
              _buildInfoCard(
                theme,
                isDark,
                "Thành viên nhóm",
                [
                  "Vũ Anh Tuấn",
                  "Lò Văn Long",
                  "Nguyễn Mạnh Điềm",
                ],
                Icons.person_outline_rounded,
              ),
              
              const SizedBox(height: 16),
              
              // Education Info Card
              _buildInfoCard(
                theme,
                isDark,
                "Thông tin đào tạo",
                [
                  "Lớp: CNTT 17 - 07",
                  "Trường: Đại học Đại Nam",
                ],
                Icons.school,
              ),
              
              const SizedBox(height: 48),
              
              Text(
                "© 2024 Mindful Load Team",
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, bool isDark, String title, List<String> items, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
