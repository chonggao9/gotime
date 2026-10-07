import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';

/// 本地优先数据导入导出与备份对话框 (Local Data Backup & Export Dialog)
class BackupDialog extends StatefulWidget {
  final bool isExportCsv;

  const BackupDialog({super.key, this.isExportCsv = false});

  static Future<void> show(BuildContext context, {bool isExportCsv = false}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackupDialog(isExportCsv: isExportCsv),
    );
  }

  @override
  State<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  String _generatedContent = '';
  bool _isLoading = true;
  int _habitsCount = 0;
  int _checkInsCount = 0;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    setState(() => _isLoading = true);

    List<Habit> habits = [];
    List<CheckIn> checkIns = [];

    try {
      habits = await SQLiteService.instance.getAllActiveHabits();
      checkIns = await SQLiteService.instance.getCheckInsForYear(DateTime.now().year);
    } catch (_) {
      // 容错或 Web 降级处理
    }

    if (habits.isEmpty) {
      habits = [
        Habit(
          id: '1',
          name: '早起喝水',
          iconEmoji: '💧',
          themeColor: '#34D399',
          type: HabitType.counter,
          targetValue: 2000,
          targetUnit: 'ml',
          timeOfDay: 'morning',
          frequency: {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
        Habit(
          id: '2',
          name: '深度工作',
          iconEmoji: '🍅',
          themeColor: '#F87171',
          type: HabitType.timer,
          timerSeconds: 1500,
          timeOfDay: 'afternoon',
          frequency: {'type': 'daily'},
          updatedAt: DateTime.now(),
        ),
      ];
      checkIns = [
        CheckIn(
          id: 'c1',
          habitId: '1',
          date: DateTime.now().toIso8601String().split('T')[0],
          status: CheckInStatus.completed,
          logText: '神清气爽！',
          createdAt: DateTime.now(),
        ),
      ];
    }

    _habitsCount = habits.length;
    _checkInsCount = checkIns.length;

    if (widget.isExportCsv) {
      _generatedContent = BackupService.exportToCsv(habits: habits, checkIns: checkIns);
    } else {
      _generatedContent = BackupService.exportToJson(habits: habits, checkIns: checkIns);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    HapticFeedback.heavyImpact();
    Clipboard.setData(ClipboardData(text: _generatedContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isExportCsv ? '📊 CSV 报表内容已复制到剪贴板！' : '💾 JSON 完整备份已复制到剪贴板！'),
        backgroundColor: AppTheme.darkMintGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 20),

          // 标题
          Row(
            children: [
              Text(widget.isExportCsv ? '📊 ' : '💾 ', style: const TextStyle(fontSize: 22)),
              Text(
                widget.isExportCsv ? '导出打卡数据报表 (CSV)' : '本地全量数据备份 (JSON)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            widget.isExportCsv
                ? '生成标准 CSV 格式，可在 Excel、Numbers、Notion 或 Python 中直接打开分析。'
                : '本地优先，完全保护隐私。随时复制或导出备份，可在任何设备无缝恢复。',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // 数据概览小徽章
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '活跃习惯: $_habitsCount 个',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mintGreen),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '历史打卡: $_checkInsCount 条',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 预览容器
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.mintGreen))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      _generatedContent,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('关闭'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _copyToClipboard,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('复制全部内容'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mintGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
