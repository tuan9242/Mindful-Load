import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_detail_screen.dart';

class JournalCalendarScreen extends StatefulWidget {
  const JournalCalendarScreen({super.key});

  @override
  State<JournalCalendarScreen> createState() => _JournalCalendarScreenState();
}

class _JournalCalendarScreenState extends State<JournalCalendarScreen> {
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Hạnh phúc': return '😊';
      case 'Vui vẻ': return '😄';
      case 'Bình thường': return '😐';
      case 'Buồn': return '😢';
      case 'Lo lắng': return '😟';
      case 'Căng thẳng': return '😤';
      case 'Giận dữ': return '😡';
      default: return '😐';
    }
  }

  List<DateTime> _generateMonths() {
    final now = DateTime.now();
    return List.generate(12, (index) => DateTime(now.year, now.month - index, 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Lịch Nhật ký',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journals')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra', style: TextStyle(color: textColor)));
          }

          final entries = snapshot.data?.docs ?? [];
          final Map<String, List<Map<String, dynamic>>> entriesByDate = {};
          
          for (var doc in entries) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['timestamp'] as Timestamp?;
            if (ts != null) {
              final date = ts.toDate();
              final key = DateFormat('yyyy-MM-dd').format(date);
              if (!entriesByDate.containsKey(key)) {
                entriesByDate[key] = [];
              }
              final dataWithId = Map<String, dynamic>.from(data);
              dataWithId['id'] = doc.id;
              entriesByDate[key]!.add(dataWithId);
            }
          }

          final months = _generateMonths();

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monthDate = months[index];
                    return Column(
                      children: [
                        _buildMonthCard(monthDate, entriesByDate, isDark, textColor, primaryColor, theme),
                        if (index < months.length - 1)
                          _buildConnector(isDark, theme),
                      ],
                    );
                  },
                  childCount: months.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnector(bool isDark, ThemeData theme) {
    return SizedBox(
      height: 40,
      width: 2,
      child: CustomPaint(
        painter: DashLinePainter(color: theme.dividerColor),
      ),
    );
  }

  Widget _buildMonthCard(
    DateTime monthDate, 
    Map<String, List<Map<String, dynamic>>> entriesByDate,
    bool isDark,
    Color textColor,
    Color primaryColor,
    ThemeData theme,
  ) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    
    int leadingSpaces = firstDayOfMonth.weekday % 7; 
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'tháng ${monthDate.month} ${monthDate.year}',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 42, 
            itemBuilder: (context, index) {
              final dayNumber = index - leadingSpaces + 1;
              if (dayNumber < 1 || dayNumber > lastDayOfMonth.day) {
                return const SizedBox();
              }
              
              final currentDate = DateTime(monthDate.year, monthDate.month, dayNumber);
              final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
              final dayEntries = entriesByDate[dateKey];

              return _buildDayItem(currentDate, dayEntries, isDark, primaryColor, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(DateTime date, List<Map<String, dynamic>>? entries, bool isDark, Color primaryColor, ThemeData theme) {
    if (entries == null || entries.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${date.day}', 
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final firstEntry = entries.first;
    final mood = firstEntry['mood'] ?? 'Bình thường';
    final hasMultiple = entries.length > 1;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JournalDetailScreen(
            entryData: firstEntry,
            docId: firstEntry['id'],
          ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryColor.withOpacity(0.2), 
          border: Border.all(color: primaryColor.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(
                     _getMoodEmoji(mood),
                     style: const TextStyle(fontSize: 20),
                   ),
                   const SizedBox(height: 2),
                   Text(
                     '${date.day}',
                     style: TextStyle(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: isDark ? Colors.white : Colors.black87,
                     ),
                   )
                 ],
               ),
            ),
            if (hasMultiple)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 8)),
                )
              )
          ],
        ),
      ),
    );
  }
}

class DashLinePainter extends CustomPainter {
  final Color color;
  DashLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
