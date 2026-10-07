import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../models/check_in.dart';
import 'webdav_service.dart';
import 'freeze_mode_service.dart';

class MilestoneBadge {
  final String id;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final Color badgeColor;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int currentValue;
  final int targetValue;
  final String unit;

  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.badgeColor,
    required this.isUnlocked,
    this.unlockedDate,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

/// 自律里程碑与成就勋章服务
class MilestoneService extends ChangeNotifier {
  MilestoneService._();
  static final MilestoneService instance = MilestoneService._();

  List<MilestoneBadge> getBadges({
    required List<Habit> habits,
    required List<CheckIn> checkIns,
    int maxStreak = 0,
    int totalFocusMinutes = 0,
  }) {
    final completedCount = checkIns.where((c) => c.status == CheckInStatus.completed).length;
    final hasFreezeEver = FreezeModeService.instance.isFreezeModeActive.value ||
        checkIns.any((c) => c.status == CheckInStatus.skipped);
    final hasWebDavOrBackup = WebDavService.instance.isConfigured;
    final hasStackedHabit = habits.any((h) => h.stackedAfterHabitId != null);

    // 计算专注时长（分钟）
    final totalFocusFromLogs = checkIns
        .where((c) => c.durationSeconds != null && c.durationSeconds! > 0)
        .fold<int>(0, (sum, c) => sum + (c.durationSeconds! ~/ 60));
    final effectiveFocusMinutes = totalFocusMinutes > totalFocusFromLogs ? totalFocusMinutes : totalFocusFromLogs;

    return [
      MilestoneBadge(
        id: 'seedling',
        title: '萌芽破晓',
        subtitle: '完成人生第一个微习惯打卡',
        iconEmoji: '🌱',
        badgeColor: const Color(0xFF10B981),
        isUnlocked: completedCount >= 1,
        unlockedDate: completedCount >= 1 ? DateTime.now() : null,
        currentValue: completedCount.clamp(0, 1),
        targetValue: 1,
        unit: '次',
      ),
      MilestoneBadge(
        id: 'streak_7',
        title: '7日破壁',
        subtitle: '单项习惯达成连续 7 天不间断',
        iconEmoji: '⚡',
        badgeColor: const Color(0xFFF59E0B),
        isUnlocked: maxStreak >= 7,
        unlockedDate: maxStreak >= 7 ? DateTime.now() : null,
        currentValue: maxStreak.clamp(0, 7),
        targetValue: 7,
        unit: '天',
      ),
      MilestoneBadge(
        id: 'habit_21',
        title: '21日筑基',
        subtitle: '跨过科学认知门槛，建立稳固大脑回路',
        iconEmoji: '🧱',
        badgeColor: const Color(0xFF3B82F6),
        isUnlocked: maxStreak >= 21 || completedCount >= 21,
        unlockedDate: (maxStreak >= 21 || completedCount >= 21) ? DateTime.now() : null,
        currentValue: (maxStreak >= 21 ? maxStreak : completedCount).clamp(0, 21),
        targetValue: 21,
        unit: '天',
      ),
      MilestoneBadge(
        id: 'century_100',
        title: '百日自律',
        subtitle: '累计完成 100 次打卡，量变引发质变',
        iconEmoji: '💯',
        badgeColor: const Color(0xFFEC4899),
        isUnlocked: completedCount >= 100,
        unlockedDate: completedCount >= 100 ? DateTime.now() : null,
        currentValue: completedCount.clamp(0, 100),
        targetValue: 100,
        unit: '次',
      ),
      MilestoneBadge(
        id: 'zen_master',
        title: '深度心流',
        subtitle: '番茄钟专注累计超过 120 分钟',
        iconEmoji: '🧘',
        badgeColor: const Color(0xFF8B5CF6),
        isUnlocked: effectiveFocusMinutes >= 120,
        unlockedDate: effectiveFocusMinutes >= 120 ? DateTime.now() : null,
        currentValue: effectiveFocusMinutes.clamp(0, 120),
        targetValue: 120,
        unit: '分',
      ),
      MilestoneBadge(
        id: 'self_compassion',
        title: '从容自洽',
        subtitle: '开启生病休假免责，绝不被自律所奴役',
        iconEmoji: '❄️',
        badgeColor: const Color(0xFF06B6D4),
        isUnlocked: hasFreezeEver,
        unlockedDate: hasFreezeEver ? DateTime.now() : null,
        currentValue: hasFreezeEver ? 1 : 0,
        targetValue: 1,
        unit: '次',
      ),
      MilestoneBadge(
        id: 'stacking_pro',
        title: '原子堆叠',
        subtitle: '设置习惯锚点触发器，借力已有日常',
        iconEmoji: '🧩',
        badgeColor: const Color(0xFFF97316),
        isUnlocked: hasStackedHabit,
        unlockedDate: hasStackedHabit ? DateTime.now() : null,
        currentValue: hasStackedHabit ? 1 : 0,
        targetValue: 1,
        unit: '个',
      ),
      MilestoneBadge(
        id: 'data_sovereign',
        title: '数据主权',
        subtitle: '启用 WebDAV 备份，数据掌握在自己手中',
        iconEmoji: '☁️',
        badgeColor: const Color(0xFF64748B),
        isUnlocked: hasWebDavOrBackup,
        unlockedDate: hasWebDavOrBackup ? DateTime.now() : null,
        currentValue: hasWebDavOrBackup ? 1 : 0,
        targetValue: 1,
        unit: '项',
      ),
    ];
  }
}
