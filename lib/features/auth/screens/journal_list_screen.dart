import 'package:flutter/material.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Fixed color palette inspired by Tailwind config
    final primaryColor = const Color(0xFF135BEC);
    final bgDark = const Color(0xFF101622);
    final bgLight = const Color(0xFFF6F6F8);
    final backgroundColor = isDarkMode ? bgDark : bgLight;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111418);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              // Custom Sticky App Bar
              SliverAppBar(
                backgroundColor: isDarkMode 
                    ? bgDark.withOpacity(0.95) 
                    : bgLight.withOpacity(0.95),
                surfaceTintColor: Colors.transparent, // Prevents Material 3 tint overlay
                pinned: true,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    height: 1.0,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  'Nhật ký Cảm xúc',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2, // ~ tracking-[-0.015em]
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: textColor),
                    onPressed: () {},
                  ),
                ],
              ),

              // Content Items
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120.0), // Padding for bottom navbar & FAB
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionDate('Hôm nay', textColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildJournalCard(
                              title: 'Lo âu',
                              time: '09:00',
                              iconShape: Icons.sentiment_dissatisfied_outlined, 
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCh4yoYcOxSaJAfGt608DnyhOgDWCDTZ7Tw0xu4sWVqr_4jK_Lje8X1McNY5sH9KL1KZScHw-ewrT2iWRXbdTZSMr4WNXQcsW_h1XGwuzOiZkwXGmMxBRsmckkekdwEbzs51lj0I9vFP5Ej48brClwONhiezgdFtJUZGH6KohNPYYRc76n7ULjPkRuBsraq6bLVEuT7HtlWy2uLILn5nrYoPMM3ReoMCx0bkj4Wqyj5O9tXFOzFYJt1-8Pw3-bXUpGBaCNRy9aOleUn',
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            _buildJournalCard(
                              title: 'Bình tĩnh',
                              time: '14:00',
                              iconShape: Icons.self_improvement,
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAzBl3szxEgiAdxdGSkeR7YKX2RCLTuFJ-I2Y_SnkUKZRcbfPltne9iVSOpNsYYu2jy7Qyc99fNmhmyKpxRWxetnPsLVdcPk22bojQMYVbjp0XkYyOVYJ-QVQbiZYBdysY5aDuDieo_iEGACe6hT9Uh1e4IeMGzxcM0z6YjEAkhnzlRPhck84ahsjLBd4KDGp4MyfpxWa_SVuHhGCWm4kqdpw_Xjp4KVI8JpGRNgemFw80uWwNqqNNUnaAl9LaZmkPcW_72oc4SuCMw',
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      _buildSectionDate('Hôm qua', textColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildJournalCard(
                              title: 'Mệt mỏi',
                              time: '20:30',
                              iconShape: Icons.battery_alert_outlined, 
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB0bFe9M6Qqmf1CF4X1ve3zjV-sKCE7QUp1Q0qtVPCWc1l4lx9DONcGjvo1kK1GpQ3FCGVwvnzfCYt8O2fZZFATvGqIDwUT6oEJcE_qbnWtQ2ooG9KIMRoqLnUTrXAPp9zYTDY1hDgPdWSqgGPYDBH2DHoWe3v-aAsWzWxDDErtD_klzGbzlNSiC1sb4SsCinXvDPKyRYdywJL8lWxgrX4W74DnVibcNk_ggX1mPITY3rokkZyA9cydnY537hnBCmzQjbKcbpr0_U1E',
                              primaryColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Button
          Positioned(
            bottom: 112, 
            right: 24,
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 56, 
                  width: 56,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30, 
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 12, bottom: 32, left: 8, right: 8), 
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? bgDark.withOpacity(0.95) 
                    : bgLight.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.check_circle_outline,
                    label: 'Check-in',
                    isActive: false,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.book,
                    label: 'Nhật ký',
                    isActive: true,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.analytics_outlined,
                    label: 'Phân tích',
                    isActive: false,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Cài đặt',
                    isActive: false,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDate(String date, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        date,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildJournalCard({
    required String title,
    required String time,
    required IconData iconShape,
    required String imageUrl,
    required Color primaryColor,
  }) {
    return Container(
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.2)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0], 
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconShape, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color primaryColor,
    required bool isDarkMode,
  }) {
    final activeColor = primaryColor;
    final inactiveColor = isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5);
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
