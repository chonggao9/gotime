import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/privacy_lock_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/webdav_service.dart';
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
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组一：外观
            _buildSectionHeader('外观', isDark),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模式',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeChip(
                        label: '深色',
                        icon: Icons.dark_mode_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.dark,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.dark),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: '浅色',
                        icon: Icons.light_mode_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.light,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.light),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeChip(
                        label: '跟随系统',
                        icon: Icons.brightness_auto_rounded,
                        isSelected: ThemeService.instance.themeMode == ThemeMode.system,
                        onTap: () => ThemeService.instance.setThemeMode(ThemeMode.system),
                        isDark: isDark,
                        primary: ThemeService.instance.brandColor.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    '主题色',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? bc.primary.withValues(alpha: 0.16) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? bc.primary : (isDark ? Colors.white12 : Colors.grey[300]!),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
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
                  const SizedBox(height: 14),
                  _buildDivider(isDark),

                  _buildSettingAction(
                    icon: Icons.widgets_rounded,
                    title: '桌面小组件',
                    onTap: () => WidgetPreviewDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  _buildSettingAction(
                    icon: Icons.watch_rounded,
                    title: '智能手表',
                    onTap: () => WatchPreviewDialog.show(context),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 分组二：通用与安全
            _buildSectionHeader('通用与安全', isDark),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
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
                            title: '应用锁',
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
                              padding: const EdgeInsets.fromLTRB(54, 0, 16, 10),
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _showSetPinDialog(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('修改密码', style: TextStyle(fontSize: 12, color: AppTheme.mintGreen)),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () => PrivacyLockService.instance.lock(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      '测试锁定',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  // 防沉迷屏障
                  _buildSettingAction(
                    icon: Icons.shield_rounded,
                    title: '防沉迷屏障',
                    onTap: () => MindfulShieldDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 健康数据自动打卡
                  _buildSettingAction(
                    icon: Icons.favorite_rounded,
                    title: '健康步数同步',
                    onTap: () => HealthSyncDialog.show(
                      context,
                      onSyncCompleted: () {
                        if (mounted) setState(() {});
                      },
                    ),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 语言
                  ListenableBuilder(
                    listenable: LocaleService.instance,
                    builder: (context, child) {
                      final currentLang = LocaleService.instance.currentLanguage;
                      return _buildSettingAction(
                        icon: Icons.language_rounded,
                        title: '语言',
                        trailingText: currentLang.name,
                        onTap: () => LanguageSelectorSheet.show(context),
                        isDark: isDark,
                      );
                    },
                  ),
                  _buildDivider(isDark),

                  // 定时提醒
                  _buildSettingAction(
                    icon: Icons.notifications_active_rounded,
                    title: '定时提醒',
                    onTap: () => ReminderSettingsDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 本地数据备份
                  _buildSettingAction(
                    icon: Icons.save_alt_rounded,
                    title: '备份',
                    onTap: () => BackupDialog.show(context, isExportCsv: false),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // CSV 导出
                  _buildSettingAction(
                    icon: Icons.table_chart_rounded,
                    title: '导出 CSV',
                    onTap: () => BackupDialog.show(context, isExportCsv: true),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // WebDAV 同步
                  _buildSettingAction(
                    icon: Icons.cloud_sync_rounded,
                    title: 'WebDAV',
                    trailingText: WebDavService.instance.isConfigured ? '已配置' : null,
                    onTap: () => WebDavDialog.show(context, onRestored: () {
                      if (mounted) setState(() {});
                    }),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 云端同步
                  _buildSettingAction(
                    icon: Icons.devices_rounded,
                    title: '云端同步',
                    onTap: () => CloudSyncDialog.show(context),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),

                  // 隐私政策
                  _buildSettingAction(
                    icon: Icons.privacy_tip_rounded,
                    title: '隐私政策',
                    onTap: () => PrivacyPolicyDialog.show(context),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 底部注销入口
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _showDeleteConfirmDialog(context);
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                label: const Text(
                  '抹掉所有数据并重置',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('抹掉所有数据', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text(
          '此操作将永久清空本地所有习惯打卡记录，不可撤销。确认继续吗？',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清空本地数据并恢复初始状态')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认抹掉'),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('设置 4 位密码', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '请输入 4 位数字',
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
            child: const Text('保存'),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? primary.withValues(alpha: 0.22) : primary.withValues(alpha: 0.12))
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mintGreen, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
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
    String? trailingText,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.mintGreen, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white30 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      endIndent: 16,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
    );
  }
}
