import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/share_poster_dialog.dart';

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
                  Text(
                    '点击格子看详情',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
}
