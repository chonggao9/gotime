import 'package:flutter/foundation.dart';
import '../database/sqlite_service.dart';
import '../../models/habit.dart';
import '../../models/check_in.dart';
import 'package:uuid/uuid.dart';

enum HealthDataType {
  steps(name: '每日步数', unit: '步', defaultTarget: 8000, iconEmoji: '👟'),
  sleep(name: '睡眠时长', unit: '分钟', defaultTarget: 480, iconEmoji: '🌙'),
  activeCalories(name: '动态卡路里', unit: '千卡', defaultTarget: 400, iconEmoji: '🔥');

  final String name;
  final String unit;
  final int defaultTarget;
  final String iconEmoji;

  const HealthDataType({
    required this.name,
    required this.unit,
    required this.defaultTarget,
    required this.iconEmoji,
  });
}

class HealthSyncResult {
  final bool isTriggered;
  final int currentValue;
  final String message;

  const HealthSyncResult({
    required this.isTriggered,
    required this.currentValue,
    required this.message,
  });
}

/// 智能健康中心 (Apple Health / Health Connect) 数据同步与自动打卡服务
class HealthSyncService extends ChangeNotifier {
  HealthSyncService._();
  static final HealthSyncService instance = HealthSyncService._();

  bool _isAutoSyncEnabled = false;
  int _simulatedSteps = 8620; // 模拟当前步数
  int _simulatedSleepMinutes = 490; // 模拟当前睡眠 8.1 小时
  DateTime? _lastSyncTime;

  bool get isAutoSyncEnabled => _isAutoSyncEnabled;
  int get simulatedSteps => _simulatedSteps;
  int get simulatedSleepMinutes => _simulatedSleepMinutes;
  DateTime? get lastSyncTime => _lastSyncTime;

  void setAutoSyncEnabled(bool enabled) {
    _isAutoSyncEnabled = enabled;
    notifyListeners();
  }

  void updateSimulatedHealthData({int? steps, int? sleepMinutes}) {
    if (steps != null) _simulatedSteps = steps;
    if (sleepMinutes != null) _simulatedSleepMinutes = sleepMinutes;
    notifyListeners();
  }

  /// 检查并自动为绑定的习惯执行健康达标打卡
  Future<List<HealthSyncResult>> checkAndAutoCheckIn(List<Habit> activeHabits) async {
    final results = <HealthSyncResult>[];
    _lastSyncTime = DateTime.now();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    for (final habit in activeHabits) {
      if (habit.type != HabitType.counter || habit.targetValue == null) continue;

      // 智能识别习惯名称中的健康关键词（步数、走、跑步、睡眠）
      final nameLower = habit.name.toLowerCase();
      final isStepsHabit = nameLower.contains('步') || nameLower.contains('走') || nameLower.contains('step');
      final isSleepHabit = nameLower.contains('睡') || nameLower.contains('sleep') || nameLower.contains('眠');

      if (isStepsHabit && _simulatedSteps >= habit.targetValue!) {
        // 步数达标，自动写入打卡记录
        final checkIn = CheckIn(
          id: const Uuid().v4(),
          habitId: habit.id,
          date: todayStr,
          status: CheckInStatus.completed,
          value: _simulatedSteps,
          logText: 'Health Connect 自动感应：今日已行走 $_simulatedSteps 步，达成目标 👟',
          mood: 5,
          createdAt: DateTime.now(),
        );

        if (!kIsWeb) {
          try {
            await SQLiteService.instance.insertCheckIn(checkIn);
          } catch (_) {}
        }

        results.add(HealthSyncResult(
          isTriggered: true,
          currentValue: _simulatedSteps,
          message: '习惯「${habit.name}」已根据今日步数 ($_simulatedSteps 步) 自动打卡！',
        ));
      } else if (isSleepHabit && _simulatedSleepMinutes >= habit.targetValue!) {
        // 睡眠达标，自动写入打卡记录
        final hours = (_simulatedSleepMinutes / 60).toStringAsFixed(1);
        final checkIn = CheckIn(
          id: const Uuid().v4(),
          habitId: habit.id,
          date: todayStr,
          status: CheckInStatus.completed,
          value: _simulatedSleepMinutes,
          logText: 'Apple Health 睡眠监测：昨晚睡眠 $hours 小时，达成目标 🌙',
          mood: 5,
          createdAt: DateTime.now(),
        );

        if (!kIsWeb) {
          try {
            await SQLiteService.instance.insertCheckIn(checkIn);
          } catch (_) {}
        }

        results.add(HealthSyncResult(
          isTriggered: true,
          currentValue: _simulatedSleepMinutes,
          message: '习惯「${habit.name}」已根据昨晚睡眠 ($hours 小时) 自动打卡！',
        ));
      }
    }

    notifyListeners();
    return results;
  }
}
