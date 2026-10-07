import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/backup_service.dart';
import 'package:gotime/models/habit.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  group('BackupService Local-First Export & Import Tests', () {
    final habits = [
      Habit(
        id: 'h1',
        name: '晨起温水',
        iconEmoji: '💧',
        themeColor: '#34D399',
        type: HabitType.counter,
        targetValue: 2000,
        targetUnit: 'ml',
        timeOfDay: 'morning',
        tags: ['健康'],
        frequency: {'type': 'daily'},
        updatedAt: DateTime.parse('2026-10-07T08:00:00Z'),
      ),
      Habit(
        id: 'h2',
        name: '深度工作',
        iconEmoji: '🍅',
        themeColor: '#F87171',
        type: HabitType.timer,
        timerSeconds: 1500,
        timeOfDay: 'afternoon',
        stackedAfterHabitId: 'h1',
        stackedAfterHabitName: '晨起温水',
        frequency: {'type': 'daily'},
        updatedAt: DateTime.parse('2026-10-07T08:00:00Z'),
      ),
    ];

    final checkIns = [
      CheckIn(
        id: 'c1',
        habitId: 'h1',
        date: '2026-10-07',
        status: CheckInStatus.completed,
        value: 2000,
        logText: '今天感觉精力充沛！',
        mood: 5,
        createdAt: DateTime.parse('2026-10-07T08:30:00Z'),
      ),
      CheckIn(
        id: 'c2',
        habitId: 'h2',
        date: '2026-10-06',
        status: CheckInStatus.skipped,
        logText: '出差在飞机上，开启休假免责 ❄️',
        mood: 4,
        createdAt: DateTime.parse('2026-10-06T09:00:00Z'),
      ),
    ];

    test('Export to JSON produces valid JSON structure with metadata', () {
      final jsonString = BackupService.exportToJson(habits: habits, checkIns: checkIns);
      expect(jsonString, contains('"app": "GoTime"'));
      expect(jsonString, contains('"habits_count": 2'));
      expect(jsonString, contains('"check_ins_count": 2'));

      final parsed = BackupService.validateAndParseJson(jsonString);
      expect(parsed, isNotNull);
      final restoredHabits = parsed!['habits'] as List<Habit>;
      final restoredCheckIns = parsed['check_ins'] as List<CheckIn>;

      expect(restoredHabits.length, 2);
      expect(restoredHabits[0].name, '晨起温水');
      expect(restoredHabits[1].stackedAfterHabitId, 'h1');
      expect(restoredCheckIns.length, 2);
      expect(restoredCheckIns[0].logText, '今天感觉精力充沛！');
    });

    test('Export to CSV produces valid tabular headers and escaped content', () {
      final csvString = BackupService.exportToCsv(habits: habits, checkIns: checkIns);
      expect(csvString, contains('日期,习惯名称,图标,习惯类型,打卡状态'));
      expect(csvString, contains('2026-10-07,"晨起温水",💧,counter,completed,2000,ml'));
      expect(csvString, contains('2026-10-06,"深度工作",🍅,timer,skipped'));
      expect(csvString, contains('"出差在飞机上，开启休假免责 ❄️"'));
    });

    test('Invalid JSON returns null from validateAndParseJson', () {
      expect(BackupService.validateAndParseJson(''), isNull);
      expect(BackupService.validateAndParseJson('{ invalid json }'), isNull);
      expect(BackupService.validateAndParseJson('{"other_app": "random"}'), isNull);
    });
  });
}
