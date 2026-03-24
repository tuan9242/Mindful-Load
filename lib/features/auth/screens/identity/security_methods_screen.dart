import 'package:flutter/material.dart';

class SecurityMethodsScreen extends StatelessWidget {
  const SecurityMethodsScreen({super.key});

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
          "Phương pháp bảo mật",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureIcon(theme, Icons.shield_rounded),
              const SizedBox(height: 24),
              Text(
                "Dữ liệu của bạn được bảo vệ như thế nào?",
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tại Mindful Load, chúng tôi cam kết bảo mật tuyệt đối thông tin cá nhân và những ghi chép tâm trạng của bạn.",
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSecurityItem(
                theme,
                isDark,
                "Lưu trữ Đám mây Bảo mật",
                "Dữ liệu được lưu trữ trên nền tảng Google Firebase với các quy tắc bảo mật nghiêm ngặt cấp doanh nghiệp.",
                Icons.cloud_done_rounded,
              ),
              
              const SizedBox(height: 16),
              
              _buildSecurityItem(
                theme,
                isDark,
                "Xác thực Người dùng",
                "Sử dụng hệ thống Firebase Authentication để đảm bảo chỉ bạn mới có quyền truy cập vào nhật ký của chính mình.",
                Icons.lock_person_rounded,
              ),
              
              const SizedBox(height: 16),
              
              _buildSecurityItem(
                theme,
                isDark,
                "Quyền riêng tư Tuyệt đối",
                "Toàn bộ ghi chép tâm trạng và hoạt động của bạn là riêng tư. Chúng tôi không chia sẻ dữ liệu này cho bất kỳ bên thứ ba nào.",
                Icons.privacy_tip_rounded,
              ),
              
              const SizedBox(height: 16),
              
              _buildSecurityItem(
                theme,
                isDark,
                "Quyền được xóa dữ liệu",
                "Bạn có toàn quyền xóa tài khoản và mọi dữ liệu liên quan bất cứ lúc nào thông qua chức năng trong ứng dụng.",
                Icons.delete_forever_rounded,
              ),
              
              const SizedBox(height: 48),
              
              Center(
                child: Text(
                  "Đội ngũ Mindful Load luôn nỗ lực vì sự an tâm của bạn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(ThemeData theme, IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: theme.primaryColor, size: 30),
    );
  }

  Widget _buildSecurityItem(ThemeData theme, bool isDark, String title, String description, IconData icon) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
