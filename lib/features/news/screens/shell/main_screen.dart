import 'package:flutter/material.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_list_screen.dart';
import 'package:mindful_load/features/news/screens/core/dashboard_screen.dart';
import 'package:mindful_load/features/news/screens/analytics/analysis_screen.dart';
// import 'reminder_screen.dart';
import 'package:mindful_load/features/auth/screens/identity/profile_screen.dart';
import 'package:mindful_load/features/interaction/screens/input/mood_check_in_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isCheckingIn = false;

  // Screens
  final List<Widget> _screens = [
    const DashboardScreen(),
    const JournalListScreen(),
    const AnalysisScreen(),
    const ProfileScreen(), 
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_isCheckingIn) _isCheckingIn = false; // Reset if switching tabs
    });
  }

  void _startCheckIn() {
    setState(() {
      _isCheckingIn = true;
    });
  }

  void _finishCheckIn() {
    setState(() {
      _isCheckingIn = false;
      _selectedIndex = 1; // Go to Journal List after check-in
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final navBarColor = theme.cardColor.withValues(alpha: 0.95);
    final iconInactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: _isCheckingIn 
          ? _buildCheckInFlow() 
          : IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: _startCheckIn,
          backgroundColor: primaryColor,
          elevation: 8,
          shape: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: navBarColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 10,
        child: Row(
          children: [
            Expanded(child: _buildNavItem(Icons.home_rounded, "Tổng quan", 0, iconInactiveColor, primaryColor)),
            Expanded(child: _buildNavItem(Icons.book_rounded, "Nhật ký", 1, iconInactiveColor, primaryColor)),
            const SizedBox(width: 80), // FAB Space
            Expanded(child: _buildNavItem(Icons.auto_graph_rounded, "Phân tích", 2, iconInactiveColor, primaryColor)),
            Expanded(child: _buildNavItem(Icons.person_rounded, "Cài đặt", 3, iconInactiveColor, primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color inactiveColor, Color primaryColor) {
    final isSelected = !_isCheckingIn && _selectedIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : inactiveColor,
              size: 24,
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
      ),
    );
  }

  Widget _buildCheckInFlow() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => MoodCheckInScreen(
            onCloseAction: () => setState(() => _isCheckingIn = false),
            onCompletedAction: _finishCheckIn,
          ),
        );
      },
    );
  }
}
