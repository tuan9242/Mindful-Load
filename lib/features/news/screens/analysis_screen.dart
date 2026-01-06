// Analysis Screen
import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Use indices for interactivity simulation
  int _selectedTimeFilterIndex = 0;
  final List<String> _timeFilters = ['7 ngày qua', '30 ngày qua', 'Tháng này'];

  @override
  Widget build(BuildContext context) {
    // Colors from HTML configuration
    final primaryColor = const Color(0xFF135BEC);
    final backgroundDark = const Color(0xFF101622);
    final surfaceDark = const Color(0xFF1C2433);
    // ignore: unused_local_variable
    final surfaceLight = const Color(0xFFFFFFFF); // Keep for reference
    
    // Text Styles
    final textStyle = const TextStyle(fontFamily: 'Manrope', color: Colors.white);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        _buildIconButton(Icons.arrow_back, surfaceDark),
                        Expanded(
                          child: Text(
                            "Phân tích Chi tiết",
                            textAlign: TextAlign.center,
                            style: textStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),

                  // Time Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ...List.generate(_timeFilters.length, (index) {
                          final isSelected = _selectedTimeFilterIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTimeFilterIndex = index),
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor : surfaceDark,
                                  borderRadius: BorderRadius.circular(999),
                                  border: isSelected ? null : Border.all(color: Colors.grey.shade800),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _timeFilters[index],
                                  style: textStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Icon(Icons.calendar_month, color: Colors.grey.shade400, size: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Điểm Cảm Xúc",
                            Icons.monitor_heart,
                            primaryColor,
                            "72",
                            "/ 100",
                            Icons.trending_up,
                            const Color(0xFF0BDA5E),
                            "+5% so với tuần trước",
                            surfaceDark,
                            textStyle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            "Ngày tích cực",
                            Icons.wb_sunny,
                            const Color(0xFFFACC15),
                            "5",
                            "/ 7 ngày",
                            null,
                            null,
                            "Tâm trạng ổn định",
                            surfaceDark,
                            textStyle,
                            subtitleColor: const Color(0xFF92A4C9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // AI Analysis Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1C2433),
                            const Color(0xFF111722),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.15),
                                    Colors.purple.withOpacity(0.15)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: surfaceDark.withOpacity(0.9), // Simulate transparency over gradient
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "AI PHÂN TÍCH",
                                        style: textStyle.copyWith(
                                          color: primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: textStyle.copyWith(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.grey.shade200,
                                          ),
                                          children: [
                                            const TextSpan(text: "Bạn thường cảm thấy "),
                                            TextSpan(
                                              text: "lo âu",
                                              style: TextStyle(color: Colors.orange.shade500, fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(text: " nhiều hơn vào buổi tối các ngày trong tuần, đặc biệt khi thời gian ngủ đêm hôm trước dưới 6 tiếng."),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chart Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Diễn biến & Giấc ngủ",
                            style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Column(
                            children: [
                              // Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLegendItem(primaryColor, "Tâm trạng"),
                                  _buildLegendItem(const Color(0xFFC084FC), "Giấc ngủ (h)"),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Chart
                              SizedBox(
                                height: 192, // h-48
                                child: Stack(
                                  children: [
                                    // Grid lines
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(5, (index) => 
                                        Container(height: 1, color: Colors.white.withOpacity(0.1))),
                                    ),
                                    // Bars and Points
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildChartColumn(0.60, 0.50, "T2", primaryColor),
                                        _buildChartColumn(0.45, 0.40, "T3", primaryColor),
                                        _buildChartColumn(0.80, 0.75, "T4", primaryColor),
                                        _buildChartColumn(0.55, 0.60, "T5", primaryColor),
                                        _buildChartColumn(0.90, 0.85, "T6", primaryColor),
                                        _buildChartColumn(0.70, 0.65, "T7", primaryColor),
                                        _buildChartColumn(0.75, 0.70, "CN", primaryColor, isToday: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Impact Factors
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tác nhân ảnh hưởng",
                            style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildImpactCard(
                          Icons.work_history,
                          Colors.red,
                          "Áp lực công việc",
                          "Tần suất: Cao",
                          "-40%",
                          surfaceDark,
                          textStyle,
                        ),
                        const SizedBox(height: 12),
                        _buildImpactCard(
                          Icons.bedtime_off,
                          Colors.orange,
                          "Thức khuya",
                          "Tần suất: Trung bình",
                          "-20%",
                          surfaceDark,
                          textStyle,
                        ),
                        const SizedBox(height: 12),
                        _buildImpactCard(
                          Icons.directions_run,
                          Colors.green,
                          "Chạy bộ sáng",
                          "Tần suất: 3 lần/tuần",
                          "+30%",
                          surfaceDark,
                          textStyle,
                        ),
                      ],
                    ),
                  ),

                   const SizedBox(height: 24),

                  // Suggestions
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gợi ý cho bạn",
                            style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              _buildSuggestionCard(
                                Icons.self_improvement,
                                primaryColor,
                                "Thiền thư giãn",
                                "Dành 5 phút tập hít thở sâu để giảm lo âu vào buổi tối.",
                                "Bắt đầu ngay",
                                true,
                                surfaceDark,
                                textStyle,
                              ),
                              const SizedBox(width: 16),
                              _buildSuggestionCard(
                                Icons.alarm_off,
                                Colors.purple,
                                "Nhắc nhở ngủ sớm",
                                "Thiết lập lời nhắc 'Wind Down' lúc 10:30 PM hàng ngày.",
                                "Cài đặt",
                                false,
                                surfaceDark,
                                textStyle,
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: surfaceDark.withOpacity(0.95),
                    border: Border(top: BorderSide(color: Colors.grey.shade800)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.check_circle_outline, "Check-in", false, primaryColor),
                      _buildNavItem(Icons.book, "Nhật ký", false, primaryColor),
                      _buildNavItem(Icons.insights, "Phân tích", true, primaryColor),
                      _buildNavItem(Icons.settings, "Cài đặt", false, primaryColor),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color bg) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    Color iconColor,
    String value,
    String suffix,
    IconData? trendIcon,
    Color? trendColor,
    String trendText,
    Color bg,
    TextStyle style, {
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: style.copyWith(fontSize: 14, color: Colors.grey.shade400)),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: style.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(suffix, style: style.copyWith(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 4),
          if (trendIcon != null)
            Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 16),
                const SizedBox(width: 4),
                Text(trendText, style: style.copyWith(fontSize: 12, color: trendColor, fontWeight: FontWeight.w600)),
              ],
            )
          else
            Text(trendText, style: style.copyWith(fontSize: 12, color: subtitleColor ?? Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildChartColumn(double barHeightPct, double pointHeightPct, String label, Color color, {bool isToday = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 128, // h-32
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Bar
                FractionallySizedBox(
                  heightFactor: barHeightPct,
                  widthFactor: 0.25, // w-2 (approx) relative to expanded
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
                 // Point
                Align(
                  alignment: Alignment(0, 1 - (pointHeightPct * 2)), // Alignment -1 to 1. Map 0.0-1.0 to 1 to -1.
                  // Wait, alignment y is: -1 top, 1 bottom.
                  // 0% height = 1.0 y. 100% height = -1.0 y.
                  // y = 1 - 2*pct
                  child: Container(
                     width: 8, height: 8,
                     decoration: BoxDecoration(
                       color: const Color(0xFFC084FC),
                       shape: BoxShape.circle,
                       border: Border.all(color: const Color(0xFF1C2433), width: 2),
                     ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(
            color: isToday ? color : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  Widget _buildImpactCard(IconData icon, Color color, String title, String subtitle, String value, Color bg, TextStyle style) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: style.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: style.copyWith(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: style.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text("Ảnh hưởng", style: style.copyWith(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    IconData icon,
    Color color,
    String title,
    String description,
    String buttonText,
    bool isPrimary,
    Color bg,
    TextStyle style,
  ) {
    return Container(
      width: 280,
      height: 192,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and decorative circle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              // We could add the decorative circle via CustomPaint or Stack if strictly needed,
              // but omitting for cleanliness as it's a minor detail.
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: style.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                description,
                style: style.copyWith(fontSize: 14, color: Colors.grey.shade400),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF135BEC) : const Color(0xFF2A3441),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
              style: style.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF135BEC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color activeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? activeColor : Colors.grey.shade500,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : Colors.grey.shade500,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Helper extension for margin/padding if needed, but standard widgets are cleaner in this single file.
