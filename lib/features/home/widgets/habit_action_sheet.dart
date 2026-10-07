import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/habit.dart';

class HabitActionSheet extends StatelessWidget {
  final Habit habit;
  final VoidCallback onWriteLog;
  final VoidCallback onSkipToday;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const HabitActionSheet({
    super.key,
    required this.habit,
    required this.onWriteLog,
    required this.onSkipToday,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拉条
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
          
          // 标题头
          Row(
            children: [
              Text(habit.iconEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 操作项列表
          _buildActionItem(
            context,
            icon: Icons.edit_note_rounded,
            label: '记录打卡心得与心情',
            color: isDark ? Colors.white : Colors.black87,
            onTap: onWriteLog,
          ),
          _buildActionItem(
            context,
            icon: Icons.ac_unit_rounded,
            label: '今日请假 (免责冻结)',
            color: const Color(0xFF0284C7),
            onTap: onSkipToday,
          ),
          _buildActionItem(
            context,
            icon: Icons.archive_outlined,
            label: '归档习惯 (暂时休眠)',
            color: Colors.amber[700]!,
            onTap: () {
              Navigator.pop(context);
              onArchive();
            },
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 12),
          _buildActionItem(
            context,
            icon: Icons.delete_outline_rounded,
            label: '彻底删除习惯',
            color: Colors.redAccent,
            onTap: () {
              HapticFeedback.heavyImpact();
              // 二次确认弹窗
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('彻底删除？', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('如果删除【${habit.name}】，所有的打卡记录将一并消失，且无法恢复。建议使用“归档”保留历史。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx); // 关弹窗
                        Navigator.pop(context); // 关 ActionSheet
                        onDelete();
                      },
                      child: const Text('确认删除', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context); // 点击后自动收起 BottomSheet
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
