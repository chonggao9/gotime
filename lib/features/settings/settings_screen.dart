import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/privacy_lock_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/webdav_service.dart';
import '../../core/services/reminder_service.dart';
import '../social/widgets/backup_dialog.dart';
import '../social/widgets/cloud_sync_dialog.dart';
import '../social/widgets/health_sync_dialog.dart';
import '../social/widgets/language_selector_sheet.dart';
import '../social/widgets/reminder_settings_dialog.dart';
import '../social/widgets/watch_preview_dialog.dart';
import '../social/widgets/webdav_dialog.dart';
import '../social/widgets/widget_preview_dialog.dart';
import '../social/widgets/privacy_policy_dialog.dart';
import '../timer/widgets/mindful_shield_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('系统设置', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外观主题与色彩模块
            Text(
              '外观与品牌个性化',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('深浅模式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildThemeChip(
                        label: '极夜暗黑',
                        icon: Icons.dark_mode_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.dark,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.dark),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: '晨曦微白',
                        icon: Icons.light_mode_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.light,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.light),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: '随系统',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.system,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.system),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text('品牌主色调', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BrandColor.values.map((bc) {
                      final isSelected = ThemeService.instance.brandColor == bc;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ThemeService.instance.setBrandColor(bc);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? bc.primary.withValues(alpha: 0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? bc.primary : (isDark ? Colors.white12 : Colors.grey[300]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: bc.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bc.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildDivider(isDark),

                  _buildSettingAction(
                    icon: Icons.widgets_rounded,
                    title: '桌面小组件工坊 (Widgets)',
                    subtitle: '配置与预览 2×2 / 4×2 手机桌面小组件',
                    onTap: () => WidgetPreviewDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  _buildSettingAction(
                    icon: Icons.watch_rounded,
                    title: '智能手表微端与表盘 (watchOS / Wear OS)',
                    subtitle: '腕上微端独立打卡、表盘复杂功能与表冠模拟',
                    onTap: () => WatchPreviewDialog.show(context),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 高级与安全设置
            Text(
              '高级、健康与安全设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  // 隐私安全锁
                  ListenableBuilder(
                    listenable: PrivacyLockService.instance,
                    builder: (context, child) {
                      final isLockEnabled = PrivacyLockService.instance.isLockEnabled;
                      return Column(
                        children: [
                          _buildSettingSwitch(
                            icon: Icons.lock_rounded,
                            title: '应用隐私安全锁',
                            subtitle: isLockEnabled ? '已启用 4 位安全密码与生物识别保护' : '离开应用后进入隐私保护锁定',
                            value: isLockEnabled,
                            onChanged: (val) {
                              if (val) {
                                _showSetPinDialog(context);
                              } else {
                                PrivacyLockService.instance.setLockEnabled(false);
                              }
                            },
                            isDark: isDark,
                          ),
                          if (isLockEnabled)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(60, 0, 20, 12),
                              child: Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showSetPinDialog(context),
                                    icon: const Icon(Icons.edit_rounded, size: 16),
                                    label: const Text('修改密码', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      PrivacyLockService.instance.lock();
                                    },
                                    icon: const Icon(Icons.lock_outline_rounded, size: 16),
                                    label: const Text('立即锁定测试', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  // 正念自律屏障
                  _buildSettingAction(
                    icon: Icons.shield_rounded,
                    title: '正念自律屏障与防沉迷盾牌 (Mindful Shield)',
                    subtitle: '在分心冲动与反应之间插入冷静呼吸，重塑大脑前额叶',
                    onTap: () => MindfulShieldDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 健康数据自动打卡
                  _buildSettingAction(
                    icon: Icons.favorite_rounded,
                    title: '系统健康数据自动打卡 (Health Sync)',
                    subtitle: '关联 Apple Health / 步数与睡眠数据无感自动打卡',
                    onTap: () => HealthSyncDialog.show(
                      context,
                      onSyncCompleted: () {
                        if (mounted) setState(() {});
                      },
                    ),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 语言偏好
                  ListenableBuilder(
                    listenable: LocaleService.instance,
                    builder: (context, child) {
                      final currentLang = LocaleService.instance.currentLanguage;
                      return _buildSettingAction(
                        icon: Icons.language_rounded,
                        title: '语言偏好 (Language)',
                        subtitle: '${currentLang.flagEmoji} ${currentLang.name}',
                        onTap: () => LanguageSelectorSheet.show(context),
                        isDark: isDark,
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  // 智能时段提醒
                  ListenableBuilder(
                    listenable: ReminderService.instance,
                    builder: (context, child) {
                      return _buildSettingAction(
                        icon: Icons.notifications_active_rounded,
                        title: '智能时段提醒与免打扰 (Smart Reminders)',
                        subtitle: ReminderService.instance.getNextScheduledSummary(),
                        onTap: () => ReminderSettingsDialog.show(context),
                        isDark: isDark,
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  // 本地备份
                  _buildSettingAction(
                    icon: Icons.save_alt_rounded,
                    title: '本地全量数据备份 (JSON)',
                    subtitle: '本地优先，随时导出与迁移',
                    onTap: () => BackupDialog.show(context, isExportCsv: false),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // CSV 导出
                  _buildSettingAction(
                    icon: Icons.table_chart_rounded,
                    title: '导出打卡数据报表 (CSV)',
                    subtitle: '可在 Excel / Notion 中离线分析',
                    onTap: () => BackupDialog.show(context, isExportCsv: true),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // WebDAV 双向同步
                  _buildSettingAction(
                    icon: Icons.cloud_sync_rounded,
                    title: 'WebDAV 私有网盘双向同步',
                    subtitle: WebDavService.instance.isConfigured
                        ? '已配置云端，支持坚果云/私有网盘一键双向同步'
                        : '支持坚果云 / Nextcloud / 群晖私密备份与恢复',
                    onTap: () => WebDavDialog.show(context, onRestored: () {
                      if (mounted) setState(() {});
                    }),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 设备集群与云端增量同步
                  _buildSettingAction(
                    icon: Icons.devices_rounded,
                    title: '设备集群与跨端增量同步 (Cloud Sync)',
                    subtitle: '多设备增量自动合库，LWW 无损合并与拓扑集群',
                    onTap: () => CloudSyncDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 隐私政策
                  _buildSettingAction(
                    icon: Icons.privacy_tip_rounded,
                    title: '隐私政策与数据安全 (Privacy Policy)',
                    subtitle: '符合 Google Play 及 Apple 审核规范 · 权限与数据保护透明披露',
                    onTap: () => PrivacyPolicyDialog.show(context),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // 底部合规协议与注销入口
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      PrivacyPolicyDialog.show(context);
                    },
                    icon: const Icon(Icons.privacy_tip_outlined, size: 14, color: Colors.grey),
                    label: const Text('隐私政策', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const Text('·', style: TextStyle(color: Colors.grey)),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                    },
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 14),
                    label: const Text('注销账号并粉碎所有数据', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('设置 4 位安全密码', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '请输入 4 位纯数字密码',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                PrivacyLockService.instance.setPinCode(pinController.text);
                PrivacyLockService.instance.setLockEnabled(true);
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mintGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('保存密码'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primary,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? primary.withValues(alpha: 0.25) : primary.withValues(alpha: 0.12))
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mintGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.mintGreen,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.mintGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 20,
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
    );
  }
}
