import 'package:cloud_firestore/cloud_firestore.dart';

class AiInsightService {
  final List<Map<String, dynamic>> entries;

  AiInsightService(this.entries);

  Map<String, String> generateInsights() {
    if (entries.isEmpty) {
      return {
        'summary': "Chào bạn mới! Mình là người bạn AI của bạn đây. Hãy bắt đầu ghi chép để mình có thể đồng hành và hiểu bạn hơn nhé! ✨",
        'advice': "Mẹo nhỏ: Thêm nhãn về hoạt động sẽ giúp mình phân tích chính xác những gì làm bạn vui hay buồn đấy!",
        'proposal': "Mình cần thêm dữ liệu về: Hoạt động thường ngày, Thời gian ngủ và Những người bạn gặp."
      };
    }

    final analysis = _runAnalysis();
    return _buildResult(analysis);
  }

  Map<String, dynamic> _runAnalysis() {
    int workStress = 0, lateNight = 0, outdoorPositive = 0;
    int financialStress = 0, healthIssue = 0, trafficStress = 0;
    double totalSleep = 0;
    int sleepCount = 0;

    for (var e in entries) {
      final mood = e['mood'] ?? 'Bình thường';
      final activities = List<String>.from(e['activities'] ?? []);
      final note = (e['note'] ?? '').toString().toLowerCase();
      final score = _getMoodScore(mood);

      if (activities.contains('Công việc') && score < 50) {
        workStress++;
      }
      if (activities.contains('Vận động') && score >= 80) {
        outdoorPositive++;
      }
      
      if (note.contains('áp lực') || note.contains('mệt') || note.contains('deadline')) {
        workStress++;
      }
      if (note.contains('tiền') || note.contains('lương') || note.contains('chi phí')) {
        financialStress++;
      }
      if (note.contains('đau') || note.contains('ốm') || note.contains('bệnh')) {
        healthIssue++;
      }
      if (note.contains('kẹt xe') || note.contains('tắc đường')) {
        trafficStress++;
      }

      final sleep = (e['sleepHours'] as num?)?.toDouble();
      if (sleep != null) {
        totalSleep += sleep;
        sleepCount++;
      }

      final ts = e['timestamp'] as Timestamp?;
      if (ts != null) {
        final hour = ts.toDate().hour;
        if ((hour >= 23 || hour <= 4) && score < 50) {
          lateNight++;
        }
      }
    }

    return {
      'workStress': workStress,
      'lateNight': lateNight,
      'outdoorPositive': outdoorPositive,
      'financialStress': financialStress,
      'healthIssue': healthIssue,
      'trafficStress': trafficStress,
      'avgSleep': sleepCount > 0 ? totalSleep / sleepCount : 0.0,
      'distribution': _calculateDistribution(),
    };
  }

  Map<String, String> _buildResult(Map<String, dynamic> analysis) {
    String summary = "";
    String advice = "";
    String proposal = "Để hiểu bạn sâu hơn, mình mong bạn chia sẻ: ";

    final dist = analysis['distribution'] as Map<String, double>;
    final avgSleep = analysis['avgSleep'] as double;

    if (dist['Vui']! > 0.5) {
      summary = "Woa! Bạn đang tràn đầy năng lượng tích cực. Thật tuyệt vời! 🌟";
      advice = "Hãy lan tỏa niềm vui này nhé!";
    } else if (dist['Lo âu']! > 0.3 || dist['Buồn']! > 0.3) {
      summary = "Dạo này tâm trạng bạn hơi trĩu nặng. Mình luôn ở đây lắng nghe. 🌿";
      advice = "Thử dành 5 phút thiền hoặc đi dạo xem sao?";
    } else {
      summary = "Mọi thứ dường như đang cân bằng. Một trạng thái rất đáng quý! 🧘‍♂️";
      advice = "Duy trì thói quen tốt hiện tại bạn nhé.";
    }

    if (avgSleep < 6 && avgSleep > 0) {
      advice += "\n\n😴 Ngủ đủ giấc sẽ giúp tinh thần minh mẫn hơn.";
    }

    if (analysis['workStress'] > 1) {
      advice += "\n\nĐừng để áp lực công việc làm bạn quá tải. Hãy hít thở sâu!";
    }

    return {
      'summary': summary,
      'advice': advice,
      'proposal': '$proposal cảm xúc sau mỗi sự kiện.',
    };
  }

  double _getMoodScore(String mood) {
    const weights = {
      'Hạnh phúc': 100.0, 'Vui vẻ': 85.0, 'Bình thường': 70.0,
      'Lo lắng': 40.0, 'Buồn': 25.0, 'Căng thẳng': 20.0, 'Giận dữ': 10.0,
    };
    return weights[mood] ?? 70.0;
  }

  Map<String, double> _calculateDistribution() {
    int vui = 0, binhYen = 0, loAu = 0, buon = 0;
    if (entries.isEmpty) {
      return {'Vui': 0, 'Bình yên': 0, 'Lo âu': 0, 'Buồn': 0};
    }

    for (var e in entries) {
      final m = e['mood'] ?? 'Bình thường';
      if (['Hạnh phúc', 'Vui vẻ'].contains(m)) {
        vui++;
      } else if (['Bình thường'].contains(m)) {
        binhYen++;
      } else if (['Lo lắng', 'Căng thẳng'].contains(m)) {
        loAu++;
      } else if (['Buồn', 'Giận dữ'].contains(m)) {
        buon++;
      }
    }

    final total = entries.length;
    return {
      'Vui': vui / total,
      'Bình yên': binhYen / total,
      'Lo âu': loAu / total,
      'Buồn': buon / total,
    };
  }
}
