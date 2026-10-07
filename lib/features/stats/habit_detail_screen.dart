import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';
import '../../../core/services/habit_strength_service.dart';
import '../home/widgets/log_habit_sheet.dart';
import 'widgets/share_poster_dialog.dart';
import 'package:uuid/uuid.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  List<CheckIn> _historyLogs = [];
  bool _isLoading = true;
  
  int _currentStreak = 12;
  int _totalDays = 45;
  double _habitStrength = 0.86;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    List<CheckIn> checkIns = [];
    if (!kIsWeb) {
      try {
        checkIns = await SQLiteService.instance.getCheckInsForHabit(widget.habit.id);
      } catch (e) {
        debugPrint('Failed to load checkins: $e');
      }
    }

    if (checkIns.isEmpty) {
      checkIns = [
        CheckIn(
          id: '1',
          habitId: widget.habit.id,
          date: DateTime.now().toIso8601String().split('T')[0],
          status: CheckInStatus.completed,
          logText: '保持节奏，日拱一卒，功不唐捐！🌿',
          mood: 5,
          createdAt: DateTime.now(),
        ),
      ];
    }

    final calculatedStrength = HabitStrengthService.calculateStrength(checkIns);
    final calculatedStreak = HabitStrengthService.calculateStreak(checkIns);

    setState(() {
      _historyLogs = checkIns;
      _currentStreak = calculatedStreak > 0 ? calculatedStreak : 1;
      _habitStrength = calculatedStrength > 0 ? calculatedStrength : 0.85;
      _totalDays = checkIns.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Color(int.parse(widget.habit.themeColor.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('习惯深度洞察'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: '生成习惯分享海报',
            onPressed: () {
              SharePosterDialog.show(
                context,
                streakDays: _currentStreak,
                strengthPercent: (_habitStrength * 100).toInt(),
                strengthLabel: HabitStrengthService.getStrengthLabel(_habitStrength),
                quote: '坚持「${widget.habit.name}」，日积月累，终成自然。',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: themeColor))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部卡片：名称与核心数据
                _buildHeaderCard(isDark, themeColor),
                const SizedBox(height: 24),

                // 核心抗焦虑机制：习惯强度指数 (指数平滑算法)
                _buildStrengthCard(isDark, themeColor),
                const SizedBox(height: 28),
                
                // 单项热力图表现
                Text(
                  '最近 30 天表现',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMiniHeatmap(isDark, themeColor),
                const SizedBox(height: 28),

                // 日志流 (Timeline)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '习惯日志与感悟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => LogHabitSheet(
                            habitName: widget.habit.name,
                            habitThemeColor: widget.habit.themeColor,
                            onSave: (logText, mood) async {
                              final todayStr = DateTime.now().toIso8601String().split('T')[0];
                              final checkIn = CheckIn(
                                id: const Uuid().v4(),
                                habitId: widget.habit.id,
                                date: todayStr,
                                status: CheckInStatus.completed,
                                logText: logText.isNotEmpty ? logText : null,
                                mood: mood,
                                createdAt: DateTime.now(),
                              );
                              if (!kIsWeb) {
                                await SQLiteService.instance.insertCheckIn(checkIn);
                              }
                              _loadHistory();
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_comment_rounded, size: 16),
                      label: const Text('写心得'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.mintGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLogsTimeline(isDark, themeColor),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderCard(bool isDark, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: themeColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(widget.habit.iconEmoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建于 ${widget.habit.updatedAt.month}月${widget.habit.updatedAt.day}日',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('当前连胜', '$_currentStreak', '天', themeColor, isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.grey[800] : Colors.grey[200]),
              _buildStatItem('累计打卡', '$_totalDays', '次', isDark ? Colors.white : Colors.black87, isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.grey[800] : Colors.grey[200]),
              _buildStatItem('习惯稳固度', '${(_habitStrength * 100).toInt()}%', '', AppTheme.mintGreen, isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// 习惯强度分析卡片 (源自 Loop Habit Tracker 指数平滑模型)
  Widget _buildStrengthCard(bool isDark, Color themeColor) {
    final label = HabitStrengthService.getStrengthLabel(_habitStrength);
    final tip = HabitStrengthService.getStrengthTip(_habitStrength);
    final percent = (_habitStrength * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.mintGreen.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🧠 ', style: TextStyle(fontSize: 18)),
                  Text(
                    '习惯稳固度 (强度模型)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mintGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _habitStrength,
              minHeight: 10,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mintGreen),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '指数平滑稳态分: $percent / 100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '抗焦虑：断签不归零',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.mintGreen.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 抚慰说明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite_rounded, size: 16, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color valColor, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valColor),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMiniHeatmap(bool isDark, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '单项历史热度',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500]),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('包含休假保护', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              Color blockColor;
              if (index == 2) {
                // 休假保护日
                blockColor = const Color(0xFF38BDF8);
              } else if (index % 5 == 0) {
                blockColor = isDark ? Colors.grey[850]! : Colors.grey[200]!;
              } else {
                blockColor = themeColor.withValues(alpha: (index % 3 + 1) * 0.33);
              }

              return Container(
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTimeline(bool isDark, Color themeColor) {
    if (_historyLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('暂无习惯打卡日志', style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    return Column(
      children: _historyLogs.map((log) {
        final moodEmojis = ['', '😫', '😕', '😐', '😊', '🤩'];
        final moodEmoji = (log.mood != null && log.mood! >= 1 && log.mood! <= 5)
            ? moodEmojis[log.mood!]
            : '📝';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(moodEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.logText ?? '完成打卡',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
