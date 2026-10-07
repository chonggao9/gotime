import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/watch_companion_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../models/habit.dart';

class WatchPreviewDialog extends StatefulWidget {
  const WatchPreviewDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const WatchPreviewDialog(),
    );
  }

  @override
  State<WatchPreviewDialog> createState() => _WatchPreviewDialogState();
}

class _WatchPreviewDialogState extends State<WatchPreviewDialog> {
  final _watchService = WatchCompanionService.instance;
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final list = await SQLiteService.instance.getAllActiveHabits();
      if (mounted) {
        setState(() {
          _habits = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _habits = [
            Habit(
              id: 'w1',
              name: '晨起温水',
              iconEmoji: '💧',
              themeColor: '#34D399',
              type: HabitType.boolean,
              isPinned: true,
              frequency: const {'type': 'daily'},
              updatedAt: DateTime.now(),
            ),
            Habit(
              id: 'w2',
              name: '25分番茄专注',
              iconEmoji: '🍅',
              themeColor: '#F87171',
              type: HabitType.timer,
              timerSeconds: 1500,
              isPinned: true,
              frequency: const {'type': 'daily'},
              updatedAt: DateTime.now(),
            ),
            Habit(
              id: 'w3',
              name: '万步健行',
              iconEmoji: '👟',
              themeColor: '#60A5FA',
              type: HabitType.counter,
              targetValue: 10000,
              targetUnit: '步',
              frequency: const {'type': 'daily'},
              updatedAt: DateTime.now(),
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.instance.brandColor.primary;
    final watchHabits = _watchService.getWatchHabits(_habits);
    final formFactor = _watchService.formFactor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽手柄
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

          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⌚ 智能手表微端与表盘',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '抬腕即打卡 · watchOS & Wear OS 双平台自适应',
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

          // 表壳外形切换器
          Row(
            children: WatchFormFactor.values.map((factor) {
              final isSelected = formFactor == factor;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _watchService.setFormFactor(factor));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withValues(alpha: 0.18) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        factor.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 手表硬件与 OLED 屏幕真机渲染仿真
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _buildWatchHardware(formFactor, watchHabits, primaryColor),
            ),
          ),
          const SizedBox(height: 20),

          // 底部同步确认按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已同步 ${watchHabits.length} 项核心习惯至智能手表表盘与微端！⌚✨'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.sync_rounded),
              label: const Text('同步表盘复杂功能至手表', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchHardware(
    WatchFormFactor factor,
    List<Habit> habits,
    Color primaryColor,
  ) {
    final isRound = factor == WatchFormFactor.round;
    final watchSize = isRound ? 270.0 : 255.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 手表表带（上下暗影）
        Positioned(
          top: -24,
          child: Container(
            width: 130,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        Positioned(
          bottom: -24,
          child: Container(
            width: 130,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // 右侧表冠 (Digital Crown)
        Positioned(
          right: isRound ? -14 : -16,
          top: isRound ? 70 : 60,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            child: Container(
              width: 14,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4D52),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24, width: 0.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 0)),
                ],
              ),
            ),
          ),
        ),

        // 右侧侧边按键 (Side Button)
        if (!isRound)
          Positioned(
            right: -12,
            bottom: 60,
            child: Container(
              width: 10,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF383A3D),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

        // 钛金属/阳极氧化铝外壳
        Container(
          width: watchSize,
          height: watchSize,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2023),
            shape: isRound ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isRound ? null : BorderRadius.circular(factor.bezelRadius),
            border: Border.all(color: const Color(0xFF4E5156), width: 5),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black, // OLED 纯黑屏幕
              shape: isRound ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isRound ? null : BorderRadius.circular(factor.bezelRadius - 8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isRound ? 130 : factor.bezelRadius - 8),
              child: _buildWatchScreenContent(habits, primaryColor, isRound),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchScreenContent(
    List<Habit> habits,
    Color primaryColor,
    bool isRound,
  ) {
    final completedCount = habits.where((h) => _watchService.isCompleted(h.id)).length;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isRound ? 24.0 : 16.0,
        vertical: 14.0,
      ),
      child: Column(
        children: [
          // 顶部时间与状态栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '09:41',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  const Text('🔥12', style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$completedCount/${habits.length}',
                      style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 核心微习惯胶囊打卡列表
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: habits.length,
              separatorBuilder: (_, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isDone = _watchService.isCompleted(habit.id);

                return GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _watchService.toggleWatchCheckIn(habit);
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone ? primaryColor.withValues(alpha: 0.35) : const Color(0xFF1C1D21),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDone ? primaryColor : Colors.white12,
                        width: isDone ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(habit.iconEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDone ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Icon(
                          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isDone ? primaryColor : Colors.white30,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
