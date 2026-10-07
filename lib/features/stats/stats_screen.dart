import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/heatmap_calendar.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

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
      // 随机生成一些状态，模拟真实打卡情况
      if (i % 7 == 0) {
        data[date] = HeatmapLevel.skipped; // 假装每周日请假
      } else if (i % 3 == 0) {
        data[date] = HeatmapLevel.high; // 完美的一天
      } else if (i % 2 == 0) {
        data[date] = HeatmapLevel.medium; // 完成了大部分
      } else if (i % 5 == 0) {
        data[date] = HeatmapLevel.low; // 只完成了一点点
      } else {
        data[date] = HeatmapLevel.none; // 彻底摆烂
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
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部大字报指标区
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  _buildStatCard(
                    title: '当前连胜',
                    value: '12',
                    unit: '天',
                    icon: '🔥',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
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
          
          // 年度热力图区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
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
    final emojis = ['😫', '😎', '🎉', '🤔', '💪'];
    final texts = [
      '今天喝得肚子胀，但是坚持下来了！',
      '读完了第三章，感觉灵魂得到了升华。',
      '突破了 5 公里！配速 5分30秒。',
      '番茄钟中途被打断了一次，明天需要找个更安静的地方。',
      '虽然有点累，但动量分数保住了！'
    ];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间线轴
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              if (index < 5) // 只要不是最后一个，就画一条线
                Container(
                  width: 2,
                  height: 60,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // 右侧日志内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10月${10 - index}日',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emojis[index - 1], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          texts[index - 1],
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
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
