import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';

class HabitMatrixGridView extends StatefulWidget {
  final List<Habit> habits;
  final Future<void> Function(Habit habit, String dateStr)? onToggleCell;
  final void Function(Habit habit)? onHabitLongPress;
  final void Function(Habit habit, String dateStr)? onCellLongPress;

  const HabitMatrixGridView({
    super.key,
    required this.habits,
    this.onToggleCell,
    this.onHabitLongPress,
    this.onCellLongPress,
  });

  @override
  State<HabitMatrixGridView> createState() => _HabitMatrixGridViewState();
}

class _HabitMatrixGridViewState extends State<HabitMatrixGridView> {
  late DateTime _selectedMonday;
  bool _isLoadingWeek = false;

  // habitId -> dateStr -> CheckIn
  final Map<String, Map<String, CheckIn>> _weekCheckIns = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // 找到本周周一 (ISO 8601: 1=Mon ... 7=Sun)
    _selectedMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    _loadWeekData();
  }

  @override
  void didUpdateWidget(covariant HabitMatrixGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habits.length != oldWidget.habits.length) {
      _loadWeekData();
    }
  }

  List<DateTime> get _weekDays {
    return List.generate(7, (i) => _selectedMonday.add(Duration(days: i)));
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _isThisWeek() {
    final now = DateTime.now();
    final thisMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _selectedMonday.year == thisMonday.year &&
        _selectedMonday.month == thisMonday.month &&
        _selectedMonday.day == thisMonday.day;
  }

  Future<void> _loadWeekData() async {
    setState(() => _isLoadingWeek = true);
    final days = _weekDays;
    final startStr = _formatDate(days.first);
    final endStr = _formatDate(days.last);

    _weekCheckIns.clear();

    if (!kIsWeb) {
      try {
        final records = await SQLiteService.instance.getCheckInsForDateRange(startStr, endStr);
        for (final rec in records) {
          _weekCheckIns.putIfAbsent(rec.habitId, () => {})[rec.date] = rec;
        }
      } catch (_) {}
    } else {
      // Web 端演示数据：给今日与前几天随机生成演示打卡状态
      final todayStr = _formatDate(DateTime.now());
      for (final h in widget.habits) {
        _weekCheckIns[h.id] = {
          todayStr: CheckIn(
            id: 'mock_${h.id}_$todayStr',
            habitId: h.id,
            date: todayStr,
            status: CheckInStatus.completed,
            createdAt: DateTime.now(),
          ),
        };
      }
    }

    if (mounted) {
      setState(() => _isLoadingWeek = false);
    }
  }

  void _previousWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonday = _selectedMonday.subtract(const Duration(days: 7));
    });
    _loadWeekData();
  }

  void _nextWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonday = _selectedMonday.add(const Duration(days: 7));
    });
    _loadWeekData();
  }

  void _resetToThisWeek() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    setState(() {
      _selectedMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    });
    _loadWeekData();
  }

  Color _parseHabitColor(String hexStr) {
    try {
      final hex = hexStr.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return AppTheme.mintGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _weekDays;
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final weekStartStr = '${days.first.month}月${days.first.day}日';
    final weekEndStr = '${days.last.month}月${days.last.day}日';
    final isCurrentWeek = _isThisWeek();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 周历导航与切换器卡片
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '上一周',
                  onPressed: _previousWeek,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_view_week_rounded, size: 16, color: AppTheme.mintGreen),
                      const SizedBox(width: 6),
                      Text(
                        '$weekStartStr - $weekEndStr',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isCurrentWeek) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.mintGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '本周',
                            style: TextStyle(
                              color: AppTheme.mintGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isCurrentWeek)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: _resetToThisWeek,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mintGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '今',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mintGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '下一周',
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 周历矩阵主体横向卡片
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 表头行：左侧习惯标题 + 7 列星期日期
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              '习惯名称',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          ...days.map((d) {
                            final dateStr = _formatDate(d);
                            final isToday = dateStr == todayStr;
                            final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
                            final dayName = weekdayNames[d.weekday - 1];

                            return Container(
                              width: 36,
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppTheme.mintGreen.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isToday
                                    ? Border.all(color: AppTheme.mintGreen, width: 1.2)
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isToday
                                          ? AppTheme.mintGreen
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${d.day}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                      color: isToday
                                          ? AppTheme.mintGreen
                                          : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 1),
                      const SizedBox(height: 8),

                      if (_isLoadingWeek)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppTheme.mintGreen, strokeWidth: 2),
                          ),
                        )
                      else if (widget.habits.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              '暂无待展示习惯',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ),
                        )
                      else
                        // 各习惯行
                        ...widget.habits.map((habit) {
                          final habitColor = _parseHabitColor(habit.themeColor);
                          final habitCheckIns = _weekCheckIns[habit.id] ?? {};

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                // 习惯标题栏
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onHabitLongPress?.call(habit);
                                  },
                                  onLongPress: () {
                                    HapticFeedback.mediumImpact();
                                    widget.onHabitLongPress?.call(habit);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 110,
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                    child: Row(
                                      children: [
                                        Text(habit.iconEmoji, style: const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            habit.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (habit.isPinned)
                                          const Text('📌', style: TextStyle(fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                ),

                                // 7 个打卡矩阵格点
                                ...days.map((d) {
                                  final dateStr = _formatDate(d);
                                  final checkIn = habitCheckIns[dateStr];
                                  final isCompleted = checkIn?.status == CheckInStatus.completed;
                                  final isSkipped = checkIn?.status == CheckInStatus.skipped;
                                  final isFuture = d.isAfter(DateTime(now.year, now.month, now.day));

                                  return Container(
                                    width: 36,
                                    height: 36,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(9),
                                      onTap: () async {
                                        if (isFuture) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('未来的日子还未到来，专注当下吧 ⏳'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                          return;
                                        }
                                        HapticFeedback.lightImpact();
                                        await widget.onToggleCell?.call(habit, dateStr);
                                        _loadWeekData();
                                      },
                                      onLongPress: () {
                                        if (isFuture) return;
                                        HapticFeedback.mediumImpact();
                                        widget.onCellLongPress?.call(habit, dateStr);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? habitColor
                                              : (isSkipped
                                                  ? const Color(0xFF0284C7)
                                                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9))),
                                          borderRadius: BorderRadius.circular(9),
                                          border: Border.all(
                                            color: isCompleted || isSkipped
                                                ? Colors.transparent
                                                : (isFuture
                                                    ? (isDark ? Colors.grey[850]! : Colors.grey[300]!)
                                                    : (isDark ? Colors.grey[700]! : Colors.grey[350]!)),
                                            width: 1,
                                          ),
                                          boxShadow: isCompleted
                                              ? [
                                                  BoxShadow(
                                                    color: habitColor.withValues(alpha: 0.35),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: isCompleted
                                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                              : (isSkipped
                                                  ? const Text('❄️', style: TextStyle(fontSize: 12))
                                                  : (isFuture
                                                      ? Text('·', style: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[400], fontSize: 16))
                                                      : const SizedBox.shrink())),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
