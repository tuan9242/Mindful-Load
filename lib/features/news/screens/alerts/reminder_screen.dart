import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:mindful_load/models/user_settings_model.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _isNotificationEnabled = true;
  String _selectedFrequency = '3 lần/ngày';
  String _selectedSound = 'Nước chảy';
  
  TimeOfDay _timeMorning = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _timeAfternoon = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _timeEvening = const TimeOfDay(hour: 20, minute: 0);
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        final settings = UserSettingsModel.fromMap(data);
        setState(() {
          _isNotificationEnabled = settings.isNotificationEnabled;
          if (settings.reminderTimes.isNotEmpty) {
             _timeMorning = _parseTime(settings.reminderTimes[0]);
             if (settings.reminderTimes.length > 1) {
               _timeAfternoon = _parseTime(settings.reminderTimes[1]);
             }
             if (settings.reminderTimes.length > 2) {
               _timeEvening = _parseTime(settings.reminderTimes[2]);
             }
             _selectedFrequency = '${settings.reminderTimes.length} lần/ngày';
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải cài đặt: $e");
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch(e) {
        return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Lưu ý', 'Vui lòng đăng nhập', true);
      }
      return;
    }

    setState(() => _isLoading = true);

    List<String> times = [];
    if (_selectedFrequency == '1 lần/ngày') {
      times.add(_formatTime(_timeMorning));
    } else if (_selectedFrequency == '3 lần/ngày' || _selectedFrequency == 'Tùy chỉnh') {
      times.addAll([
        _formatTime(_timeMorning),
        _formatTime(_timeAfternoon),
        _formatTime(_timeEvening)
      ]);
    }

    final settings = UserSettingsModel(
      userId: user.uid,
      reminderTimes: times,
      isNotificationEnabled: _isNotificationEnabled,
      isCalendarSync: false,
      isLocationEnabled: false,
      currentTheme: Theme.of(context).brightness == Brightness.dark ? 'Dark' : 'Light',
      appLockEnabled: false,
    );

    try {
      await FirebaseFirestore.instance.collection('settings').doc(user.uid).set(settings.toMap(), SetOptions(merge: true));
      if (mounted) {
         NotificationHelper.showTopNotification(context, 'Thành công', 'Đã lưu cấu hình nhắc nhở!', false);
         Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showTopNotification(context, 'Lỗi', 'Lỗi lưu cấu hình: $e', true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSelected) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: Theme.of(context).brightness == Brightness.dark 
               ? const ColorScheme.dark(primary: Colors.blueAccent)
               : const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      }
    );
    if (pickedTime != null) {
      onSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Cài đặt Nhắc nhở", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNotificationToggle(theme),
                const SizedBox(height: 24),
                _buildSuggestionCard(theme),
                const SizedBox(height: 24),
                _buildFrequencySection(theme),
                const SizedBox(height: 24),
                if (_selectedFrequency != 'Tùy chỉnh' && _isNotificationEnabled) ...[
                   _buildExactTimeSection(theme),
                   const SizedBox(height: 24),
                ],
                _buildSoundSection(theme),
                const SizedBox(height: 24),
                _buildTestNotificationSection(theme),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButton(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bật thông báo", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text("Nhận nhắc nhở check-in mỗi ngày", style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: _isNotificationEnabled,
            onChanged: (val) => setState(() => _isNotificationEnabled = val),
            activeThumbColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Gợi ý từ Tâm An", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
                    children: [
                      const TextSpan(text: "Dựa trên nhật ký của bạn, căng thẳng thường tăng cao vào buổi chiều. Chúng mình đề xuất nhắc nhở vào lúc "),
                      TextSpan(text: "14:00", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)),
                      const TextSpan(text: " để bạn có khoảng nghỉ hợp lý."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection(ThemeData theme) {
    final frequencies = ['1 lần/ngày', '3 lần/ngày', 'Tùy chỉnh'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tần suất nhắc nhở", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: frequencies.map((freq) {
            final isSelected = _selectedFrequency == freq;
            return ChoiceChip(
              label: Text(freq),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFrequency = freq);
                }
              },
              backgroundColor: theme.cardColor,
              selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExactTimeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Khung giờ nhắc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_selectedFrequency == '1 lần/ngày' || _selectedFrequency == '3 lần/ngày')
            _buildTimeBox(theme, "Buổi Sáng", _timeMorning, (time) => setState(() => _timeMorning = time)),
        if (_selectedFrequency == '3 lần/ngày') ...[
           const SizedBox(height: 8),
           _buildTimeBox(theme, "Buổi Chiều", _timeAfternoon, (time) => setState(() => _timeAfternoon = time)),
           const SizedBox(height: 8),
           _buildTimeBox(theme, "Buổi Tối", _timeEvening, (time) => setState(() => _timeEvening = time)),
        ]
      ],
    );
  }

  Widget _buildTimeBox(ThemeData theme, String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () => _pickTime(context, time, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            Row(
              children: [
                Text(_formatTime(time), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSection(ThemeData theme) {
    final sounds = [
       {'label': 'Chuông gió', 'icon': Icons.wind_power},
       {'label': 'Nước chảy', 'icon': Icons.water_drop},
       {'label': 'Yên lặng', 'icon': Icons.notifications_off},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Âm báo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...sounds.map((s) {
          final isSelected = _selectedSound == s['label'];
          return ListTile(
            title: Text(s['label'] as String),
            leading: Icon(s['icon'] as IconData, color: isSelected ? Colors.blueAccent : Colors.grey),
            trailing: Radio<String>(
              value: s['label'] as String,
              groupValue: _selectedSound,
              activeColor: Colors.blueAccent,
              onChanged: (val) {
                if (val != null) setState(() => _selectedSound = val);
              },
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              setState(() => _selectedSound = s['label'] as String);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTestNotificationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kiểm tra hệ thống", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await NotificationHelper.showLocalNotification(
              title: "Tâm An nhắc bạn",
              body: "Đã đến lúc kiểm tra cảm xúc của bạn rồi đấy!",
            );
          },
          icon: const Icon(Icons.send, size: 18),
          label: const Text("Gửi thông báo thử nghiệm"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.blueAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveSettings,
        icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check),
        label: Text(_isLoading ? "Đang lưu..." : "Lưu cài đặt"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}
