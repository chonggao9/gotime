import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/freeze_mode_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/webdav_service.dart';
import 'widgets/backup_dialog.dart';
import 'widgets/webdav_dialog.dart';
import 'widgets/widget_preview_dialog.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool _isCloudSyncEnabled = false;
  bool _isPrivacyLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('圈子与设置', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圈子模块
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '专属圈子',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('邀请搭子'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.mintGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 好友对决卡片
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🏆 本周全勤对决',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '剩余 3 天',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 我的进度
                  _buildComparisonTrack(
                    name: '我 (Zhenhua)',
                    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                    progress: 0.8,
                    days: 4,
                    color: AppTheme.mintGreen,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  
                  // 好友进度
                  _buildComparisonTrack(
                    name: '搭子 (Alex)',
                    avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=100&q=80',
                    progress: 0.4,
                    days: 2,
                    color: Colors.blueAccent,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 外观主题与色彩模块
            Text(
              '外观与品牌个性化',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

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
                            color: isSelected ? bc.primary.withOpacity(0.18) : Colors.transparent,
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
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 高级设置模块
            Text(
              '高级与安全设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
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
                    )
                ],
              ),
              child: Column(
                children: [
                  // 休假/生病免责冻结开关
                  ValueListenableBuilder<bool>(
                    valueListenable: FreezeModeService.instance.isFreezeModeActive,
                    builder: (context, isFrozen, child) {
                      return _buildSettingSwitch(
                        icon: Icons.ac_unit_rounded,
                        title: '休假/生病免责模式',
                        subtitle: '开启期间不扣减强度分，连胜不中断',
                        value: isFrozen,
                        onChanged: (val) {
                          FreezeModeService.instance.setFreezeMode(val);
                        },
                        isDark: isDark,
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSettingSwitch(
                    icon: Icons.cloud_sync_rounded,
                    title: 'Firebase 云端备份',
                    subtitle: '安全同步到您的 Google 账号',
                    value: _isCloudSyncEnabled,
                    onChanged: (val) => setState(() => _isCloudSyncEnabled = val),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingSwitch(
                    icon: Icons.fingerprint_rounded,
                    title: '隐私安全锁',
                    subtitle: '后台切回时需 FaceID 解锁',
                    value: _isPrivacyLockEnabled,
                    onChanged: (val) => setState(() => _isPrivacyLockEnabled = val),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingItem(
                    icon: Icons.language_rounded,
                    title: '语言偏好 (Language)',
                    trailing: const Text('跟随系统', style: TextStyle(color: Colors.grey)),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingAction(
                    icon: Icons.save_alt_rounded,
                    title: '本地全量数据备份 (JSON)',
                    subtitle: '本地优先，随时导出与迁移',
                    onTap: () => BackupDialog.show(context, isExportCsv: false),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSettingAction(
                    icon: Icons.table_chart_rounded,
                    title: '导出打卡数据报表 (CSV)',
                    subtitle: '可在 Excel / Notion 中离线分析',
                    onTap: () => BackupDialog.show(context, isExportCsv: true),
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
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
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 注销合规按钮 (App Store 审核必备)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                },
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                label: const Text('注销账号并粉碎所有数据', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTrack({
    required String name,
    required String avatarUrl,
    required double progress,
    required int days,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.6 * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 40,
          child: Text(
            '$days 天',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppTheme.mintGreen,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          trailing,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
            ),
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
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[500], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
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
            color: isSelected ? primary.withOpacity(0.18) : (isDark ? Colors.grey[850] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? primary : Colors.grey),
              const SizedBox(width: 6),
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
}

