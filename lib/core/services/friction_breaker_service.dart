import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/habit.dart';

/// 《原子习惯》两分钟定律与心理阻力破壁服务 (Two-Minute Rule & Friction Breaker)
class FrictionBreakerService extends ChangeNotifier {
  FrictionBreakerService._();
  static final FrictionBreakerService instance = FrictionBreakerService._();

  static const int totalDurationSeconds = 120; // 2 分钟 = 120 秒

  int _remainingSeconds = totalDurationSeconds;
  bool _isRunning = false;
  Timer? _timer;
  Habit? _activeHabit;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isCompleted => _remainingSeconds <= 0;
  Habit? get activeHabit => _activeHabit;
  double get progress => (totalDurationSeconds - _remainingSeconds) / totalDurationSeconds;

  /// 根据习惯特征智能推导专属的“两分钟微启动”建议
  String getMicroActionSuggestion(Habit habit) {
    final name = habit.name.toLowerCase();

    if (name.contains('读') || name.contains('书') || name.contains('看')) {
      return '只读 1 页书，读完随时可收工，重点在于开启书籍';
    }
    if (name.contains('跑') || name.contains('步') || name.contains('跑') || name.contains('动') || name.contains('练')) {
      return '换好跑鞋并在原地轻松活动 2 分钟，起步即破壁';
    }
    if (name.contains('写') || name.contains('作') || name.contains('工') || name.contains('日记')) {
      return '打开文档只敲下第 1 行句子或列出 3 个关键词草稿，专注 2 分钟';
    }
    if (name.contains('水') || name.contains('喝')) {
      return '倒上半杯温水慢慢喝完，润喉醒脑';
    }
    if (name.contains('冥想') || name.contains('禅') || name.contains('呼') || name.contains('息')) {
      return '闭上眼睛完成 3 次舒缓的 4-7-8 腹式深呼吸';
    }
    if (habit.type == HabitType.timer) {
      return '只专注进入状态 2 分钟，计时结束随时可以停下';
    }
    if (habit.type == HabitType.counter) {
      final unit = habit.targetUnit ?? '个';
      return '完成 1 个极小单元即可（如先做 1 $unit）';
    }
    return '开启 2 分钟微习惯启动版本，万事开头难，动起来就赢了！';
  }

  void startSession(Habit habit) {
    _stopTimer();
    _activeHabit = habit;
    _remainingSeconds = totalDurationSeconds;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds -= 1;
        notifyListeners();
        if (_remainingSeconds == 0) {
          _isRunning = false;
          _stopTimer();
          notifyListeners();
        }
      }
    });
    notifyListeners();
  }

  void togglePause() {
    if (_isRunning) {
      _stopTimer();
      _isRunning = false;
    } else if (_remainingSeconds > 0 && _activeHabit != null) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds -= 1;
          notifyListeners();
          if (_remainingSeconds == 0) {
            _isRunning = false;
            _stopTimer();
            notifyListeners();
          }
        }
      });
    }
    notifyListeners();
  }

  void stopSession() {
    _stopTimer();
    _isRunning = false;
    _remainingSeconds = totalDurationSeconds;
    _activeHabit = null;
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
