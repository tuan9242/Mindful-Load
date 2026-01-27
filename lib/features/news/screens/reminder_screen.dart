import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Colors from HTML
  static const Color primary = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color textSlate800 = Color(0xFF1E293B);
  static const Color textSlate700 = Color(0xFF334155);
  static const Color textSlate500 = Color(0xFF64748B);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color indigo50 = Color(0xFFEEF2FF);

  bool _isNotificationEnabled = true;
  String _selectedFrequency = '3 lần/ngày';
  RangeValues _timeRange = const RangeValues(8, 21); // 08:00 to 21:00
  String _selectedSound = 'Nước chảy';

  final List<String> _frequencies = [
    '1 lần/ngày',
    '3 lần/ngày',
    '5 lần/ngày',
    'Tùy chỉnh'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // padding bottom for fixed button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildNotificationToggle(),
                        const SizedBox(height: 24),
                        _buildSuggestionCard(),
                        const SizedBox(height: 12), // Divider margin
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 12),
                        _buildFrequencySection(),
                        const SizedBox(height: 24),
                        _buildActiveTimeSection(),
                        const SizedBox(height: 24),
                        _buildSoundSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Fixed Bottom Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundLight.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)), // border-gray-100
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent, // hover bg handled by InkWell usually
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: textSlate700),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 20,
            ),
          ),
          Expanded(
            child: Text(
              "Cài đặt Nhắc nhở",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSlate800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015 * 18,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Bật thông báo",
                  style: TextStyle(
                    color: textSlate800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Nhận nhắc nhở check-in mỗi ngày",
                  style: TextStyle(
                    color: textSlate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isNotificationEnabled,
            onChanged: (val) => setState(() => _isNotificationEnabled = val),
            activeThumbColor: primary,
            activeTrackColor: primary.withOpacity(0.2), // Adjust to match design
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue50, indigo50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)), // blue-100
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: const Icon(Icons.psychology_alt, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gợi ý từ Tâm An",
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: "Dựa trên nhật ký của bạn, căng thẳng thường tăng cao vào buổi chiều. Chúng mình đề xuất nhắc nhở vào lúc "),
                      TextSpan(
                        text: "14:00",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " để bạn thư giãn."),
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

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: const Text(
            "Tần suất nhắc nhở",
            style: TextStyle(
              color: textSlate800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _frequencies.map((freq) {
            final isSelected = _selectedFrequency == freq;
            return GestureDetector(
              onTap: () => setState(() => _selectedFrequency = freq),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primary : surfaceLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? primary : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  freq,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textSlate700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActiveTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Thời gian hoạt động",
                style: TextStyle(
                  color: textSlate800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${(_timeRange.end - _timeRange.start).toInt()} tiếng",
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeBox("Bắt đầu", _timeRange.start),
                  const Icon(Icons.arrow_forward, color: Color(0xFFCBD5E1)),
                  _buildTimeBox("Kết thúc", _timeRange.end, alignEnd: true),
                ],
              ),
              const SizedBox(height: 24),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primary,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: surfaceLight,
                  overlayColor: primary.withOpacity(0.2), // Halo effect
                  trackHeight: 6.0,
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 4,
                 ),
                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: RangeSlider(
                  values: _timeRange,
                  min: 0,
                  max: 24,
                  divisions: 48, // Every 30 mins
                  onChanged: (RangeValues values) {
                    setState(() {
                      _timeRange = values;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Thông báo sẽ không làm phiền bạn ngoài giờ này.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSlate500, // text-slate-400
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(String label, double timeVal, {bool alignEnd = false}) {
    int hour = timeVal.floor();
    int minute = ((timeVal - hour) * 60).round();
    String timeStr = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: textSlate500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // gray-50
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            timeStr,
            style: const TextStyle(
              color: textSlate700,
              fontSize: 20,
              fontFamily: 'Monospace', // font-mono
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: const Text(
            "Âm báo",
            style: TextStyle(
              color: textSlate800,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildSoundOption(Icons.wind_power, "Chuông gió", Colors.blue),
            const SizedBox(height: 8),
            _buildSoundOption(Icons.water_drop, "Nước chảy", Colors.indigo),
            const SizedBox(height: 8),
            _buildSoundOption(Icons.notifications_off, "Yên lặng", Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundOption(IconData icon, String label, MaterialColor colorSwatch) {
    final isSelected = _selectedSound == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSound = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.05) : surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorSwatch[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorSwatch[600], size: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: textSlate700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Radio<String>(
              value: label,
              groupValue: _selectedSound,
              onChanged: (val) => setState(() => _selectedSound = val!),
              activeColor: primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundLight.withOpacity(0.8),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 448), // max-w-md
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              // Save changes logic
            },
            icon: const Icon(Icons.check, size: 20),
            label: const Text(
              "Lưu thay đổi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 4,
              shadowColor: primary.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
