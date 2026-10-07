import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/year_in_pixels_service.dart';
import 'package:gotime/models/check_in.dart';

void main() {
  group('YearInPixelsService Tests', () {
    final service = YearInPixelsService.instance;

    test('calculatePixelColor maps ratio and freeze status to distinct hues', () {
      final colorSkipped = service.calculatePixelColor(ratio: 0.0, isSkipped: true);
      expect(colorSkipped, equals(const Color(0xFF38BDF8))); // 冰蓝

      final colorFull = service.calculatePixelColor(ratio: 1.0, isSkipped: false);
      expect(colorFull, equals(const Color(0xFF10B981))); // 翠绿

      final colorMid = service.calculatePixelColor(ratio: 0.65, isSkipped: false);
      expect(colorMid, equals(const Color(0xFF34D399))); // 薄荷绿

      final colorLow = service.calculatePixelColor(ratio: 0.35, isSkipped: false);
      expect(colorLow, equals(const Color(0xFFFBBF24))); // 暖黄

      final colorEmpty = service.calculatePixelColor(ratio: 0.0, isSkipped: false, isDark: true);
      expect(colorEmpty, equals(const Color(0xFF262626)));
    });

    test('generateYearGrid constructs all 12 months for 2026 with correct day counts', () {
      final checkIns = [
        CheckIn(
          id: 'c1',
          habitId: 'h1',
          date: '2026-01-15',
          status: CheckInStatus.completed,
          createdAt: DateTime.now(),
        ),
        CheckIn(
          id: 'c2',
          habitId: 'h2',
          date: '2026-02-14',
          status: CheckInStatus.skipped,
          createdAt: DateTime.now(),
        ),
      ];

      final grid = service.generateYearGrid(
        year: 2026,
        checkIns: checkIns,
        totalDailyHabitsTarget: 2,
      );

      expect(grid.length, equals(12));
      expect(grid[1]!.length, equals(31)); // Jan has 31
      expect(grid[2]!.length, equals(28)); // 2026 Feb has 28
      expect(grid[4]!.length, equals(30)); // Apr has 30

      // Jan 15 should have completed count = 1
      final jan15 = grid[1]!.firstWhere((p) => p.date.day == 15);
      expect(jan15.completedCount, equals(1));
      expect(jan15.ratio, equals(0.5));
      expect(jan15.isSkipped, isFalse);

      // Feb 14 should have isSkipped = true
      final feb14 = grid[2]!.firstWhere((p) => p.date.day == 14);
      expect(feb14.isSkipped, isTrue);
      expect(feb14.color, equals(const Color(0xFF38BDF8)));
    });

    test('calculateAnnualStats aggregates totals accurately', () {
      final grid = service.generateYearGrid(
        year: 2026,
        checkIns: [
          CheckIn(
            id: 'c1',
            habitId: 'h1',
            date: '2026-01-01',
            status: CheckInStatus.completed,
            createdAt: DateTime.now(),
          ),
          CheckIn(
            id: 'c2',
            habitId: 'h2',
            date: '2026-01-01',
            status: CheckInStatus.completed,
            createdAt: DateTime.now(),
          ),
          CheckIn(
            id: 'c3',
            habitId: 'h1',
            date: '2026-01-02',
            status: CheckInStatus.skipped,
            createdAt: DateTime.now(),
          ),
        ],
        totalDailyHabitsTarget: 2,
      );

      final stats = service.calculateAnnualStats(grid);
      expect(stats.totalDaysLogged, greaterThanOrEqualTo(2));
      expect(stats.fullyCompletedDays, greaterThanOrEqualTo(1));
      expect(stats.skippedDays, greaterThanOrEqualTo(1));
    });
  });
}
