import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Vừa xong';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textMuted = theme.textTheme.bodySmall?.color ?? Colors.grey;

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả là đã đọc',
              onPressed: () async {
                final batch = FirebaseFirestore.instance.batch();
                final unreadDocs = await FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: user.uid)
                    .where('isRead', isEqualTo: false)
                    .get();
                
                for (var doc in unreadDocs.docs) {
                  batch.update(doc.reference, {'isRead': true});
                }
                await batch.commit();
              },
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Đã có lỗi xảy ra',
                          style: TextStyle(color: textMuted)));
                }

                final docs = snapshot.data?.docs.toList() ?? [];

                docs.sort((a, b) {
                  final tsA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  final tsB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  if (tsA == null && tsB == null) return 0;
                  if (tsA == null) return 1;
                  if (tsB == null) return -1;
                  return tsB.compareTo(tsA); // descending
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 80, color: textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Bạn chưa có thông báo nào mới',
                          style: TextStyle(color: textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Thông báo';
                    final message = data['message'] ?? '';
                    final isRead = data['isRead'] ?? false;
                    final timestamp = data['timestamp'] as Timestamp?;

                    return GestureDetector(
                      onTap: () {
                         if (!isRead) {
                           FirebaseFirestore.instance
                               .collection('notifications')
                               .doc(docs[index].id)
                               .update({'isRead': true});
                         }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead
                              ? surfaceColor
                              : primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? theme.dividerColor
                                : primaryColor.withValues(alpha: 0.3),
                          ),
                          boxShadow: isDark ? [] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? (isDark ? Colors.white10 : Colors.grey.shade100)
                                    : primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isRead
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: isRead ? textMuted : primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(timestamp),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: isRead ? textMuted : textColor,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
