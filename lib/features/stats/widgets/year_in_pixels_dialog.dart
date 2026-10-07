import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/year_in_pixels_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/database/sqlite_service.dart';
import '../../../models/check_in.dart';
import 'share_poster_dialog.dart';

class YearInPixelsDialog extends StatefulWidget {
  const YearInPixelsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const YearInPixelsDialog(),
    );
  }

  @override
  State<YearInPixelsDialog> createState() => _YearInPixelsDialogState();
}

class _YearInPixelsDialogState extends State<YearInPixelsDialog> {
  final _service = YearInPixelsService.instance;
  final int _currentYear = DateTime.now().year;
  PixelDay? _selectedPixel;
  List<CheckIn> _checkIns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final list = await SQLiteService.instance.getCheckInsForDateRange(
        '$_currentYear-01-01',
        '$_currentYear-12-31',
      );
      if (mounted) {
        setState(() {
          _checkIns = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.instance.brandColor.primary;

    final grid = _service.generateYearGrid(
      year: _currentYear,
      checkIns: _checkIns,
      totalDailyHabitsTarget: 3,
      isDark: isDark,
    );

    final stats = _service.calculateAnnualStats(grid);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽条
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
          const SizedBox(height: 16),

          // 标题与年度概览
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$_currentYear 全景像素年鉴',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '365 Days',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '每一个像素，都是生命长河里被点亮的一寸光阴',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 年度三联关键指标
          Row(
            children: [
              _buildMetricCard('坚持天数', '${stats.totalDaysLogged}', '天', primaryColor, isDark),
              const SizedBox(width: 10),
              _buildMetricCard('年度达成率', '${(stats.overallFulfillment * 100).toInt()}', '%', const Color(0xFF10B981), isDark),
              const SizedBox(width: 10),
              _buildMetricCard('从容休假', '${stats.skippedDays}', '天 ❄️', const Color(0xFF38BDF8), isDark),
            ],
          ),
          const SizedBox(height: 16),

          // 图例一览
          _buildLegendRow(isDark),
          const SizedBox(height: 16),

          // 365 天 12 个月像素网格
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildMonthsMosaic(grid, isDark),
            ),
          ),
          const SizedBox(height: 16),

          // 底部选中日期详情及导出按钮
          if (_selectedPixel != null)
            _buildSelectedPixelInspector(_selectedPixel!, isDark, primaryColor),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
                SharePosterDialog.show(
                  context,
                  quote: '$_currentYear 年度像素年鉴：已坚持 ${stats.totalDaysLogged} 天，自律达成率 ${(stats.overallFulfillment * 100).toInt()}% 🌟',
                );
              },
              icon: const Icon(Icons.palette_rounded, size: 18),
              label: const Text('生成并导出全景年鉴海报', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String unit, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 2),
                Text(unit, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _buildLegendItem('100% 满格', const Color(0xFF10B981)),
        _buildLegendItem('60%+ 良好', const Color(0xFF34D399)),
        _buildLegendItem('30%+ 起步', const Color(0xFFFBBF24)),
        _buildLegendItem('❄️ 休假免责', const Color(0xFF38BDF8)),
        _buildLegendItem('⚪ 待点亮', isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMonthsMosaic(Map<int, List<PixelDay>> grid, bool isDark) {
    const monthNames = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: List.generate(12, (index) {
        final month = index + 1;
        final days = grid[month] ?? [];

        return Container(
          width: 156,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthNames[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: days.map((pixel) {
                  final isSelected = _selectedPixel?.dateString == pixel.dateString;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedPixel = pixel);
                    },
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: pixel.color,
                        borderRadius: BorderRadius.circular(2.5),
                        border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSelectedPixelInspector(PixelDay pixel, bool isDark, Color primaryColor) {
    final statusStr = pixel.isSkipped
        ? '❄️ 免责休假模式保护'
        : pixel.completedCount > 0
            ? '已完成 ${pixel.completedCount} 项习惯打卡 (${(pixel.ratio * 100).toInt()}%)'
            : '本日无打卡记录';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pixel.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: pixel.color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          Text(pixel.dateString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusStr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
