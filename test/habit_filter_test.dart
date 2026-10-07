import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('Habit Model Time-of-Day and Tags Tests', () {
    test('Habit serialization with timeOfDay and tags', () {
      final habit = Habit(
        id: 'h1',
        name: '晨跑 3 公里',
        iconEmoji: '🏃',
        themeColor: '#34D399',
        type: HabitType.boolean,
        timeOfDay: 'morning',
        tags: ['健康', '户外'],
        frequency: {'type': 'daily'},
        updatedAt: DateTime.now(),
      );

      final json = habit.toJson();
      expect(json['time_of_day'], 'morning');
      expect(json['tags'], ['健康', '户外']);

      final restored = Habit.fromJson(json);
      expect(restored.timeOfDay, 'morning');
      expect(restored.tags, contains('健康'));
    });

    test('Habit filtering by time-of-day slots', () {
      final list = [
        Habit(
          id: '1',
          name: '晨起冥想',
          iconEmoji: '🧘',
          themeColor: '#34D399',
          type: HabitType.boolean,
          timeOfDay: 'morning',
          frequency: {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: '午休散步',
          iconEmoji: '🚶',
          themeColor: '#60A5FA',
          type: HabitType.boolean,
          timeOfDay: 'afternoon',
          frequency: {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '3',
          name: '睡前阅读',
          iconEmoji: '📚',
          themeColor: '#F472B6',
          type: HabitType.boolean,
          timeOfDay: 'evening',
          frequency: {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
      ];

      final morningHabits = list.where((h) => h.timeOfDay == 'morning' || h.timeOfDay == 'all').toList();
      final eveningHabits = list.where((h) => h.timeOfDay == 'evening' || h.timeOfDay == 'all').toList();

      expect(morningHabits.length, 1);
      expect(morningHabits.first.name, '晨起冥想');

      expect(eveningHabits.length, 1);
      expect(eveningHabits.first.name, '睡前阅读');
    });
  });
}
