import 'package:flutter/material.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_detail_screen.dart';
import 'package:mindful_load/features/interaction/screens/history/journal_calendar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  DateTime? _selectedFilterDate;
  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedFilterDate = null;
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '--:--';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      dt = DateTime.now();
    }
    return DateFormat('HH:mm').format(dt);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hôm nay';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Hôm qua';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Hạnh phúc': return Icons.sentiment_very_satisfied;
      case 'Vui vẻ': return Icons.sentiment_satisfied;
      case 'Bình thường': return Icons.sentiment_neutral;
      case 'Buồn': return Icons.sentiment_dissatisfied;
      case 'Lo lắng': return Icons.warning_amber;
      case 'Căng thẳng': return Icons.thunderstorm;
      case 'Giận dữ': return Icons.sentiment_very_dissatisfied;
      default: return Icons.notes;
    }
  }

  String _getMoodImage(String mood) {
    switch (mood) {
      case 'Hạnh phúc': return 'https://images.unsplash.com/photo-1499209974431-9dac3adaf470?auto=format&fit=crop&q=60&w=400';
      case 'Vui vẻ': return 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&q=60&w=400';
      case 'Bình thường': return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=60&w=400';
      case 'Buồn': return 'https://images.unsplash.com/photo-1516589174184-c685265142ec?auto=format&fit=crop&q=60&w=400';
      case 'Lo lắng': return 'https://images.unsplash.com/photo-1493676303817-11394628889c?auto=format&fit=crop&q=60&w=400';
      case 'Căng thẳng': return 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&q=60&w=400';
      case 'Giận dữ': return 'https://images.unsplash.com/photo-1444491741275-3747058cc296?auto=format&fit=crop&q=60&w=400';
      default: return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=60&w=400';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journals')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          Widget sliverContent;

          if (snapshot.connectionState == ConnectionState.waiting) {
            sliverContent = const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            sliverContent = SliverFillRemaining(
              child: Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}', style: TextStyle(color: textColor))),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            sliverContent = SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes, size: 64, color: textColor.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('Chưa có nhật ký nào.', style: TextStyle(color: textColor.withOpacity(0.5))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/mood-check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Bắt đầu ghi lại cảm xúc'),
                  ),
                ],
              ),
            );
          } else {
            // Processing data
            final docs = snapshot.data!.docs.toList();
            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final tsA = aData['timestamp'] as Timestamp?;
              final tsB = bData['timestamp'] as Timestamp?;
              if (tsA == null && tsB == null) return 0;
              if (tsA == null) return 1;
              if (tsB == null) return -1;
              return tsB.compareTo(tsA); // descending
            });

            final Map<String, List<QueryDocumentSnapshot>> groupedEntries = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['timestamp'];
              if (ts != null) {
                final date = (ts as Timestamp).toDate();
                
                // Filter by date if selected
                if (_selectedFilterDate != null) {
                   if (date.year != _selectedFilterDate!.year || date.month != _selectedFilterDate!.month || date.day != _selectedFilterDate!.day) {
                      continue;
                   }
                }

                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                if (!groupedEntries.containsKey(dateKey)) {
                  groupedEntries[dateKey] = [];
                }
                groupedEntries[dateKey]!.add(doc);
              }
            }

            if (groupedEntries.isEmpty) {
              sliverContent = SliverFillRemaining(
                child: Center(
                  child: Text('Không có nhật ký cho ngày này.', style: TextStyle(color: textColor.withOpacity(0.5))),
                ),
              );
            } else {
              final sortedKeys = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

              sliverContent = SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateKey = sortedKeys[index];
                    final entries = groupedEntries[dateKey]!;
                    final date = DateTime.parse(dateKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionDate(_formatDateHeader(date), textColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: entries.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final mood = data['mood'] ?? 'Bình thường';
                              final ts = data['timestamp'] as Timestamp;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildJournalCard(
                                  context: context,
                                  title: 'Cảm thấy $mood',
                                  time: _formatTime(ts.toDate()),
                                  iconShape: _getMoodIcon(mood),
                                  imageUrl: data['imageUrl'] ?? _getMoodImage(mood),
                                  primaryColor: primaryColor,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => JournalDetailScreen(
                                          entryData: data,
                                          docId: doc.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (index == sortedKeys.length - 1) const SizedBox(height: 100),
                      ],
                    );
                  },
                  childCount: sortedKeys.length,
                ),
              );
            }
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
                surfaceTintColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: theme.dividerColor,
                    height: 1.0,
                  ),
                ),
                automaticallyImplyLeading: false,
                title: Text(
                  'Nhật ký Cảm xúc',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: textColor),
                    onPressed: () async {
                      final selectedDate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JournalCalendarScreen(),
                        ),
                      );
                      
                      if (selectedDate != null && selectedDate is DateTime) {
                        setState(() {
                           _selectedFilterDate = selectedDate;
                        });
                      }
                    },
                  ),
                ],
              ),

              if (_selectedFilterDate != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đang lọc: ${DateFormat('dd/MM/yyyy').format(_selectedFilterDate!)}',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilterDate = null;
                            });
                          },
                          child: const Text('Bỏ lọc'),
                        )
                      ],
                    ),
                  ),
                ),

              sliverContent,
            ],
          );
        },
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
    required BuildContext context,
    required String title,
    required String time,
    required IconData iconShape,
    required String imageUrl,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
