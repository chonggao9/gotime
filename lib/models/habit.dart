// lib/models/habit.dart
enum HabitType { boolean, counter, timer, quit }

class Habit {
  final String id;
  final String name;
  final String iconEmoji;
  final String themeColor;
  final HabitType type;
  final int? targetValue;
  final String? targetUnit;
  final int? timerSeconds;
  final Map<String, dynamic> frequency;
  final List<String> reminders;
  final bool isShared;
  final bool isArchived;
  final bool isPinned;
  final String timeOfDay; // 'all', 'morning', 'afternoon', 'evening'
  final List<String> tags;
  final String? stackedAfterHabitId; // 习惯堆叠前置锚点 ID
  final String? stackedAfterHabitName; // 习惯堆叠前置习惯名称
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.themeColor,
    required this.type,
    this.targetValue,
    this.targetUnit,
    this.timerSeconds,
    required this.frequency,
    this.reminders = const [],
    this.isShared = false,
    this.isArchived = false,
    this.isPinned = false,
    this.timeOfDay = 'all',
    this.tags = const [],
    this.stackedAfterHabitId,
    this.stackedAfterHabitName,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconEmoji: json['icon_emoji'] as String,
      themeColor: json['theme_color'] as String,
      type: HabitType.values.firstWhere((e) => e.name == json['type']),
      targetValue: json['target_value'] as int?,
      targetUnit: json['target_unit'] as String?,
      timerSeconds: json['timer_seconds'] as int?,
      frequency: json['frequency'] as Map<String, dynamic>,
      reminders: List<String>.from(json['reminders'] ?? []),
      isShared: json['is_shared'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1,
      timeOfDay: json['time_of_day'] as String? ?? 'all',
      tags: List<String>.from(json['tags'] ?? []),
      stackedAfterHabitId: json['stacked_after_habit_id'] as String?,
      stackedAfterHabitName: json['stacked_after_habit_name'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_emoji': iconEmoji,
      'theme_color': themeColor,
      'type': type.name,
      'target_value': targetValue,
      'target_unit': targetUnit,
      'timer_seconds': timerSeconds,
      'frequency': frequency,
      'reminders': reminders,
      'is_shared': isShared,
      'is_archived': isArchived,
      'is_pinned': isPinned,
      'time_of_day': timeOfDay,
      'tags': tags,
      'stacked_after_habit_id': stackedAfterHabitId,
      'stacked_after_habit_name': stackedAfterHabitName,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Habit copyWith({
    String? name,
    String? iconEmoji,
    String? themeColor,
    HabitType? type,
    int? targetValue,
    String? targetUnit,
    int? timerSeconds,
    Map<String, dynamic>? frequency,
    List<String>? reminders,
    bool? isShared,
    bool? isArchived,
    bool? isPinned,
    String? timeOfDay,
    List<String>? tags,
    String? stackedAfterHabitId,
    String? stackedAfterHabitName,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      themeColor: themeColor ?? this.themeColor,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      frequency: frequency ?? this.frequency,
      reminders: reminders ?? this.reminders,
      isShared: isShared ?? this.isShared,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      tags: tags ?? this.tags,
      stackedAfterHabitId: stackedAfterHabitId ?? this.stackedAfterHabitId,
      stackedAfterHabitName: stackedAfterHabitName ?? this.stackedAfterHabitName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
