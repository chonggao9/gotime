import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';

class TimerScreen extends StatefulWidget {
  final Habit habit;

  const TimerScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  
  // 呼吸灯动画控制器，用于专注时的沉浸感
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    // 隐藏系统状态栏和底部导航栏，进入绝对沉浸模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _totalSeconds = widget.habit.timerSeconds ?? 1500; // 默认 25 分钟
    _remainingSeconds = _totalSeconds;

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _finishTimer();
      }
    });
  }

  void _finishTimer() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    // TODO: 触发打卡完成接口，并播放庆祝动效
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _giveUp() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('要放弃吗？', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('现在放弃，本次专注时间将不会被记录哦。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续专注', style: TextStyle(color: AppTheme.mintGreen, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关弹窗
              Navigator.of(context).pop(); // 退回首页
            },
            child: const Text('残忍放弃', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breatheController.dispose();
    // 恢复系统状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      // 使用极其纯净的深色背景，强制进入"暗黑模式"保护视力
      backgroundColor: const Color(0xFF0A0F0D),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 极简呼吸光晕背景
          AnimatedBuilder(
            animation: _breatheAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breatheAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.mintGreen.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 核心计时区
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'icon_${widget.habit.id}',
                child: Text(
                  widget.habit.iconEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.habit.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              
              // 巨大的倒计时与环形进度条
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mintGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()], // 保证数字等宽，不会跳动
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 底部放弃按钮 (有意弱化视觉层级)
          Positioned(
            bottom: 60,
            child: GestureDetector(
              onTap: _giveUp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                  color: Colors.transparent,
                ),
                child: const Text(
                  '放弃',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
