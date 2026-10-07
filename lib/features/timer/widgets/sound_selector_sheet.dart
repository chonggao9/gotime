import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/ambient_sound_service.dart';
import '../../../core/theme/app_theme.dart';

class SoundSelectorSheet extends StatefulWidget {
  const SoundSelectorSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SoundSelectorSheet(),
    );
  }

  @override
  State<SoundSelectorSheet> createState() => _SoundSelectorSheetState();
}

class _SoundSelectorSheetState extends State<SoundSelectorSheet> {
  final _service = AmbientSoundService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: const Color(0xFF161F1D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖拽手柄
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '沉浸专注白噪音',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '自然音律声境，隔绝外界杂音，迅速入定',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 声境卡片网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AmbientSoundType.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final sound = AmbientSoundType.values[index];
              final isSelected = _service.currentSound == sound;
              final color = Color(sound.themeColor);

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _service.setSound(sound);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.18) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.white12,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.25) : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Text(sound.iconEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sound.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sound.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? color.withOpacity(0.9) : Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 音量调节滑动条 (当非静音模式时可见)
          if (_service.currentSound != AmbientSoundType.none) ...[
            Row(
              children: [
                const Icon(Icons.volume_down_rounded, color: Colors.white54, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.mintGreen,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: AppTheme.mintGreen,
                      overlayColor: AppTheme.mintGreen.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _service.volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) {
                        _service.setVolume(val);
                      },
                    ),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${(_service.volume * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
