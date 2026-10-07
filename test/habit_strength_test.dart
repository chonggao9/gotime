import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/habit_strength_service.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  group('HabitStrengthService Exponential Smoothing Tests', () {
    test('Empty check-ins should return 0.0 strength and 0 streak', () {
      final strength = HabitStrengthService.calculateStrength([]);
      final streak = HabitStrengthService.calculateStreak([]);

      expect(strength, 0.0);
      expect(streak, 0);
      expect(HabitStrengthService.getStrengthLabel(strength), '🌰 播种起步');
    });

    test('Consecutive completed check-ins should build strength close to 1.0', () {
      final today = DateTime.now();
      final checkIns = List.generate(30, (i) {
        final date = today.subtract(Duration(days: i));
        return CheckIn(
          id: 'test_$i',
          habitId: 'habit_1',
          date: date.toIso8601String().split('T')[0],
          status: CheckInStatus.completed,
          createdAt: date,
        );
      });

      final strength = HabitStrengthService.calculateStrength(checkIns, asOfDate: today);
      final streak = HabitStrengthService.calculateStreak(checkIns, asOfDate: today);

      expect(strength, greaterThan(0.80));
      expect(streak, 30);
      expect(HabitStrengthService.getStrengthLabel(strength), '💎 磐石阶段');
    });

    test('A single missed day should only slightly decay strength without resetting to zero', () {
      final today = DateTime.now();
      final checkIns = <CheckIn>[];

      // 过去 20 天除昨天外全部打卡
      for (int i = 0; i < 20; i++) {
        if (i == 1) continue; // 昨天漏打
        final date = today.subtract(Duration(days: i));
        checkIns.add(CheckIn(
          id: 'test_$i',
          habitId: 'habit_1',
          date: date.toIso8601String().split('T')[0],
          status: CheckInStatus.completed,
          createdAt: date,
        ));
      }

      final strength = HabitStrengthService.calculateStrength(checkIns, asOfDate: today);

      // 核心抗焦虑验证：绝不归零！强度依旧保持在 60% 以上高位
      expect(strength, greaterThan(0.60));
    });

    test('Vacation/Skipped status preserves habit strength without penalty', () {
      final today = DateTime.now();
      final dateYesterday = today.subtract(const Duration(days: 1));

      final checkInsWithFreeze = [
        CheckIn(
          id: 'c1',
          habitId: 'habit_1',
          date: today.toIso8601String().split('T')[0],
          status: CheckInStatus.completed,
          createdAt: today,
        ),
        CheckIn(
          id: 'c2',
          habitId: 'habit_1',
          date: dateYesterday.toIso8601String().split('T')[0],
          status: CheckInStatus.skipped, // 免责休假
          createdAt: dateYesterday,
        ),
      ];

      final streak = HabitStrengthService.calculateStreak(checkInsWithFreeze, asOfDate: today);
      expect(streak, 2); // 休假不中断连胜
    });
  });
}
