import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// 轻量级粒子五彩纸屑画布 (Confetti Particle Animation)
/// 无需依赖外部第三方包，纯 Flutter CustomPainter 实现高性能全屏粒子庆祝
class ConfettiCelebrationDialog extends StatefulWidget {
  final VoidCallback? onDismiss;

  const ConfettiCelebrationDialog({super.key, this.onDismiss});

  static Future<void> show(BuildContext context) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const ConfettiCelebrationDialog();
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
  State<ConfettiCelebrationDialog> createState() => _ConfettiCelebrationDialogState();
}

class _ConfettiCelebrationDialogState extends State<ConfettiCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  final List<Color> _colors = const [
    Color(0xFF34D399), // 薄荷绿
    Color(0xFF38BDF8), // 天空蓝
    Color(0xFFFBBF24), // 暖阳金
    Color(0xFFF472B6), // 樱花粉
    Color(0xFFA78BFA), // 柔雾紫
    Color(0xFFFB923C), // 活力橙
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
        });
      });

    // 初始化 70 个绚丽粒子
    for (int i = 0; i < 70; i++) {
      _particles.add(
        _Particle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.4,
          y: 0.35,
          vx: (_random.nextDouble() - 0.5) * 8.0,
          vy: -(_random.nextDouble() * 10.0 + 4.0),
          color: _colors[_random.nextInt(_colors.length)],
          size: _random.nextDouble() * 8 + 6,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
          shape: _random.nextInt(3),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 粒子层
          CustomPaint(
            painter: _ConfettiPainter(particles: _particles),
          ),

          // 中心弹窗内容
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 勋章图标
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.mintGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 标题
                  Text(
                    '今日全勤达成！',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 励志语录
                  Text(
                    '今天的自律，正在悄悄塑造未来的你。\n动量分数 +10，习惯强度稳步提升！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 确认关闭按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        widget.onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mintGreen,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '太棒了，继续保持',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

class _Particle {
  double x; // 0.0 ~ 1.0 (屏幕相对宽度)
  double y; // 0.0 ~ 1.0 (屏幕相对高度)
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  int shape; // 0: 方块, 1: 圆形, 2: 细条

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });

  void update() {
    x += vx * 0.0018;
    y += vy * 0.0018;
    vy += 0.35; // 重力加速度
    vx *= 0.985; // 空气阻力
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double px = p.x * size.width;
      final double py = p.y * size.height;

      if (py > size.height + 20 || py < -50) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final paint = Paint()..color = p.color;

      if (p.shape == 0) {
        // 矩形纸屑
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else if (p.shape == 1) {
        // 圆形粒子
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      } else {
        // 彩带细长形
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.3),
            const Radius.circular(2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
