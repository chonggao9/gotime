import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/sqlite_service.dart';
import '../../core/services/ambient_sound_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/check_in.dart';
import '../../models/habit.dart';
import 'widgets/sound_mixer_sheet.dart';
import 'widgets/sound_selector_sheet.dart';
import 'widgets/sound_wave_visualizer.dart';

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
  bool _isPaused = false;
  
  // 呼吸灯动画控制器，用于专注时的沉浸感
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  final _ambientService = AmbientSoundService.instance;

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

    _ambientService.addListener(_onAmbientChanged);

    _startTimer();
  }

  void _onAmbientChanged() {
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _finishTimer();
        }
      }
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _breatheController.stop();
        _ambientService.stop();
      } else {
        _breatheController.repeat(reverse: true);
        if (_ambientService.currentSound != AmbientSoundType.none) {
          _ambientService.play();
        }
      }
    });
  }

  Future<void> _finishTimer() async {
    _timer?.cancel();
    _ambientService.stop();
    _ambientService.playCompletionChime();
    HapticFeedback.heavyImpact();

    // 自动持久化打卡记录
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final checkIn = CheckIn(
      id: const Uuid().v4(),
      habitId: widget.habit.id,
      date: todayStr,
      status: CheckInStatus.completed,
      durationSeconds: _totalSeconds,
      logText: '完成专注 ${_totalSeconds ~/ 60} 分钟 🎯',
      mood: 5,
      createdAt: DateTime.now(),
    );

    if (!kIsWeb) {
      try {
        await SQLiteService.instance.insertCheckIn(checkIn);
      } catch (e) {
        debugPrint('Failed to save focus checkin: $e');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E2923),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text('🎉 ', style: TextStyle(fontSize: 24)),
              Text('专注圆满达成！', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '你已沉浸专注 ${_totalSeconds ~/ 60} 分钟，已自动完成今日打卡！\n身心放松一下吧 🌿',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mintGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('太棒了', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _giveUp() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2923),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('要放弃吗？', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('现在放弃，本次专注时间将不会被计入打卡记录哦。', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续专注', style: TextStyle(color: AppTheme.mintGreen, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              _ambientService.stop();
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
    _ambientService.removeListener(_onAmbientChanged);
    _ambientService.stop();
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
    final activeSound = _ambientService.currentSound;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 极简呼吸光晕背景
            AnimatedBuilder(
              animation: _breatheAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPaused ? 1.0 : _breatheAnimation.value,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.mintGreen.withOpacity(_isPaused ? 0.05 : 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 顶部工具栏：白噪音浮动选择胶囊
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 返回按钮
                  IconButton(
                    onPressed: _giveUp,
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 28),
                  ),

                  // 右侧音频控制区：多轨混音台 + 单轨白噪音胶囊
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 48kHz 多轨混音调音台入口
                      IconButton(
                        tooltip: '48kHz 多轨混音台',
                        icon: const Icon(Icons.tune_rounded, color: AppTheme.mintGreen, size: 22),
                        onPressed: () => SoundMixerSheet.show(context),
                      ),
                      const SizedBox(width: 4),
                      // 白噪音胶囊控制
                      GestureDetector(
                        onTap: () => SoundSelectorSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _ambientService.isPlaying ? AppTheme.mintGreen.withOpacity(0.5) : Colors.white12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(activeSound.iconEmoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                activeSound.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SoundWaveVisualizer(
                                barColor: Color(activeSound.themeColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                const SizedBox(height: 12),
                Text(
                  widget.habit.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                
                // 倒计时与环形进度条
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (_isPaused)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '已暂停',
                              style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // 交互控制按钮：暂停/继续与放弃
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 暂停/继续按钮
                    GestureDetector(
                      onTap: _togglePause,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // 放弃按钮
                    GestureDetector(
                      onTap: _giveUp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                          color: Colors.transparent,
                        ),
                        child: const Text(
                          '放弃',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

