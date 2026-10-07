import 'package:flutter/foundation.dart';
import '../../models/habit.dart';

/// 习惯自定义排序与自由拖拽重排服务
class HabitOrderService extends ChangeNotifier {
  HabitOrderService._();
  static final HabitOrderService instance = HabitOrderService._();

  List<String> _customOrderIds = [];

  List<String> get customOrderIds => List.unmodifiable(_customOrderIds);

  void setOrder(List<String> ids) {
    _customOrderIds = List.from(ids);
    notifyListeners();
  }

  /// 对习惯列表排序（置顶优先）
  List<Habit> sortHabits(List<Habit> habits) {
    if (habits.isEmpty) return habits;

    final sorted = List<Habit>.from(habits);

    sorted.sort((a, b) {
      // 1. 置顶状态优先级最高
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 2. 自定义拖拽排序优先级
      if (_customOrderIds.isNotEmpty) {
        final indexA = _customOrderIds.indexOf(a.id);
        final indexB = _customOrderIds.indexOf(b.id);
        if (indexA != -1 && indexB != -1) {
          return indexA.compareTo(indexB);
        }
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
      }

      // 3. 默认保留创建/更新先后顺序
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return sorted;
  }

  /// 处理拖拽重排
  List<Habit> handleReorder(List<Habit> currentList, int oldIndex, int newIndex) {
    final list = List<Habit>.from(currentList);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    // 记录最新全量 ID 排序
    _customOrderIds = list.map((h) => h.id).toList();
    notifyListeners();

    return list;
  }

  void resetOrder() {
    _customOrderIds.clear();
    notifyListeners();
  }
}
