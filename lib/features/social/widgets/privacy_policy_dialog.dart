import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => const PrivacyPolicyDialog(),
    );
  }

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  bool _isEnglish = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2320) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? const Color(0xFF26473A) : const Color(0xFFE2EFE9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部区域
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.privacy_tip_rounded, color: Color(0xFF10B981), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEnglish ? 'Privacy Policy' : '隐私政策与数据安全',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _isEnglish ? 'Google Play & Apple Compliant' : '本地优先 · 零广告 · 零数据买卖',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 中英文切换小按钮
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isEnglish = !_isEnglish);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isEnglish ? '中文' : 'English',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // 可滚动内容区
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: _isEnglish ? _buildEnglishContent(isDark) : _buildChineseContent(isDark),
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // 底部确认栏
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEnglish ? 'I Have Read and Acknowledge' : '我已阅读并知悉',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChineseContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 核心亮点磁贴
        Row(
          children: [
            Expanded(child: _buildBadge('🛡️ 100% 本地优先', '数据储存于设备 SQLite', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildBadge('🚫 零广告零画像', '绝不收集买卖个人数据', isDark)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBadge('❤️ 健康数据不外传', '仅在本地感应自动打卡', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildBadge('🗑️ 随时物理粉碎', '随时一键清空所有历史', isDark)),
          ],
        ),
        const SizedBox(height: 18),

        _buildSectionTitle('一、 概述与隐私设计核心原则', isDark),
        _buildParagraph(
          'GoTime 严格遵循“本地优先 (Local-First)”与“最小必要权限”架构。您的打卡记录、习惯设置、专注时长与打卡感悟，默认仅加密存储于您设备本地的 SQLite 数据库中。',
          isDark,
        ),

        _buildSectionTitle('二、 应用权限与数据使用说明 (Google Play 合规披露)', isDark),
        _buildPermissionItem(
          icon: Icons.favorite_rounded,
          title: '系统健康数据 (Health Connect / Apple Health)',
          desc: '仅在您开启“健康自动打卡”时读取步数或睡眠数据。健康数据仅在本地比对，绝不上传至任何服务器，绝不用于广告投放或商业评估。',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.notifications_active_rounded,
          title: '系统通知与提醒 (POST_NOTIFICATIONS)',
          desc: '仅用于在您设定的时间触发本地习惯闹钟与提醒，不经由任何第三方推送中继服务。',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.fingerprint_rounded,
          title: '生物识别与安全锁 (USE_BIOMETRIC)',
          desc: '用于应用隐私锁定保护。生物特征由系统底层安全芯片验证，应用本身无法触碰且绝不存储指纹或人脸特征。',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.folder_shared_rounded,
          title: '存储读写与 WebDAV 同步',
          desc: '仅用于全量导出/导入 JSON 与 CSV 数据，以及连接您自主填写的私有 WebDAV 网盘。',
          isDark: isDark,
        ),

        _buildSectionTitle('三、 零第三方广告与分析 SDK', isDark),
        _buildParagraph(
          '本应用不集成 Google Analytics、Firebase、第三方商业广告或任何行为追踪探针。您的每一次心流与打卡完全属于您自己。',
          isDark,
        ),

        _buildSectionTitle('四、 数据主体权利：导出与粉碎', isDark),
        _buildParagraph(
          '根据 GDPR 与 CCPA 规定，您可随时在设置中完整导出所有数据，或点击“注销账号并粉碎所有数据”，系统将连带物理抹除全部本地记录，不留痕迹。',
          isDark,
        ),
      ],
    );
  }

  Widget _buildEnglishContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildBadge('🛡️ 100% Local-First', 'Stored in on-device SQLite', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildBadge('🚫 Zero Ads & Tracking', 'Never sold or profiled', isDark)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBadge('❤️ Private Health Data', 'Processed only on-device', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildBadge('🗑️ Right to Erase', 'Permanent data shredding', isDark)),
          ],
        ),
        const SizedBox(height: 18),

        _buildSectionTitle('1. Architecture & Privacy Principles', isDark),
        _buildParagraph(
          'GoTime is built on a Local-First framework. Your habits, check-in history, focus logs, and personal reflections reside solely within your local device SQLite database.',
          isDark,
        ),

        _buildSectionTitle('2. Permissions & Data Disclosure (Google Play Compliant)', isDark),
        _buildPermissionItem(
          icon: Icons.favorite_rounded,
          title: 'Health & Fitness Data (Health Connect / Apple Health)',
          desc: 'Only accessed when you explicitly enable auto check-ins. Data is evaluated locally and NEVER uploaded or used for advertising/profiling.',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications (POST_NOTIFICATIONS)',
          desc: 'Scheduled strictly on-device to trigger habit reminders without external push relays.',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.fingerprint_rounded,
          title: 'Biometrics & App Lock (USE_BIOMETRIC)',
          desc: 'Handled securely by hardware enclave. No biometric traits are ever recorded by GoTime.',
          isDark: isDark,
        ),
        _buildPermissionItem(
          icon: Icons.folder_shared_rounded,
          title: 'Storage & WebDAV Sync',
          desc: 'Used solely for JSON/CSV backup exports and user-configured private WebDAV sync.',
          isDark: isDark,
        ),

        _buildSectionTitle('3. Zero Third-Party Trackers', isDark),
        _buildParagraph(
          'GoTime contains zero commercial ad SDKs, user profiling trackers, or analytics beacons.',
          isDark,
        ),

        _buildSectionTitle('4. User Rights: Portability & Erasure', isDark),
        _buildParagraph(
          'In compliance with GDPR and CCPA, you can export your entire dataset anytime or initiate irreversible data shredding in Settings.',
          isDark,
        ),
      ],
    );
  }

  Widget _buildBadge(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.55,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
