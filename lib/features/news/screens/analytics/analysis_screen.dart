import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mindful_load/features/news/screens/alerts/reminder_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _timeFilters = ["Ngày", "Tuần", "Tháng"];
  late Stream<QuerySnapshot> _journalsStream;

  @override
  void initState() {
    super.initState();
    _journalsStream = FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _journalsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allDocs = snapshot.data?.docs ?? [];
            final analytics = JournalAnalytics(allDocs.map((d) => d.data() as Map<String, dynamic>).toList());
            
            // Get filtered data for the selected timeframe
            final filteredEntries = analytics.filterByTimeRange(_selectedFilterIndex);
            final averageScore = analytics.calculateAverageForEntries(filteredEntries);
            final positiveDays = analytics.positiveDaysThisWeek; // Heuristic remains same for week
            final currentStreak = analytics.currentStreak;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(textColor),
                    const SizedBox(height: 24),
                    _buildTimeFilters(theme, isDark),
                    const SizedBox(height: 24),
                    _buildStatsGrid(averageScore, currentStreak, positiveDays, theme, analytics),
                    const SizedBox(height: 32),
                    _buildAIAnalysisSection(analytics, theme),
                    const SizedBox(height: 32),
                    _buildChartSection(filteredEntries, theme),
                    const SizedBox(height: 32),
                    _buildImpactFactors(analytics, theme),
                    const SizedBox(height: 32),
                    _buildSuggestions(theme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Phân tích Chi tiết",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilters(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: List.generate(_timeFilters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _timeFilters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsGrid(int avgScore, int streak, int positiveDays, ThemeData theme, JournalAnalytics analyticsData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                "Chỉ số Căng thẳng",
                "${analyticsData.stressIndex}%",
                analyticsData.stressIndex < 30 ? "Thấp" : (analyticsData.stressIndex < 60 ? "Trung bình" : "Cao"),
                analyticsData.stressIndex < 30 ? Colors.green : (analyticsData.stressIndex < 60 ? Colors.orange : Colors.red),
                Icons.psychology_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme,
                "Giấc ngủ & Năng lượng",
                "${analyticsData.averageSleepHours.toStringAsFixed(1)}h / ${analyticsData.averageEnergyLevel.toStringAsFixed(1)}",
                "Chất lượng: ${analyticsData.averageSleepHours >= 7 ? 'Tốt' : 'Cần chú ý'}",
                const Color(0xFF6366F1),
                Icons.bedtime_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                "Điểm Cảm Xúc",
                "$avgScore / 100",
                avgScore >= 70 ? "Rất ổn định" : (avgScore >= 50 ? "Bình thường" : "Cần lưu ý"),
                avgScore >= 70 ? const Color(0xFF0BDA5E) : (avgScore >= 50 ? const Color(0xFFFACC15) : Colors.red),
                avgScore >= 70 ? Icons.trending_up : (avgScore >= 50 ? Icons.trending_flat : Icons.trending_down),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme,
                "Chuỗi ngày",
                "$streak Ngày",
                "Check-in liên tục",
                const Color(0xFFFACC15),
                Icons.local_fire_department,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    String subtext,
    Color trendColor,
    IconData trendIcon,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  subtext,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisSection(JournalAnalytics analytics, ThemeData theme) {
    final insights = analytics.aiInsights;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "NGƯỜI BẠN AI",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insights['summary'] ?? '',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            insights['advice'] ?? '',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withAlpha(178),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (insights['proposal'] != null && insights['proposal']!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withAlpha(25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: theme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insights['proposal']!,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection(List<Map<String, dynamic>> entries, ThemeData theme) {
    // final isDark = theme.brightness == Brightness.dark;
    
    // Group entries by 60-minute window to avoid crowded data points
    final analytics = JournalAnalytics(entries);
    final chartEntries = analytics.getAggregatedEntries(60);
    final moodSpots = <FlSpot>[];
    final sleepSpots = <FlSpot>[];
    
    final analyticsHelper = JournalAnalytics([]); // Used for getScore helper
    for (int i = 0; i < chartEntries.length; i++) {
        final entry = chartEntries[i];
        
        final moodScore = analyticsHelper.getScore(entry['mood'] ?? 'Bình thường');
        moodSpots.add(FlSpot(i.toDouble(), moodScore));
        
        final sleep = (entry['sleepHours'] as num?)?.toDouble() ?? 0.0;
        sleepSpots.add(FlSpot(i.toDouble(), sleep)); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoodChart(theme, moodSpots, chartEntries),
        const SizedBox(height: 24),
        _buildWellnessChart(theme, sleepSpots, chartEntries),
      ],
    );
  }

  Widget _buildMoodChart(ThemeData theme, List<FlSpot> spots, List<Map<String, dynamic>> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Biến động Tâm trạng",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: spots.isEmpty 
            ? const Center(child: Text("Chưa có dữ liệu"))
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val == 90) return _smallText("90-Tuyệt");
                          if (val == 70) return _smallText("70-Tốt");
                          if (val == 50) return _smallText("50-Ổn");
                          if (val == 30) return _smallText("30-Tệ");
                          if (val == 10) return _smallText("10-Kém");
                          return const SizedBox.shrink();
                        },
                        reservedSize: 60,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => _getBottomTitle(val, entries),
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  minY: 0,
                  maxY: 100,
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: theme.primaryColor,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [theme.primaryColor.withAlpha(51), theme.primaryColor.withAlpha(0)],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => theme.cardColor,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String label = "Bình thường";
                          if (spot.y >= 90) {
                            label = "Tuyệt vời";
                          } else if (spot.y >= 70) {
                            label = "Rất tốt";
                          } else if (spot.y >= 50) {
                            label = "Ổn";
                          } else if (spot.y >= 30) {
                            label = "Kém";
                          } else {
                            label = "Rất kém";
                          }
                          return LineTooltipItem(label, TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold));
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildWellnessChart(ThemeData theme, List<FlSpot> sleepSpots, List<Map<String, dynamic>> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Biến động Giấc ngủ",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: sleepSpots.isEmpty
            ? const Center(child: Text("Chưa có dữ liệu"))
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val == 0 || val == 4 || val == 8 || val == 12) {
                            return _smallText(val.toInt().toString());
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                        interval: 4,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) => _getBottomTitle(val, entries),
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  minY: 0,
                  maxY: 12,
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sleepSpots,
                      isCurved: true,
                      color: Colors.indigoAccent,
                      barWidth: 3,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem("Ngủ (giờ)", Colors.indigoAccent),
          ],
        ),
      ],
    );
  }

  Widget _smallText(String text) {
    return Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey));
  }

  Widget _getBottomTitle(double val, List<Map<String, dynamic>> entries) {
    // Only show title for actual data points (integer indices) to avoid duplicates
    if (val != val.toInt().toDouble()) return const SizedBox.shrink();
    
    final int index = val.toInt();
    if (index >= 0 && index < entries.length) {
      final ts = entries[index]['timestamp'] as Timestamp?;
      if (ts != null) {
        final date = ts.toDate();
        // Intelligent label: only show date at start of day or start of chart
        bool showTime = false;
        if (index > 0) {
          final prevTs = entries[index - 1]['timestamp'] as Timestamp?;
          if (prevTs != null) {
            final prevDate = prevTs.toDate();
            if (date.day == prevDate.day && date.month == prevDate.month) {
              showTime = true;
            }
          }
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            showTime ? DateFormat('HH:mm').format(date) : DateFormat('dd/MM').format(date),
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }



  Widget _buildImpactFactors(JournalAnalytics analytics, ThemeData theme) {
    final factors = analytics.calculateImpactFactors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tác nhân ảnh hưởng",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...factors.map((factor) {
           final colorVal = factor['colorValue'];
           final color = colorVal is int ? Color(colorVal) : Colors.grey;
           return Padding(
             padding: const EdgeInsets.only(bottom: 12),
             child: _buildImpactCard(
               theme,
               Icons.bolt,
               color,
               factor['title'] as String? ?? 'Đang phân tích',
               factor['subtitle'] as String? ?? '',
               factor['impact'] as String? ?? '0%',
             ),
           );
        }),
      ],
    );
  }

  Widget _buildImpactCard(
    ThemeData theme,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String impact,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Text(
            impact,
            style: TextStyle(
              color: Colors.red.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gợi ý cho bạn",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSuggestionCard(
                theme,
                "Thiền thư giãn",
                "Dành 5 phút hít thở sâu để giải tỏa căng thẳng ngay lập tức.",
                Icons.self_improvement,
                theme.primaryColor,
                () {
                  // Proactive: Could navigate to a meditation feature if it existed.
                  // For now, show a simple dialog or navigate to home.
                },
              ),
              const SizedBox(width: 16),
              _buildSuggestionCard(
                theme,
                "Ngủ sớm",
                "Đặt nhắc nhở lúc 10:30 PM để đảm bảo năng lượng ngày mai.",
                Icons.alarm,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReminderScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildSuggestionCard(
                theme,
                "Nhật ký chi tiết",
                "Ghi chép thêm nhãn để AI hiểu bạn sâu sắc hơn.",
                Icons.edit_note_rounded,
                Colors.orange,
                () => Navigator.pop(context), // Go back to start check-in
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    ThemeData theme,
    String title,
    String desc,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(color: theme.textTheme.bodySmall?.color, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Xem ngay",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

