import 'package:flutter/foundation.dart';

enum HabitViewMode {
  list,
  matrix,
}

class HabitViewModeService extends ChangeNotifier {
  static final HabitViewModeService instance = HabitViewModeService._();
  HabitViewModeService._();

  HabitViewMode _viewMode = HabitViewMode.list;

  HabitViewMode get viewMode => _viewMode;
  bool get isMatrixMode => _viewMode == HabitViewMode.matrix;
  bool get isListMode => _viewMode == HabitViewMode.list;

  void init() {
    // In-memory state, defaults to list
  }

  void setViewMode(HabitViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void toggleViewMode() {
    final nextMode = _viewMode == HabitViewMode.list ? HabitViewMode.matrix : HabitViewMode.list;
    setViewMode(nextMode);
  }
}
