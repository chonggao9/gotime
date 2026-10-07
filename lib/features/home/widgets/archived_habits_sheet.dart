import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class ArchivedHabitsSheet extends StatefulWidget {
  final VoidCallback onHabitRestored;

  const ArchivedHabitsSheet({
    Key? key,
    required this.onHabitRestored,
  }) : super(key: key);

  static void show(BuildContext context, {required VoidCallback onHabitRestored}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ArchivedHabitsSheet(onHabitRestored: onHabitRestored),
    );
  }

  @override
  State<ArchivedHabitsSheet> createState() => _ArchivedHabitsSheetState();
}

class _ArchivedHabitsSheetState extends State<ArchivedHabitsSheet> {
  List<Habit> _archivedHabits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchived();
  }

  Future<void> _loadArchived() async {
    final list = await SQLiteService.instance.getArchivedHabits();
    if (mounted) {
      setState(() {
        _archivedHabits = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreHabit(Habit habit) async {
    HapticFeedback.mediumImpact();
    await SQLiteService.instance.archiveHabit(habit.id, false);
    widget.onHabitRestored();
    _loadArchived();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已恢复习惯「${habit.name}」到打卡流中 🌿'),
          backgroundColor: AppTheme.mintGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    HapticFeedback.heavyImpact();
    await SQLiteService.instance.deleteHabit(habit.id);
    _loadArchived();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已彻底删除习惯「${habit.name}」'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拉条
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已归档习惯 (休眠池)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '暂不执行的习惯在此休眠，随时可一键唤醒',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 习惯列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _archivedHabits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📦', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              '暂无归档习惯',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '长按主页习惯卡片即可将其归档休眠',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _archivedHabits.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final habit = _archivedHabits[i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2923) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(habit.iconEmoji, style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '休眠中 • 历史数据已封存',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 唤醒恢复按钮
                                TextButton.icon(
                                  onPressed: () => _restoreHabit(habit),
                                  icon: const Icon(Icons.unarchive_rounded, size: 18),
                                  label: const Text('唤醒'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.mintGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                ),
                                // 删除按钮
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                                  onPressed: () => _deleteHabit(habit),
                                ),
                              ],
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
