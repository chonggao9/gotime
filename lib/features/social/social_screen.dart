import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/freeze_mode_service.dart';

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

            const SizedBox(height: 40),
            
            // 高级设置模块
            Text(
              '高级设置',
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

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
    );
  }
}
