import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/cloud_sync_service.dart';
import 'package:gotime/core/services/habit_order_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('HabitOrderService Tests', () {
    final now = DateTime.now();

    final habitA = Habit(
      id: 'h_a',
      name: '习惯A',
      iconEmoji: '🅰️',
      themeColor: '#34D399',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: now.subtract(const Duration(minutes: 10)),
      isPinned: false,
    );

    final habitB = Habit(
      id: 'h_b',
      name: '习惯B (置顶)',
      iconEmoji: '🅱️',
      themeColor: '#60A5FA',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: now.subtract(const Duration(minutes: 20)),
      isPinned: true,
    );

    final habitC = Habit(
      id: 'h_c',
      name: '习惯C',
      iconEmoji: '🅲',
      themeColor: '#F87171',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: now,
      isPinned: false,
    );

    setUp(() {
      HabitOrderService.instance.resetOrder();
    });

    test('sortHabits puts pinned habits at the top', () {
      final List<Habit> list = [habitA, habitB, habitC];
      final sorted = HabitOrderService.instance.sortHabits(list);

      // habitB is pinned, so it must be first
      expect(sorted.first.id, equals('h_b'));
    });

    test('custom drag order takes precedence for unpinned habits', () {
      // Set custom order: C -> A
      HabitOrderService.instance.setOrder(['h_c', 'h_a']);
      final List<Habit> list = [habitA, habitB, habitC];
      final sorted = HabitOrderService.instance.sortHabits(list);

      // habitB is pinned, so it remains #1
      expect(sorted[0].id, equals('h_b'));
      // habitC was ordered before habitA
      expect(sorted[1].id, equals('h_c'));
      expect(sorted[2].id, equals('h_a'));
    });

    test('handleReorder moves items properly and updates custom order', () {
      final List<Habit> list = [habitA, habitC];
      // Move habitC (index 1) to index 0
      final reordered = HabitOrderService.instance.handleReorder(list, 1, 0);

      expect(reordered.first.id, equals('h_c'));
      expect(reordered.last.id, equals('h_a'));
      expect(HabitOrderService.instance.customOrderIds, equals(['h_c', 'h_a']));
    });

    test('resetOrder clears custom ordering', () {
      HabitOrderService.instance.setOrder(['h_c', 'h_a']);
      expect(HabitOrderService.instance.customOrderIds.isNotEmpty, isTrue);

      HabitOrderService.instance.resetOrder();
      expect(HabitOrderService.instance.customOrderIds.isEmpty, isTrue);
    });
  });

  group('CloudSyncService Tests', () {
    setUp(() {
      CloudSyncService.instance.unlinkAccount();
    });

    test('default state is disabled and unlinked', () {
      final service = CloudSyncService.instance;
      expect(service.isEnabled, isFalse);
      expect(service.isAccountLinked, isFalse);
      expect(service.accountEmail, isNull);
      expect(service.devices.length, greaterThanOrEqualTo(2));
      expect(service.getLastSyncSummary(), contains('已关闭'));
    });

    test('linkAccount connects account and enables sync', () {
      final service = CloudSyncService.instance;
      service.linkAccount('alice@gotime.app');

      expect(service.isEnabled, isTrue);
      expect(service.isAccountLinked, isTrue);
      expect(service.accountEmail, equals('alice@gotime.app'));
      expect(service.getLastSyncSummary(), contains('账号已就绪'));
    });

    test('unlinkAccount revokes account and disables sync', () {
      final service = CloudSyncService.instance;
      service.linkAccount('test@gotime.app');
      expect(service.isEnabled, isTrue);

      service.unlinkAccount();
      expect(service.isEnabled, isFalse);
      expect(service.isAccountLinked, isFalse);
      expect(service.accountEmail, isNull);
    });

    test('performCloudSync executes synchronization and updates timestamp', () async {
      final service = CloudSyncService.instance;
      // Sync while disabled returns false
      final disabledResult = await service.performCloudSync();
      expect(disabledResult, isFalse);

      service.linkAccount('cloud@gotime.app');
      final syncFuture = service.performCloudSync();
      expect(service.status, equals(CloudSyncStatus.syncing));

      final success = await syncFuture;
      expect(success, isTrue);
      expect(service.status, equals(CloudSyncStatus.success));
      expect(service.lastSyncedAt, isNotNull);
      expect(service.getLastSyncSummary(), contains('刚刚已同步完成'));
    });

    test('setAutoSyncOnWifi toggles option', () {
      final service = CloudSyncService.instance;
      service.setAutoSyncOnWifi(false);
      expect(service.autoSyncOnWifi, isFalse);
      service.setAutoSyncOnWifi(true);
      expect(service.autoSyncOnWifi, isTrue);
    });
  });
}
