import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/counter_step_helper.dart';
import '../../../models/habit.dart';

class QuickCounterSheet extends StatefulWidget {
  final Habit habit;
  final int initialValue;
  final Function(int) onSave;

  const QuickCounterSheet({
    super.key,
    required this.habit,
    required this.initialValue,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required Habit habit,
    required int initialValue,
    required Function(int) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickCounterSheet(
        habit: habit,
        initialValue: initialValue,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickCounterSheet> createState() => _QuickCounterSheetState();
}

class _QuickCounterSheetState extends State<QuickCounterSheet> {
  late int _currentVal;
  late int _targetVal;
  late String _unit;
  late int _step;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _currentVal = widget.initialValue;
    _targetVal = widget.habit.targetValue ?? 100;
    _unit = widget.habit.targetUnit ?? '';
    _step = CounterStepHelper.deduceDefaultStep(_targetVal, _unit);
    _textController = TextEditingController(text: '$_currentVal');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addDelta(int delta) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentVal = (_currentVal + delta).clamp(0, _targetVal * 2);
      _textController.text = '$_currentVal';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_currentVal / _targetVal).clamp(0.0, 1.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(widget.habit.iconEmoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.habit.name} · 量化打卡',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 核心数值显示仪表板
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_currentVal',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: progress >= 1.0 ? AppTheme.mintGreen : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ $_targetVal $_unit',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      progress >= 1.0 ? AppTheme.mintGreen : const Color(0xFF60A5FA),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 快捷加量芯片 (Quick Steppers)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStepperChip('+$_step$_unit', () => _addDelta(_step), isDark),
              _buildStepperChip('+${_step * 2}$_unit', () => _addDelta(_step * 2), isDark),
              _buildStepperChip('直接达标 🎯', () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _currentVal = _targetVal;
                  _textController.text = '$_currentVal';
                });
              }, isDark),
            ],
          ),
          const SizedBox(height: 20),

          // 滑动条微调
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.mintGreen,
              thumbColor: AppTheme.mintGreen,
              trackHeight: 4,
            ),
            child: Slider(
              value: _currentVal.clamp(0, _targetVal).toDouble(),
              min: 0,
              max: _targetVal.toDouble(),
              onChanged: (val) {
                setState(() {
                  _currentVal = val.toInt();
                  _textController.text = '$_currentVal';
                });
              },
            ),
          ),
          const SizedBox(height: 14),

          // 手动输入数字
          TextField(
            controller: _textController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: '或直接输入累计值 ($_unit)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (text) {
              final val = int.tryParse(text);
              if (val != null) {
                setState(() => _currentVal = val);
              }
            },
          ),
          const SizedBox(height: 20),

          // 保存提交按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onSave(_currentVal);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(
                _currentVal >= _targetVal ? '完成目标并打卡！🌟' : '保存打卡进度',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mintGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperChip(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
