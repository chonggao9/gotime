import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

// 热力图数据级别枚举
enum HeatmapLevel {
  none,      // 0%
  low,       // 1% - 49%
  medium,    // 50% - 99%
  high,      // 100% 满分
  skipped    // 请假/冻结 (冰蓝保护色)
}

class HeatmapCalendar extends StatefulWidget {
  final Map<DateTime, HeatmapLevel> data;
  
  const HeatmapCalendar({super.key, required this.data});

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
        return isDark ? AppTheme.darkMintGreen.withValues(alpha: 0.4) : AppTheme.lightMintGreen;
      case HeatmapLevel.medium:
        return AppTheme.mintGreen;
      case HeatmapLevel.high:
        return isDark ? const Color(0xFF00FFB2) : AppTheme.darkMintGreen; // 满分深色模式下给一点荧光绿
      case HeatmapLevel.skipped:
        // 冰蓝色表示休假/冻结保护色，传递安心舒适感
        return isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8);
    }
  }

  void _showDayInfo(DateTime date, HeatmapLevel level) {
    HapticFeedback.selectionClick();
    final String dateStr = '${date.month}月${date.day}日';
    String tip = '未打卡';
    if (level == HeatmapLevel.high) {
      tip = '🌟 100% 完美达成';
    } else if (level == HeatmapLevel.medium) {
      tip = '🌱 已完成过半';
    } else if (level == HeatmapLevel.low) {
      tip = '💧 已部分打卡';
    } else if (level == HeatmapLevel.skipped) {
      tip = '❄️ 免责休假保护中 (连胜保留)';
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$dateStr: $tip', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 生成过去 52 周的数据 (粗略计算 364 天)
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(const Duration(days: 364));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 热力图滚动主区域
        SliverFadeEffect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧星期标签
                  Column(
                    children: [
                      _buildDayLabel('一'),
                      _buildDayLabel(''),
                      _buildDayLabel('三'),
                      _buildDayLabel(''),
                      _buildDayLabel('五'),
                      _buildDayLabel(''),
                      _buildDayLabel('日'),
                    ],
                  ),
                  const SizedBox(width: 8),
                  
                  // 52 列数据网格
                  Row(
                    children: List.generate(53, (colIndex) {
                      return Column(
                        children: List.generate(7, (rowIndex) {
                          // 计算对应单元格的精确日期
                          final int dayOffset = (colIndex * 7) + rowIndex;
                          final DateTime cellDate = startDate.add(Duration(days: dayOffset));
                          
                          // 如果超出今天则绘制透明占位
                          if (cellDate.isAfter(today)) {
                            return const SizedBox(width: 14, height: 14);
                          }

                          // 匹配外部传入的完成度等级
                          final DateTime dateKey = DateTime(cellDate.year, cellDate.month, cellDate.day);
                          final HeatmapLevel level = widget.data[dateKey] ?? HeatmapLevel.none;

                          return GestureDetector(
                            onTap: () => _showDayInfo(cellDate, level),
                            child: Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _getColorForLevel(level, isDark),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 底部图例指示区
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('少', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(width: 4),
              _buildLegendItem(HeatmapLevel.none, isDark),
              _buildLegendItem(HeatmapLevel.low, isDark),
              _buildLegendItem(HeatmapLevel.medium, isDark),
              _buildLegendItem(HeatmapLevel.high, isDark),
              const SizedBox(width: 4),
              Text('多', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(width: 16),
              _buildLegendItem(HeatmapLevel.skipped, isDark),
              const SizedBox(width: 4),
              Text('❄️休假', style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))),
            ],
          ),
        ),
      ],
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

class SliverFadeEffect extends StatelessWidget {
  final Widget child;
  const SliverFadeEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
