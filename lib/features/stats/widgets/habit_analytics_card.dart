import 'package:flutter/material.dart';
import '../../../core/services/habit_analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/check_in.dart';

class HabitAnalyticsCard extends StatelessWidget {
  final List<CheckIn> checkIns;

  const HabitAnalyticsCard({super.key, required this.checkIns});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = HabitAnalyticsService.instance.analyzeCheckIns(checkIns);

    final moodEmoji = _getMoodEmoji(report.averageMood);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppTheme.mintGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '深度节律与周中分布',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '洞察一周最佳心流日 · 顺应自然精力起伏',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(moodEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '心情 ${report.averageMood.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7 日柱状图分布
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: report.dayStats.map((stat) {
                final isBest = stat.weekday == report.bestWeekday && stat.completedCount > 0;
                final barHeight = (stat.rate * 80).clamp(6.0, 80.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isBest) ...[
                      const Text('👑', style: TextStyle(fontSize: 11)),
                      const SizedBox(height: 2),
                    ] else
                      Text(
                        '${stat.completedCount}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    const SizedBox(height: 4),
                    // 胶囊柱
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: isBest
                            ? const LinearGradient(
                                colors: [AppTheme.mintGreen, Color(0xFF10B981)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : LinearGradient(
                                colors: isDark
                                    ? [Colors.grey[700]!, Colors.grey[800]!]
                                    : [Colors.grey[300]!, Colors.grey[200]!],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                        color: isBest
                            ? AppTheme.mintGreen
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // 抗焦虑心流寄语卡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.mintGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report.insightMessage,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
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

  String _getMoodEmoji(double mood) {
    if (mood >= 4.5) return '🤩';
    if (mood >= 3.8) return '😊';
    if (mood >= 3.0) return '🙂';
    if (mood >= 2.0) return '😐';
    return '🌱';
  }
}
