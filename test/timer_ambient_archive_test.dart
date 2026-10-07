import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gotime/core/services/ambient_sound_service.dart';
import 'package:gotime/core/database/sqlite_service.dart';
import 'package:gotime/models/habit.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AmbientSoundService Soundscape Tests', () {
    test('Default ambient sound is none and volume is clamped', () {
      final service = AmbientSoundService.instance;
      service.setSound(AmbientSoundType.none);
      expect(service.currentSound, equals(AmbientSoundType.none));
      expect(service.isPlaying, isFalse);

      service.setVolume(1.5);
      expect(service.volume, equals(1.0));

      service.setVolume(-0.5);
      expect(service.volume, equals(0.0));
    });

    test('Switching sound sets active state and notifies', () {
      final service = AmbientSoundService.instance;
      service.setSound(AmbientSoundType.rain);
      expect(service.currentSound, equals(AmbientSoundType.rain));
      expect(service.isPlaying, isTrue);

      service.stop();
      expect(service.isPlaying, isFalse);

      service.play();
      expect(service.isPlaying, isTrue);

      service.setSound(AmbientSoundType.none);
      expect(service.currentSound, equals(AmbientSoundType.none));
      expect(service.isPlaying, isFalse);
    });
  });

  group('SQLiteService Archive & CheckIn Query Tests', () {
    test('Archive and restore habit', () async {
      final db = SQLiteService.instance;
      final habit = Habit(
        id: 'test_archive_1',
        name: '考研英语单词',
        iconEmoji: '📖',
        themeColor: '#10B981',
        type: HabitType.boolean,
        frequency: {'type': 'daily', 'days_of_week': []},
        reminders: [],
        updatedAt: DateTime.now(),
        isArchived: false,
      );

      await db.insertHabit(habit);
      
      // 归档该习惯
      await db.archiveHabit('test_archive_1', true);
      final archived = await db.getArchivedHabits();
      expect(archived.any((h) => h.id == 'test_archive_1'), isTrue);

      final active = await db.getAllActiveHabits();
      expect(active.any((h) => h.id == 'test_archive_1'), isFalse);

      // 唤醒恢复
      await db.archiveHabit('test_archive_1', false);
      final activeRestored = await db.getAllActiveHabits();
      expect(activeRestored.any((h) => h.id == 'test_archive_1'), isTrue);

      // 清理
      await db.deleteHabit('test_archive_1');
    });

    test('Insert and query check-ins for habit with logText and mood', () async {
      final db = SQLiteService.instance;
      final habit = Habit(
        id: 'test_habit_log_1',
        name: '晚间正念冥想',
        iconEmoji: '🧘',
        themeColor: '#38BDF8',
        type: HabitType.boolean,
        frequency: {'type': 'daily', 'days_of_week': []},
        reminders: [],
        updatedAt: DateTime.now(),
      );
      await db.insertHabit(habit);

      final checkIn = CheckIn(
        id: 'ci_1',
        habitId: 'test_habit_log_1',
        date: '2026-10-07',
        status: CheckInStatus.completed,
        logText: '专注呼吸 15 分钟，身心舒畅',
        mood: 5,
        durationSeconds: 900,
        createdAt: DateTime.now(),
      );
      await db.insertCheckIn(checkIn);

      final history = await db.getCheckInsForHabit('test_habit_log_1');
      expect(history.length, equals(1));
      expect(history.first.logText, equals('专注呼吸 15 分钟，身心舒畅'));
      expect(history.first.mood, equals(5));
      expect(history.first.durationSeconds, equals(900));

      // 删除打卡记录
      await db.deleteCheckIn('test_habit_log_1', '2026-10-07');
      final historyAfterDelete = await db.getCheckInsForHabit('test_habit_log_1');
      expect(historyAfterDelete.isEmpty, isTrue);

      // 清理
      await db.deleteHabit('test_habit_log_1');
    });
  });
}
