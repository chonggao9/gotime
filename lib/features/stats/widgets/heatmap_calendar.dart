import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

// 热力图数据级别枚举
enum HeatmapLevel {
  none,      // 0%
  low,       // 1% - 49%
  medium,    // 50% - 99%
  high,      // 100% 满分
  skipped    // 请假/冻结
}

class HeatmapCalendar extends StatefulWidget {
  final Map<DateTime, HeatmapLevel> data;
  
  const HeatmapCalendar({Key? key, required this.data}) : super(key: key);

  @override
  State<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends State<HeatmapCalendar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 初始化时自动滚动到最右侧 (今天)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getColorForLevel(HeatmapLevel level, bool isDark) {
    switch (level) {
      case HeatmapLevel.none:
        return isDark ? Colors.grey[850]! : Colors.grey[200]!;
      case HeatmapLevel.low:
        return isDark ? AppTheme.darkMintGreen.withOpacity(0.4) : AppTheme.lightMintGreen;
      case HeatmapLevel.medium:
        return AppTheme.mintGreen;
      case HeatmapLevel.high:
        return isDark ? const Color(0xFF00FFB2) : AppTheme.darkMintGreen; // 满分深色模式下给一点荧光绿
      case HeatmapLevel.skipped:
        return isDark ? Colors.grey[700]! : Colors.grey[400]!;
    }
  }

  void _showDayInfo(DateTime date, HeatmapLevel level) {
    HapticFeedback.selectionClick();
    // 这里可以用极简的 Tooltip 或 Snackbar 展示当天详情，暂时只做震动反馈
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 生成过去 52 周的数据 (粗略计算 364 天)
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(const Duration(days: 364));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          // 标题与图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '年度成功图',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem(HeatmapLevel.none, isDark),
                  _buildLegendItem(HeatmapLevel.low, isDark),
                  _buildLegendItem(HeatmapLevel.medium, isDark),
                  _buildLegendItem(HeatmapLevel.high, isDark),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // 热力图矩阵
          SizedBox(
            height: 140, // 7个格子的高度 + 间距
            child: Row(
              children: [
                // 星期标签 Y轴
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayLabel('一'),
                    _buildDayLabel('三'),
                    _buildDayLabel('五'),
                    _buildDayLabel('日'),
                  ],
                ),
                const SizedBox(width: 8),
                
                // 滚动的格子矩阵 X轴
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 52, // 52 周
                    itemBuilder: (context, weekIndex) {
                      return Column(
                        children: List.generate(7, (dayIndex) {
                          // 计算当前格子的具体日期
                          final int dayOffset = (weekIndex * 7) + dayIndex;
                          final DateTime cellDate = startDate.add(Duration(days: dayOffset));
                          
                          // 模拟超出今天的数据为空白
                          if (cellDate.isAfter(today)) {
                            return const SizedBox(width: 14, height: 14, child: Margin(margin: EdgeInsets.all(2)));
                          }

                          // 从传入的 map 中读取当天状态，没有则为 none
                          // 实际开发中需要剔除时分秒，只比较 yyyy-mm-dd
                          final HeatmapLevel level = widget.data.entries.firstWhere(
                            (entry) => entry.key.year == cellDate.year && 
                                       entry.key.month == cellDate.month && 
                                       entry.key.day == cellDate.day,
                            orElse: () => MapEntry(cellDate, HeatmapLevel.none),
                          ).value;

                          return GestureDetector(
                            onTap: () => _showDayInfo(cellDate, level),
                            child: Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _getColorForLevel(level, isDark),
                                borderRadius: BorderRadius.circular(4), // GitHub是直角，我们这里做微圆角更精致
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(HeatmapLevel level, bool isDark) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: _getColorForLevel(level, isDark),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildDayLabel(String text) {
    return SizedBox(
      height: 18, // 与格子的实际占据高度对齐
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}
// 用于处理空白占位的辅助类
class Margin extends StatelessWidget {
  final EdgeInsets margin;
  const Margin({Key? key, required this.margin}) : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(padding: margin, child: const SizedBox.expand());
}
