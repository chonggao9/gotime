import 'package:flutter/material.dart';
import '../../models/check_in.dart';

class PixelDay {
  final DateTime date;
  final int completedCount;
  final bool isSkipped;
  final double? averageMood;
  final double ratio;
  final Color color;

  const PixelDay({
    required this.date,
    required this.completedCount,
    required this.isSkipped,
    this.averageMood,
    required this.ratio,
    required this.color,
  });

  String get dateString => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class AnnualStats {
  final int totalDaysLogged;
  final int fullyCompletedDays;
  final int skippedDays;
  final double overallFulfillment;

  const AnnualStats({
    required this.totalDaysLogged,
    required this.fullyCompletedDays,
    required this.skippedDays,
    required this.overallFulfillment,
  });
}

/// 年度像素年鉴服务
class YearInPixelsService {
  YearInPixelsService._();
  static final YearInPixelsService instance = YearInPixelsService._();

  /// 计算某天的像素颜色
  Color calculatePixelColor({
    required double ratio,
    required bool isSkipped,
    bool isDark = true,
  }) {
    if (isSkipped) {
      return const Color(0xFF38BDF8); // 冰蓝：免责休假日
    }
    if (ratio >= 1.0) {
      return const Color(0xFF10B981); // 翠绿：完美达成
    }
    if (ratio >= 0.6) {
      return const Color(0xFF34D399); // 薄荷绿：良好
    }
    if (ratio >= 0.3) {
      return const Color(0xFFFBBF24); // 暖黄：部分完成
    }
    if (ratio > 0.0) {
      return const Color(0xFFF87171); // 珊瑚红：起步阶段
    }
    return isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB); // 休息空白日
  }

  /// 构建全年像素数据
  Map<int, List<PixelDay>> generateYearGrid({
    int? year,
    required List<CheckIn> checkIns,
    int totalDailyHabitsTarget = 3,
    bool isDark = true,
  }) {
    final targetYear = year ?? DateTime.now().year;
    final Map<int, List<PixelDay>> grid = {};

    // 预聚合打卡数据为 map: "YYYY-MM-DD" -> List<CheckIn>
    final checkInsByDate = <String, List<CheckIn>>{};
    for (final c in checkIns) {
      checkInsByDate.putIfAbsent(c.date, () => []).add(c);
    }

    for (int month = 1; month <= 12; month++) {
      final daysInMonth = DateUtils.getDaysInMonth(targetYear, month);
      final monthDays = <PixelDay>[];

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(targetYear, month, day);
        final dateKey = '$targetYear-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final dayLogs = checkInsByDate[dateKey] ?? [];

        final completed = dayLogs.where((l) => l.status == CheckInStatus.completed).length;
        final hasSkipped = dayLogs.any((l) => l.status == CheckInStatus.skipped);

        final target = totalDailyHabitsTarget > 0 ? totalDailyHabitsTarget : 1;
        final ratio = (completed / target).clamp(0.0, 1.0);

        // 心情均值
        final moods = dayLogs.where((l) => l.mood != null).map((l) => l.mood!).toList();
        final avgMood = moods.isNotEmpty ? moods.reduce((a, b) => a + b) / moods.length : null;

        final color = calculatePixelColor(
          ratio: ratio,
          isSkipped: hasSkipped,
          isDark: isDark,
        );

        monthDays.add(PixelDay(
          date: date,
          completedCount: completed,
          isSkipped: hasSkipped,
          averageMood: avgMood,
          ratio: ratio,
          color: color,
        ));
      }

      grid[month] = monthDays;
    }

    return grid;
  }

  /// 计算全年汇总指标
  AnnualStats calculateAnnualStats(Map<int, List<PixelDay>> grid) {
    int totalLogged = 0;
    int fullyDone = 0;
    int skipped = 0;
    double totalRatio = 0.0;
    int eligibleDays = 0;

    final today = DateTime.now();

    for (final monthDays in grid.values) {
      for (final p in monthDays) {
        if (p.date.isAfter(today)) continue;
        eligibleDays++;
        if (p.completedCount > 0 || p.isSkipped) {
          totalLogged++;
        }
        if (p.ratio >= 1.0) {
          fullyDone++;
        }
        if (p.isSkipped) {
          skipped++;
        }
        totalRatio += p.ratio;
      }
    }

    final fulfillment = eligibleDays > 0 ? (totalRatio / eligibleDays) : 0.0;

    return AnnualStats(
      totalDaysLogged: totalLogged,
      fullyCompletedDays: fullyDone,
      skippedDays: skipped,
      overallFulfillment: fulfillment,
    );
  }
}
