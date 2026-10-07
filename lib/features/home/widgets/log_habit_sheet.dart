import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class LogHabitSheet extends StatefulWidget {
  final String habitName;
  final String habitThemeColor;
  final Function(String logText, int mood) onSave;

  const LogHabitSheet({
    Key? key,
    required this.habitName,
    required this.habitThemeColor,
    required this.onSave,
  }) : super(key: key);

  @override
  State<LogHabitSheet> createState() => _LogHabitSheetState();
}

class _LogHabitSheetState extends State<LogHabitSheet> {
  final _logController = TextEditingController();
  int _selectedMood = 3; // 默认心情 3 (也就是一般/开心)
  
  // 心情值 1-5 对应的 Emoji
  final List<String> _moodEmojis = ['😫', '☹️', '😐', '🙂', '😎'];

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    widget.onSave(_logController.text.trim(), _selectedMood);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Color(int.parse(widget.habitThemeColor.replaceFirst('#', '0xFF')));

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              '记录: ${widget.habitName}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            // 心情打分区
            Text(
              '今天感觉如何？',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final isSelected = _selectedMood == index + 1;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedMood = index + 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? themeColor.withOpacity(0.2) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _moodEmojis[index],
                      style: TextStyle(
                        fontSize: isSelected ? 40 : 32,
                        // 没选中的稍微变灰一点
                        color: isSelected ? null : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 日志输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _logController,
                maxLength: 140,
                maxLines: 4,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: '写下今天的感悟或阻碍...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('保 存', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
