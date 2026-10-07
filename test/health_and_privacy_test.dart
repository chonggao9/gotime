import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/health_sync_service.dart';
import 'package:gotime/core/services/privacy_lock_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('PrivacyLockService Tests', () {
    final lockService = PrivacyLockService.instance;

    setUp(() {
      lockService.setLockEnabled(false);
      lockService.setPinCode('1234');
    });

    test('Initial state should be unlocked and disabled', () {
      expect(lockService.isLockEnabled, isFalse);
      expect(lockService.isLocked, isFalse);
      expect(lockService.pinCode, equals('1234'));
    });

    test('Enabling and triggering lock should set isLocked to true', () {
      lockService.setLockEnabled(true);
      expect(lockService.isLockEnabled, isTrue);
      expect(lockService.isLocked, isFalse);

      lockService.lock();
      expect(lockService.isLocked, isTrue);
    });

    test('Cannot lock when lock is disabled', () {
      lockService.setLockEnabled(false);
      lockService.lock();
      expect(lockService.isLocked, isFalse);
    });

    test('Unlocking with correct PIN succeeds and clears locked state', () {
      lockService.setLockEnabled(true);
      lockService.lock();
      expect(lockService.isLocked, isTrue);

      final wrongResult = lockService.unlock('0000');
      expect(wrongResult, isFalse);
      expect(lockService.isLocked, isTrue);

      final successResult = lockService.unlock('1234');
      expect(successResult, isTrue);
      expect(lockService.isLocked, isFalse);
    });

    test('Updating PIN code updates verification value', () {
      lockService.setPinCode('8888');
      expect(lockService.pinCode, equals('8888'));

      lockService.setLockEnabled(true);
      lockService.lock();

      expect(lockService.unlock('1234'), isFalse);
      expect(lockService.unlock('8888'), isTrue);
      expect(lockService.isLocked, isFalse);
    });

    test('Disabling lock automatically resets locked state', () {
      lockService.setLockEnabled(true);
      lockService.lock();
      expect(lockService.isLocked, isTrue);

      lockService.setLockEnabled(false);
      expect(lockService.isLocked, isFalse);
    });
  });

  group('HealthSyncService Tests', () {
    final healthService = HealthSyncService.instance;

    setUp(() {
      healthService.setAutoSyncEnabled(false);
      healthService.updateSimulatedHealthData(steps: 8000, sleepMinutes: 480);
    });

    test('Toggling auto sync state updates flag', () {
      expect(healthService.isAutoSyncEnabled, isFalse);
      healthService.setAutoSyncEnabled(true);
      expect(healthService.isAutoSyncEnabled, isTrue);
    });

    test('Simulated health data updates correctly', () {
      healthService.updateSimulatedHealthData(steps: 10500, sleepMinutes: 520);
      expect(healthService.simulatedSteps, equals(10500));
      expect(healthService.simulatedSleepMinutes, equals(520));
    });

    test('Auto check-in triggers when counter habit target is met', () async {
      healthService.updateSimulatedHealthData(steps: 9000, sleepMinutes: 500);

      final habits = [
        Habit(
          id: 'step-habit-1',
          name: '每日万步走路',
          iconEmoji: '👟',
          themeColor: '#34D399',
          type: HabitType.counter,
          targetValue: 8000,
          targetUnit: '步',
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'sleep-habit-1',
          name: '健康睡眠保证',
          iconEmoji: '🌙',
          themeColor: '#60A5FA',
          type: HabitType.counter,
          targetValue: 480,
          targetUnit: '分钟',
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: 'read-habit-1',
          name: '晨间阅读',
          iconEmoji: '📖',
          themeColor: '#F59E0B',
          type: HabitType.boolean,
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
      ];

      final results = await healthService.checkAndAutoCheckIn(habits);

      expect(results.length, equals(2));
      expect(results[0].isTriggered, isTrue);
      expect(results[0].currentValue, equals(9000));
      expect(results[0].message, contains('每日万步走路'));

      expect(results[1].isTriggered, isTrue);
      expect(results[1].currentValue, equals(500));
      expect(results[1].message, contains('健康睡眠保证'));

      expect(healthService.lastSyncTime, isNotNull);
    });

    test('Auto check-in does not trigger if target not reached', () async {
      healthService.updateSimulatedHealthData(steps: 5000, sleepMinutes: 300);

      final habits = [
        Habit(
          id: 'step-habit-2',
          name: '每天走步打卡',
          iconEmoji: '👟',
          themeColor: '#34D399',
          type: HabitType.counter,
          targetValue: 8000,
          targetUnit: '步',
          frequency: const {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
      ];

      final results = await healthService.checkAndAutoCheckIn(habits);
      expect(results.isEmpty, isTrue);
    });
  });
}
