import 'package:flutter/foundation.dart';

/// 破戒复盘记录
class RelapseRecord {
  final DateTime timestamp;
  final String trigger; // 诱因: 压力、无聊、情绪低落、聚会诱惑等
  final String note;

  RelapseRecord({
    required this.timestamp,
    required this.trigger,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'trigger': trigger,
    'note': note,
  };

  factory RelapseRecord.fromJson(Map<String, dynamic> json) => RelapseRecord(
    timestamp: DateTime.parse(json['timestamp'] as String),
    trigger: json['trigger'] as String? ?? '情绪冲动',
    note: json['note'] as String? ?? '',
  );
}

/// 坏习惯戒除进度模型
class QuitHabitProgress {
  final String habitId;
  final DateTime startedAt;
  final DateTime? lastRelapseAt;
  final List<RelapseRecord> history;

  QuitHabitProgress({
    required this.habitId,
    required this.startedAt,
    this.lastRelapseAt,
    this.history = const [],
  });

  /// 已坚持天数
  int get daysClean {
    final reference = lastRelapseAt ?? startedAt;
    final diff = DateTime.now().difference(reference);
    return diff.inDays >= 0 ? diff.inDays : 0;
  }

  /// 剩余小时数
  int get hoursCleanRemainder {
    final reference = lastRelapseAt ?? startedAt;
    final diff = DateTime.now().difference(reference);
    return (diff.inHours % 24);
  }

  /// 已坚持时长描述
  String get formattedCleanDuration {
    final days = daysClean;
    final hours = hoursCleanRemainder;
    if (days == 0) {
      return '$hours 小时';
    }
    return '$days 天 $hours 小时';
  }
}

/// 坏习惯戒除服务
class QuitHabitService extends ChangeNotifier {
  QuitHabitService._();
  static final QuitHabitService instance = QuitHabitService._();

  final Map<String, QuitHabitProgress> _cache = {};

  QuitHabitProgress getProgress(String habitId, DateTime fallbackCreatedAt) {
    if (!_cache.containsKey(habitId)) {
      // 默认从习惯创建时开始算起
      _cache[habitId] = QuitHabitProgress(
        habitId: habitId,
        startedAt: fallbackCreatedAt,
      );
    }
    return _cache[habitId]!;
  }

  /// 记录一次破戒，重置计时
  void recordRelapse(
    String habitId, {
    String trigger = '压力与情绪波动',
    String note = '',
  }) {
    final now = DateTime.now();
    final current = _cache[habitId] ??
        QuitHabitProgress(habitId: habitId, startedAt: now);

    final record = RelapseRecord(
      timestamp: now,
      trigger: trigger,
      note: note,
    );

    final updatedHistory = List<RelapseRecord>.from(current.history)
      ..insert(0, record);

    _cache[habitId] = QuitHabitProgress(
      habitId: habitId,
      startedAt: current.startedAt,
      lastRelapseAt: now,
      history: updatedHistory,
    );

    notifyListeners();
  }

  /// 重置重新启航
  void resetToNow(String habitId) {
    recordRelapse(habitId, trigger: '自我重启', note: '从头再来，允许不完美');
  }

  /// 设置自定义起始时间
  void setCustomStartDate(String habitId, DateTime customStartDate) {
    _cache[habitId] = QuitHabitProgress(
      habitId: habitId,
      startedAt: customStartDate,
      lastRelapseAt: null,
      history: _cache[habitId]?.history ?? [],
    );
    notifyListeners();
  }
}
