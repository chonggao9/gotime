import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/theme/app_theme.dart';

class ReminderSettingsDialog extends StatefulWidget {
  const ReminderSettingsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ReminderSettingsDialog(),
    );
  }

  @override
  State<ReminderSettingsDialog> createState() => _ReminderSettingsDialogState();
}

class _ReminderSettingsDialogState extends State<ReminderSettingsDialog> {
  final _service = ReminderService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _pickTime(TimeOfDay initial, Function(TimeOfDay) onSelected) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔔 智能时段提醒与免打扰',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Text(
                          '零焦虑唤醒',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '科学分时段温和提醒 · 避免信息轰炸 · 守护作息节律',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 三大习惯时段
                  const Text('分时段科学唤醒', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _buildSlotTile(
                    title: '🌅 晨间唤醒',
                    subtitle: '温水打卡、晨跑、开启元气一天',
                    time: _service.morningTime,
                    isEnabled: _service.isMorningEnabled,
                    isDark: isDark,
                    onToggle: (v) => _service.updateSlot(morningEnabled: v),
                    onTimeTap: () => _pickTime(
                      _service.morningTime,
                      (t) => _service.updateSlot(morning: t),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSlotTile(
                    title: '☀️ 午间回能',
                    subtitle: '午间小憩、站立拉伸、补水充电',
                    time: _service.afternoonTime,
                    isEnabled: _service.isAfternoonEnabled,
                    isDark: isDark,
                    onToggle: (v) => _service.updateSlot(afternoonEnabled: v),
                    onTimeTap: () => _pickTime(
                      _service.afternoonTime,
                      (t) => _service.updateSlot(afternoon: t),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSlotTile(
                    title: '🌙 晚间复盘',
                    subtitle: '深度阅读、日记感悟、全勤结算',
                    time: _service.eveningTime,
                    isEnabled: _service.isEveningEnabled,
                    isDark: isDark,
                    onToggle: (v) => _service.updateSlot(eveningEnabled: v),
                    onTimeTap: () => _pickTime(
                      _service.eveningTime,
                      (t) => _service.updateSlot(evening: t),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 夜间免打扰静音模式 (Quiet Hours)
                  const Text('夜间深睡眠免打扰 (DND)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('🔕', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('静音休息区间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('时段内严禁任何震动打扰', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                  ],
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _service.isQuietHoursEnabled,
                              activeColor: AppTheme.mintGreen,
                              onChanged: (v) => _service.updateQuietHours(enabled: v),
                            ),
                          ],
                        ),
                        if (_service.isQuietHoursEnabled) ...[
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => _pickTime(
                                  _service.quietStart,
                                  (t) => _service.updateQuietHours(start: t),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bedtime_rounded, size: 16, color: Colors.indigoAccent),
                                      const SizedBox(width: 6),
                                      Text('入睡: ${_service.formatTime(_service.quietStart)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const Text('至', style: TextStyle(color: Colors.grey)),
                              InkWell(
                                onTap: () => _pickTime(
                                  _service.quietEnd,
                                  (t) => _service.updateQuietHours(end: t),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.wb_sunny_rounded, size: 16, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      Text('清晨: ${_service.formatTime(_service.quietEnd)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 模拟测试提醒按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Text('🔔', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('【GoTime 温和提醒】新的一天，别忘了照顾好身心状态，喝杯温水吧！💧'),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E293B),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: const Text('模拟触发温和通知测试'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.mintGreen,
                        side: const BorderSide(color: AppTheme.mintGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isEnabled,
    required bool isDark,
    required Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          InkWell(
            onTap: onTimeTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppTheme.mintGreen.withValues(alpha: 0.15)
                    : (isDark ? Colors.white10 : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _service.formatTime(time),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? AppTheme.mintGreen : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isEnabled,
            activeColor: AppTheme.mintGreen,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
