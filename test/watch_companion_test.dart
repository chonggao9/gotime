import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/watch_companion_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('WatchCompanionService Tests', () {
    final watchService = WatchCompanionService.instance;

    setUp(() {
      watchService.setFormFactor(WatchFormFactor.squircle);
      watchService.setHapticCrownEnabled(true);
      watchService.todayWatchCompletedIds.clear();
    });

    test('Initial form factor and crown state', () {
      expect(watchService.formFactor, equals(WatchFormFactor.squircle));
      expect(watchService.isHapticCrownEnabled, isTrue);

      watchService.setFormFactor(WatchFormFactor.round);
      expect(watchService.formFactor, equals(WatchFormFactor.round));

      watchService.setHapticCrownEnabled(false);
      expect(watchService.isHapticCrownEnabled, isFalse);
    });

    test('getWatchHabits prioritizes pinned habits and takes at most 4', () {
      final habits = [
        Habit(
          id: 'h1',
          name: '普通习惯1',
          iconEmoji: '1️⃣',
          themeColor: '#34D399',
          type: HabitType.boolean,
          isPinned: false,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'h2',
          name: '置顶习惯2',
          iconEmoji: '2️⃣',
          themeColor: '#60A5FA',
          type: HabitType.boolean,
          isPinned: true,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'h3',
          name: '归档习惯3',
          iconEmoji: '3️⃣',
          themeColor: '#F59E0B',
          type: HabitType.boolean,
          isArchived: true,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'h4',
          name: '普通习惯4',
          iconEmoji: '4️⃣',
          themeColor: '#8B5CF6',
          type: HabitType.boolean,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'h5',
          name: '置顶习惯5',
          iconEmoji: '5️⃣',
          themeColor: '#EC4899',
          type: HabitType.boolean,
          isPinned: true,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'h6',
          name: '普通习惯6',
          iconEmoji: '6️⃣',
          themeColor: '#10B981',
          type: HabitType.boolean,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
      ];

      final watchHabits = watchService.getWatchHabits(habits);

      expect(watchHabits.length, equals(4));
      // First two should be pinned habits
      expect(watchHabits[0].isPinned, isTrue);
      expect(watchHabits[1].isPinned, isTrue);
      // Archived habit should be excluded
      expect(watchHabits.any((h) => h.id == 'h3'), isFalse);
    });

    test('toggleWatchCheckIn toggles completed status in set', () async {
      final habit = Habit(
        id: 'watch-test-1',
        name: '喝水',
        iconEmoji: '💧',
        themeColor: '#34D399',
        type: HabitType.boolean,
        frequency: const {'type': 'daily'},
        updatedAt: DateTime.now(),
      );

      expect(watchService.isCompleted('watch-test-1'), isFalse);

      final result1 = await watchService.toggleWatchCheckIn(habit);
      expect(result1, isTrue);
      expect(watchService.isCompleted('watch-test-1'), isTrue);

      final result2 = await watchService.toggleWatchCheckIn(habit);
      expect(result2, isFalse);
      expect(watchService.isCompleted('watch-test-1'), isFalse);
    });
  });
}
