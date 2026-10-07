import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import '../../timer/timer_screen.dart';
import '../../stats/habit_detail_screen.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isSkipped;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.isSkipped = false,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  
  int _currentCounterValue = 0;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    if (widget.isCompleted) {
      _checkController.value = 1.0;
      if (widget.habit.type == HabitType.counter && widget.habit.targetValue != null) {
        _currentCounterValue = widget.habit.targetValue!;
      }
    }
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _checkController.forward();
        if (widget.habit.type == HabitType.counter && widget.habit.targetValue != null) {
          _currentCounterValue = widget.habit.targetValue!;
        }
      } else {
        _checkController.reverse();
        if (widget.habit.type == HabitType.counter) {
          _currentCounterValue = 0;
        }
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    if (widget.isCompleted || widget.isSkipped) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentCounterValue += 250;
      if (_currentCounterValue >= (widget.habit.targetValue ?? 0)) {
        _currentCounterValue = widget.habit.targetValue ?? 0;
        widget.onToggle(); 
      }
    });
  }

  void _handleActionTap() {
    HapticFeedback.lightImpact();
    if (widget.isSkipped) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❄️ 该习惯今日处于免责休假状态，连胜与动量已锁定保护。长按可重新调整。'),
          duration: Duration(milliseconds: 2000),
        ),
      );
      return;
    }

    if (widget.habit.type == HabitType.timer) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => TimerScreen(habit: widget.habit)),
      );
      return;
    }
    if (widget.habit.type == HabitType.counter) {
      _incrementCounter();
    } else {
      widget.onToggle();
    }
  }

  void _handleCardTap() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => HabitDetailScreen(habit: widget.habit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color cardColor;
    if (widget.isSkipped) {
      cardColor = isDark ? const Color(0xFF0369A1).withValues(alpha: 0.15) : const Color(0xFFE0F2FE);
    } else if (widget.isCompleted) {
      cardColor = AppTheme.mintGreen.withValues(alpha: isDark ? 0.15 : 0.08);
    } else {
      cardColor = Theme.of(context).cardColor;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleCardTap,
        onLongPress: () {
          HapticFeedback.heavyImpact();
          widget.onLongPress();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              if (!isDark && !widget.isCompleted && !widget.isSkipped)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
            border: widget.isSkipped
                ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5)
                : widget.isCompleted
                    ? Border.all(color: AppTheme.mintGreen.withValues(alpha: 0.3), width: 1.5)
                    : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Stack(
            children: [
              if (widget.habit.type == HabitType.counter && widget.habit.targetValue != null)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      width: MediaQuery.of(context).size.width * 0.9 * (_currentCounterValue / widget.habit.targetValue!),
                      color: AppTheme.mintGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.isSkipped
                            ? const Color(0xFF38BDF8)
                            : widget.isCompleted
                                ? AppTheme.mintGreen
                                : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.isSkipped ? '❄️' : widget.habit.iconEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isSkipped
                                      ? (isDark ? Colors.lightBlueAccent : Colors.blueGrey)
                                      : widget.isCompleted
                                          ? (isDark ? Colors.white54 : Colors.black45)
                                          : (isDark ? Colors.white : Colors.black87),
                                  decoration: widget.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                                child: Text(widget.habit.name),
                              ),
                              if (widget.habit.isPinned) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('📌', style: TextStyle(fontSize: 10)),
                                ),
                              ],
                              if (widget.isSkipped) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '免责休假',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (widget.habit.type == HabitType.counter && widget.habit.targetValue != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '$_currentCounterValue / ${widget.habit.targetValue} ${widget.habit.targetUnit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (widget.habit.type == HabitType.timer && widget.habit.timerSeconds != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${widget.habit.timerSeconds! ~/ 60} 分钟专注',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                          if (widget.habit.frequencySummary != '每日打卡') ...[
                            const SizedBox(height: 4),
                            Text(
                              '🗓️ ${widget.habit.frequencySummary}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 右侧操作区 - 独立 GestureDetector
                    GestureDetector(
                      onTap: _handleActionTap,
                      child: _buildActionArea(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea(bool isDark) {
    if (widget.isSkipped) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.ac_unit_rounded, color: Color(0xFF0284C7), size: 20),
        ),
      );
    }
    if (widget.habit.type == HabitType.quit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.red[900]?.withValues(alpha: 0.3) : Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('🔥 12天', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      );
    }
    if (widget.habit.type == HabitType.timer) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: widget.isCompleted ? Colors.transparent : AppTheme.mintGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: widget.isCompleted
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 32)
            : const Icon(Icons.play_arrow_rounded, color: AppTheme.darkMintGreen, size: 28),
      );
    }
    if (widget.habit.type == HabitType.counter && !widget.isCompleted) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 28),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isCompleted ? AppTheme.mintGreen : Colors.grey.withValues(alpha: 0.4),
          width: 2,
        ),
        color: widget.isCompleted ? AppTheme.mintGreen : Colors.transparent,
      ),
      child: ScaleTransition(
        scale: _checkAnimation,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
