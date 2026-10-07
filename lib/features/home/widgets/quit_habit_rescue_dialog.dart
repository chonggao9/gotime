import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/quit_habit_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class QuitHabitRescueDialog extends StatefulWidget {
  final Habit habit;

  const QuitHabitRescueDialog({super.key, required this.habit});

  static void show(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuitHabitRescueDialog(habit: habit),
    );
  }

  @override
  State<QuitHabitRescueDialog> createState() => _QuitHabitRescueDialogState();
}

class _QuitHabitRescueDialogState extends State<QuitHabitRescueDialog> with SingleTickerProviderStateMixin {
  final _service = QuitHabitService.instance;
  late TabController _tabController;
  
  // 呼吸急救状态
  Timer? _countdownTimer;
  int _secondsRemaining = 180; // 3 分钟急救冲浪
  bool _isSurfingActive = false;
  String _breathPhase = '准备平息冲动';

  // 复盘状态
  String _selectedTrigger = '😫 压力焦虑';
  final _noteController = TextEditingController();

  final List<String> _triggers = [
    '😫 压力焦虑',
    '🥱 闲暇无聊',
    '🍻 社交诱惑',
    '💔 情绪低落',
    '⚡ 习惯性反射',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _startUrgeSurfing() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSurfingActive = true;
      _secondsRemaining = 180;
      _breathPhase = '缓慢吸气... (4秒)';
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isSurfingActive = false;
            _secondsRemaining = 0;
            _breathPhase = '🎉 太棒了！冲动高峰已平息！';
          });
          HapticFeedback.heavyImpact();
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
            final cycle = _secondsRemaining % 19;
            if (cycle >= 15) {
              _breathPhase = '缓慢吸气... (4秒)';
            } else if (cycle >= 8) {
              _breathPhase = '屏息觉察... (7秒)';
            } else {
              _breathPhase = '深长呼气... (8秒)';
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _service.getProgress(widget.habit.id, widget.habit.updatedAt);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部手柄
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 标题栏与当前戒除战绩
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.habit.iconEmoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        widget.habit.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '🔥 已坚守 ${progress.formattedCleanDuration}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '科学抗复发干预 · 冲动高峰只维持 3 分钟',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 选项卡
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.mintGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.mintGreen,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.waves_rounded, size: 18), text: '🌊 冲动冲浪急救'),
              Tab(icon: Icon(Icons.refresh_rounded, size: 18), text: '⚠️ 坦然复盘重启'),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrgeSurfingTab(isDark),
                _buildRelapseTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 冲动冲浪急救页面
  Widget _buildUrgeSurfingTab(bool isDark) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            '冲动像海浪一样，终会退潮。\n别与它对抗，闭上眼睛，伴随呼吸顺浪滑过。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.4),
          ),
          const SizedBox(height: 24),

          // 动态呼吸脉冲圆圈
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            width: _isSurfingActive ? 180 : 150,
            height: _isSurfingActive ? 180 : 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.mintGreen.withValues(alpha: _isSurfingActive ? 0.35 : 0.15),
                  AppTheme.mintGreen.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppTheme.mintGreen.withValues(alpha: _isSurfingActive ? 0.8 : 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _breathPhase,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mintGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          if (!_isSurfingActive)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _startUrgeSurfing,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('开始 3 分钟冲动急救冲浪'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  _countdownTimer?.cancel();
                  setState(() {
                    _isSurfingActive = false;
                    _secondsRemaining = 180;
                    _breathPhase = '急救已暂停';
                  });
                },
                icon: const Icon(Icons.pause_rounded),
                label: const Text('暂停冲浪'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 破戒复盘页面
  Widget _buildRelapseTab(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261919) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '自我宽恕（Self-Compassion）：\n破戒不代表前功尽弃，此前坚守的每一天神经回路都在重建。记录诱因，重新出发！',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text('刚才是什么触发了破戒？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _triggers.map((t) {
              final isSelected = _selectedTrigger == t;
              return ChoiceChip(
                label: Text(t),
                selected: isSelected,
                selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedTrigger = t);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: '写下一句对自己的温和鼓励，或者下次防范措施...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _service.recordRelapse(
                  widget.habit.id,
                  trigger: _selectedTrigger,
                  note: _noteController.text.trim(),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已记录复盘，重置计时器。放下包袱，从当下这一秒重新启航！✨'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('接纳复盘 · 重新开启计时'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
