import 'package:flutter/foundation.dart';
import '../../models/habit.dart';
import '../../models/check_in.dart';
import '../database/sqlite_service.dart';
import 'package:uuid/uuid.dart';

enum WatchFormFactor {
  squircle(name: 'Apple Watch (方形)', bezelRadius: 54.0),
  round(name: 'Pixel / Galaxy Watch (圆形)', bezelRadius: 130.0);

  final String name;
  final double bezelRadius;

  const WatchFormFactor({required this.name, required this.bezelRadius});
}

/// 智能手表微端与表盘插件服务 (watchOS & Wear OS Companion)
class WatchCompanionService extends ChangeNotifier {
  WatchCompanionService._();
  static final WatchCompanionService instance = WatchCompanionService._();

  WatchFormFactor _formFactor = WatchFormFactor.squircle;
  final Set<String> _todayWatchCompletedIds = {};
  bool _isHapticCrownEnabled = true;

  WatchFormFactor get formFactor => _formFactor;
  Set<String> get todayWatchCompletedIds => _todayWatchCompletedIds;
  bool get isHapticCrownEnabled => _isHapticCrownEnabled;

  void setFormFactor(WatchFormFactor factor) {
    _formFactor = factor;
    notifyListeners();
  }

  void setHapticCrownEnabled(bool enabled) {
    _isHapticCrownEnabled = enabled;
    notifyListeners();
  }

  /// 筛选同步到智能手表的微习惯（置顶优先，最多 4 个）
  List<Habit> getWatchHabits(List<Habit> allHabits) {
    final active = allHabits.where((h) => !h.isArchived).toList();
    active.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return active.take(4).toList();
  }

  bool isCompleted(String habitId) {
    return _todayWatchCompletedIds.contains(habitId);
  }

  /// 手表端即时打卡切换
  Future<bool> toggleWatchCheckIn(Habit habit, {String? dateStr}) async {
    final date = dateStr ?? DateTime.now().toIso8601String().split('T')[0];
    final isDone = _todayWatchCompletedIds.contains(habit.id);

    if (isDone) {
      _todayWatchCompletedIds.remove(habit.id);
    } else {
      _todayWatchCompletedIds.add(habit.id);
    }
    notifyListeners();

    if (!kIsWeb) {
      try {
        if (!isDone) {
          final checkIn = CheckIn(
            id: const Uuid().v4(),
            habitId: habit.id,
            date: date,
            status: CheckInStatus.completed,
            logText: '来自智能手表腕上即时打卡 ⌚',
            mood: 5,
            createdAt: DateTime.now(),
          );
          await SQLiteService.instance.insertCheckIn(checkIn);
        }
      } catch (_) {}
    }

    return !isDone;
  }
}
