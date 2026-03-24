import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mindful_load/core/services/ai_insight_service.dart';

class JournalDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? entryData;
  final String? docId;

  const JournalDetailScreen({super.key, this.entryData, this.docId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final borderColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, isDark, textColor, (entryData?['timestamp'] as Timestamp?)?.toDate()),

              // Mood Header
              _buildMoodHeader(entryData?['mood'] ?? 'Bình thường', primaryColor, textColor),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Main Content Card
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Section: Chi tiết (Details)
                          _buildMoodDetailsSection(textColor, surfaceColor, borderColor, primaryColor),
                          
                          _buildDivider(isDark, theme),

                          // Section: Ghi chú (Notes)
                          _buildNotesSection(textColor, secondaryTextColor, surfaceColor, borderColor, primaryColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Insights
                    _buildInsightSection(isDark, primaryColor, textColor, secondaryTextColor),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor, DateTime? timestamp) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Column(
            children: [
              Text(
                'Chi tiết Nhật ký',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (timestamp != null)
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhật ký?'),
        content: const Text('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa bản ghi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (docId == null) {
                Navigator.pop(context);
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('journals').doc(docId).delete();
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa nhật ký')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHeader(String mood, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getMoodIcon(mood), color: primaryColor, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Cảm thấy $mood',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
      default: return Icons.sentiment_neutral;
    }
  }

  Widget _buildMoodDetailsSection(Color textColor, Color surfaceColor, Color borderColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Chi tiết bối cảnh',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              if (entryData?['locations'] != null)
                ...(entryData!['locations'] as List).map((l) => _buildChip(l.toString(), Colors.blue, textColor, Icons.location_on_outlined)),
              if (entryData?['activities'] != null)
                ...(entryData!['activities'] as List).map((a) => _buildChip(a.toString(), Colors.orange, textColor, Icons.bolt_outlined)),
              if (entryData?['companions'] != null)
                ...(entryData!['companions'] as List).map((c) => _buildChip(c.toString(), Colors.green, textColor, Icons.people_outline)),
              
              if ((entryData?['locations'] as List?)?.isEmpty == true && 
                  (entryData?['activities'] as List?)?.isEmpty == true &&
                  (entryData?['companions'] as List?)?.isEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Không có thông tin chi tiết', style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color, Color textColor, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: color, size: 14),
      label: Text(label, style: TextStyle(color: textColor, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }


  Widget _buildNotesSection(Color textColor, Color secondaryTextColor, Color surfaceColor, Color borderColor, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entryData?['note'] ?? 'Không có ghi chú nào được lưu lại.',
            style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(bool isDark, Color primaryColor, Color textColor, Color secondaryTextColor) {
    final insightService = AiInsightService([entryData ?? {}]);
    final insight = insightService.generateInsights();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['summary'] ?? '',
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                if (insight['advice'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    insight['advice']!,
                    style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark, ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor,
    );
  }
}
