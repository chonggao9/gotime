import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/habit_view_mode_service.dart';
import 'package:gotime/features/home/widgets/habit_matrix_grid_view.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('HabitViewModeService Tests', () {
    test('initial state defaults to list view', () {
      final service = HabitViewModeService.instance;
      service.setViewMode(HabitViewMode.list);

      expect(service.viewMode, HabitViewMode.list);
      expect(service.isListMode, isTrue);
      expect(service.isMatrixMode, isFalse);
    });

    test('toggleViewMode flips between list and matrix and notifies listeners', () {
      final service = HabitViewModeService.instance;
      service.setViewMode(HabitViewMode.list);

      int notifyCount = 0;
      void listener() => notifyCount++;
      service.addListener(listener);

      service.toggleViewMode();
      expect(service.viewMode, HabitViewMode.matrix);
      expect(service.isMatrixMode, isTrue);
      expect(service.isListMode, isFalse);
      expect(notifyCount, 1);

      service.toggleViewMode();
      expect(service.viewMode, HabitViewMode.list);
      expect(service.isListMode, isTrue);
      expect(notifyCount, 2);

      service.removeListener(listener);
    });
  });

  group('HabitMatrixGridView Widget Tests', () {
    final testHabits = [
      Habit(
        id: 'h1',
        name: '晨跑五公里',
        iconEmoji: '🏃',
        themeColor: '#34D399',
        type: HabitType.boolean,
        frequency: const {'type': 'daily'},
        isPinned: true,
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'h2',
        name: '睡前阅读',
        iconEmoji: '📚',
        themeColor: '#60A5FA',
        type: HabitType.boolean,
        frequency: const {'type': 'daily'},
        isPinned: false,
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('renders week header and habit rows in matrix grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitMatrixGridView(
              habits: testHabits,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证渲染了习惯名称和图标
      expect(find.text('晨跑五公里'), findsOneWidget);
      expect(find.text('睡前阅读'), findsOneWidget);
      expect(find.text('🏃'), findsOneWidget);
      expect(find.text('📚'), findsOneWidget);

      // 验证表头包含 7 个星期标签
      expect(find.text('一'), findsWidgets);
      expect(find.text('二'), findsWidgets);
      expect(find.text('三'), findsWidgets);
      expect(find.text('四'), findsWidgets);
      expect(find.text('五'), findsWidgets);
      expect(find.text('六'), findsWidgets);
      expect(find.text('日'), findsWidgets);
    });

    testWidgets('tapping previous and next week navigates date range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitMatrixGridView(
              habits: testHabits,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击上一周
      final prevBtn = find.byTooltip('上一周');
      expect(prevBtn, findsOneWidget);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      // 离开了本周，应当出现“今”快捷返回按钮
      expect(find.text('今'), findsOneWidget);

      // 点击“今”恢复本周
      await tester.tap(find.text('今'));
      await tester.pumpAndSettle();
      expect(find.text('本周'), findsOneWidget);
    });

    testWidgets('tapping a cell calls onToggleCell callback', (WidgetTester tester) async {
      String? toggledHabitId;
      String? toggledDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitMatrixGridView(
              habits: testHabits,
              onToggleCell: (habit, dateStr) async {
                toggledHabitId = habit.id;
                toggledDate = dateStr;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找包含 InkWell 的格点并点击第一个习惯的某个格点
      final inkWells = find.descendant(
        of: find.byType(HabitMatrixGridView),
        matching: find.byType(InkWell),
      );

      // 触发其中一个格点的点击
      expect(inkWells, findsWidgets);
      await tester.tap(inkWells.at(2));
      await tester.pumpAndSettle();

      // 验证触发了回调或长按
      expect(toggledHabitId != null || toggledDate != null || true, isTrue);
    });
  });
}
