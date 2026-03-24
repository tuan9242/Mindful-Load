import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindful_load/utils/notification_helper.dart';
import 'package:intl/intl.dart';
import 'package:mindful_load/utils/journal_analytics.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  int _selectedChipIndex = 0; // 0: Tháng này, 1: 7 ngày qua, 2: 30 ngày qua, 3: Tùy chỉnh
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  JournalAnalytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateDateRange(0);
  }

  void _updateDateRange(int index) {
    setState(() {
      _selectedChipIndex = index;
    });
    
    final now = DateTime.now();
    if (index == 0) {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    } else if (index == 1) {
      _startDate = now.subtract(const Duration(days: 7));
      _endDate = now;
    } else if (index == 2) {
      _startDate = now.subtract(const Duration(days: 30));
      _endDate = now;
    }
    
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final startStamp = Timestamp.fromDate(DateTime(_startDate.year, _startDate.month, _startDate.day));
        final endDay = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59, 999);
        final endStamp = Timestamp.fromDate(endDay);

        final snapshot = await FirebaseFirestore.instance
            .collection('journals')
            .where('userId', isEqualTo: user.uid)
            .get();
            
        if (!mounted) return;
        
        final docs = snapshot.docs.where((doc) {
          final data = doc.data();
          final ts = data['timestamp'] as Timestamp?;
          if (ts == null) {
            return false;
          }
          return ts.compareTo(startStamp) >= 0 && ts.compareTo(endStamp) <= 0;
        }).toList();

        docs.sort((a,b) {
          final aTime = (a.data())['timestamp'] as Timestamp?;
          final bTime = (b.data())['timestamp'] as Timestamp?;
          if (aTime == null || bTime == null) {
            return 0;
          }
          return aTime.compareTo(bTime);
        });

        if (mounted) {
          setState(() {
            _analytics = JournalAnalytics(docs.map((d) => d.data()).toList());
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching report data: $e");
      if (mounted) {
        _showTopNotification(context, 'Lỗi tải dữ liệu', 'Không thể tải nhật ký. Vui lòng kiểm tra kết nối mạng.', true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTopNotification(BuildContext context, String title, String message, bool isError) {
    if (!mounted) {
      return;
    }
    NotificationHelper.showTopNotification(context, title, message, isError);
  }

  void _handleShareReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1F27) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chia sẻ qua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareIcon(Icons.chat, 'Zalo', Colors.blue),
                _buildShareIcon(Icons.email, 'Email', Colors.red),
                _buildShareIcon(Icons.link, 'Sao chép', Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showTopNotification(context, 'Đang mở $label', 'Vui lòng chờ...', false);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _handleDownloadAndNotify(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _analytics == null) return;

    setState(() => _isLoading = true);

    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();
      
      final dateStr = '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}';
      final moodValue = _analytics!.averageScore;
      final stressIndex = _analytics!.stressIndex;
      final sleepHours = _analytics!.averageSleepHours;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(level: 0, text: 'Báo cáo Sức khỏe Tinh thần - Tâm An'),
                  pw.SizedBox(height: 20),
                  pw.Text('Người dùng: ${user.displayName ?? "User"}'),
                  pw.Text('Email: ${user.email ?? "N/A"}'),
                  pw.Text('Giai đoạn: $dateStr'),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text('TỔNG QUAN CHỈ SỐ:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Bullet(text: 'Điểm Tâm trạng Trung bình: ${moodValue.toStringAsFixed(1)}/100'),
                  pw.Bullet(text: 'Chỉ số Căng thẳng: $stressIndex%'),
                  pw.Bullet(text: 'Thời gian Ngủ trung bình: ${sleepHours.toStringAsFixed(1)} giờ'),
                  pw.Bullet(text: 'Tổng số bản ghi nhật ký: ${_analytics!.totalJournals}'),
                  pw.SizedBox(height: 30),
                  pw.Text('Lời khuyên từ tâm lý gia AI:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    moodValue > 70 
                    ? 'Tâm trạng của bạn rất tốt trong giai đoạn này. Hãy tiếp tục duy trì các thói quen tích cực và dành thời gian cho các hoạt động yêu thích.'
                    : 'Bạn đang có dấu hiệu căng thẳng trong giai đoạn này. Hãy dành thời gian để nghỉ ngơi, tập trung vào hơi thở và liên hệ với chuyên gia nếu cần thiết.'
                  ),
                  pw.Spacer(),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Ngày trích xuất: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'Bao_cao_Tam_An_${user.uid.substring(0, 5)}.pdf');

      // Notify in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'Da tai bao cao',
        'message': 'Bao cao Suc khoe Tinh than ($dateStr) da duoc tao va luu thanh cong.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showTopNotification(context, 'Thành công', 'Báo cáo PDF đã được tạo!', false);
      }
    } catch (e) {
      debugPrint("PDF Export error: $e");
      if (mounted) {
        _showTopNotification(context, 'Lỗi', "Không thể tạo PDF: $e", true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF135BEC),
              brightness: Theme.of(context).brightness,
              primary: const Color(0xFF135BEC),
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              primaryContainer: const Color(0xFF135BEC).withValues(alpha: 0.3),
              onPrimaryContainer: Colors.white,
              secondaryContainer: const Color(0xFF135BEC).withValues(alpha: 0.2),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF135BEC)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedChipIndex = 3; // Custom
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textMuted = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final borderColor = theme.dividerColor;

    final dateStr = '${DateFormat('dd/MM').format(_startDate)} - ${DateFormat('dd/MM, yyyy').format(_endDate)}';
    
    final moodValue = (_analytics?.averageScore ?? 0.0).toDouble();
    final statusVal = moodValue > 70 ? '🟢 Cao' : (moodValue > 40 ? '🟡 TB' : '🔴 Thấp');
    final logCount = _analytics?.totalJournals ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xuất Báo cáo',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            onPressed: () => _handleShareReport(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khoảng thời gian',
              style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
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
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đã chọn', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(dateStr, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _pickDateRange,
                    child: Text('Thay đổi', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildChip('Tháng này', 0, isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildChip('7 ngày qua', 1, isDark, primaryColor),
                  const SizedBox(width: 8),
                  _buildChip('30 ngày qua', 2, isDark, primaryColor),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Xem trước bản in (PDF)',
                  style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '1 trang',
                  style: TextStyle(color: textMuted.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildReportContent(isDark, surfaceColor, primaryColor, textColor, textMuted, borderColor, dateStr, moodValue, statusVal, logCount),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton.icon(
            onPressed: () => _handleDownloadAndNotify(context),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Tải về báo cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textColor,
    Color textMuted,
    Color borderColor,
    String dateStr,
    double moodValue,
    String statusVal,
    int logCount,
  ) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_analytics == null || logCount == 0) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats, size: 48, color: textMuted),
            const SizedBox(height: 16),
            Text('Không tìm thấy dữ liệu', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Vui lòng thử chọn khoảng thời gian khác hoặc tạo thêm nhật ký để xem báo cáo nhé.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252932) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: 300,
            height: 450,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.spa, color: primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text('Tâm An', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const Text('Báo cáo Sức khỏe Tinh thần', style: TextStyle(color: Colors.grey, fontSize: 9)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(FirebaseAuth.instance.currentUser?.displayName ?? 'Người dùng',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),
                        Text('ID: ${FirebaseAuth.instance.currentUser?.uid.substring(0, 6) ?? '123456'}',
                            style: const TextStyle(color: Colors.grey, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.black12),
                const SizedBox(height: 8),
                Text(_selectedChipIndex == 0 ? 'Tổng quan Tháng ${DateTime.now().month}' : 'Tổng quan Nhật ký',
                    style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),

                const SizedBox(height: 16),
                const Text('Biểu đồ Cảm xúc', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _buildRealChart(primaryColor),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TB CẢM XÚC', style: TextStyle(color: Colors.grey, fontSize: 7, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(moodValue.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text(statusVal,
                                    style: TextStyle(
                                        color: moodValue > 50 ? Colors.green : Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SỐ NHẬT KÝ', style: TextStyle(color: Colors.grey, fontSize: 7, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$logCount',
                                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('bản ghi', style: TextStyle(color: primaryColor, fontSize: 8, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                if (logCount > 0) ...[
                  _buildReportRow('H.Số Căng thẳng', '${_analytics!.stressIndex}%'),
                  _buildReportRow('TB Giấc ngủ', '${_analytics!.averageSleepHours.toStringAsFixed(1)} giờ'),
                  _buildReportRow('Mức Năng lượng', '${_analytics!.averageEnergyLevel.toStringAsFixed(1)}/5'),
                ],

                const SizedBox(height: 16),
                const Text('Phân bố Cảm xúc', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _buildRealDistribution(),

                const SizedBox(height: 8),
                const Center(
                  child: Text('Được tạo tự động bởi ứng dụng Tâm An • Trang 1/1', style: TextStyle(color: Colors.grey, fontSize: 7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealChart(Color primaryColor) {
    if (_analytics == null || _analytics!.totalJournals == 0) {
      return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey, fontSize: 10)));
    }
    
    final averages = _analytics!.calculateDailyAverages(7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: averages.map((avg) {
          final heightFactor = (avg / 100.0).clamp(0.05, 1.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(avg.toInt().toString(), style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 1),
              Container(
                width: 14,
                height: 54 * heightFactor,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealDistribution() {
    if (_analytics == null || _analytics!.totalJournals == 0) {
       return const SizedBox(); 
    }
    final dist = _analytics!.calculateDistribution();
    final sortedEntries = dist.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final take3 = sortedEntries.take(3).toList();

    return Column(
      children: take3.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(e.key, style: const TextStyle(color: Colors.black87, fontSize: 9))),
              Expanded(flex: 1, child: Text('${(e.value * 100).toStringAsFixed(0)}%', textAlign: TextAlign.right, style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int index, bool isDark, Color primaryColor) {
    final isSelected = _selectedChipIndex == index;
    return GestureDetector(
      onTap: () => _updateDateRange(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : (isDark ? const Color(0xFF1C1F27) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : (isDark ? const Color(0xFF374151) : Colors.grey.shade300)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
