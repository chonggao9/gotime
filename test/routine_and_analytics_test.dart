import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/routine_service.dart';
import 'package:gotime/core/services/habit_analytics_service.dart';
import 'package:gotime/models/habit.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  group('RoutineService Tests', () {
    final habit1 = Habit(
      id: 'h1',
      name: '晨起温水',
      iconEmoji: '💧',
      themeColor: '#34D399',
      type: HabitType.counter,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final habit2 = Habit(
      id: 'h2',
      name: '正念冥想',
      iconEmoji: '🧘',
      themeColor: '#60A5FA',
      type: HabitType.timer,
      timerSeconds: 600,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final habit3 = Habit(
      id: 'h3',
      name: '核心拉伸',
      iconEmoji: '🤸',
      themeColor: '#F87171',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    setUp(() {
      RoutineService.instance.endRoutine();
    });

    test('startRoutine initializes steps and starts running', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1, habit2, habit3], title: '晨间测试心流');

      expect(service.isActive, isTrue);
      expect(service.status, equals(RoutineStatus.running));
      expect(service.routineTitle, equals('晨间测试心流'));
      expect(service.steps.length, equals(3));
      expect(service.currentIndex, equals(0));
      expect(service.currentStep?.habit.id, equals('h1'));
      expect(service.overallProgress, equals(0.0));
    });

    test('togglePause toggles running and paused states', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1, habit2]);
      expect(service.status, equals(RoutineStatus.running));

      service.togglePause();
      expect(service.status, equals(RoutineStatus.paused));

      service.togglePause();
      expect(service.status, equals(RoutineStatus.running));
    });

    test('completeCurrentStep marks step done and advances to next', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1, habit2]);

      final hasNext = service.completeCurrentStep();
      expect(hasNext, isTrue);
      expect(service.steps[0].isCompleted, isTrue);
      expect(service.currentIndex, equals(1));
      expect(service.overallProgress, equals(0.5));

      final finished = service.completeCurrentStep();
      expect(finished, isFalse);
      expect(service.status, equals(RoutineStatus.completed));
      expect(service.overallProgress, equals(1.0));
    });

    test('skipCurrentStep moves forward without completing', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1, habit2]);

      service.skipCurrentStep();
      expect(service.steps[0].isCompleted, isFalse);
      expect(service.currentIndex, equals(1));
      expect(service.overallProgress, equals(0.0));
    });

    test('previousStep moves backward', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1, habit2]);
      service.completeCurrentStep();
      expect(service.currentIndex, equals(1));

      service.previousStep();
      expect(service.currentIndex, equals(0));
    });

    test('endRoutine resets to idle', () {
      final service = RoutineService.instance;
      service.startRoutine([habit1]);
      service.endRoutine();

      expect(service.isActive, isFalse);
      expect(service.status, equals(RoutineStatus.idle));
      expect(service.steps.isEmpty, isTrue);
    });
  });

  group('HabitAnalyticsService Tests', () {
    test('handles empty check-ins gracefully', () {
      final report = HabitAnalyticsService.instance.analyzeCheckIns([]);
      expect(report.dayStats.length, equals(7));
      expect(report.averageMood, greaterThan(0.0));
      expect(report.insightMessage.isNotEmpty, isTrue);
    });

    test('computes day of week distribution and highest weekday', () {
      final checkIns = [
        // 2026-10-05 is Monday (weekday 1)
        CheckIn(
          id: 'c1',
          habitId: 'h1',
          date: '2026-10-05',
          status: CheckInStatus.completed,
          mood: 5,
          createdAt: DateTime.parse('2026-10-05 08:00:00'),
        ),
        CheckIn(
          id: 'c2',
          habitId: 'h2',
          date: '2026-10-05',
          status: CheckInStatus.completed,
          mood: 4,
          createdAt: DateTime.parse('2026-10-05 09:00:00'),
        ),
        // 2026-10-06 is Tuesday (weekday 2)
        CheckIn(
          id: 'c3',
          habitId: 'h1',
          date: '2026-10-06',
          status: CheckInStatus.completed,
          mood: 3,
          createdAt: DateTime.parse('2026-10-06 08:00:00'),
        ),
      ];

      final report = HabitAnalyticsService.instance.analyzeCheckIns(checkIns);

      expect(report.bestWeekday, equals(1)); // Monday has 2 completions
      expect(report.bestWeekdayName, equals('周一'));
      expect(report.dayStats[0].completedCount, equals(2));
      expect(report.dayStats[1].completedCount, equals(1));
      expect(report.averageMood, closeTo(4.0, 0.01)); // (5+4+3)/3 = 4.0
      expect(report.insightMessage, contains('周一'));
    });
  });
}
