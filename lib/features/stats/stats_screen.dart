import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/milestone_service.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/milestone_hall_dialog.dart';
import 'widgets/share_poster_dialog.dart';
import 'widgets/year_in_pixels_dialog.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // 模拟热力图数据
  Map<DateTime, HeatmapLevel> _generateMockData() {
    final Map<DateTime, HeatmapLevel> data = {};
    final DateTime today = DateTime.now();
    
    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      if (i % 7 == 0) {
        data[dateKey] = HeatmapLevel.skipped; // 规律休假保护日
      } else if (i % 3 == 0) {
        data[dateKey] = HeatmapLevel.high; // 完美的一天
      } else if (i % 2 == 0) {
        data[dateKey] = HeatmapLevel.medium; // 完成大部分
      } else if (i % 5 == 0) {
        data[dateKey] = HeatmapLevel.low; // 部分完成
      } else {
        data[dateKey] = HeatmapLevel.none; // 未打卡
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('数据洞察', style: TextStyle(letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: '生成分享海报',
            onPressed: () {
              SharePosterDialog.show(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部指标大字报卡片区
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _buildStatCard(
                    title: '当前连胜',
                    value: '12',
                    unit: '天',
                    icon: '🔥',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: '习惯稳固度',
                    value: '88',
                    unit: '%',
                    icon: '💎',
                    highlightColor: AppTheme.mintGreen,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: '本月达成',
                    value: '86',
                    unit: '%',
                    icon: '📈',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          
          // 年度热力图区域标题与说明
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '年度坚持热力图',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => YearInPixelsDialog.show(context),
                    icon: const Icon(Icons.palette_outlined, size: 16),
                    label: const Text('全景年鉴 🎨', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          // 年度热力图区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HeatmapCalendar(data: _generateMockData()),
            ),
          ),

          // 本周温情复盘报告卡 (自我关怀与动量)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: _buildWeeklyReviewCard(isDark, ThemeService.instance.brandColor.primary),
            ),
          ),

          // 自律成就勋章殿堂 (F6.2)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: _buildMilestonesSection(isDark, ThemeService.instance.brandColor.primary),
            ),
          ),
          
          // 习惯日志流 (Timeline) 占位
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '习惯日志流',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }
                  return _buildLogItem(isDark, index);
                },
                childCount: 6, // 1个标题 + 5条日志
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required String icon,
    Color? highlightColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: highlightColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(bool isDark, int index) {
    final emojis = ['😫', '😎', '🎉', '❄️', '💪'];
    final texts = [
      '今天喝得肚子胀，但是坚持下来了！',
      '读完了第三章，感觉灵魂得到了升华。',
      '突破了 5 公里！配速 5分30秒。',
      '连续出差，开启免责休假冻结保护中 ❄️',
      '虽然有点累，但动量分数保住了！'
    ];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(emojis[index - 1], style: const TextStyle(fontSize: 18))),
              ),
              if (index < 5)
                Container(
                  width: 2,
                  height: 48,
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '10月${7 - index}日',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    texts[index - 1],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.4,
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

  Widget _buildWeeklyReviewCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16201D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('🌿', style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '本周习惯动量复盘',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '基于抗焦虑心理学模型自愈总结',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  SharePosterDialog.show(
                    context,
                    streakDays: 12,
                    strengthPercent: 88,
                    strengthLabel: '🌿 稳步成型',
                    quote: '本周你完成了 5 天打卡，合法免责休假 2 天。日拱一卒，慢慢来会更快。',
                  );
                },
                icon: const Icon(Icons.ios_share_rounded, size: 15),
                label: const Text('分享周报'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 核心胶囊数据行
          Row(
            children: [
              _buildMiniMetric('持续打卡', '5 天', '✓ 专注执行', primaryColor, isDark),
              const SizedBox(width: 8),
              _buildMiniMetric('合法休假', '2 天', '❄️ 锁定连胜', const Color(0xFF0284C7), isDark),
              const SizedBox(width: 8),
              _buildMiniMetric('心理内耗', '0 负荷', '🛡️ 无罪恶感', Colors.amber[700]!, isDark),
            ],
          ),
          const SizedBox(height: 16),

          // 暖心心理学寄语
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    '“你不需要逼自己做超人。适时停下来合法休假，本身就是长期主义最宝贵的能力。下周继续保持现在的节奏就好。”',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String val, String tip, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(tip, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesSection(bool isDark, Color primaryColor) {
    final badges = MilestoneService.instance.getBadges(
      habits: [],
      checkIns: [],
      maxStreak: 12,
      totalFocusMinutes: 135,
    );
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '自律成就勋章',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount/${badges.length}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => MilestoneHallDialog.show(context, badges: badges),
              child: const Row(
                children: [
                  Text('成就殿堂', style: TextStyle(fontSize: 13)),
                  Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return GestureDetector(
                onTap: () => MilestoneHallDialog.show(context, badges: badges),
                child: Container(
                  width: 104,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badge.isUnlocked
                          ? badge.badgeColor.withValues(alpha: 0.4)
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(badge.iconEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        badge.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.isUnlocked ? '已点亮' : '${badge.currentValue}/${badge.targetValue}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.normal,
                          color: badge.isUnlocked ? badge.badgeColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

