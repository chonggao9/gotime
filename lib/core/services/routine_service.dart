import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/habit.dart';

enum RoutineStatus { idle, running, paused, completed }

class RoutineStep {
  final Habit habit;
  bool isCompleted;
  int elapsedSeconds;

  RoutineStep({
    required this.habit,
    this.isCompleted = false,
    this.elapsedSeconds = 0,
  });
}

/// 习惯仪式引导服务
class RoutineService extends ChangeNotifier {
  RoutineService._();
  static final RoutineService instance = RoutineService._();

  RoutineStatus _status = RoutineStatus.idle;
  String _routineTitle = '晨间心流仪式';
  List<RoutineStep> _steps = [];
  int _currentIndex = 0;
  Timer? _timer;

  RoutineStatus get status => _status;
  String get routineTitle => _routineTitle;
  List<RoutineStep> get steps => List.unmodifiable(_steps);
  int get currentIndex => _currentIndex;
  bool get isActive => _status == RoutineStatus.running || _status == RoutineStatus.paused;

  RoutineStep? get currentStep {
    if (_steps.isEmpty || _currentIndex < 0 || _currentIndex >= _steps.length) {
      return null;
    }
    return _steps[_currentIndex];
  }

  double get overallProgress {
    if (_steps.isEmpty) return 0.0;
    final done = _steps.where((s) => s.isCompleted).length;
    return done / _steps.length;
  }

  void startRoutine(List<Habit> habits, {String title = '日常心流仪式'}) {
    if (habits.isEmpty) return;

    _stopTimer();
    _routineTitle = title;
    _steps = habits.map((h) => RoutineStep(habit: h)).toList();
    _currentIndex = 0;
    _status = RoutineStatus.running;

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == RoutineStatus.running && currentStep != null) {
        currentStep!.elapsedSeconds += 1;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void togglePause() {
    if (_status == RoutineStatus.running) {
      _status = RoutineStatus.paused;
    } else if (_status == RoutineStatus.paused) {
      _status = RoutineStatus.running;
    }
    notifyListeners();
  }

  /// 完成当前步骤并跳转下一步
  bool completeCurrentStep() {
    if (currentStep == null) return false;

    currentStep!.isCompleted = true;

    if (_currentIndex + 1 < _steps.length) {
      _currentIndex += 1;
      notifyListeners();
      return true; // 还有后续步骤
    } else {
      _status = RoutineStatus.completed;
      _stopTimer();
      notifyListeners();
      return false; // 全部仪式已达成
    }
  }

  /// 跳过当前步骤
  void skipCurrentStep() {
    if (currentStep == null) return;

    if (_currentIndex + 1 < _steps.length) {
      _currentIndex += 1;
    } else {
      _status = RoutineStatus.completed;
      _stopTimer();
    }
    notifyListeners();
  }

  void previousStep() {
    if (_currentIndex > 0) {
      _currentIndex -= 1;
      notifyListeners();
    }
  }

  void endRoutine() {
    _stopTimer();
    _status = RoutineStatus.idle;
    _steps.clear();
    _currentIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
