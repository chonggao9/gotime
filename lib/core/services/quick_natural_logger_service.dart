import '../../models/habit.dart';

class ParsedCheckInIntent {
  final Habit habit;
  final int? value;
  final int? durationSeconds;
  final int? mood;
  final String note;

  ParsedCheckInIntent({
    required this.habit,
    this.value,
    this.durationSeconds,
    this.mood,
    this.note = '自然语言极速速记打卡',
  });
}

/// 自然语言文本/语音速记极速打卡解析服务 (Offline Natural Language Quick Logger)
class QuickNaturalLoggerService {
  QuickNaturalLoggerService._();
  static final QuickNaturalLoggerService instance = QuickNaturalLoggerService._();

  /// 解析用户输入的速记文本并匹配现有习惯
  List<ParsedCheckInIntent> parseText(String input, List<Habit> habits) {
    if (input.trim().isEmpty || habits.isEmpty) return [];

    final cleanInput = input.trim();
    final matchedIntents = <ParsedCheckInIntent>[];

    // 推导全局心情 (若存在)
    final globalMood = _detectMood(cleanInput);

    // 将输入按逗号、分号、句号、换行或空格切分为意图子句
    final clauses = cleanInput.split(RegExp(r'[,，;；。\n\+]'));

    for (final habit in habits) {
      final habitNameLower = habit.name.toLowerCase();
      bool isHabitMatched = false;
      int? habitValue;
      int? habitSeconds;
      String habitNote = '极速速记打卡';

      // 1. 尝试在各个子句中精准或模糊匹配习惯名
      for (final clause in clauses) {
        final c = clause.trim();
        if (c.isEmpty) continue;

        final textOnly = c
            .replaceAll(RegExp(r'\d+'), '')
            .replaceAll(RegExp(r'(ml|km|kg|min|s|h|毫升|千米|公斤|分钟|小时|秒|页|次|杯|组)'), '')
            .replaceAll(RegExp(r'[^\w\u4e00-\u9fa5]'), '')
            .toLowerCase();

        final matchesFull = c.toLowerCase().contains(habitNameLower);
        final matchesSub = textOnly.isNotEmpty &&
            (habitNameLower.contains(textOnly) || textOnly.contains(habitNameLower));

        if (matchesFull || matchesSub) {
          isHabitMatched = true;

          // 提取该子句中的数值
          final val = _extractNumber(c);
          if (val != null) {
            if (habit.type == HabitType.timer) {
              habitSeconds = val * 60; // 默认分钟转换为秒
            } else {
              habitValue = val;
            }
          }
          habitNote = c;
          break;
        }
      }

      // 2. 若全句包含习惯名关键词也算匹配
      if (!isHabitMatched && cleanInput.toLowerCase().contains(habitNameLower)) {
        isHabitMatched = true;
        final val = _extractNumber(cleanInput);
        if (val != null) {
          if (habit.type == HabitType.timer) {
            habitSeconds = val * 60;
          } else {
            habitValue = val;
          }
        }
      }

      if (isHabitMatched) {
        matchedIntents.add(ParsedCheckInIntent(
          habit: habit,
          value: habitValue ?? (habit.type == HabitType.counter ? (habit.targetValue?.toInt() ?? 1) : null),
          durationSeconds: habitSeconds ?? (habit.type == HabitType.timer ? habit.timerSeconds : null),
          mood: globalMood ?? 5,
          note: habitNote,
        ));
      }
    }

    return matchedIntents;
  }

  int? _detectMood(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('超好') || lower.contains('太棒') || lower.contains('开心') || lower.contains('兴奋')) {
      return 5;
    }
    if (lower.contains('好') || lower.contains('不错') || lower.contains('满意') || lower.contains('充实')) {
      return 4;
    }
    if (lower.contains('一般') || lower.contains('平淡') || lower.contains('还行')) {
      return 3;
    }
    if (lower.contains('累') || lower.contains('疲惫') || lower.contains('差')) {
      return 2;
    }
    if (lower.contains('难过') || lower.contains('糟糕') || lower.contains('沮丧')) {
      return 1;
    }
    return null;
  }

  int? _extractNumber(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
