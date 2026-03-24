import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Class xử lý phân tích dữ liệu nhật ký với tư duy của một "thám tử" và "bác sĩ tâm lý".
class JournalAnalytics {
  final List<Map<String, dynamic>> entries;

  JournalAnalytics(this.entries) {
    _sortEntries();
  }

  void _sortEntries() {
    entries.sort((a, b) {
      final tsA = a['timestamp'] as Timestamp?;
      final tsB = b['timestamp'] as Timestamp?;
      if (tsA == null && tsB == null) {
        return 0;
      }
      if (tsA == null) {
        return 1;
      }
      if (tsB == null) {
        return -1;
      }
      return tsB.compareTo(tsA);
    });
  }

  static const Map<String, double> moodWeights = {
    'Hạnh phúc': 100,
    'Vui vẻ': 85,
    'Bình thường': 70,
    'Lo lắng': 40,
    'Buồn': 25,
    'Căng thẳng': 20,
    'Giận dữ': 10,
  };

  double getScore(String mood) {
    return moodWeights[mood] ?? 70;
  }

  bool _isMeaningful(String tag) {
    if (tag.length < 2) {
      return false;
    }
    final lower = tag.toLowerCase();
    if (RegExp(r'^(.)\1+$').hasMatch(lower)) {
      return false;
    }
    final vowels = r'aeiouyàáạảãâầấyẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹ';
    if (!RegExp('[$vowels]').hasMatch(lower)) {
      return false;
    }
    if (RegExp('[^$vowels\\s]{4,}').hasMatch(lower)) {
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> filterByTimeRange(int index) {
    final now = DateTime.now();
    DateTime threshold;
    if (index == 0) {
      threshold = now.subtract(const Duration(hours: 24));
    } else if (index == 1) {
      threshold = now.subtract(const Duration(days: 7));
    } else {
      threshold = now.subtract(const Duration(days: 30));
    }

    return entries.where((e) {
      final ts = e['timestamp'] as Timestamp?;
      if (ts == null) {
        return false;
      }
      return ts.toDate().isAfter(threshold);
    }).toList();
  }

  int get positiveDaysThisWeek {
    final now = DateTime.now();
    final Set<String> positiveDates = {};
    for (var e in entries) {
      final ts = e['timestamp'] as Timestamp?;
      if (ts == null) {
        continue;
      }
      final date = ts.toDate();
      if (now.difference(date).inDays < 7) {
        if (getScore(e['mood'] ?? 'Bình thường') >= 70) {
          positiveDates.add(DateFormat('yyyy-MM-dd').format(date));
        }
      }
    }
    return positiveDates.length;
  }

  // --- Hệ thống Cấp độ & XP (Infrastructure) ---

  int get totalJournals => entries.length;
  int get totalXP => entries.length * 50;
  int get currentLevel => (totalXP ~/ 1000) + 1;
  int get nextLevelXP => currentLevel * 1000;

  Map<String, dynamic> calculateLevel() {
    return {
      'level': currentLevel,
      'xp': totalXP,
      'progress': (totalXP % 1000) / 1000.0,
    };
  }

  // --- Các chỉ số thống kê & Stress Index ---

  int calculateAverageForEntries(List<Map<String, dynamic>> en) {
    return _calculateAverage(en);
  }

  late final int averageScore = _calculateAverage(entries);
  int _calculateAverage(List<Map<String, dynamic>> en) {
    if (en.isEmpty) {
      return 70;
    }
    final double total = en.map((e) => getScore(e['mood'] ?? 'Bình thường')).reduce((a, b) => a + b);
    return (total / en.length).round();
  }

  double _avgField(String field) {
    final valid = entries.map((e) => e[field] as num?).whereType<num>();
    if (valid.isEmpty) {
      return 0.0;
    }
    return (valid.reduce((a, b) => a + b) / valid.length).toDouble();
  }
  double get averageSleepHours => _avgField('sleepHours');
  double get averageEnergyLevel => _avgField('energyLevel');

  late final int stressIndex = _calculateStressIndex();
  int _calculateStressIndex() {
    if (entries.isEmpty) {
      return 0;
    }
    double totalScore = 0;
    final recent = entries.take(7).toList();
    for (var e in recent) {
      double dayStress = 0;
      final moodScore = getScore(e['mood'] ?? 'Bình thường');
      if (moodScore < 40) {
        dayStress += 30;
      } else if (moodScore < 60) {
        dayStress += 15;
      }

      final sleep = (e['sleepHours'] as num?)?.toDouble() ?? 7.0;
      if (sleep < 5) {
        dayStress += 20;
      } else if (sleep < 7) {
        dayStress += 10;
      }

      final energy = (e['energyLevel'] as num?)?.toInt() ?? 3;
      if (energy < 2) {
        dayStress += 20;
      } else if (energy < 3) {
        dayStress += 10;
      }
      totalScore += dayStress;
    }
    return (totalScore / recent.length).clamp(0, 100).toInt();
  }

  // --- UI Insights Generation (Mental Health Detective) ---

  late final Map<String, String> aiInsights = _generateDiagnosticInsights();

  Map<String, String> _generateDiagnosticInsights() {
    if (entries.isEmpty) {
      return {
        'summary': "Chào bạn! Mình là Tâm An, bác sĩ tâm lý AI của riêng bạn. 🌿",
        'advice': "Hãy ghi lại cảm xúc đầu tiên để mình có thể bắt đầu hành trình 'thám tử' tìm hiểu sâu về thế giới nội tâm của bạn nhé.",
        'proposal': "Gợi ý: Chia sẻ về giấc ngủ và các hoạt động để mình tìm ra sự liên kết ẩn giấu."
      };
    }

    final patterns = identifyTimePatterns();
    final correlations = _discoverTopCorrelations();
    final thresholds = _calculateAdaptiveThresholds();
    final transitions = synthesizeTransitions();
    
    final latestMoods = entries.take(3).toList();
    final List<double> scores = latestMoods.map((e) => getScore(e['mood'] ?? 'Bình thường')).toList();
    
    // Ensure we have at least 3 scores for proper trend detection, padding if necessary
    while (scores.length < 3) {
      scores.add(averageScore.toDouble());
    }

    final String summary = _pickEmpathicGreeting(averageScore, scores);

    final List<String> findings = [];
    
    // 1. Time Pattern
    final double? worstDayScore = patterns['worstDayScore'] as double?;
    if (worstDayScore != null && worstDayScore < thresholds['moodLow']!) {
      final days = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
      findings.add("Dữ liệu chỉ ra một mô thức: bạn thường dễ mệt mỏi nhất vào các ngày ${days[(patterns['worstDay'] as int) % 7]}.");
    }

    // 2. Dynamic Correlations (Personalized Learning)
    final positiveTriggers = correlations.where((c) => c['impact'] > 10).take(2).toList();
    final negativeTriggers = correlations.where((c) => c['impact'] < -10).take(2).toList();

    if (negativeTriggers.isNotEmpty) {
      final t = negativeTriggers.first;
      String impactText = t['impact'].abs() > 30 ? "ảnh hưởng rất lớn" : "có dấu hiệu gây áp lực";
      findings.add("Mình nhận thấy '${t['tag']}' $impactText đến tâm trạng của bạn dạo gần đây.");
    }

    // 3. Positive Contrast (Motivation) - Only if current mood is low or dropping
    final isCurrentlyLow = scores[0] <= 50;
    final isDropping = scores[0] < scores[1] - 20;
    
    if ((isCurrentlyLow || isDropping) && positiveTriggers.isNotEmpty) {
      final joy = positiveTriggers.first['tag'];
      findings.add("Trong quá khứ, mình thấy bạn thường cảm thấy rất tốt khi gắn bó với '$joy'. Có lẽ đây là lúc bạn cần tìm lại nguồn năng lượng đó.");
    }

    // 4. Transitions
    if (transitions.isNotEmpty) {
      final lastT = transitions.last;
      if (getScore(lastT['to'] as String) < getScore(lastT['from'] as String) - 30) {
        findings.add("Tôi nhận thấy một sự sụt giảm tâm trạng rõ rệt từ '${lastT['from']}' xuống '${lastT['to']}' ngay sau khi có sự xuất hiện của '${lastT['trigger']}'.");
      }
    }

    final String advice = findings.isNotEmpty 
        ? findings.join("\n\n") 
        : "Mình đang lặng lẽ quan sát và học hỏi từ những thói quen của bạn. Hãy tiếp tục chia sẻ để chúng ta tìm ra những quy luật ẩn giấu nhé.";
    
    final List<String> rootTags = negativeTriggers.map((t) => t['tag'] as String).toList();
    final isCrisis = scores.every((s) => s <= 40);
    final String proposal = _generatePsychologicalAdvice(averageScore, rootTags, isCrisis);

    return {'summary': summary, 'advice': advice, 'proposal': proposal};
  }

  Map<String, double> _calculateAdaptiveThresholds() {
    if (entries.isEmpty) return {'moodLow': 50.0, 'sleepLow': 6.0};
    final avgMood = averageScore.toDouble();
    final avgSleep = averageSleepHours;
    return {
      'moodLow': (avgMood - 15).clamp(20, 50),
      'sleepLow': (avgSleep - 1.0).clamp(4, 7),
    };
  }

  List<Map<String, dynamic>> _discoverTopCorrelations() {
    final Map<String, List<double>> tagScores = {};
    for (var e in entries) {
      final s = getScore(e['mood'] ?? 'Bình thường');
      final act = e['activities'] is List ? List.from(e['activities'] as List) : [];
      final loc = e['locations'] is List ? List.from(e['locations'] as List) : [];
      final com = e['companions'] is List ? List.from(e['companions'] as List) : [];
      final all = [...act, ...loc, ...com].whereType<String>().where(_isMeaningful).toSet();
      for (var t in all) {
        tagScores.putIfAbsent(t, () => []).add(s);
      }
    }
    
    final List<Map<String, dynamic>> correlations = [];
    final avgGlobal = averageScore.toDouble();
    
    tagScores.forEach((tag, scores) {
      if (scores.length >= 2) {
        final avgTag = scores.reduce((a, b) => a + b) / scores.length;
        correlations.add({
          'tag': tag,
          'impact': (avgTag - avgGlobal),
          'count': scores.length,
        });
      }
    });
    
    correlations.sort((a, b) => (b['impact'] as double).abs().compareTo((a['impact'] as double).abs()));
    return correlations;
  }

  // --- Advanced Diagnostic Methods ---

  Map<String, dynamic> identifyTimePatterns() {
    if (entries.isEmpty) {
      return {};
    }
    final Map<int, List<double>> weekdayScores = {};
    final Map<int, List<double>> hourScores = {};
    for (var e in entries) {
      final ts = e['timestamp'] as Timestamp?;
      if (ts == null) {
        continue;
      }
      final d = ts.toDate();
      final s = getScore(e['mood'] ?? 'Bình thường');
      weekdayScores.putIfAbsent(d.weekday, () => []).add(s);
      hourScores.putIfAbsent(d.hour, () => []).add(s);
    }
    
    int worstD = -1; 
    double lowD = 101.0;
    weekdayScores.forEach((d, sc) {
      final a = sc.reduce((a, b) => a + b) / sc.length;
      if (a < lowD) {
        lowD = a;
        worstD = d;
      }
    });
    
    int worstH = -1; 
    double lowH = 101.0;
    hourScores.forEach((h, sc) {
      final a = sc.reduce((a, b) => a + b) / sc.length;
      if (a < lowH) {
        lowH = a;
        worstH = h;
      }
    });
    
    return {'worstDay': worstD, 'worstDayScore': lowD, 'worstHour': worstH, 'worstHourScore': lowH};
  }

  Map<String, int> calculateLifestyleCorrelations() {
    if (entries.isEmpty) {
      return {};
    }
    final List<double> littleS = [];
    final List<double> enoughS = [];
    final List<double> ex = [];
    final List<double> noEx = [];

    for (var e in entries) {
      final s = getScore(e['mood'] ?? 'Bình thường');
      final sl = (e['sleepHours'] as num?)?.toDouble() ?? 0.0;
      final actObj = e['activities'];
      final List<String> act = actObj is List ? List<String>.from(actObj) : [];

      if (sl > 0) {
        if (sl < 6) {
          littleS.add(s);
        } else {
          enoughS.add(s);
        }
      }
      if (act.any((a) => a.contains('Vận động') || a.contains('Thể thao'))) {
        ex.add(s);
      } else if (act.isNotEmpty) {
        noEx.add(s);
      }
    }
    
    double sImpact = 0;
    double eImpact = 0;
    if (littleS.isNotEmpty && enoughS.isNotEmpty) {
      final aL = littleS.reduce((a, b) => a + b) / littleS.length;
      final aE = enoughS.reduce((a, b) => a + b) / enoughS.length;
      sImpact = (aE - aL) / aE;
    }
    if (ex.isNotEmpty && noEx.isNotEmpty) {
      final aX = ex.reduce((a, b) => a + b) / ex.length;
      final aNX = noEx.reduce((a, b) => a + b) / noEx.length;
      eImpact = (aX - aNX) / aX;
    }
    return {'sleepImpact': (sImpact * 100).round(), 'exerciseImpact': (eImpact * 100).round()};
  }

  List<Map<String, dynamic>> synthesizeTransitions() {
    if (entries.length < 2) {
      return [];
    }
    final sorted = List<Map<String, dynamic>>.from(entries);
    sorted.sort((a, b) {
      final tsA = a['timestamp'] as Timestamp;
      final tsB = b['timestamp'] as Timestamp;
      return tsA.compareTo(tsB);
    });
    
    final List<Map<String, dynamic>> transitions = [];
    for (int i = 0; i < sorted.length - 1; i++) {
      final DateTime t1 = (sorted[i]['timestamp'] as Timestamp).toDate();
      final DateTime t2 = (sorted[i+1]['timestamp'] as Timestamp).toDate();
      if (t2.difference(t1).inMinutes < 60) {
        final actObj = sorted[i+1]['activities'];
        final List<dynamic> act = actObj is List ? actObj : [];
        transitions.add({
          'from': sorted[i]['mood'] ?? 'Bình thường',
          'to': sorted[i+1]['mood'] ?? 'Bình thường',
          'trigger': act.isNotEmpty ? act.first : 'bối cảnh hiện tại',
        });
      }
    }
    return transitions;
  }

  String _pickEmpathicGreeting(int avgScore, List<double> last3Scores) {
    if (last3Scores.length < 3) return "Mình ở đây cùng bạn, hãy cứ thư thả nhé. ✨";

    final m1 = last3Scores[0]; // Most recent
    final m2 = last3Scores[1];
    final m3 = last3Scores[2];

    // Scenario 1: Recovery (Tệ -> Vui -> Vui)
    if (m1 >= 70 && m2 >= 70 && m3 <= 40) {
      return "Thật tuyệt vời khi thấy bạn đã vượt qua được khoảnh khắc khó khăn và đang lấy lại năng lượng tích cực! ✨";
    }

    // Scenario 2: Maintaining Highs
    if (m1 >= 80 && m2 >= 80) {
      return "Chào bạn! Rất vui được thấy chuỗi cảm xúc rạng rỡ của bạn dạo gần đây. 🌟";
    }

    // Scenario 3: Sudden Drop (Tốt -> Tệ)
    if (m1 <= 40 && m2 >= 70) {
      return "Mình nhận thấy một sự sụt giảm tâm trạng đột ngột. Chuyện gì vừa diễn ra khiến bạn thấy trĩu nặng vậy? 🌧️";
    }

    // Scenario 4: Persistent Low
    if (m1 <= 40 && m2 <= 40) {
      return "Mình biết bạn đang trải qua những giờ phút rất khó khăn. Tâm An luôn ở đây lắng nghe bạn. 🌱";
    }

    // Default based on current mood
    if (m1 >= 80) {
      return "Woa! Năng lượng của bạn dạo này thật đáng ngưỡng mộ. 🌟";
    } else if (m1 >= 60) {
      return "Mọi thứ dường như đang diễn ra khá bình yên và cân bằng. 🧘‍♂️";
    } else {
      return "Chào bạn, thỉnh thoảng lòng trĩu lại một chút cũng không sao, mình vẫn ở đây nhé. ✨";
    }
  }

  String _generatePsychologicalAdvice(int score, List<String> causes, bool isCrisis) {
    if (isCrisis) {
      return "Dành cho bạn: Hãy thử kỹ thuật hít thở 4-7-8 hoặc đếm ngược 5-4-3-2-1 để ổn định lại tâm trí ngay lập tức nhé.";
    }

    if (score < 60) {
      if (causes.any((c) => c.contains('Làm việc') || c.contains('Công việc'))) {
        return "Lời khuyên: Công việc dường như đang chiếm lấy sự bình yên của bạn. Hãy thử đặt ranh giới 'không làm việc' sau 7 giờ tối nhé.";
      }
      if (causes.any((c) => c.contains('Trường học') || c.contains('Học tập'))) {
        return "Lời khuyên: Áp lực học tập có thể rất lớn. Thử phương pháp Pomodoro (25p học - 5p nghỉ) để não bộ được thư giãn nhé.";
      }
      if (causes.any((c) => c.contains('Gia đình'))) {
        return "Dành cho bạn: Những mâu thuẫn gia đình thường rất đau đớn. Hãy thử dành 5 phút viết ra giấy những gì bạn đang cảm thấy nhé.";
      }
      return "Dành cho bạn: Đừng quên đặt ranh giới cho công việc và dành thời gian ít nhất 15 phút mỗi ngày cho bản thân.";
    }
    
    if (entries.length < 5) {
      return "Gợi ý: Mình rất muốn thấu hiểu bạn hơn. Hãy thử ghi chép thêm 1-2 nhãn chi tiết mỗi khi check-in nhé.";
    }

    return "Lời khuyên: Hãy tiếp tục nuôi dưỡng những thói quen tích cực và ghi lại ít nhất một điều bạn biết ơn mỗi ngày.";
  }

  // --- Visualization Helpers ---

  Map<String, double> calculateDistribution() {
    if (entries.isEmpty) {
      return {'Vui': 0.0, 'Bình yên': 0.0, 'Lo âu': 0.0, 'Buồn': 0.0};
    }
    int v = 0, y = 0, l = 0, b = 0;
    for (var e in entries) {
      final m = e['mood'] ?? 'Bình thường';
      if (['Hạnh phúc', 'Vui vẻ'].contains(m)) {
        v++;
      } else if (['Bình thường'].contains(m)) {
        y++;
      } else if (['Lo lắng', 'Căng thẳng'].contains(m)) {
        l++;
      } else if (['Buồn', 'Giận dữ'].contains(m)) {
        b++;
      }
    }
    final t = entries.length;
    return {'Vui': v / t, 'Bình yên': y / t, 'Lo âu': l / t, 'Buồn': b / t};
  }

  List<double> calculateDailyAverages(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final target = now.subtract(Duration(days: days - 1 - i));
      final dayEn = entries.where((e) {
        final d = (e['timestamp'] as Timestamp?)?.toDate();
        return d != null && d.year == target.year && d.month == target.month && d.day == target.day;
      }).toList();
      return _calculateAverage(dayEn).toDouble();
    });
  }

  List<Map<String, dynamic>> calculateImpactFactors() {
    final Map<String, int> pos = {};
    final Map<String, int> neg = {};
    for (var e in entries) {
      final act = e['activities'] is List ? List.from(e['activities'] as List) : [];
      final loc = e['locations'] is List ? List.from(e['locations'] as List) : [];
      final com = e['companions'] is List ? List.from(e['companions'] as List) : [];
      final all = [...act, ...loc, ...com].whereType<String>().where(_isMeaningful);
      final s = getScore(e['mood'] ?? 'Bình thường');
      for (var t in all) {
        if (s >= 80) {
          pos[t] = (pos[t] ?? 0) + 1;
        }
        if (s <= 40) {
          neg[t] = (neg[t] ?? 0) + 1;
        }
      }
    }
    final List<Map<String, dynamic>> impacts = [
      ...neg.entries.map((e) => {'title': e.key, 'subtitle': 'Tác nhân căng thẳng', 'impact': '-${(e.value * 12).clamp(5, 45)}%', 'colorValue': 0xFFF44336}),
      ...pos.entries.map((e) => {'title': e.key, 'subtitle': 'Cảm hứng tích cực', 'impact': '+${(e.value * 15).clamp(5, 55)}%', 'colorValue': 0xFF4CAF50}),
    ];
    if (impacts.isEmpty) {
      return [{'title': 'Đang phân tích...', 'subtitle': 'Ghi thêm nhật ký nhé', 'impact': '0%', 'colorValue': 0xFF9E9E9E}];
    }
    impacts.sort((a, b) => b['impact'].toString().compareTo(a['impact'].toString()));
    return impacts;
  }

  int get currentStreak {
    if (entries.isEmpty) {
      return 0;
    }
    final List<DateTime> dates = entries.map((e) => (e['timestamp'] as Timestamp?)?.toDate()).whereType<DateTime>().map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (dates.isEmpty) {
      return 0;
    }
    if (dates.first.isBefore(today.subtract(const Duration(days: 1))) && dates.first != today) {
      return 0;
    }
    int s = 0; 
    DateTime c = dates.first;
    for (var d in dates) {
      if (d == c) {
        s++; 
        c = c.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return s;
  }

  /// Nhóm các bản ghi theo khoảng thời gian để hiển thị trên biểu đồ.
  List<Map<String, dynamic>> getAggregatedEntries(int intervalMinutes) {
    if (entries.isEmpty) {
      return [];
    }
    final chronological = entries.reversed.toList();
    final List<Map<String, dynamic>> aggregated = [];
    Map<String, dynamic>? currentGroup;
    
    for (var entry in chronological) {
      if (currentGroup == null) {
        currentGroup = Map<String, dynamic>.from(entry);
        aggregated.add(currentGroup);
      } else {
        final ts = (entry['timestamp'] as Timestamp).toDate();
        final lastTs = (currentGroup['timestamp'] as Timestamp).toDate();
        if (ts.difference(lastTs).inMinutes < intervalMinutes) {
          currentGroup['mood'] = entry['mood'];
          currentGroup['sleepHours'] = entry['sleepHours'];
          currentGroup['energyLevel'] = entry['energyLevel'];
          currentGroup['timestamp'] = entry['timestamp'];
        } else {
          currentGroup = Map<String, dynamic>.from(entry);
          aggregated.add(currentGroup);
        }
      }
    }
    return aggregated;
  }

  /// Gom nhóm dữ liệu giấc ngủ theo ngày (Mỗi ngày 1 điểm duy nhất).
  List<Map<String, dynamic>> getDailySleepEntries() {
    if (entries.isEmpty) return [];

    final Map<String, Map<String, dynamic>> dailyMap = {};
    
    // Sort chronological first
    final chronological = entries.reversed.toList();
    
    for (var entry in chronological) {
      final ts = entry['timestamp'] as Timestamp?;
      if (ts == null) continue;
      
      final dateStr = DateFormat('yyyy-MM-dd').format(ts.toDate());
      
      // Nghiệm vụ: Lấy bản ghi cuối cùng của ngày đó làm đại diện cho giấc ngủ
      dailyMap[dateStr] = Map<String, dynamic>.from(entry);
    }
    
    final result = dailyMap.values.toList();
    result.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
    return result;
  }
}
