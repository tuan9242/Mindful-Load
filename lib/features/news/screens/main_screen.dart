import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analysis_screen.dart';
import 'reminder_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Scaffold(
      body: Center(child: Text("Nhật ký (Coming Soon)")),
    ), // Diary Placeholder
    const AnalysisScreen(),
    const SettingsTab(), // Defines the Settings Tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selectedIndex == 2; // Analysis screen is dark
    final bgColor = isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    final navBarColor = isDark
        ? const Color(0xFF1C2433).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);
    final navBarBorderColor = isDark
        ? Colors.grey.shade800
        : const Color(0xFFE2E8F0);
    final iconInactiveColor = isDark
        ? Colors.grey.shade500
        : const Color(0xFF94A3B8); // text-slate-400

    return Scaffold(
      backgroundColor:
          bgColor, // Match the background of the active screen for overscroll etc
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),

          // Custom Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
                left: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                color: navBarColor,
                border: Border(top: BorderSide(color: navBarBorderColor)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    Icons.check_circle_outline,
                    "Check-in",
                    0,
                    iconInactiveColor,
                  ),
                  _buildNavItem(Icons.book, "Nhật ký", 1, iconInactiveColor),
                  _buildNavItem(
                    Icons.insights,
                    "Phân tích",
                    2,
                    iconInactiveColor,
                  ),
                  _buildNavItem(
                    Icons.settings,
                    "Cài đặt",
                    3,
                    iconInactiveColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color inactiveColor,
  ) {
    final isSelected = _selectedIndex == index;
    // Primary color is consistent #135BEC across light/dark for active state,
    // but Analysis used white/primary mix. Let's use Primary #135BEC for consistency.
    const primaryColor = Color(0xFF135BEC);

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : inactiveColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Settings Tab that links to ReminderScreen
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: const Text(
          "Cài đặt",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.notifications_active,
            title: "Cài đặt Nhắc nhở",
            subtitle: "Quản lý thời gian và âm báo",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            context,
            icon: Icons.person,
            title: "Tài khoản",
            subtitle: "Thông tin cá nhân & bảo mật",
            onTap: () {},
          ),
          // Add more settings as placeholders
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF135BEC).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF135BEC)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
