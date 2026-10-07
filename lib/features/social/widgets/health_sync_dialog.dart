import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/health_sync_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/database/sqlite_service.dart';

class HealthSyncDialog extends StatefulWidget {
  final VoidCallback onSyncCompleted;

  const HealthSyncDialog({super.key, required this.onSyncCompleted});

  static void show(BuildContext context, {required VoidCallback onSyncCompleted}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HealthSyncDialog(onSyncCompleted: onSyncCompleted),
    );
  }

  @override
  State<HealthSyncDialog> createState() => _HealthSyncDialogState();
}

class _HealthSyncDialogState extends State<HealthSyncDialog> {
  final _service = HealthSyncService.instance;
  bool _isScanning = false;
  List<String> _scanLogs = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.instance.brandColor.primary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽手柄
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

          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '系统健康数据自动打卡',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Apple Health / Android Health Connect 感应',
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
          const SizedBox(height: 20),

          // 自动感应全局开关卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2923) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _service.isAutoSyncEnabled ? primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('💓', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '自动同步步数与睡眠',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '达到设定步数或睡眠时长后静默打卡',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _service.isAutoSyncEnabled,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _service.setAutoSyncEnabled(val);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 实时健康读数仪表板
          Text('今日健康传感器读数', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('👟', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text('今日行走', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_service.simulatedSteps} 步',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text('已超标达标 8000 步 ✓', style: TextStyle(fontSize: 10, color: primaryColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🌙', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text('昨晚睡眠', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_service.simulatedSleepMinutes / 60).toStringAsFixed(1)} 小时',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                      ),
                      const SizedBox(height: 4),
                      const Text('深度好眠 490 分钟 ✓', style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 日志扫描展示
          if (_scanLogs.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _scanLogs.map((log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Text('🎉 ', style: TextStyle(fontSize: 14)),
                      Expanded(child: Text(log, style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Spacer(),

          // 立即触发感应打卡按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isScanning
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _isScanning = true;
                        _scanLogs.clear();
                      });

                      final habits = await SQLiteService.instance.getAllActiveHabits();
                      final results = await _service.checkAndAutoCheckIn(habits);

                      if (mounted) {
                        setState(() {
                          _isScanning = false;
                          if (results.isEmpty) {
                            _scanLogs.add('未检测到需感应打卡的数值型习惯（或今日已完成）');
                          } else {
                            _scanLogs = results.map((r) => r.message).toList();
                          }
                        });
                        widget.onSyncCompleted();
                      }
                    },
              icon: _isScanning
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.sync_rounded),
              label: const Text('立即感应并自动打卡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
