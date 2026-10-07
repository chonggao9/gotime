import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gotime/core/services/webdav_service.dart';
import 'package:gotime/core/database/sqlite_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('WebDAV Service & Config Tests', () {
    test('WebDavConfig serialization and deserialization', () {
      const config = WebDavConfig(
        serverUrl: 'https://dav.jianguoyun.com/dav/',
        username: 'test_user@example.com',
        password: 'secure_app_password',
        remotePath: '/gotime/backup.json',
      );

      final json = config.toJson();
      expect(json['server_url'], equals('https://dav.jianguoyun.com/dav/'));
      expect(json['username'], equals('test_user@example.com'));
      expect(json['remote_path'], equals('/gotime/backup.json'));

      final parsed = WebDavConfig.fromJson(json);
      expect(parsed.serverUrl, equals(config.serverUrl));
      expect(parsed.username, equals(config.username));
      expect(parsed.password, equals(config.password));
      expect(parsed.remotePath, equals(config.remotePath));
    });

    test('WebDavService config state management', () {
      final service = WebDavService.instance;
      const config = WebDavConfig(
        serverUrl: 'https://nextcloud.example.com/remote.php/dav/files/user/',
        username: 'user',
        password: 'pass',
      );
      service.saveConfig(config);
      expect(service.isConfigured, isTrue);
      expect(service.config?.serverUrl, contains('nextcloud'));
    });
  });

  group('Habit Pinning (置顶) Tests', () {
    test('Pinning habit elevates it to top in SQLite getAllActiveHabits', () async {
      final db = SQLiteService.instance;
      final habitA = Habit(
        id: 'habit_normal',
        name: '普通习惯',
        iconEmoji: '🏃',
        themeColor: '#10B981',
        type: HabitType.boolean,
        frequency: {'type': 'daily', 'days_of_week': []},
        isPinned: false,
        updatedAt: DateTime.now(),
      );
      final habitB = Habit(
        id: 'habit_pinned',
        name: '置顶习惯',
        iconEmoji: '⭐',
        themeColor: '#F59E0B',
        type: HabitType.boolean,
        frequency: {'type': 'daily', 'days_of_week': []},
        isPinned: true,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await db.insertHabit(habitA);
      await db.insertHabit(habitB);

      final habits = await db.getAllActiveHabits();
      final indexB = habits.indexWhere((h) => h.id == 'habit_pinned');
      final indexA = habits.indexWhere((h) => h.id == 'habit_normal');

      // 置顶习惯必须排在普通习惯前面
      expect(indexB < indexA, isTrue);

      // 取消置顶
      await db.pinHabit('habit_pinned', false);
      final habitsAfterUnpin = await db.getAllActiveHabits();
      final updatedHabit = habitsAfterUnpin.firstWhere((h) => h.id == 'habit_pinned');
      expect(updatedHabit.isPinned, isFalse);

      // 清理
      await db.deleteHabit('habit_normal');
      await db.deleteHabit('habit_pinned');
    });
  });
}
