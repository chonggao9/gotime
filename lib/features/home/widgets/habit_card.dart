import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import '../../timer/timer_screen.dart';
import '../../stats/habit_detail_screen.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onLongPress,
  }) : super(key: key);

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
    if (widget.isCompleted) return;
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
    final Color cardColor = widget.isCompleted
        ? AppTheme.mintGreen.withOpacity(isDark ? 0.15 : 0.08)
        : Theme.of(context).cardColor;

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
              if (!isDark && !widget.isCompleted)
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
            ],
            border: widget.isCompleted
                ? Border.all(color: AppTheme.mintGreen.withOpacity(0.3), width: 1.5)
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
                      color: AppTheme.mintGreen.withOpacity(isDark ? 0.2 : 0.1),
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
                        color: widget.isCompleted ? AppTheme.mintGreen : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(widget.habit.iconEmoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: widget.isCompleted ? (isDark ? Colors.white54 : Colors.black45) : (isDark ? Colors.white : Colors.black87),
                              decoration: widget.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                            child: Text(widget.habit.name),
                          ),
                          if (widget.habit.type == HabitType.counter && widget.habit.targetValue != null) ...[
                            const SizedBox(height: 4),
                            Text('$_currentCounterValue / ${widget.habit.targetValue} ${widget.habit.targetUnit}', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.bold)),
                          ],
                          if (widget.habit.type == HabitType.timer && widget.habit.timerSeconds != null) ...[
                            const SizedBox(height: 4),
                            Text('${widget.habit.timerSeconds! ~/ 60} 分钟专注', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
    if (widget.habit.type == HabitType.quit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[50], borderRadius: BorderRadius.circular(12)),
        child: const Text('🔥 12天', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      );
    }
    if (widget.habit.type == HabitType.timer) {
      return Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: widget.isCompleted ? Colors.transparent : AppTheme.mintGreen.withOpacity(0.1), shape: BoxShape.circle),
        child: widget.isCompleted ? const Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 32) : const Icon(Icons.play_arrow_rounded, color: AppTheme.darkMintGreen, size: 28),
      );
    }
    if (widget.habit.type == HabitType.counter && !widget.isCompleted) {
      return Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], shape: BoxShape.circle),
        child: Icon(Icons.add_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 28),
      );
    }
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: widget.isCompleted ? AppTheme.mintGreen : Colors.grey.withOpacity(0.4), width: 2),
        color: widget.isCompleted ? AppTheme.mintGreen : Colors.transparent,
      ),
      child: ScaleTransition(
        scale: _checkAnimation,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
