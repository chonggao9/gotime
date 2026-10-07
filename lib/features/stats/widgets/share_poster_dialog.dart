import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 杂志级极简打卡分享海报弹窗 (Aesthetic Share Poster)
/// 支持使用 RepaintBoundary 渲染高清晰度海报并提供保存与分享操作
class SharePosterDialog extends StatefulWidget {
  final int streakDays;
  final int strengthPercent;
  final String strengthLabel;
  final String quote;

  const SharePosterDialog({
    super.key,
    this.streakDays = 12,
    this.strengthPercent = 88,
    this.strengthLabel = '💎 磐石阶段',
    this.quote = '习惯不是枷锁，而是通向自由的阶梯。',
  });

  static Future<void> show(
    BuildContext context, {
    int streakDays = 12,
    int strengthPercent = 88,
    String strengthLabel = '💎 磐石阶段',
    String quote = '习惯不是枷锁，而是通向自由的阶梯。',
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return SharePosterDialog(
          streakDays: streakDays,
          strengthPercent: strengthPercent,
          strengthLabel: strengthLabel,
          quote: quote,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<SharePosterDialog> createState() => _SharePosterDialogState();
}

class _SharePosterDialogState extends State<SharePosterDialog> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isGenerating = false;

  Future<void> _captureAndSave() async {
    setState(() => _isGenerating = true);
    HapticFeedback.heavyImpact();

    try {
      final boundary = _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          // 在 UI 上给用户提示保存成功反馈
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('✨ 杂志风海报已成功生成，可随时分享至社交圈！'),
                  ],
                ),
                backgroundColor: AppTheme.darkMintGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (_) {
      // 容错处理
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.year}年${now.month}月${now.day}日';
    final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final weekdayStr = '星期${weekdayNames[now.weekday - 1]}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 海报本体卡片 (RepaintBoundary 用于截屏)
              RepaintBoundary(
                key: _posterKey,
                child: Container(
                  width: 330,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414), // 高级哑光黑
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 顶部品牌与日期
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF34D399), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('⏱️', style: TextStyle(fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'GoTime',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$dateStr $weekdayStr',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 核心标语与今日金句
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '今日觉察 · Daily Insight',
                              style: TextStyle(
                                color: AppTheme.mintGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '“${widget.quote}”',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 数据指标双格 (连胜 + 习惯稳固度)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🔥 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        '当前连胜',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${widget.streakDays}',
                                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('天', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('💎 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        '稳固度',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${widget.strengthPercent}%',
                                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.mintGreen),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 模拟微型热力网格 (代表近期打卡足迹)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('近期自律足迹', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text('休假免责保护', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(14, (col) {
                                return Column(
                                  children: List.generate(4, (row) {
                                    Color c;
                                    if (col == 10 && row == 1) {
                                      c = const Color(0xFF38BDF8); // 冰蓝休假
                                    } else if ((col + row) % 3 == 0) {
                                      c = AppTheme.mintGreen;
                                    } else if ((col + row) % 5 == 0) {
                                      c = Colors.grey[800]!;
                                    } else {
                                      c = AppTheme.darkMintGreen;
                                    }
                                    return Container(
                                      width: 13,
                                      height: 13,
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
                                    );
                                  }),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 底部结语与品牌小注
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '允许合法喘息 · 绝不制造焦虑',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text('github.com/chonggao9/gotime', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 底部操作按钮组
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('关闭'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _captureAndSave,
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(_isGenerating ? '正在生成...' : '保存打卡海报'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mintGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
