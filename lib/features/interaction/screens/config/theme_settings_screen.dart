import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindful_load/core/state/app_state.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  int _selectedThemeIndex = 0; // 0: Dark, 1: Light

  @override
  void initState() {
    super.initState();
    // Initialize based on current app theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _selectedThemeIndex = appState.themeMode == ThemeMode.dark ? 0 : 1;
      });
    });
  }

  void _handleThemeSelection(int index) {
    setState(() {
      _selectedThemeIndex = index;
    });
    
    // Update global app state via Provider
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setThemeMode((index == 0) ? ThemeMode.dark : ThemeMode.light);

    // Show top-down notification
    _showTopNotification(
      (index == 0) ? 'Bầu trời đêm' : 'Sương sớm',
      'Đã thay đổi giao diện thành công.',
      false
    );
  }

  void _showTopNotification(String title, String message, bool isError) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) {
              // Notification will be removed by user swipe or timer
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade800 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (message.isNotEmpty)
                          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao diện & Chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn chế độ hiển thị',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tùy chỉnh giao diện phù hợp với thị giác của bạn.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildThemeCard(0, 'Bầu trời đêm', 'Chế độ tối mượt mà', Icons.dark_mode, const Color(0xFF0A0E1A)),
                  _buildThemeCard(1, 'Sương sớm', 'Chế độ sáng rạng rỡ', Icons.light_mode, Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(int index, String title, String subtitle, IconData icon, Color previewColor) {
    final isSelected = _selectedThemeIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _handleThemeSelection(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF135BEC) : theme.dividerColor,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF135BEC).withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 2)
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: previewColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF135BEC) : Colors.grey, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Icon(Icons.check_circle, color: Color(0xFF135BEC), size: 20),
            ]
          ],
        ),
      ),
    );
  }
}
