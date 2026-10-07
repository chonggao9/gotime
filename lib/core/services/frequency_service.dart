import '../../models/habit.dart';
import '../../models/check_in.dart';

class WeeklyProgress {
  final int completedCount;
  final int targetCount;
  final bool isMet;
  final double ratio;

  const WeeklyProgress({
    required this.completedCount,
    required this.targetCount,
    required this.isMet,
    required this.ratio,
  });
}

/// 灵活周期打卡频次计算服务 (支持每周 X 次、指定工作日等调度)
class FrequencyService {
  FrequencyService._();
  static final FrequencyService instance = FrequencyService._();

  /// 获取指定日期所在周的周一 00:00:00
  DateTime getStartOfWeek(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(start.year, start.month, start.day);
  }

  /// 获取指定日期所在周的周日 23:59:59
  DateTime getEndOfWeek(DateTime date) {
    final end = getStartOfWeek(date).add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  /// 计算习惯在当前周的实际完成次数与目标
  WeeklyProgress calculateWeeklyProgress(
    Habit habit,
    List<CheckIn> checkIns, {
    DateTime? referenceDate,
  }) {
    final date = referenceDate ?? DateTime.now();
    final start = getStartOfWeek(date);
    final end = getEndOfWeek(date);

    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final weeklyCheckIns = checkIns.where((c) {
      return c.habitId == habit.id &&
          c.status == CheckInStatus.completed &&
          c.date.compareTo(startStr) >= 0 &&
          c.date.compareTo(endStr) <= 0;
    }).toList();

    final completedCount = weeklyCheckIns.length;
    final int targetCount;

    if (habit.frequencyType == 'flexible_weekly') {
      targetCount = habit.targetTimesPerPeriod;
    } else if (habit.frequencyType == 'weekly_days') {
      targetCount = habit.targetDaysOfWeek.isEmpty ? 7 : habit.targetDaysOfWeek.length;
    } else {
      // 默认每日
      targetCount = 7;
    }

    final isMet = completedCount >= targetCount;
    final ratio = targetCount > 0 ? (completedCount / targetCount).clamp(0.0, 1.0) : 0.0;

    return WeeklyProgress(
      completedCount: completedCount,
      targetCount: targetCount,
      isMet: isMet,
      ratio: ratio,
    );
  }

  /// 判断指定日期是否应当打卡该习惯
  bool isScheduledForDate(Habit habit, DateTime date) {
    final type = habit.frequencyType;
    if (type == 'daily' || type == 'everyday') {
      return true;
    }
    if (type == 'weekly_days') {
      return habit.targetDaysOfWeek.contains(date.weekday);
    }
    if (type == 'flexible_weekly') {
      // 灵活每周 X 次：任何一天均可安排打卡
      return true;
    }
    return true;
  }
}
