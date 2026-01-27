import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bouncing_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Colors from HTML
  static const Color primary = Color(0xFF135BEC);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF101622);
  static const Color surfaceDark = Color(0xFF1A2230);

  // Text Colors
  static const Color textSlate900 = Color(0xFF0F172A);
  static const Color textSlate500 = Color(0xFF64748B);
  static const Color textSlate400 = Color(0xFF94A3B8);

  // Status Colors
  static const Color successGreen = Color(0xFF0BDA5E);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color deepOrange = Colors.orange;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: FadeTransition(
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
                        _buildEmotionalFluctuationCard(),
                        const SizedBox(height: 24),
                        _buildEmotionDistributionCard(),
                        const SizedBox(height: 24),
                        _buildAIAnalysisSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FAB "Edit" with Bouncing Effect
            Positioned(
              bottom: 96,
              right: 20,
              child: BouncingButton(
                onTap: () {},
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 28),
                ),
              ),
            ),

            // Bottom Navigation Bar handled by MainScreen
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: backgroundLight.withOpacity(
        0.95,
      ), // backdrop blur effect simulation
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withOpacity(0.2), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuDzzFXxR8A_hXhOONYISTASA9gO_kP7A_ddAf1jDsXHPU5iXubMTCSC4zVPUWsC_iC8x4-eG3nYt1PR-bDFy-T992-yjMGFHwYWiimTMgBuHaCjEqSscDUcel73pL7mMSeQJPmPh2GTb9sf461RRszRn6NzwB1uEkx2JO3NNXWOl5JlYqxjm3Opx8YxTy_1FZQDfDy5M5R_s3gdGml4otkekn5ACwDF04TuPGaSY1gCw4fAEKCpp098N01OpP8lCeW0-myxA84H8lwi",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Tâm An",
                style: TextStyle(
                  color: textSlate900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015 * 18, // tracking-[-0.015em]
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              size: 26,
              color: textSlate900,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              hoverColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Chào buổi tối, Minh 👋",
            style: TextStyle(
              color: textSlate900,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.1, // leading-tight
              letterSpacing: -0.02 * 28, // tracking-tight
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Hôm nay bạn cảm thấy thế nào?",
            style: TextStyle(color: textSlate500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalFluctuationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // black/5
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Biến động cảm xúc",
                    style: TextStyle(
                      color: textSlate900,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "7 ngày qua",
                    style: TextStyle(color: textSlate400, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // blue-50
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "+12% Tích cực",
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120, // Height from HTML visual estimation
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(color: primary, strokeWidth: 2),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: primary,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(1, 45),
                      FlSpot(2, 40),
                      FlSpot(3, 60),
                      FlSpot(4, 55),
                      FlSpot(5, 75),
                      FlSpot(6, 65),
                    ],
                    isCurved: true,
                    color: primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.3),
                          primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDistributionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Phân bố cảm xúc",
                      style: TextStyle(
                        color: textSlate900,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: textSlate500, fontSize: 14),
                        children: [
                          TextSpan(text: "Chủ đạo: "),
                          TextSpan(
                            text: "Bình yên",
                            style: TextStyle(
                              color: textSlate900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(label: "Vui", percent: 0.3, color: successGreen),
            const SizedBox(height: 12),
            _buildProgressBar(label: "Buồn", percent: 0.1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildProgressBar(
              label: "Lo âu",
              percent: 0.2,
              color: warningOrange,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(label: "Yên", percent: 0.4, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double percent,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 50, // w-12 approx
          child: Text(
            label,
            style: const TextStyle(
              color: textSlate500,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.auto_awesome, color: primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Phân tích từ AI",
                style: TextStyle(
                  color: textSlate900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildAnalysisCard(
                icon: Icons.schedule,
                gradientColors: [Colors.indigo, Colors.purple],
                title: "Thời gian",
                contentRich: TextSpan(
                  children: [
                    const TextSpan(text: "Căng thẳng thường đạt đỉnh vào "),
                    TextSpan(
                      text: "14:00 chiều thứ Hai",
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildAnalysisCard(
                icon: Icons.group, // groups
                gradientColors: [Colors.green, Colors.teal],
                title: "Mối quan hệ",
                contentRich: TextSpan(
                  children: [
                    const TextSpan(text: "Bạn cảm thấy "),
                    TextSpan(
                      text: "Tích cực",
                      style: TextStyle(
                        color: successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: " hơn khi gặp gỡ Gia đình."),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildAnalysisCard(
                icon: Icons.work,
                gradientColors: [Colors.orange, Colors.red],
                title: "Công việc",
                contentRich: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Làm việc khuya có liên quan đến việc ",
                    ),
                    TextSpan(
                      text: "giảm chỉ số tâm trạng",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: " vào sáng hôm sau."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard({
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required TextSpan contentRich,
    VoidCallback? onTap,
  }) {
    return BouncingButton(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textSlate900,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: textSlate500, // text-slate-600 in HTML
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5, // leading-relaxed
                      ),
                      children: [contentRich],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textSlate400),
          ],
        ),
      ),
    );
  }
}
