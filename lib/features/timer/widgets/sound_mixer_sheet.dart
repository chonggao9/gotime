import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/ambient_sound_service.dart';
import '../../../core/services/multi_track_mixer_service.dart';
import '../../../core/theme/app_theme.dart';

class SoundMixerSheet extends StatefulWidget {
  const SoundMixerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SoundMixerSheet(),
    );
  }

  @override
  State<SoundMixerSheet> createState() => _SoundMixerSheetState();
}

class _SoundMixerSheetState extends State<SoundMixerSheet> {
  final _mixer = MultiTrackMixerService.instance;

  final List<AmbientSoundType> _tracks = [
    AmbientSoundType.rain,
    AmbientSoundType.forest,
    AmbientSoundType.waves,
    AmbientSoundType.fire,
    AmbientSoundType.cafe,
  ];

  @override
  void initState() {
    super.initState();
    _mixer.addListener(_onMixerChanged);
  }

  @override
  void dispose() {
    _mixer.removeListener(_onMixerChanged);
    super.dispose();
  }

  void _onMixerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = _mixer.isPlaying;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部小手柄
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

          // 标题行与总控播放
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🎛️ ', style: TextStyle(fontSize: 20)),
                      Text(
                        '48kHz 母带白噪音混音台',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '支持多轨同时自由叠加 · 调配专属心流声场',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 总音量与总播放卡片
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _mixer.togglePlayPause();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: isPlaying ? AppTheme.mintGreen : Colors.grey,
                  ),
                  icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('主控音量', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('${(_mixer.masterVolume * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: _mixer.masterVolume,
                          activeColor: AppTheme.mintGreen,
                          onChanged: (val) {
                            _mixer.setMasterVolume(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 预设混音快捷胶囊
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: MultiTrackMixerService.presets.map((preset) {
                final isSelected = _mixer.activePresetId == preset.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    avatar: Text(preset.emoji, style: const TextStyle(fontSize: 12)),
                    label: Text(preset.name),
                    backgroundColor: isSelected
                        ? AppTheme.mintGreen.withValues(alpha: 0.2)
                        : (isDark ? const Color(0xFF1E293B) : Colors.grey[100]),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.mintGreen
                          : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppTheme.mintGreen : null,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _mixer.applyPreset(preset);
                      if (!_mixer.isPlaying) {
                        _mixer.play();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 多轨分路音量推子列表
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                final vol = _mixer.getTrackVolume(track);
                final isActive = vol > 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? Color(track.themeColor).withValues(alpha: 0.5)
                          : (isDark ? Colors.grey[850]! : Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(track.themeColor).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(track.iconEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 68,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '${(vol * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive ? Color(track.themeColor) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: vol,
                            activeColor: Color(track.themeColor),
                            onChanged: (v) {
                              _mixer.setTrackVolume(track, v);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          size: 18,
                          color: isActive ? Color(track.themeColor) : Colors.grey,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _mixer.setTrackVolume(track, isActive ? 0.0 : 0.6);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
