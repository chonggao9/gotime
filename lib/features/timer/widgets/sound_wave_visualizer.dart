import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/services/ambient_sound_service.dart';

class SoundWaveVisualizer extends StatefulWidget {
  final Color barColor;
  final int barCount;

  const SoundWaveVisualizer({
    Key? key,
    this.barColor = const Color(0xFF10B981),
    this.barCount = 4,
  }) : super(key: key);

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isPlaying = AmbientSoundService.instance.isPlaying;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            // 计算不同柱子的正弦振幅相位差
            final phase = index * (math.pi / widget.barCount);
            final wave = math.sin(_controller.value * 2 * math.pi + phase).abs();
            final height = isPlaying ? 6.0 + wave * 14.0 : 4.0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: isPlaying ? widget.barColor : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
