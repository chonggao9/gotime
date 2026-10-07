import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/friction_breaker_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class TwoMinuteFrictionDialog extends StatefulWidget {
  final Habit habit;
  final Future<void> Function(Habit, String note) onCompleteMicroStart;

  const TwoMinuteFrictionDialog({
    super.key,
    required this.habit,
    required this.onCompleteMicroStart,
  });

  static void show(
    BuildContext context, {
    required Habit habit,
    required Future<void> Function(Habit, String note) onCompleteMicroStart,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TwoMinuteFrictionDialog(
        habit: habit,
        onCompleteMicroStart: onCompleteMicroStart,
      ),
    );
  }

  @override
  State<TwoMinuteFrictionDialog> createState() => _TwoMinuteFrictionDialogState();
}

class _TwoMinuteFrictionDialogState extends State<TwoMinuteFrictionDialog> {
  final _service = FrictionBreakerService.instance;

  @override
  void initState() {
    super.initState();
    _service.startSession(widget.habit);
    _service.addListener(_onChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _service.stopSession();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestion = _service.getMicroActionSuggestion(widget.habit);
    final isCompleted = _service.isCompleted;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 顶部小手柄
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 顶栏：标题与关闭
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🌱 ', style: TextStyle(fontSize: 20)),
                  Text(
                    '两分钟微启动定律',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 心理学破壁引导提示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.mintGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '微行动目标：${widget.habit.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 环形倒计时进度器
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: _service.progress,
                  strokeWidth: 8,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(AppTheme.mintGreen),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.habit.iconEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(_service.remainingSeconds),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    isCompleted ? '破壁达成！' : (_service.isRunning ? '破壁专注中' : '已暂停'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isCompleted ? AppTheme.mintGreen : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 达成后祝贺提示卡
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '太棒了！两分钟微启动已成功达成！最大的心理阻力已被你彻底破除。',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // 底部控制操作栏
          Row(
            children: [
              if (!isCompleted) ...[
                IconButton.filledTonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _service.togglePause();
                  },
                  icon: Icon(_service.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final note = '🌱 达成两分钟微启动破壁（${_formatTime(FrictionBreakerService.totalDurationSeconds - _service.remainingSeconds)}）';
                      await widget.onCompleteMicroStart(widget.habit, note);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mintGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      isCompleted ? '见好就收，打卡收工！' : '提早完成，打卡记下！',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
