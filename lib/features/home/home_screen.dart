import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_sheet.dart';
import 'widgets/log_habit_sheet.dart';
import 'widgets/habit_action_sheet.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;
  
  // 临时保存今天已打卡的习惯 ID（后期要读 check_ins 表）
  final Set<String> _completedHabitIds = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    
    if (kIsWeb) {
      // 网页端预览时使用假数据以避开底层依赖
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _habits = [
          Habit(
            id: '1', name: '早起喝水', iconEmoji: '💧', themeColor: '#34D399', type: HabitType.counter,
            targetValue: 2000, targetUnit: 'ml', frequency: {'type': 'daily'}, updatedAt: DateTime.now(),
          ),
          Habit(
            id: '2', name: '深度工作', iconEmoji: '🍅', themeColor: '#F87171', type: HabitType.timer,
            timerSeconds: 1500, frequency: {'type': 'daily'}, updatedAt: DateTime.now(),
          ),
        ];
        _isLoading = false;
      });
      return;
    }

    // 移动端真实读取所有习惯
    final habitsData = await SQLiteService.instance.getAllActiveHabits();
    
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final checkIns = await SQLiteService.instance.getCheckInsForDate(todayStr);
    
    final completedIds = checkIns
        .where((c) => c.status == CheckInStatus.completed)
        .map((c) => c.habitId)
        .toSet();

    setState(() {
      _habits = habitsData;
      _completedHabitIds.clear();
      _completedHabitIds.addAll(completedIds);
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
          _loadHabits(); // 刷新列表
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
          // 延迟一点点，等 action sheet 关掉后再弹日志面板
          Future.delayed(const Duration(milliseconds: 200), () {
            _showLogSheet(habit);
          });
        },
        onSkipToday: () {
          // TODO: 请假逻辑
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已使用一次请假额度')));
        },
        onDelete: () async {
          if (!kIsWeb) {
            await SQLiteService.instance.deleteHabit(habit.id);
          } else {
            setState(() => _habits.removeWhere((h) => h.id == habit.id));
          }
          _loadHabits(); // 刷新列表
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('习惯日志已保存！')),
          );
        },
      ),
    );
  }

  Future<void> _toggleHabit(Habit habit) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      if (_completedHabitIds.contains(habit.id)) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 高级毛玻璃 AppBar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                '10月6日, 星期二', // TODO: 格式化真实日期
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Icon(Icons.cloud_done_rounded, color: AppTheme.mintGreen, size: 28),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
            ],
          ),
          
          // 每日名言卡 (Banner)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.mintGreen.withOpacity(0.8),
                      AppTheme.darkMintGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mintGreen.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, color: Colors.white70, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      "习惯不是枷锁，\n而是通向自由的阶梯。",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
            const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.mintGreen)))
          else if (_habits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    children: [
                      Text('🌱', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        '从第一个好习惯开始',
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[500] : Colors.grey[400]),
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
                    return HabitCard(
                      habit: habit,
                      isCompleted: isCompleted,
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
      
      // 悬浮大加号，触发弹窗
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: AppTheme.mintGreen,
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text(
          '添加',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
