import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/milestone_service.dart';
import '../../../core/services/theme_service.dart';
import 'share_poster_dialog.dart';

class MilestoneHallDialog extends StatelessWidget {
  final List<MilestoneBadge> badges;

  const MilestoneHallDialog({super.key, required this.badges});

  static void show(BuildContext context, {required List<MilestoneBadge> badges}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MilestoneHallDialog(badges: badges),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.instance.brandColor.primary;
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

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
          const SizedBox(height: 20),

          // 标题与统计横幅
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🏆 自律成就殿堂',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unlockedCount / ${badges.length} 已点亮',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '每一个勋章，都是你与自律深度对话的勋绩',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
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

          // 勋章九宫格
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(context, badge, isDark, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    MilestoneBadge badge,
    bool isDark,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBadgeDetail(context, badge, isDark, primaryColor);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? (isDark ? const Color(0xFF1F2937) : Colors.white)
              : (isDark ? const Color(0xFF151C24) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: badge.isUnlocked
                ? badge.badgeColor.withValues(alpha: 0.6)
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            width: badge.isUnlocked ? 1.5 : 1,
          ),
          boxShadow: badge.isUnlocked
              ? [
                  BoxShadow(
                    color: badge.badgeColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 勋章 Emoji
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badge.isUnlocked
                        ? badge.badgeColor.withValues(alpha: 0.15)
                        : (isDark ? Colors.black26 : Colors.black12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge.iconEmoji,
                    style: TextStyle(
                      fontSize: 30,
                      color: badge.isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
                if (!badge.isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white70),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 勋章标题
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),

            // 进度文字
            Text(
              badge.isUnlocked
                  ? '已达成 ✨'
                  : '${badge.currentValue}/${badge.targetValue} ${badge.unit}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: badge.isUnlocked ? FontWeight.w600 : FontWeight.normal,
                color: badge.isUnlocked ? badge.badgeColor : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),

            // 迷你进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 4,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  badge.isUnlocked ? badge.badgeColor : Colors.grey[600]!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(
    BuildContext context,
    MilestoneBadge badge,
    bool isDark,
    Color primaryColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.badgeColor.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Text(badge.iconEmoji, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              Text(
                badge.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                badge.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('解锁状态', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(
                      badge.isUnlocked ? '已点亮 🌟' : '进行中 (${(badge.progress * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked ? badge.badgeColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('关闭'),
                    ),
                  ),
                  if (badge.isUnlocked) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          SharePosterDialog.show(context, quote: '成就解锁：${badge.title} - ${badge.subtitle}');
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('分享勋章'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badge.badgeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
