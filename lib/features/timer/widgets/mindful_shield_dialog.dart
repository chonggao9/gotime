import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/mindful_shield_service.dart';

class MindfulShieldDialog extends StatefulWidget {
  const MindfulShieldDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => const MindfulShieldDialog(),
    );
  }

  @override
  State<MindfulShieldDialog> createState() => _MindfulShieldDialogState();
}

class _MindfulShieldDialogState extends State<MindfulShieldDialog> with SingleTickerProviderStateMixin {
  final _service = MindfulShieldService.instance;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isCoolingDown = false;
  String _selectedTrigger = '无聊/习惯性摸手机';
  bool _justOvercame = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _service.calmDownSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCoolDown() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCoolingDown = true;
      _remainingSeconds = _service.calmDownSeconds;
      _justOvercame = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isCoolingDown = false;
        });
        HapticFeedback.lightImpact();
      }
    });
  }

  void _confirmOvercome() {
    HapticFeedback.heavyImpact();
    _service.recordUrgeOvercome(
      trigger: _selectedTrigger,
      calmSeconds: _service.calmDownSeconds,
    );
    setState(() {
      _justOvercame = true;
      _isCoolingDown = false;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 390,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141F1A) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? const Color(0xFF1F3D2F) : const Color(0xFFE0EFE8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部标题与关闭
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '正念自律屏障',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '在冲动与反应之间插入正念缓冲',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 核心倒计时与呼吸光晕
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isCoolingDown ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withValues(alpha: _isCoolingDown ? 0.25 : 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: _isCoolingDown
                                    ? (_remainingSeconds / _service.calmDownSeconds)
                                    : 1.0,
                                strokeWidth: 5,
                                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _justOvercame
                                      ? '✨'
                                      : (_isCoolingDown ? '$_remainingSeconds' : '🛡️'),
                                  style: TextStyle(
                                    fontSize: _isCoolingDown ? 32 : 36,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                if (_isCoolingDown)
                                  const Text(
                                    '秒深呼吸',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              Text(
                _justOvercame
                    ? '太棒了！你又一次夺回了大脑控制权 👑'
                    : (_isCoolingDown ? '停顿片刻 · 觉察冲动 · 深吸气后慢慢呼出...' : '面对分心诱惑，先给自己 15 秒理性缓冲：'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _justOvercame ? FontWeight.bold : FontWeight.normal,
                  color: _justOvercame
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(height: 14),

              // 常见冲动诱因选择
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '本次觉察到的分心冲动源：',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: MindfulShieldService.commonUrgeTriggers.map((trig) {
                    final isSelected = _selectedTrigger == trig;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(trig, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                        onSelected: (val) {
                          if (val) setState(() => _selectedTrigger = trig);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // 底部按钮栏
              if (!_isCoolingDown) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _startCoolDown,
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: const Text('启动 15s 冷却', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmOvercome,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('战胜了冲动 ✨', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmOvercome,
                    icon: const Icon(Icons.verified_rounded, size: 18),
                    label: const Text('觉察完毕，我选择重返专注 🎯', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // 今日战绩徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🛡️ 今日已阻断冲动：', style: TextStyle(fontSize: 12)),
                        Text(
                          '${_service.todayOvercomeCount} 次',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '每一次抵抗都在重塑前额叶',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
