import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../core/services/freeze_mode_service.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_sheet.dart';
import 'widgets/log_habit_sheet.dart';
import 'widgets/habit_action_sheet.dart';
import 'widgets/confetti_overlay.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;
  
  // 保存今天已完成的习惯 ID
  final Set<String> _completedHabitIds = {};
  // 保存今天已免责跳过/休假的习惯 ID
  final Set<String> _skippedHabitIds = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 300));
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
            frequency: {'type': 'daily'},
            updatedAt: DateTime.now(),
          ),
          Habit(
            id: '3',
            name: '睡前阅读',
            iconEmoji: '📚',
            themeColor: '#60A5FA',
            type: HabitType.boolean,
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

  void _showCreateSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateHabitSheet(
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('习惯日志已保存！'), behavior: SnackBarBehavior.floating),
            );
          }
        },
      ),
    );
  }

  Future<void> _toggleHabit(Habit habit) async {
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
          createdAt: DateTime.now(),
        );
        await SQLiteService.instance.insertCheckIn(checkIn);
      }
    }

    // 检查是否全勤达成，触发 F1.3 五彩纸屑庆祝与触感回馈！
    if (_habits.isNotEmpty &&
        _completedHabitIds.length + _skippedHabitIds.length >= _habits.length &&
        !wasAlreadyCompleted) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final dateTitle = '${now.month}月${now.day}日 星期${weekdayNames[now.weekday - 1]}';

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
              // 休假/冻结模式快捷开关
              ValueListenableBuilder<bool>(
                valueListenable: FreezeModeService.instance.isFreezeModeActive,
                builder: (context, isFrozen, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ActionChip(
                      avatar: Text(isFrozen ? '❄️' : '🌴', style: const TextStyle(fontSize: 14)),
                      label: Text(
                        isFrozen ? '休假中' : '休假模式',
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
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.cloud_done_rounded, color: AppTheme.mintGreen, size: 26),
                  onPressed: () {
                    HapticFeedback.lightImpact();
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

          // 每日名言卡 (Banner)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, color: Colors.white70, size: 28),
                    SizedBox(height: 6),
                    Text(
                      "习惯不是枷锁，\n而是通向自由的阶梯。",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
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
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _habits[index];
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
                  childCount: _habits.length,
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
