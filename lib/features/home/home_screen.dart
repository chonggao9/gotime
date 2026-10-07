import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../core/services/freeze_mode_service.dart';
import '../../../core/services/habit_order_service.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_sheet.dart';
import 'widgets/log_habit_sheet.dart';
import 'widgets/habit_action_sheet.dart';
import 'widgets/confetti_overlay.dart';
import 'widgets/archived_habits_sheet.dart';
import 'widgets/routine_play_sheet.dart';
import 'widgets/two_minute_friction_dialog.dart';
import 'widgets/quick_natural_log_dialog.dart';
import 'widgets/kindness_mailbox_dialog.dart';
import '../stats/widgets/share_poster_dialog.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/habit_view_mode_service.dart';
import 'widgets/habit_matrix_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;
  bool _isReorderMode = false;
  
  // 时段筛选：all, morning, afternoon, evening
  String _selectedTimeSlot = 'all';

  // 保存今天已完成的习惯 ID
  final Set<String> _completedHabitIds = {};
  // 保存今天已免责跳过/休假的习惯 ID
  final Set<String> _skippedHabitIds = {};

  @override
  void initState() {
    super.initState();
    HabitOrderService.instance.addListener(_onHabitOrderChanged);
    HabitViewModeService.instance.addListener(_onViewModeChanged);
    HabitViewModeService.instance.init();
    _loadHabits();
  }

  @override
  void dispose() {
    HabitOrderService.instance.removeListener(_onHabitOrderChanged);
    HabitViewModeService.instance.removeListener(_onViewModeChanged);
    super.dispose();
  }

  void _onHabitOrderChanged() {
    if (mounted) setState(() {});
  }

  void _onViewModeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 250));
      setState(() {
        _habits = [
          Habit(
            id: '1',
            name: '早起喝水',
            iconEmoji: '💧',
            themeColor: '#34D399',
            type: HabitType.counter,
            targetValue: 2000,
            targetUnit: 'ml',
            timeOfDay: 'morning',
            frequency: {'type': 'daily'},
            updatedAt: DateTime.now(),
          ),
          Habit(
            id: '2',
            name: '深度工作',
            iconEmoji: '🍅',
            themeColor: '#F87171',
            type: HabitType.timer,
            timerSeconds: 1500,
            timeOfDay: 'afternoon',
            frequency: {'type': 'daily'},
            updatedAt: DateTime.now(),
          ),
          Habit(
            id: '3',
            name: '睡前阅读',
            iconEmoji: '📚',
            themeColor: '#60A5FA',
            type: HabitType.boolean,
            timeOfDay: 'evening',
            frequency: {'type': 'daily'},
            updatedAt: DateTime.now(),
          ),
        ];
        _isLoading = false;
      });
      return;
    }

    final habitsData = await SQLiteService.instance.getAllActiveHabits();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final checkIns = await SQLiteService.instance.getCheckInsForDate(todayStr);
    
    final completedIds = checkIns
        .where((c) => c.status == CheckInStatus.completed)
        .map((c) => c.habitId)
        .toSet();

    final skippedIds = checkIns
        .where((c) => c.status == CheckInStatus.skipped)
        .map((c) => c.habitId)
        .toSet();

    setState(() {
      _habits = habitsData;
      _completedHabitIds.clear();
      _completedHabitIds.addAll(completedIds);
      _skippedHabitIds.clear();
      _skippedHabitIds.addAll(skippedIds);
      _isLoading = false;
    });
  }

  List<Habit> get _filteredHabits {
    final list = _selectedTimeSlot == 'all'
        ? _habits
        : _habits.where((h) => h.timeOfDay == _selectedTimeSlot || h.timeOfDay == 'all').toList();
    return HabitOrderService.instance.sortHabits(list);
  }

  void _showCreateSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateHabitSheet(
        existingHabits: _habits,
        onSave: (newHabit) async {
          if (!kIsWeb) {
            await SQLiteService.instance.insertHabit(newHabit);
          } else {
            setState(() => _habits.add(newHabit));
          }
          _loadHabits();
        },
      ),
    );
  }

  void _showActionSheet(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitActionSheet(
        habit: habit,
        onWriteLog: () {
          Future.delayed(const Duration(milliseconds: 200), () {
            _showLogSheet(habit);
          });
        },
        onSkipToday: () async {
          final todayStr = DateTime.now().toIso8601String().split('T')[0];
          
          if (!kIsWeb) {
            final checkIn = CheckIn(
              id: const Uuid().v4(),
              habitId: habit.id,
              date: todayStr,
              status: CheckInStatus.skipped,
              createdAt: DateTime.now(),
            );
            await SQLiteService.instance.insertCheckIn(checkIn);
          }

          setState(() {
            _skippedHabitIds.add(habit.id);
            _completedHabitIds.remove(habit.id);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Text('❄️ ', style: TextStyle(fontSize: 16)),
                    Text('已开启今日免责休假，连胜与习惯强度已锁定保护！'),
                  ],
                ),
                backgroundColor: Color(0xFF0284C7),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onTogglePin: () async {
          HapticFeedback.mediumImpact();
          final newPinned = !habit.isPinned;
          if (!kIsWeb) {
            await SQLiteService.instance.pinHabit(habit.id, newPinned);
          } else {
            final index = _habits.indexWhere((h) => h.id == habit.id);
            if (index != -1) {
              _habits[index] = habit.copyWith(isPinned: newPinned);
              _habits.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));
            }
          }
          _loadHabits();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(newPinned ? '已置顶习惯「${habit.name}」📌' : '已取消置顶「${habit.name}」'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onArchive: () async {
          HapticFeedback.mediumImpact();
          if (!kIsWeb) {
            await SQLiteService.instance.archiveHabit(habit.id, true);
          } else {
            setState(() => _habits.removeWhere((h) => h.id == habit.id));
          }
          _loadHabits();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已归档「${habit.name}」，可在归档池随时唤醒 📦'),
                backgroundColor: Colors.amber[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onTwoMinuteRule: () {
          _showTwoMinuteDialog(habit);
        },
        onDelete: () async {
          if (!kIsWeb) {
            await SQLiteService.instance.deleteHabit(habit.id);
          } else {
            setState(() => _habits.removeWhere((h) => h.id == habit.id));
          }
          _loadHabits();
        },
      ),
    );
  }

  void _showTwoMinuteDialog(Habit habit) {
    TwoMinuteFrictionDialog.show(
      context,
      habit: habit,
      onCompleteMicroStart: (h, note) async {
        if (!_completedHabitIds.contains(h.id)) {
          await _toggleHabit(h, note: note);
        }
      },
    );
  }

  void _showQuickNaturalLogSheet() {
    QuickNaturalLogDialog.show(
      context,
      habits: _habits,
      onBatchCheckIn: (intents) async {
        for (final intent in intents) {
          if (!_completedHabitIds.contains(intent.habit.id)) {
            await _toggleHabit(
              intent.habit,
              value: intent.value,
              durationSeconds: intent.durationSeconds,
              mood: intent.mood,
              note: intent.note,
            );
          }
        }
      },
    );
  }

  void _showLogSheet(Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogHabitSheet(
        habitName: habit.name,
        habitThemeColor: habit.themeColor,
        onSave: (logText, mood) async {
          HapticFeedback.heavyImpact();
          final todayStr = DateTime.now().toIso8601String().split('T')[0];
          final checkIn = CheckIn(
            id: const Uuid().v4(),
            habitId: habit.id,
            date: todayStr,
            status: CheckInStatus.completed,
            logText: logText.isNotEmpty ? logText : null,
            mood: mood,
            createdAt: DateTime.now(),
          );

          if (!kIsWeb) {
            await SQLiteService.instance.insertCheckIn(checkIn);
          }

          setState(() {
            _skippedHabitIds.remove(habit.id);
            _completedHabitIds.add(habit.id);
          });

          _checkAllCompleted();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('「${habit.name}」心得日志已保存，今日已打卡！✨'),
                backgroundColor: AppTheme.mintGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _toggleHabitForDate(Habit habit, String dateStr) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    if (dateStr == todayStr) {
      await _toggleHabit(habit);
      return;
    }

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已就地更新「${habit.name}」在 $dateStr 的打卡状态 ✨'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final existing = await SQLiteService.instance.getCheckInsForDate(dateStr);
    final targetRecord = existing.where((c) => c.habitId == habit.id).firstOrNull;

    if (targetRecord != null && targetRecord.status == CheckInStatus.completed) {
      await SQLiteService.instance.deleteCheckIn(habit.id, dateStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${habit.name}」已取消 $dateStr 打卡'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final checkIn = CheckIn(
        id: const Uuid().v4(),
        habitId: habit.id,
        date: dateStr,
        status: CheckInStatus.completed,
        createdAt: DateTime.now(),
      );
      await SQLiteService.instance.insertCheckIn(checkIn);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${habit.name}」已补签 $dateStr ✨'),
            backgroundColor: AppTheme.mintGreen,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> _toggleHabit(
    Habit habit, {
    int? value,
    int? durationSeconds,
    int? mood,
    String? note,
  }) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final bool wasAlreadyCompleted = _completedHabitIds.contains(habit.id);

    setState(() {
      _skippedHabitIds.remove(habit.id);
      if (wasAlreadyCompleted) {
        _completedHabitIds.remove(habit.id);
      } else {
        _completedHabitIds.add(habit.id);
      }
    });

    if (!kIsWeb) {
      if (_completedHabitIds.contains(habit.id)) {
        final checkIn = CheckIn(
          id: const Uuid().v4(),
          habitId: habit.id,
          date: todayStr,
          status: CheckInStatus.completed,
          value: value,
          durationSeconds: durationSeconds,
          mood: mood,
          logText: note,
          createdAt: DateTime.now(),
        );
        await SQLiteService.instance.insertCheckIn(checkIn);
      } else {
        await SQLiteService.instance.deleteCheckIn(habit.id, todayStr);
      }
    }

    // 检查是否有下游堆叠的习惯触发提醒 (F2.3 习惯堆叠触发器)
    if (!wasAlreadyCompleted && _completedHabitIds.contains(habit.id)) {
      final stackedHabits = _habits.where((h) => 
        h.stackedAfterHabitId == habit.id || 
        h.stackedAfterHabitName == habit.name
      ).toList();

      if (stackedHabits.isNotEmpty) {
        final nextHabit = stackedHabits.first;
        if (!_completedHabitIds.contains(nextHabit.id)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⛓️ 习惯堆叠：完成了【${habit.name}】，顺便完成【${nextHabit.name}】吧！'),
                  backgroundColor: AppTheme.darkMintGreen,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: '立即完成',
                    textColor: Colors.white,
                    onPressed: () {
                      _toggleHabit(nextHabit);
                    },
                  ),
                ),
              );
            }
          });
        }
      }
    }

    // 检查是否全勤达成，触发五彩纸屑庆祝
    if (!wasAlreadyCompleted) {
      _checkAllCompleted();
    }
  }

  void _checkAllCompleted() {
    if (_habits.isNotEmpty &&
        _completedHabitIds.length + _skippedHabitIds.length >= _habits.length) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ConfettiCelebrationDialog.show(context);
        }
      });
    }
  }

  void _showVacationDialog() {
    HapticFeedback.mediumImpact();
    final reasonController = TextEditingController(text: FreezeModeService.instance.currentReason);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('❄️ '),
            Text('休假免责模式设置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开启后，在休假期间未打卡不会扣减习惯强度，连胜记录亦不会清零，给身心合法喘息的机会。',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: '休假/免责原因',
                hintText: '如：年度休假、身体不适休养、出差中',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              FreezeModeService.instance.setFreezeMode(false);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('退出休假', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              FreezeModeService.instance.setFreezeMode(true, reason: reasonController.text);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('开启保护', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterBar(bool isDark) {
    final slots = [
      {'key': 'all', 'label': '全部', 'icon': '✨'},
      {'key': 'morning', 'label': '晨间', 'icon': '🌅'},
      {'key': 'afternoon', 'label': '午间', 'icon': '☀️'},
      {'key': 'evening', 'label': '晚间', 'icon': '🌙'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...slots.map((slot) {
          final isSelected = _selectedTimeSlot == slot['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: Text(slot['icon']!, style: const TextStyle(fontSize: 13)),
              label: Text(slot['label']!),
              selected: isSelected,
              selectedColor: isDark ? AppTheme.darkMintGreen.withValues(alpha: 0.5) : AppTheme.mintGreen.withValues(alpha: 0.2),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppTheme.darkMintGreen)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.mintGreen
                    : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _selectedTimeSlot = slot['key']!);
              },
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: ActionChip(
            avatar: const Text('▶️', style: TextStyle(fontSize: 12)),
            label: Text(
              _selectedTimeSlot == 'morning'
                  ? '开启晨间心流'
                  : (_selectedTimeSlot == 'evening' ? '开启晚间仪式' : '开启心流仪式'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.mintGreen,
              ),
            ),
            backgroundColor: AppTheme.mintGreen.withValues(alpha: 0.12),
            side: BorderSide(color: AppTheme.mintGreen.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              HapticFeedback.mediumImpact();
              final candidates = _filteredHabits;
              if (candidates.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('当前时段暂无待办习惯，先添加一个吧 🌱')),
                );
                return;
              }
              final title = _selectedTimeSlot == 'morning'
                  ? '晨间心流仪式'
                  : (_selectedTimeSlot == 'evening' ? '晚间安眠仪式' : '日常心流仪式');
              RoutinePlaySheet.show(
                context,
                habits: candidates,
                title: title,
                onHabitCompleted: (h) async {
                  if (!_completedHabitIds.contains(h.id)) {
                    await _toggleHabit(h);
                  }
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final dateTitle = '${now.month}月${now.day}日 星期${weekdayNames[now.weekday - 1]}';
    final displayedHabits = _filteredHabits;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 高级毛玻璃 AppBar
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                dateTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              // 善意共鸣信箱入口 (F13.1)
              IconButton(
                icon: const Icon(Icons.mail_outline_rounded, size: 22),
                tooltip: '善意共鸣信箱 💌',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  KindnessMailboxDialog.show(context);
                },
              ),
              // 分享海报生成入口
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, size: 22),
                tooltip: '生成今日打卡海报',
                onPressed: () {
                  SharePosterDialog.show(context);
                },
              ),
              // 自然语言极速速记打卡 (F11.2)
              IconButton(
                icon: const Icon(Icons.flash_on_rounded, size: 22),
                tooltip: '自然语言极速速记打卡',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showQuickNaturalLogSheet();
                },
              ),
              // 休假/冻结模式快捷开关
              ValueListenableBuilder<bool>(
                valueListenable: FreezeModeService.instance.isFreezeModeActive,
                builder: (context, isFrozen, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ActionChip(
                      avatar: Text(isFrozen ? '❄️' : '🌴', style: const TextStyle(fontSize: 13)),
                      label: Text(
                        isFrozen ? '休假中' : '休假',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFrozen ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                        ),
                      ),
                      backgroundColor: isFrozen
                          ? const Color(0xFF0284C7)
                          : (isDark ? Colors.grey[850] : Colors.grey[200]),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: _showVacationDialog,
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: _isReorderMode ? '完成自定义排序' : '习惯排序与重排',
                icon: Icon(
                  _isReorderMode ? Icons.check_circle_rounded : Icons.swap_vert_rounded,
                  size: 22,
                  color: _isReorderMode ? AppTheme.mintGreen : null,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isReorderMode = !_isReorderMode);
                },
              ),
              // 周历矩阵 vs 卡片列表视图切换 (F14.1)
              ListenableBuilder(
                listenable: HabitViewModeService.instance,
                builder: (context, _) {
                  final isMatrix = HabitViewModeService.instance.isMatrixMode;
                  return IconButton(
                    tooltip: isMatrix ? '切换至卡片列表视图' : '切换至周历矩阵视图',
                    icon: Icon(
                      isMatrix ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                      size: 22,
                      color: isMatrix ? AppTheme.mintGreen : null,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      HabitViewModeService.instance.toggleViewMode();
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  tooltip: '已归档习惯 (休眠池)',
                  icon: const Icon(Icons.inventory_2_outlined, size: 22),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ArchivedHabitsSheet.show(
                      context,
                      onHabitRestored: () {
                        _loadHabits();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          // 全局休假模式横幅 (若激活)
          ValueListenableBuilder<bool>(
            valueListenable: FreezeModeService.instance.isFreezeModeActive,
            builder: (context, isFrozen, child) {
              if (!isFrozen) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('❄️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '免责休假保护中 · ${FreezeModeService.instance.currentReason}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Text(
                                '不扣减习惯强度，连胜不断签，安心休息',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _showVacationDialog,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('管理', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 每日名言卡 (Banner) - 点击直接生成海报
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  SharePosterDialog.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.mintGreen.withValues(alpha: 0.8),
                        AppTheme.darkMintGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mintGreen.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_quote_rounded, color: Colors.white70, size: 24),
                                SizedBox(width: 4),
                                Text(
                                  '每日灵感 · 点击分享',
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "习惯不是枷锁，\n而是通向自由的阶梯。",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 时段分类胶囊筛选栏 (F2.2)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _buildTimeFilterBar(isDark),
            ),
          ),

          if (_isReorderMode && displayedHabits.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.mintGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.mintGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded, size: 18, color: AppTheme.mintGreen),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '拖动右侧手柄即可调整习惯执行排序，置顶习惯优先位于顶层',
                          style: TextStyle(fontSize: 12, color: AppTheme.mintGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          HabitOrderService.instance.resetOrder();
                          setState(() {});
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.mintGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('恢复默认', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 习惯卡片列表或空状态
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.mintGreen),
                ),
              ),
            )
          else if (_habits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        '从第一个好习惯开始',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (displayedHabits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      Text(
                        '该时段暂无排期习惯',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_isReorderMode)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverReorderableList(
                itemCount: displayedHabits.length,
                onReorder: (oldIndex, newIndex) {
                  HapticFeedback.selectionClick();
                  HabitOrderService.instance.handleReorder(displayedHabits, oldIndex, newIndex);
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  final habit = displayedHabits[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(habit.id),
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: habit.isPinned
                              ? AppTheme.mintGreen.withValues(alpha: 0.6)
                              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                          width: habit.isPinned ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(habit.iconEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  habit.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (habit.isPinned) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.mintGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('置顶', style: TextStyle(color: AppTheme.mintGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(Icons.drag_handle_rounded, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else if (HabitViewModeService.instance.isMatrixMode)
            SliverToBoxAdapter(
              child: HabitMatrixGridView(
                habits: displayedHabits,
                onToggleCell: (habit, dateStr) async {
                  await _toggleHabitForDate(habit, dateStr);
                },
                onHabitLongPress: (habit) {
                  _showActionSheet(habit);
                },
                onCellLongPress: (habit, dateStr) {
                  _showLogSheet(habit);
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = displayedHabits[index];
                    final isCompleted = _completedHabitIds.contains(habit.id);
                    final isSkipped = _skippedHabitIds.contains(habit.id);
                    return HabitCard(
                      habit: habit,
                      isCompleted: isCompleted,
                      isSkipped: isSkipped,
                      onToggle: () => _toggleHabit(habit),
                      onLongPress: () => _showActionSheet(habit),
                    );
                  },
                  childCount: displayedHabits.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      // 悬浮大加号
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: AppTheme.mintGreen,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text(
          '添加习惯',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
