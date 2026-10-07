import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/quit_habit_service.dart';
import 'package:gotime/core/utils/counter_step_helper.dart';

void main() {
  group('QuitHabitService 坏习惯戒除服务测试', () {
    test('初始进度正确计算坚持时长', () {
      final service = QuitHabitService.instance;
      final habitId = 'quit_smoking_1';
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5, hours: 4));

      final progress = service.getProgress(habitId, fiveDaysAgo);
      expect(progress.daysClean, 5);
      expect(progress.hoursCleanRemainder, 4);
      expect(progress.formattedCleanDuration, contains('5 天 4 小时'));
    });

    test('记录破戒后历史条目增加并重置当前坚持天数', () {
      final service = QuitHabitService.instance;
      final habitId = 'quit_sugar_1';
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));

      service.getProgress(habitId, tenDaysAgo);
      service.recordRelapse(
        habitId,
        trigger: '🍻 聚会诱惑',
        note: '朋友聚会喝了一杯奶茶',
      );

      final progressAfter = service.getProgress(habitId, tenDaysAgo);
      expect(progressAfter.daysClean, 0);
      expect(progressAfter.history.isNotEmpty, isTrue);
      expect(progressAfter.history.first.trigger, '🍻 聚会诱惑');
      expect(progressAfter.history.first.note, '朋友聚会喝了一杯奶茶');
    });

    test('设置自定义起始时间可重设基准时间', () {
      final service = QuitHabitService.instance;
      final habitId = 'quit_game_1';
      final twentyDaysAgo = DateTime.now().subtract(const Duration(days: 20));

      service.setCustomStartDate(habitId, twentyDaysAgo);
      final progress = service.getProgress(habitId, DateTime.now());
      expect(progress.daysClean, 20);
    });
  });

  group('CounterStepHelper 自适应步进器推导测试', () {
    test('水等液体单位 (ml) 自动推导为 250ml 步进', () {
      expect(CounterStepHelper.deduceDefaultStep(2000, 'ml'), 250);
      expect(CounterStepHelper.deduceDefaultStep(1500, '毫升'), 250);
    });

    test('距离等大颗粒度单位 (km) 自动推导为 1km 步进', () {
      expect(CounterStepHelper.deduceDefaultStep(10, 'km'), 1);
      expect(CounterStepHelper.deduceDefaultStep(5, '公里'), 1);
    });

    test('阅读页数 (页) 根据目标大小推导 5 或 10 页步进', () {
      expect(CounterStepHelper.deduceDefaultStep(30, '页'), 5);
      expect(CounterStepHelper.deduceDefaultStep(100, '页'), 10);
    });

    test('时间单位 (分钟) 自动推导为 15 分钟步进', () {
      expect(CounterStepHelper.deduceDefaultStep(60, '分钟'), 15);
      expect(CounterStepHelper.deduceDefaultStep(45, 'min'), 15);
    });

    test('计数/次数单位 (个/组/杯) 自动推导为 1 步进', () {
      expect(CounterStepHelper.deduceDefaultStep(8, '杯'), 1);
      expect(CounterStepHelper.deduceDefaultStep(5, '组'), 1);
      expect(CounterStepHelper.deduceDefaultStep(50, '个'), 1);
    });
  });
}
