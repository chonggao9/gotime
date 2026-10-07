import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/quick_natural_logger_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class QuickNaturalLogDialog extends StatefulWidget {
  final List<Habit> habits;
  final Future<void> Function(List<ParsedCheckInIntent>) onBatchCheckIn;

  const QuickNaturalLogDialog({
    super.key,
    required this.habits,
    required this.onBatchCheckIn,
  });

  static void show(
    BuildContext context, {
    required List<Habit> habits,
    required Future<void> Function(List<ParsedCheckInIntent>) onBatchCheckIn,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickNaturalLogDialog(
        habits: habits,
        onBatchCheckIn: onBatchCheckIn,
      ),
    );
  }

  @override
  State<QuickNaturalLogDialog> createState() => _QuickNaturalLogDialogState();
}

class _QuickNaturalLogDialogState extends State<QuickNaturalLogDialog> {
  final _controller = TextEditingController();
  List<ParsedCheckInIntent> _parsedIntents = [];

  final List<String> _quickSuggestions = [
    '喝水 500ml，看书 15页，心情超好',
    '早起喝水，晚间阅读，心情不错',
    '深度工作 25分钟，跑步 3km',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final results = QuickNaturalLoggerService.instance.parseText(text, widget.habits);
    setState(() {
      _parsedIntents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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

              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('🎙️ ', style: TextStyle(fontSize: 20)),
                          Text(
                            '自然语言极速速记打卡',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '打字或语音输入一句话，智能匹配批量打卡',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 快捷预设输入胶囊
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _quickSuggestions.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _controller.text = s;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 输入框
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '如：喝水 500ml，阅读 20页，心情开心...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.mintGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 解析出的习惯列表
              if (_parsedIntents.isNotEmpty) ...[
                Text(
                  '已智能识别 ${_parsedIntents.length} 项习惯：',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._parsedIntents.map((intent) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.mintGreen.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Text(intent.habit.iconEmoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                intent.habit.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              if (intent.value != null || intent.durationSeconds != null)
                                Text(
                                  intent.value != null
                                      ? '数值：${intent.value} ${intent.habit.targetUnit ?? ""}'
                                      : '专注：${(intent.durationSeconds ?? 0) ~/ 60} 分钟',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.mintGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '心情 ${intent.mood ?? 5} 🌟',
                            style: const TextStyle(fontSize: 11, color: AppTheme.mintGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // 提交批量打卡按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _parsedIntents.isEmpty
                      ? null
                      : () async {
                          HapticFeedback.mediumImpact();
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          await widget.onBatchCheckIn(_parsedIntents);
                          if (mounted) {
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text('🎉 成功批量完成 ${_parsedIntents.length} 项习惯打卡！')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mintGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 20),
                  label: Text(
                    _parsedIntents.isEmpty
                        ? '请输入包含习惯名称的内容'
                        : '一键完成批量打卡 (${_parsedIntents.length} 项)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
