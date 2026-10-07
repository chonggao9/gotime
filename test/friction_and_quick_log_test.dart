import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/friction_breaker_service.dart';
import 'package:gotime/core/services/quick_natural_logger_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('FrictionBreakerService Two-Minute Rule Tests', () {
    final readHabit = Habit(
      id: 'h_read',
      name: '睡前阅读',
      iconEmoji: '📚',
      themeColor: '#60A5FA',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final runHabit = Habit(
      id: 'h_run',
      name: '晨跑健身',
      iconEmoji: '🏃',
      themeColor: '#34D399',
      type: HabitType.counter,
      targetValue: 5,
      targetUnit: 'km',
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final timerHabit = Habit(
      id: 'h_timer',
      name: '深度专注工作',
      iconEmoji: '🍅',
      themeColor: '#F87171',
      type: HabitType.timer,
      timerSeconds: 1800,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    setUp(() {
      FrictionBreakerService.instance.stopSession();
    });

    test('getMicroActionSuggestion generates targeted 2-minute micro goals', () {
      final service = FrictionBreakerService.instance;

      final readSuggestion = service.getMicroActionSuggestion(readHabit);
      expect(readSuggestion, contains('读 1 页书'));

      final runSuggestion = service.getMicroActionSuggestion(runHabit);
      expect(runSuggestion, contains('跑鞋'));

      final timerSuggestion = service.getMicroActionSuggestion(timerHabit);
      expect(timerSuggestion, contains('2 分钟'));
    });

    test('startSession initializes 120s countdown and running state', () {
      final service = FrictionBreakerService.instance;
      service.startSession(readHabit);

      expect(service.isRunning, isTrue);
      expect(service.remainingSeconds, equals(120));
      expect(service.activeHabit?.id, equals('h_read'));
      expect(service.isCompleted, isFalse);
    });

    test('togglePause pauses and resumes session', () {
      final service = FrictionBreakerService.instance;
      service.startSession(runHabit);
      expect(service.isRunning, isTrue);

      service.togglePause();
      expect(service.isRunning, isFalse);

      service.togglePause();
      expect(service.isRunning, isTrue);
    });

    test('stopSession resets timer and state', () {
      final service = FrictionBreakerService.instance;
      service.startSession(readHabit);
      service.stopSession();

      expect(service.isRunning, isFalse);
      expect(service.activeHabit, isNull);
      expect(service.remainingSeconds, equals(120));
    });
  });

  group('QuickNaturalLoggerService Tests', () {
    final waterHabit = Habit(
      id: 'h1',
      name: '早起喝水',
      iconEmoji: '💧',
      themeColor: '#34D399',
      type: HabitType.counter,
      targetValue: 2000,
      targetUnit: 'ml',
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final readHabit = Habit(
      id: 'h2',
      name: '晚间阅读',
      iconEmoji: '📚',
      themeColor: '#60A5FA',
      type: HabitType.counter,
      targetValue: 30,
      targetUnit: '页',
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final workHabit = Habit(
      id: 'h3',
      name: '深度工作',
      iconEmoji: '🍅',
      themeColor: '#F87171',
      type: HabitType.timer,
      timerSeconds: 1500,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    test('handles empty input gracefully', () {
      final intents = QuickNaturalLoggerService.instance.parseText('', [waterHabit]);
      expect(intents.isEmpty, isTrue);
    });

    test('parses single habit with value and mood keyword', () {
      final input = '喝水 600ml，心情超好';
      final intents = QuickNaturalLoggerService.instance.parseText(input, [waterHabit]);

      expect(intents.length, equals(1));
      expect(intents.first.habit.id, equals('h1'));
      expect(intents.first.value, equals(600));
      expect(intents.first.mood, equals(5)); // '超好' -> 5
    });

    test('parses multi-habit composite sentence', () {
      final input = '喝水 300ml，阅读 15页，深度工作 30分钟，心情不错';
      final intents = QuickNaturalLoggerService.instance.parseText(
        input,
        [waterHabit, readHabit, workHabit],
      );

      expect(intents.length, equals(3));
      final water = intents.firstWhere((i) => i.habit.id == 'h1');
      final read = intents.firstWhere((i) => i.habit.id == 'h2');
      final work = intents.firstWhere((i) => i.habit.id == 'h3');

      expect(water.value, equals(300));
      expect(read.value, equals(15));
      expect(work.durationSeconds, equals(30 * 60)); // 30 minutes in seconds
      expect(water.mood, equals(4)); // '不错' -> 4
    });

    test('detects negative mood keywords properly', () {
      final input = '晚间阅读 5页，今天很累';
      final intents = QuickNaturalLoggerService.instance.parseText(input, [readHabit]);

      expect(intents.length, equals(1));
      expect(intents.first.mood, equals(2)); // '累' -> 2
    });
  });
}
