import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/routine_service.dart';
import '../../../core/services/ambient_sound_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class RoutinePlaySheet extends StatefulWidget {
  final List<Habit> habits;
  final String title;
  final Future<void> Function(Habit) onHabitCompleted;

  const RoutinePlaySheet({
    super.key,
    required this.habits,
    this.title = '晨间心流仪式',
    required this.onHabitCompleted,
  });

  static void show(
    BuildContext context, {
    required List<Habit> habits,
    String title = '晨间心流仪式',
    required Future<void> Function(Habit) onHabitCompleted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoutinePlaySheet(
        habits: habits,
        title: title,
        onHabitCompleted: onHabitCompleted,
      ),
    );
  }

  @override
  State<RoutinePlaySheet> createState() => _RoutinePlaySheetState();
}

class _RoutinePlaySheetState extends State<RoutinePlaySheet> {
  final _routineService = RoutineService.instance;
  final _soundService = AmbientSoundService.instance;

  @override
  void initState() {
    super.initState();
    _routineService.startRoutine(widget.habits, title: widget.title);
    _routineService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _routineService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _routineService.currentStep;
    final isDone = _routineService.status == RoutineStatus.completed;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: isDone
          ? _buildCompletedView(isDark)
          : (step == null ? const SizedBox.shrink() : _buildStepView(step, isDark)),
    );
  }

  Widget _buildStepView(RoutineStep step, bool isDark) {
    final habit = step.habit;
    final totalSteps = _routineService.steps.length;
    final currentIdx = _routineService.currentIndex;
    final progress = (currentIdx + 1) / totalSteps;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 顶部手柄
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),

        // 顶栏：仪式标题与关闭按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _routineService.routineTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '第 ${currentIdx + 1} / $totalSteps 步 · 心流专注中',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _routineService.endRoutine();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 进度进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(AppTheme.mintGreen),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 28),

        // 核心习惯主卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(habit.iconEmoji, style: const TextStyle(fontSize: 38)),
              ),
              const SizedBox(height: 16),
              Text(
                habit.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _getHabitTargetLabel(habit),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),

              // 计时器指示器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppTheme.mintGreen),
                    const SizedBox(width: 6),
                    Text(
                      _formatSeconds(step.elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 白噪音伴奏开关
        ListenableBuilder(
          listenable: _soundService,
          builder: (context, _) {
            final isPlaying = _soundService.isPlaying;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    isPlaying ? _soundService.currentSound.iconEmoji : '🔇',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPlaying
                          ? '背景白噪音：${_soundService.currentSound.name}'
                          : '环境白噪音静音中',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch.adaptive(
                    value: isPlaying,
                    activeTrackColor: AppTheme.mintGreen,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      if (val) {
                        _soundService.setSound(AmbientSoundType.rain);
                      } else {
                        _soundService.setSound(AmbientSoundType.none);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // 底部主操作区
        Row(
          children: [
            if (currentIdx > 0) ...[
              IconButton.filledTonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _routineService.previousStep();
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
            ],
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _routineService.skipCurrentStep();
              },
              child: const Text('跳过此项', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await widget.onHabitCompleted(habit);
                    _routineService.completeCurrentStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mintGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: Text(
                    currentIdx + 1 == totalSteps ? '打卡并圆满完成' : '打卡并进行下一项',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedView(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const Text('🎉', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          '${_routineService.routineTitle} 已达成！',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '连续完成了 ${_routineService.steps.length} 项心流习惯，今天的你元气满满 ✨',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _routineService.endRoutine();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mintGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('收下今天的成就感', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  String _getHabitTargetLabel(Habit habit) {
    switch (habit.type) {
      case HabitType.counter:
        return '目标：${habit.targetValue?.toInt() ?? 1} ${habit.targetUnit ?? "次"}';
      case HabitType.timer:
        final m = (habit.timerSeconds ?? 1500) ~/ 60;
        return '目标：专注 $m 分钟';
      case HabitType.quit:
        return '戒断守护中';
      case HabitType.boolean:
        return '完成即打卡';
    }
  }
}
