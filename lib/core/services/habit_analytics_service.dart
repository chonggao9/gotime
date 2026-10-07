import '../../models/check_in.dart';

class DayOfWeekStat {
  final int weekday; // 1 = 周一, 7 = 周日
  final String label;
  final int completedCount;
  final double rate; // 0.0 ~ 1.0

  DayOfWeekStat({
    required this.weekday,
    required this.label,
    required this.completedCount,
    required this.rate,
  });
}

class HabitAnalyticsReport {
  final List<DayOfWeekStat> dayStats;
  final int bestWeekday;
  final String bestWeekdayName;
  final double averageMood;
  final String insightMessage;

  HabitAnalyticsReport({
    required this.dayStats,
    required this.bestWeekday,
    required this.bestWeekdayName,
    required this.averageMood,
    required this.insightMessage,
  });
}

/// 习惯深度节律、周中完成率分布与情绪相关性分析服务
class HabitAnalyticsService {
  HabitAnalyticsService._();
  static final HabitAnalyticsService instance = HabitAnalyticsService._();

  static const List<String> weekdayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  /// 分析周一到周日的打卡完成分布及情绪关联
  HabitAnalyticsReport analyzeCheckIns(List<CheckIn> checkIns) {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final moodValues = <int>[];

    for (final c in checkIns) {
      if (c.status == CheckInStatus.completed) {
        try {
          final parts = c.date.split('-');
          if (parts.length == 3) {
            final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            counts[dt.weekday] = (counts[dt.weekday] ?? 0) + 1;
          }
        } catch (_) {}

        if (c.mood != null && c.mood! >= 1 && c.mood! <= 5) {
          moodValues.add(c.mood!);
        }
      }
    }

    final maxCount = counts.values.fold<int>(0, (prev, val) => val > prev ? val : prev);

    final dayStats = <DayOfWeekStat>[];
    int bestWeekday = 1;
    int bestCount = -1;

    for (int i = 1; i <= 7; i++) {
      final count = counts[i] ?? 0;
      final rate = maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;
      dayStats.add(DayOfWeekStat(
        weekday: i,
        label: weekdayLabels[i - 1],
        completedCount: count,
        rate: rate,
      ));

      if (count > bestCount) {
        bestCount = count;
        bestWeekday = i;
      }
    }

    final avgMood = moodValues.isNotEmpty
        ? (moodValues.reduce((a, b) => a + b) / moodValues.length)
        : 4.2;

    final insight = _generateInsight(bestWeekday, dayStats);

    return HabitAnalyticsReport(
      dayStats: dayStats,
      bestWeekday: bestWeekday,
      bestWeekdayName: weekdayLabels[bestWeekday - 1],
      averageMood: avgMood,
      insightMessage: insight,
    );
  }

  String _generateInsight(int bestWeekday, List<DayOfWeekStat> stats) {
    final bestName = weekdayLabels[bestWeekday - 1];
    final weekendCount = (stats[5].completedCount + stats[6].completedCount);
    final weekdayCount = stats.take(5).fold<int>(0, (sum, s) => sum + s.completedCount);

    if (bestWeekday <= 5) {
      if (weekendCount < weekdayCount * 0.3) {
        return '$bestName是你的巅峰自律日！工作日专注度极高，周末适度放慢步调更有利于长期自律充电。';
      }
      return '$bestName是你的最佳心流日！保持当下的生活节律，自然形成无痛习惯闭环。';
    } else {
      return '$bestName完成率尤为亮眼！说明你善于利用周末打造个人高质量自律时光。';
    }
  }
}
