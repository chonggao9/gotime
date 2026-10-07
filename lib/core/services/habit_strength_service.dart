import '../../models/check_in.dart';

/// 习惯强度与动量计算服务 (基于指数平滑算法 Exponential Smoothing)
/// 灵感来源：开源 Loop Habit Tracker (iSoron/uhabits) 与《原子习惯》
/// 核心理念：抗焦虑。漏打一天仅轻微衰减，次日继续可快速回升，拒绝断签归零挫败感。
class HabitStrengthService {
  /// 衰减平滑系数 (Alpha)，默认 0.94
  /// 相当于习惯半衰期约为 11~14 天
  static const double defaultAlpha = 0.94;

  /// 计算单个习惯的历史强度分数 (0.0 ~ 1.0)
  /// [checkIns]: 针对该习惯的历史所有打卡记录
  /// [asOfDate]: 截止计算日期，默认今天
  /// [days]: 回溯历史天数，默认 60 天
  static double calculateStrength(
    List<CheckIn> checkIns, {
    DateTime? asOfDate,
    int days = 60,
    double alpha = defaultAlpha,
  }) {
    if (checkIns.isEmpty) return 0.0;

    final today = asOfDate ?? DateTime.now();
    
    // 按日期字符串映射每日状态
    final Map<String, CheckIn> dateMap = {
      for (final checkIn in checkIns) checkIn.date: checkIn
    };

    double score = 0.0;

    // 从过去 days 天一直模拟平滑演进到今天
    for (int i = days; i >= 0; i--) {
      final curDate = today.subtract(Duration(days: i));
      final dateKey = curDate.toIso8601String().split('T')[0];
      final record = dateMap[dateKey];

      if (record != null) {
        if (record.status == CheckInStatus.completed) {
          // 满分完成
          score = score * alpha + 1.0 * (1.0 - alpha);
        } else if (record.status == CheckInStatus.partial) {
          // 部分完成 (取 0.5 作为过渡)
          score = score * alpha + 0.5 * (1.0 - alpha);
        } else if (record.status == CheckInStatus.skipped) {
          // 请假/休假免责保护：不扣减强度，保持前一天的分数！
          score = score;
        }
      } else {
        // 当天未打卡：衰减
        score = score * alpha;
      }

      // 截断在 [0.0, 1.0] 范围内
      if (score < 0.0) score = 0.0;
      if (score > 1.0) score = 1.0;
    }

    return score;
  }

  /// 计算习惯当前连胜天数（特别考虑休假/请假冻结不中断原则）
  static int calculateStreak(List<CheckIn> checkIns, {DateTime? asOfDate}) {
    if (checkIns.isEmpty) return 0;

    final today = asOfDate ?? DateTime.now();
    final Map<String, CheckIn> dateMap = {
      for (final checkIn in checkIns) checkIn.date: checkIn
    };

    int streak = 0;
    // 检查今天是否打卡，未打卡则从昨天开始算
    final todayKey = today.toIso8601String().split('T')[0];
    int startOffset = 0;
    if (dateMap[todayKey]?.status != CheckInStatus.completed &&
        dateMap[todayKey]?.status != CheckInStatus.skipped) {
      startOffset = 1; // 今天还没打卡，检查昨天的连胜
    }

    for (int i = startOffset; i < 365; i++) {
      final curDate = today.subtract(Duration(days: i));
      final dateKey = curDate.toIso8601String().split('T')[0];
      final record = dateMap[dateKey];

      if (record != null) {
        if (record.status == CheckInStatus.completed) {
          streak++;
        } else if (record.status == CheckInStatus.skipped) {
          // 休假/跳过免责：不断签，计入保留或不增加天数
          streak++;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return streak;
  }

  /// 习惯强度级别文案（符合经典 21 天习惯成型模型）
  static String getStrengthLabel(double strength) {
    if (strength >= 0.80) return '💎 磐石阶段';
    if (strength >= 0.50) return '🌿 稳步成型';
    if (strength >= 0.25) return '🌱 破土萌芽';
    return '🌰 播种起步';
  }

  /// 习惯强度心理抚慰文案
  static String getStrengthTip(double strength) {
    if (strength >= 0.80) {
      return '这个习惯已深深烙印在你的潜意识中，即使偶尔暂停一天也能轻松回归。';
    } else if (strength >= 0.50) {
      return '正处于自动化形成期，保持当前节奏，动量持续累积中。';
    } else if (strength >= 0.25) {
      return '你已经迈出了最难的第一步，请记住：允许偶尔不完美，重要的是明天继续。';
    }
    return '万事开头难，把目标切得更小一点（微习惯），更容易坚持哦。';
  }
}
