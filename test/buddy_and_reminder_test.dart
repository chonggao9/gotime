import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/models/check_in.dart';
import 'package:gotime/core/services/buddy_service.dart';
import 'package:gotime/core/services/reminder_service.dart';

void main() {
  group('BuddyService 习惯搭子与结对互勉测试', () {
    test('初始状态包含默认搭子并且具备有效专属结对密令', () {
      final service = BuddyService.instance;
      expect(service.myPairCode.startsWith('GT-MINT-'), isTrue);
      expect(service.hasBuddy, isTrue);
      expect(service.buddy, isNotNull);
      expect(service.buddy!.name, contains('Alex'));
    });

    test('使用自定义口令可成功绑定新搭子', () {
      final service = BuddyService.instance;
      final ok = service.pairWithCode('GT-LILY-9999', nickname: '自律小李');
      expect(ok, isTrue);
      expect(service.buddy!.name, '自律小李');
      expect(service.buddy!.pairCode, 'GT-LILY-9999');
      expect(service.buddy!.interactions.isNotEmpty, isTrue);
    });

    test('空口令结对返回 false', () {
      final service = BuddyService.instance;
      final ok = service.pairWithCode('   ');
      expect(ok, isFalse);
    });

    test('能够发送不同类型的互动消息 (戳一戳、击掌、请假卡)', () {
      final service = BuddyService.instance;
      service.pairWithCode('GT-TEST-1111');
      final initialCount = service.buddy!.interactions.length;

      service.sendInteraction(BuddyInteractionType.poke);
      expect(service.buddy!.interactions.length, initialCount + 1);
      expect(service.buddy!.interactions.first.type, BuddyInteractionType.poke);
      expect(service.buddy!.interactions.first.fromMe, isTrue);

      service.sendInteraction(
        BuddyInteractionType.freezePass,
        customMessage: '今天放心歇，我罩着你！',
      );
      expect(service.buddy!.interactions.first.type, BuddyInteractionType.freezePass);
      expect(service.buddy!.interactions.first.message, '今天放心歇，我罩着你！');
    });

    test('解除结对后 hasBuddy 变为 false', () {
      final service = BuddyService.instance;
      service.unpair();
      expect(service.hasBuddy, isFalse);
      expect(service.buddy, isNull);
    });

    test('calculateMyWeeklyDays 能够精准统计当周内有效打卡天数', () {
      final service = BuddyService.instance;
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final checkIns = [
        CheckIn(
          id: 'c1',
          habitId: 'h1',
          date: todayStr,
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
        // 同一天另一习惯打卡，天数集合应去重
        CheckIn(
          id: 'c2',
          habitId: 'h2',
          date: todayStr,
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
      ];

      final days = service.calculateMyWeeklyDays(checkIns);
      expect(days, 1);
    });
  });

  group('ReminderService 智能提醒与免打扰测试', () {
    test('初始时段配置合法且格式化正常', () {
      final service = ReminderService.instance;
      expect(service.isMorningEnabled, isTrue);
      expect(service.isAfternoonEnabled, isTrue);
      expect(service.isEveningEnabled, isTrue);

      final summary = service.getNextScheduledSummary();
      expect(summary.contains('08:00'), isTrue);
      expect(summary.contains('13:00'), isTrue);
      expect(summary.contains('21:00'), isTrue);
    });

    test('更新时段与开关状态正确生效', () {
      final service = ReminderService.instance;
      service.updateSlot(
        morning: const TimeOfDay(hour: 7, minute: 30),
        morningEnabled: false,
      );
      expect(service.formatTime(service.morningTime), '07:30');
      expect(service.isMorningEnabled, isFalse);

      final summary = service.getNextScheduledSummary();
      expect(summary.contains('晨间'), isFalse);
    });

    test('跨午夜静音免打扰判定精准生效 (22:30 ~ 07:00)', () {
      final service = ReminderService.instance;
      service.updateQuietHours(
        enabled: true,
        start: const TimeOfDay(hour: 22, minute: 30),
        end: const TimeOfDay(hour: 7, minute: 0),
      );

      // 深夜 23:15 -> 应在免打扰时段内
      final lateNight = DateTime(2026, 10, 7, 23, 15);
      expect(service.isInQuietHours(lateNight), isTrue);

      // 凌晨 04:30 -> 应在免打扰时段内
      final earlyMorning = DateTime(2026, 10, 7, 4, 30);
      expect(service.isInQuietHours(earlyMorning), isTrue);

      // 白天 14:00 -> 不在免打扰时段内
      final daytime = DateTime(2026, 10, 7, 14, 0);
      expect(service.isInQuietHours(daytime), isFalse);

      // 关闭免打扰总开关后，任何时段均返回 false
      service.updateQuietHours(enabled: false);
      expect(service.isInQuietHours(lateNight), isFalse);
    });
  });
}
