import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JournalAnalytics {
  final List<Map<String, dynamic>> entries;

  JournalAnalytics(this.entries) {
    // We assume entries are already sorted or we sort them here if needed.
    // However, to keep it consistent with the previous logic:
    _sortEntries();
  }

  void _sortEntries() {
    // sort descending by timestamp ONCE
    entries.sort((a, b) {
      final tsA = a['timestamp'] as Timestamp?;
      final tsB = b['timestamp'] as Timestamp?;
      if (tsA == null && tsB == null) return 0;
      if (tsA == null) return 1;
      if (tsB == null) return -1;
      return tsB.compareTo(tsA);
    });
  }

  // Constants for scoring
  static const Map<String, double> moodWeights = {
    'Hạnh phúc': 100,
    'Vui vẻ': 85,
    'Bình thường': 70,
    'Lo lắng': 40,
    'Buồn': 25,
    'Căng thẳng': 20,
    'Giận dữ': 10,
  };

  // Tag validation helper
  bool _isMeaningful(String tag) {
    if (tag.length < 2) return false;
    final lower = tag.toLowerCase();
    
    // Catch repeated identical characters (e.g., "aaaa", "....")
    if (RegExp(r'^(.)\1+$').hasMatch(lower)) return false;
    
    // Catch short nonsense like "a1", "x9"
    if (RegExp(r'^[a-z0-9]{1,2}$').hasMatch(lower)) return false;
    
    // Catch gibberish without vowels (English + basic Vietnamese vowels)
    // Vowels: a, e, i, o, u, y, and basic accented ones
    final hasVowel = RegExp(r'[aeiouyàáạảãâầấyẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹ]').hasMatch(lower);
    if (!hasVowel) return false;

    // Catch weird clusters (3+ same consonants or too many consonants in short string)
    if (RegExp(r'([^aeiouy\s]){4,}').hasMatch(lower)) return false;

    return true;
  }


  int get totalJournals => entries.length;

  // Get score for a specific mood string
  double getScore(String mood) {
    return moodWeights[mood] ?? 70; // default to neutral
  }

  // XP and Level Calculation
  int get totalXP => entries.length * 50;
  int get currentLevel => (totalXP ~/ 1000) + 1;
  int get nextLevelXP => currentLevel * 1000;

  Map<String, dynamic> calculateLevel() {
    int level = currentLevel;
    int xpInThisLevel = totalXP % 1000;
    double progress = xpInThisLevel / 1000.0;
    return {
      'level': level,
      'xp': totalXP,
      'progress': progress,
    };
  }

  // Time Filtering
  List<Map<String, dynamic>> filterByTimeRange(int index) {
    final now = DateTime.now();
    DateTime threshold;
    
    if (index == 0) { // Ngày (Last 24h)
      threshold = now.subtract(const Duration(hours: 24));
    } else if (index == 1) { // Tuần (Last 7 days)
      threshold = now.subtract(const Duration(days: 7));
    } else { // Tháng (Last 30 days)
      threshold = now.subtract(const Duration(days: 30));
    }

    return entries.where((e) {
      final ts = e['timestamp'] as Timestamp?;
      if (ts == null) return false;
      return ts.toDate().isAfter(threshold);
    }).toList();
  }

  // Calculate Streak (Consecutive days)
  int get currentStreak {
    if (entries.isEmpty) return 0;
    
    final sortedDates = entries
        .map((e) => (e['timestamp'] as Timestamp?)?.toDate())
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (sortedDates.first.isBefore(yesterday) && sortedDates.first != today) return 0;

    int streak = 0;
    DateTime currentCheck = sortedDates.first;

    for (var date in sortedDates) {
      if (date == currentCheck) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Calculate average score for a specific list of entries
  int calculateAverageForEntries(List<Map<String, dynamic>> specificEntries) {
    if (specificEntries.isEmpty) return 70;
    double total = 0;
    for (var e in specificEntries) {
      total += getScore(e['mood'] ?? 'Bình thường');
    }
    return (total / specificEntries.length).round();
  }

  // Calculate Distribution for a specific list
  Map<String, double> calculateDistributionForEntries(List<Map<String, dynamic>> specificEntries) {
    int vui = 0, binhYen = 0, loAu = 0, buon = 0;
    int total = specificEntries.length;

    if (total == 0) return {'Vui': 0.0, 'Bình yên': 0.0, 'Lo âu': 0.0, 'Buồn': 0.0};

    for (var entry in specificEntries) {
      final mood = entry['mood'] ?? 'Bình thường';
      if (['Hạnh phúc', 'Vui vẻ'].contains(mood)) vui++;
      else if (['Bình thường'].contains(mood)) binhYen++;
      else if (['Lo lắng', 'Căng thẳng'].contains(mood)) loAu++;
      else if (['Buồn', 'Giận dữ'].contains(mood)) buon++;
    }

    return {
      'Vui': vui / total,
      'Bình yên': binhYen / total,
      'Lo âu': loAu / total,
      'Buồn': buon / total,
    };
  }

  late final int averageScore = _calculateAverageForEntries(entries);
  
  int _calculateAverageForEntries(List<Map<String, dynamic>> specificEntries) {
    if (specificEntries.isEmpty) return 70;
    double total = 0;
    for (var e in specificEntries) {
      total += getScore(e['mood'] ?? 'Bình thường');
    }
    return (total / specificEntries.length).round();
  }
  
  double get averageSleepHours {
    if (entries.isEmpty) return 0.0;
    double total = 0;
    int count = 0;
    for (var e in entries) {
      final sleep = e['sleepHours'];
      if (sleep != null) {
        total += (sleep as num).toDouble();
        count++;
      }
    }
    return count > 0 ? total / count : 0.0;
  }

  double get averageEnergyLevel {
    if (entries.isEmpty) return 0.0;
    double total = 0;
    int count = 0;
    for (var e in entries) {
      final energy = e['energyLevel'];
      if (energy != null) {
        total += (energy as num).toDouble();
        count++;
      }
    }
    return count > 0 ? total / count : 0.0;
  }

  late final int stressIndex = _calculateStressIndex();

  int _calculateStressIndex() {
    if (entries.isEmpty) return 0;
    // Stress index calculated from: Low mood + low sleep + low energy + negative tags
    double score = 0;
    final recent = entries.take(7).toList();
    for (var e in recent) {
       double dayStress = 0;
       final moodScore = getScore(e['mood'] ?? 'Bình thường');
       if (moodScore < 40) dayStress += 30;
       else if (moodScore < 60) dayStress += 15;

       final sleep = (e['sleepHours'] as num?)?.toDouble() ?? 7.0;
       if (sleep < 5) dayStress += 20;
       else if (sleep < 7) dayStress += 10;

       final energy = (e['energyLevel'] as num?)?.toInt() ?? 3;
       if (energy < 2) dayStress += 20;
       else if (energy < 3) dayStress += 10;

       score += dayStress;
    }
    return (score / recent.length).clamp(0, 100).toInt();
  }

  int get positiveDaysThisWeek {
    final now = DateTime.now();
    Set<String> positiveDates = {};
    for (var e in entries) {
      final ts = e['timestamp'] as Timestamp?;
      if (ts == null) continue;
      final date = ts.toDate();
      if (now.difference(date).inDays < 7) {
        if (getScore(e['mood'] ?? 'Bình thường') >= 70) {
          positiveDates.add(DateFormat('yyyy-MM-dd').format(date));
        }
      }
    }
    return positiveDates.length;
  }

  late final Map<String, String> aiInsights = _generateAIInsights();

  // Enhanced AI Insights with "Friend" tone
  Map<String, String> _generateAIInsights() {
    if (entries.isEmpty) {
      return {
        'summary': "Chào bạn mới! Mình là người bạn AI của bạn đây. Hãy bắt đầu ghi chép để mình có thể đồng hành và hiểu bạn hơn nhé! ✨",
        'advice': "Mẹo nhỏ: Thêm nhãn về hoạt động sẽ giúp mình phân tích chính xác những gì làm bạn vui hay buồn đấy!",
        'proposal': "Mình cần thêm dữ liệu về: Hoạt động thường ngày, Thời gian ngủ và Những người bạn gặp."
      };
    }

    int workStress = 0, lateNight = 0, positiveFamily = 0, outdoorPositive = 0;
    int financialStress = 0, healthIssue = 0, trafficStress = 0;

    for (var e in entries) {
      final mood = e['mood'] ?? 'Bình thường';
      final activities = List<String>.from(e['activities'] ?? []);
      final companions = List<String>.from(e['companions'] ?? []);
      final note = (e['note'] ?? '').toString().toLowerCase();
      final score = getScore(mood);

      // Activity-based analysis
      if (activities.contains('Công việc') && score < 50) workStress++;
      if (activities.contains('Vận động') && score >= 80) outdoorPositive++;
      if (companions.contains('Gia đình') && score >= 80) positiveFamily++;

      // Note-based keyword analysis
      if (note.contains('áp lực') || note.contains('mệt') || note.contains('deadline')) workStress++;
      if (note.contains('tiền') || note.contains('lương') || note.contains('chi phí')) financialStress++;
      if (note.contains('đau') || note.contains('ốm') || note.contains('bệnh')) healthIssue++;
      if (note.contains('kẹt xe') || note.contains('tắc đường')) trafficStress++;

      final ts = e['timestamp'] as Timestamp?;
      if (ts != null) {
        final hour = ts.toDate().hour;
        if ((hour >= 23 || hour <= 4) && score < 50) lateNight++;
      }
    }

    String summary = "";
    String advice = "";
    String proposal = "Để hiểu bạn sâu hơn, mình rất mong bạn chia sẻ thêm về: ";

    int nonsenseCount = 0;
    for (var e in entries) {
      final allTags = [
        ...List<String>.from(e['activities'] ?? []),
        ...List<String>.from(e['locations'] ?? []),
        ...List<String>.from(e['companions'] ?? []),
      ];
      nonsenseCount += allTags.where((t) => !_isMeaningful(t)).length;
    }

    final dist = calculateDistributionForEntries(entries);
    if (dist['Vui']! > 0.5) {
      summary = "Woa! dạo này bạn tràn đầy năng lượng tích cực luôn. Mình thấy rất vui khi thấy bạn hạnh phúc như vậy đấy! 🌟";
      advice = "Hãy tận dụng nguồn năng lượng này để hoàn thành những việc quan trọng hoặc đơn giản là lan tỏa niềm vui tới mọi người xung quanh nhé.";
    } else if (dist['Lo âu']! > 0.3 || dist['Buồn']! > 0.3) {
      summary = "Dạo này mình thấy tâm trạng bạn hơi trĩu nặng một chút. Đừng lo lắng quá nhé, mình luôn ở đây lắng nghe bạn mà. 🌿";
      advice = "Thử dành 5-10 phút để thiền hoặc đi dạo nhẹ nhàng xem sao? Những lúc như này, yêu thương bản thân là điều quan trọng nhất.";
    } else {
      summary = "Mọi thứ dường như đang diễn ra khá bình yên và ổn định với bạn. Một trạng thái cân bằng rất đáng quý đấy! 🧘‍♂️";
      advice = "Duy trì sự ổn định này bằng những thói quen tốt hiện tại bạn nhé.";
    }

    if (averageSleepHours < 6 && averageSleepHours > 0) {
      advice += "\n\n😴 Mình thấy bạn ngủ hơi ít (TB ${averageSleepHours.toStringAsFixed(1)}h). Thiếu ngủ có thể làm tâm trạng bạn dễ cáu gắt và mệt mỏi hơn đấy.";
    }
    
    if (nonsenseCount > 5) {
      advice += "\n\n⚠️ Lưu ý nhỏ: Mình thấy một số nhãn ghi chép dường như chưa có ý nghĩa rõ ràng. Thêm các nhãn cụ thể hơn sẽ giúp mình đưa ra những lời khuyên 'đốn tim' và chính xác hơn cho bạn nhé!";
    }

    if (workStress > 1) {
      advice += "\n\nMình nhận ra áp lực công việc hoặc deadline đang làm bạn mệt mỏi. Đừng quên nghỉ ngơi giữa giờ và hít thở sâu, bạn đã làm rất tốt rồi!";
    }
    if (financialStress > 0) {
      advice += "\n\nCó vẻ chuyện tài chính đang làm bạn bận tâm. Hãy thử lập kế hoạch chi tiêu nhỏ hoặc đơn giản là hít thở thật sâu để lấy lại bình tĩnh trước khi xử lý nhé.";
    }
    if (healthIssue > 0) {
      advice += "\n\nSức khỏe là vàng, đừng quên dành thời gian chăm sóc bản thân và nghỉ ngơi đầy đủ nếu cảm thấy không khỏe nhé.";
    }
    if (trafficStress > 0) {
      advice += "\n\nKẹt xe thật là một thử thách kiên nhẫn! Lần tới bạn thử nghe một bản nhạc yêu thích hoặc podcast để thời gian trôi qua nhẹ nhàng hơn xem sao.";
    }
    if (outdoorPositive > 0) {
      advice += "\n\nCứ tiếp tục vận động nhé! Đây chính là 'liều thuốc' tuyệt vời giúp tâm trạng bạn cải thiện rõ rệt đấy.";
    }

    List<String> neededData = [];
    if (lateNight > 0) {
      proposal += "Giờ ngủ cụ thể (để mình giúp bạn tối ưu giấc ngủ), ";
      advice += "\n\nNgủ đủ giấc sẽ giúp bạn có một tinh thần minh mẫn hơn vào ngày mai. Đêm nay hãy ngủ sớm một chút nhé! 🌙";
    }
    if (workStress > 0) neededData.add("Cảm xúc khi hoàn thành việc");
    if (entries.length < 10) neededData.add("Thêm nhiều nhãn chi tiết");
    
    proposal += neededData.isEmpty ? "Cảm xúc chi tiết sau mỗi sự kiện." : neededData.join(", ");

    return {
      'summary': summary,
      'advice': advice,
      'proposal': proposal,
    };
  }

  // Generate impact factors for analysis screen
  List<Map<String, dynamic>> calculateImpactFactors() {
    Map<String, int> positiveFactors = {};
    Map<String, int> negativeFactors = {};

    for (var e in entries) {
      final mood = e['mood'] ?? 'Bình thường';
      final activities = List<String>.from(e['activities'] ?? []);
      final locations = List<String>.from(e['locations'] ?? []);
      final companions = List<String>.from(e['companions'] ?? []);
      final score = getScore(mood);

      final allTags = [...activities, ...locations, ...companions]
          .where((t) => _isMeaningful(t)).toList();
      for (var tag in allTags) {
        if (score >= 80) positiveFactors[tag] = (positiveFactors[tag] ?? 0) + 1;
        if (score <= 40) negativeFactors[tag] = (negativeFactors[tag] ?? 0) + 1;
      }
    }

    List<Map<String, dynamic>> impacts = [];
    
    negativeFactors.forEach((key, value) {
      impacts.add({
        'title': key,
        'subtitle': 'Tần suất gây căng thẳng: ${value > 2 ? 'Cao' : 'Trung bình'}',
        'impact': '-${(value * 8).clamp(5, 40)}%',
        'colorValue': 0xFFF44336,
      });
    });

    positiveFactors.forEach((key, value) {
      impacts.add({
        'title': key,
        'subtitle': 'Nguồn cảm hứng tích cực',
        'impact': '+${(value * 10).clamp(5, 50)}%',
        'colorValue': 0xFF4CAF50,
      });
    });

    if (impacts.isEmpty) {
      impacts.add({
        'title': 'Đang phân tích...',
        'subtitle': 'Ghi thêm nhật ký để thấy rõ tác nhân nhé!',
        'impact': '0%',
        'colorValue': 0xFF9E9E9E,
      });
    }

    impacts.sort((a, b) => b['impact'].toString().compareTo(a['impact'].toString()));
    return impacts;
  }

  // Helper for dashboard chart
  List<double> calculateDailyAverages(int days) {
    if (entries.isEmpty) return List.filled(days, 70.0);
    
    final now = DateTime.now();
    List<double> averages = [];
    
    for (int i = days - 1; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayEntries = entries.where((e) {
        final ts = e['timestamp'] as Timestamp?;
        if (ts == null) return false;
        final d = ts.toDate();
        return d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day;
      }).toList();
      
      if (dayEntries.isEmpty) {
        averages.add(70.0);
      } else {
        double sum = 0;
        for (var e in dayEntries) sum += getScore(e['mood'] ?? 'Bình thường');
        averages.add(sum / dayEntries.length);
      }
    }
    return averages;
  }

  // Legacy distribution for dashboard
  Map<String, double> calculateDistribution() {
    return calculateDistributionForEntries(entries);
  }

  // Legacy dominant emotion getter
  String get dominantEmotion {
    final dist = calculateDistribution();
    var maxVal = -1.0;
    var dominant = "Bình thường";
    dist.forEach((key, value) {
      if (value > maxVal) {
        maxVal = value;
        dominant = key;
      }
    });
    return dominant;
  }

  // Aggregation helper for charts (within X minutes)
  List<Map<String, dynamic>> getAggregatedEntries(int intervalMinutes) {
    if (entries.isEmpty) return [];
    
    // entries is sorted descending, so we need reverse for chronological charts
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
    
    // Return last 7 groups by default for line charts
    return aggregated.length > 7 
        ? aggregated.sublist(aggregated.length - 7) 
        : aggregated;
  }
}

