import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/frequency_service.dart';
import 'package:gotime/core/services/milestone_service.dart';
import 'package:gotime/models/habit.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  group('FrequencyService & Flexible Frequency Tests', () {
    final freqService = FrequencyService.instance;

    test('Habit frequency summary returns appropriate descriptions', () {
      final dailyHabit = Habit(
        id: 'h1',
        name: '阅读',
        iconEmoji: '📖',
        themeColor: '#34D399',
        type: HabitType.boolean,
        frequency: const {'type': 'daily'},
        updatedAt: DateTime.now(),
      );
      expect(dailyHabit.frequencySummary, equals('每日打卡'));

      final flexWeeklyHabit = Habit(
        id: 'h2',
        name: '健身房举铁',
        iconEmoji: '🏋️',
        themeColor: '#60A5FA',
        type: HabitType.boolean,
        frequency: const {'type': 'flexible_weekly', 'target_times': 3},
        updatedAt: DateTime.now(),
      );
      expect(flexWeeklyHabit.frequencySummary, equals('每周 3 次'));

      final daysHabit = Habit(
        id: 'h3',
        name: '周一三五晨跑',
        iconEmoji: '🏃',
        themeColor: '#F59E0B',
        type: HabitType.boolean,
        frequency: const {'type': 'weekly_days', 'days': [1, 3, 5]},
        updatedAt: DateTime.now(),
      );
      expect(daysHabit.frequencySummary, equals('周一、三、五'));
    });

    test('calculateWeeklyProgress correctly accumulates check-ins in current week', () {
      final flexHabit = Habit(
        id: 'flex-1',
        name: '游泳',
        iconEmoji: '🏊',
        themeColor: '#38BDF8',
        type: HabitType.boolean,
        frequency: const {'type': 'flexible_weekly', 'target_times': 3},
        updatedAt: DateTime.now(),
      );

      // Wednesday Oct 7, 2026: Week starts Monday Oct 5, 2026 to Sunday Oct 11, 2026
      final refDate = DateTime(2026, 10, 7);

      final checkIns = [
        CheckIn(
          id: 'c1',
          habitId: 'flex-1',
          date: '2026-10-05', // Monday (in week)
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
        CheckIn(
          id: 'c2',
          habitId: 'flex-1',
          date: '2026-10-06', // Tuesday (in week)
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
        CheckIn(
          id: 'c3',
          habitId: 'flex-1',
          date: '2026-09-30', // Previous week
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
      ];

      final progress = freqService.calculateWeeklyProgress(
        flexHabit,
        checkIns,
        referenceDate: refDate,
      );

      expect(progress.completedCount, equals(2));
      expect(progress.targetCount, equals(3));
      expect(progress.isMet, isFalse);
      expect(progress.ratio, closeTo(2 / 3, 0.01));

      // Add a third check-in
      checkIns.add(CheckIn(
        id: 'c4',
        habitId: 'flex-1',
        date: '2026-10-07',
        status: CheckInStatus.completed,
        createdAt: DateTime.now(),
      ));

      final progressUpdated = freqService.calculateWeeklyProgress(
        flexHabit,
        checkIns,
        referenceDate: refDate,
      );

      expect(progressUpdated.completedCount, equals(3));
      expect(progressUpdated.isMet, isTrue);
      expect(progressUpdated.ratio, equals(1.0));
    });

    test('isScheduledForDate respects weekly_days specification', () {
      final daysHabit = Habit(
        id: 'h-days',
        name: '工作日专注',
        iconEmoji: '💻',
        themeColor: '#8B5CF6',
        type: HabitType.boolean,
        frequency: const {'type': 'weekly_days', 'days': [1, 2, 3, 4, 5]},
        updatedAt: DateTime.now(),
      );

      // 2026-10-07 is Wednesday (weekday = 3)
      expect(freqService.isScheduledForDate(daysHabit, DateTime(2026, 10, 7)), isTrue);
      // 2026-10-10 is Saturday (weekday = 6)
      expect(freqService.isScheduledForDate(daysHabit, DateTime(2026, 10, 10)), isFalse);
    });
  });

  group('MilestoneService Badge Tests', () {
    final milestoneService = MilestoneService.instance;

    test('Seedling badge unlocks on first completed check-in', () {
      final emptyBadges = milestoneService.getBadges(
        habits: [],
        checkIns: [],
      );
      final seedlingEmpty = emptyBadges.firstWhere((b) => b.id == 'seedling');
      expect(seedlingEmpty.isUnlocked, isFalse);

      final unlockedBadges = milestoneService.getBadges(
        habits: [],
        checkIns: [
          CheckIn(
            id: 'c1',
            habitId: 'h1',
            date: '2026-10-07',
            status: CheckInStatus.completed,
            createdAt: DateTime.now(),
          ),
        ],
      );
      final seedlingUnlocked = unlockedBadges.firstWhere((b) => b.id == 'seedling');
      expect(seedlingUnlocked.isUnlocked, isTrue);
      expect(seedlingUnlocked.progress, equals(1.0));
    });

    test('Streak and focus badges reflect input conditions', () {
      final badges = milestoneService.getBadges(
        habits: [
          Habit(
            id: 'h-stacked',
            name: '堆叠习惯',
            iconEmoji: '☕',
            themeColor: '#F59E0B',
            type: HabitType.boolean,
            stackedAfterHabitId: 'anchor-1',
            frequency: const {'type': 'daily'},
            updatedAt: DateTime.now(),
          ),
        ],
        checkIns: [],
        maxStreak: 8,
        totalFocusMinutes: 150,
      );

      final streak7 = badges.firstWhere((b) => b.id == 'streak_7');
      expect(streak7.isUnlocked, isTrue);

      final zenMaster = badges.firstWhere((b) => b.id == 'zen_master');
      expect(zenMaster.isUnlocked, isTrue);

      final stackingBadge = badges.firstWhere((b) => b.id == 'stacking_pro');
      expect(stackingBadge.isUnlocked, isTrue);

      final century100 = badges.firstWhere((b) => b.id == 'century_100');
      expect(century100.isUnlocked, isFalse);
      expect(century100.currentValue, equals(0));
    });
  });
}
