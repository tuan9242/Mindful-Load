import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_load/utils/journal_analytics.dart';

void main() {
  group('JournalAnalytics Diagnostic Engine Tests', () {
    late Timestamp now;
    late Timestamp yesterday;
    late Timestamp twoDaysAgo;

    setUp(() {
      final nowDateTime = DateTime.now();
      now = Timestamp.fromDate(nowDateTime);
      yesterday = Timestamp.fromDate(nowDateTime.subtract(const Duration(days: 1)));
      twoDaysAgo = Timestamp.fromDate(nowDateTime.subtract(const Duration(days: 2)));
    });

    test('Sorting entries by timestamp (descending)', () {
      final entries = [
        {'timestamp': yesterday, 'mood': 'Bình thường'},
        {'timestamp': now, 'mood': 'Hạnh phúc'},
        {'timestamp': twoDaysAgo, 'mood': 'Buồn'},
      ];

      final analytics = JournalAnalytics(entries);

      expect(analytics.entries[0]['mood'], 'Hạnh phúc');
      expect(analytics.entries[1]['mood'], 'Bình thường');
      expect(analytics.entries[2]['mood'], 'Buồn');
    });

    test('XP and Level calculation (Restored)', () {
      final entries = List.generate(25, (index) => {'mood': 'Bình thường'});
      final analytics = JournalAnalytics(entries);

      expect(analytics.totalXP, 1250);
      expect(analytics.currentLevel, 2);
      
      final levelData = analytics.calculateLevel();
      expect(levelData['level'], 2);
      expect(levelData['xp'], 1250);
    });

    test('Stress Index calculation (Restored)', () {
      final entries = [
        {'mood': 'Căng thẳng', 'sleepHours': 4.0, 'energyLevel': 1},
        {'mood': 'Hạnh phúc', 'sleepHours': 8.0, 'energyLevel': 5},
      ];
      final analytics = JournalAnalytics(entries);
      expect(analytics.stressIndex, 35);
    });

    test('Pattern Recognition: Worst Day/Hour', () {
      final entries = [
        {'timestamp': now, 'mood': 'Buồn'}, // Worst
        {'timestamp': yesterday, 'mood': 'Hạnh phúc'},
      ];
      final analytics = JournalAnalytics(entries);
      final patterns = analytics.identifyTimePatterns();

      expect(patterns['worstDay'], now.toDate().weekday);
      expect(patterns['worstHour'], now.toDate().hour);
    });

    test('Lifestyle Correlations: Sleep Impact', () {
      final entries = [
        {'mood': 'Lo lắng', 'sleepHours': 4.0},
        {'mood': 'Lo lắng', 'sleepHours': 4.0},
        {'mood': 'Hạnh phúc', 'sleepHours': 8.0},
        {'mood': 'Hạnh phúc', 'sleepHours': 8.0},
      ];
      final analytics = JournalAnalytics(entries);
      final correlations = analytics.calculateLifestyleCorrelations();

      // (100 - 40) / 100 = 0.6 -> 60%
      expect(correlations['sleepImpact'], greaterThan(10));
    });

    test('Self-Learning: Dynamic Correlations', () {
      final entries = [
        {'mood': 'Lo lắng', 'timestamp': now, 'activities': ['Học tập']},
        {'mood': 'Lo lắng', 'timestamp': yesterday, 'activities': ['Học tập']},
        {'mood': 'Tệ', 'timestamp': twoDaysAgo, 'activities': ['Học tập']},
        {'mood': 'Hạnh phúc', 'timestamp': now, 'activities': ['Gia đình']},
        {'mood': 'Hạnh phúc', 'timestamp': yesterday, 'activities': ['Gia đình']},
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      // Should identify 'Học tập' as a negative trigger and 'Gia đình' as a positive one
      expect(insights['advice'], contains('Học tập'));
      expect(insights['advice'], contains('dấu hiệu gây áp lực'));
    });

    test('Trend Analysis: Recovery Scenario', () {
      final entries = [
        {'mood': 'Hạnh phúc', 'timestamp': now},        // Score 100
        {'mood': 'Hạnh phúc', 'timestamp': yesterday},  // Score 100
        {'mood': 'Giận dữ', 'timestamp': twoDaysAgo},   // Score 0
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      // Should acknowledge recovery from 'Giận dữ'
      expect(insights['summary'], contains('vượt qua được khoảnh khắc khó khăn'));
      expect(insights['summary'], contains('năng lượng tích cực'));
    });

    test('Trend Analysis: Maintaining Highs', () {
      final entries = [
        {'mood': 'Hạnh phúc', 'timestamp': now},
        {'mood': 'Hạnh phúc', 'timestamp': yesterday},
        {'mood': 'Hạnh phúc', 'timestamp': twoDaysAgo},
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      expect(insights['summary'], contains('chuỗi cảm xúc rạng rỡ'));
    });

    test('Trend Analysis: Sudden Drop', () {
      final entries = [
        {'mood': 'Căng thẳng', 'timestamp': now},       // Score 40
        {'mood': 'Hạnh phúc', 'timestamp': yesterday},  // Score 100
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      expect(insights['summary'], contains('sụt giảm tâm trạng đột ngột'));
    });

    test('Dynamic/Diagnostic: Positive Contrast Avoidance on High Mood', () {
      final entries = [
        {'mood': 'Hạnh phúc', 'timestamp': now, 'activities': ['Làm việc']},
        {'mood': 'Hạnh phúc', 'timestamp': yesterday, 'activities': ['Ăn uống']},
        {'mood': 'Hạnh phúc', 'timestamp': twoDaysAgo, 'activities': ['Ăn uống']},
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      // Even if 'Ăn uống' is a positive trigger, don't nag with contrast if currently happy
      expect(insights['advice'], isNot(contains('tìm lại nguồn năng lượng')));
    });

    test('Crisis Mode Advice', () {
      final entries = [
        {'mood': 'Căng thẳng', 'timestamp': now},
        {'mood': 'Căng thẳng', 'timestamp': now},
        {'mood': 'Căng thẳng', 'timestamp': now},
      ];
      final analytics = JournalAnalytics(entries);
      final insights = analytics.aiInsights;

      expect(insights['proposal'], contains('5-4-3-2-1'));
    });

    test('Meaningful tag validation (Vietnamese support)', () {
      final entries = [
        {'mood': 'Hạnh phúc', 'activities': ['Vận động'], 'timestamp': now},
      ];
      final analytics = JournalAnalytics(entries);
      final impacts = analytics.calculateImpactFactors();
      
      expect(impacts.any((i) => i['title'] == 'Vận động'), isTrue);
    });
  });
}
