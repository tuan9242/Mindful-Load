import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_load/features/news/widgets/bouncing_button.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:mindful_load/features/news/screens/shell/main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Color get _bgColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;

  // Text Colors
  Color get textSlate900 => Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
  Color get textSlate500 => Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF64748B);
  Color get textSlate400 => Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : const Color(0xFF94A3B8);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get primary => const Color(0xFF135BEC);
  Color get _primaryColor => primary; 
  Color get _textColor => textSlate900;
  Color get _textMuted => textSlate500;
  Color get _borderColor => Theme.of(context).dividerColor;

  // Status Colors
  static const Color successGreen = Color(0xFF0BDA5E);
  static const Color warningOrange = Color(0xFFF97316);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Stream<QuerySnapshot> _journalsStream;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _journalsStream = FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<QuerySnapshot>(
                stream: _journalsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final analytics = JournalAnalytics(docs.map((d) => d.data() as Map<String, dynamic>).toList());

                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            _buildGreeting(),
                            const SizedBox(height: 24),
                            _buildEmotionalFluctuationCard(analytics),
                            const SizedBox(height: 24),
                            _buildEmotionDistributionCard(analytics),
                            const SizedBox(height: 24),
                            _buildAIAnalysisSection(analytics),
                            const SizedBox(height: 24),
                          ],
                        ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: _bgColor.withValues(alpha: 0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withAlpha(20),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuDzzFXxR8A_hXhOONYISTASA9gO_kP7A_ddAf1jDsXHPU5iXubMTCSC4zVPUWsC_iC8x4-eG3nYt1PR-bDFy-T992-yjMGFHwYWiimTMgBuHaCjEqSscDUcel73pL7mMSeQJPmPh2GTb9sf461RRszRn6NzwB1uEkx2JO3NNXWOl5JlYqxjm3Opx8YxTy_1FZQDfDy5M5R_s3gdGml4otkekn5ACwDF04TuPGaSY1gCw4fAEKCpp098N01OpP8lCeW0-myxA84H8lwi",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Tâm An",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015 * 18,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, size: 26, color: _textColor),
                Positioned(
                  top: 2,
                  right: 2,
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
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    final hour = DateTime.now().hour;
    String timeGreeting = hour < 12 ? 'buổi sáng' : (hour < 18 ? 'buổi chiều' : 'buổi tối');
    final displayName = user?.email?.split('@').first ?? 'bạn';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào $timeGreeting, $displayName 👋',
            style: TextStyle(
              color: _textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: -0.02 * 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hôm nay bạn cảm thấy thế nào?',
            style: TextStyle(color: _textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalFluctuationCard(JournalAnalytics analytics) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Biến động cảm xúc",
                    style: TextStyle(color: textSlate900, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("7 ngày qua", style: TextStyle(color: textSlate400, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${analytics.averageScore} điểm TB",
                  style: TextStyle(color: _primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: _borderColor, strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) {
                        if (val == 0 || val == 50 || val == 100) {
                          return Text(val.toInt().toString(), style: TextStyle(color: textSlate500, fontSize: 10, fontWeight: FontWeight.bold));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        if (val != val.toInt().toDouble()) return const SizedBox.shrink();
                        final int index = val.toInt();
                        if (index >= 0 && index < 7) {
                           return Text("${index + 1}", style: TextStyle(color: textSlate500, fontSize: 10, fontWeight: FontWeight.bold));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: analytics.calculateDailyAverages(7).asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: _primaryColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDistributionCard(JournalAnalytics analytics) {
    final dist = analytics.calculateDistribution();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Text("Phân bổ cảm xúc", style: TextStyle(color: textSlate900, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildProgressBar(label: "Vui", percent: dist['Vui'] ?? 0.0, color: successGreen),
            const SizedBox(height: 12),
            _buildProgressBar(label: "Buồn", percent: dist['Buồn'] ?? 0.0, color: Colors.grey),
            const SizedBox(height: 12),
            _buildProgressBar(label: "Lo âu", percent: dist['Lo âu'] ?? 0.0, color: warningOrange),
            const SizedBox(height: 12),
            _buildProgressBar(label: "Yên", percent: dist['Bình yên'] ?? 0.0, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({required String label, required double percent, required Color color}) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyle(color: _textMuted, fontSize: 13, fontWeight: FontWeight.bold))),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisSection(JournalAnalytics analytics) {
    final insights = analytics.aiInsights;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primary, size: 20),
              const SizedBox(width: 8),
              Text("Người bạn AI tư vấn", style: TextStyle(color: textSlate900, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          BouncingButton(
            onTap: () {
              final mainState = context.findAncestorStateOfType<MainScreenState>();
              if (mainState != null) {
                mainState.onItemTapped(2);
              } else {
                Navigator.pushNamed(context, '/analysis');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insights['summary'] ?? '', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(insights['advice'] ?? '', style: TextStyle(color: _textMuted, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
