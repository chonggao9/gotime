import 'package:flutter/foundation.dart';
import 'audio_player/audio_player.dart';

enum AmbientSoundType {
  none(
    name: '静音专注',
    iconEmoji: '🔇',
    description: '绝对安静，万物归一',
    themeColor: 0xFF64748B,
    fileName: null,
    qualityLabel: '无伴奏',
  ),
  rain(
    name: '淅淅春雨',
    iconEmoji: '🌧️',
    description: '窗外细雨，冲刷杂念',
    themeColor: 0xFF38BDF8,
    fileName: 'rain.mp3',
    qualityLabel: '48kHz 实录真音',
  ),
  forest(
    name: '幽静森林',
    iconEmoji: '🌲',
    description: '林间微风，万木吐翠',
    themeColor: 0xFF10B981,
    fileName: 'forest.mp3',
    qualityLabel: '48kHz 实录真音',
  ),
  waves(
    name: '舒缓潮汐',
    iconEmoji: '🌊',
    description: '深海呼吸，身心舒缓',
    themeColor: 0xFF6366F1,
    fileName: 'waves.mp3',
    qualityLabel: '48kHz 实录真音',
  ),
  fire(
    name: '温暖壁炉',
    iconEmoji: '🔥',
    description: '柴火微响，沉浸专注',
    themeColor: 0xFFF97316,
    fileName: 'fire.mp3',
    qualityLabel: '48kHz 实录真音',
  ),
  cafe(
    name: '街角咖啡',
    iconEmoji: '☕',
    description: '午后香气，高效思考',
    themeColor: 0xFFA855F7,
    fileName: 'cafe.mp3',
    qualityLabel: '48kHz 实录真音',
  );

  final String name;
  final String iconEmoji;
  final String description;
  final int themeColor;
  final String? fileName;
  final String qualityLabel;

  const AmbientSoundType({
    required this.name,
    required this.iconEmoji,
    required this.description,
    required this.themeColor,
    required this.fileName,
    required this.qualityLabel,
  });

  /// 音频实际相对资源路径 (网页端使用 sounds/ 根目录确保完全离线快速加载)
  String? get soundUrl {
    if (fileName == null) return null;
    return kIsWeb ? 'sounds/$fileName' : 'assets/audio/$fileName';
  }
}

/// 白噪音播放服务
class AmbientSoundService extends ChangeNotifier {
  AmbientSoundService._();
  static final AmbientSoundService instance = AmbientSoundService._();

  final PlatformAudioPlayer _player = PlatformAudioPlayer();

  AmbientSoundType _currentSound = AmbientSoundType.none;
  double _volume = 0.6; // 0.0 - 1.0
  bool _isPlaying = false;

  AmbientSoundType get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  /// 切换白噪音
  void setSound(AmbientSoundType type) {
    if (_currentSound == type) {
      if (_isPlaying) {
        stop();
      } else {
        play();
      }
      return;
    }
    _currentSound = type;
    if (_currentSound == AmbientSoundType.none) {
      stop();
    } else {
      play();
    }
  }

  void setVolume(double newVolume) {
    _volume = newVolume.clamp(0.0, 1.0);
    _player.setVolume(_volume);
    notifyListeners();
  }

  void play() {
    if (_currentSound == AmbientSoundType.none) return;
    final url = _currentSound.soundUrl;
    if (url != null) {
      _player.play(url, loop: true, volume: _volume);
    }
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    _player.stop();
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      stop();
    } else {
      play();
    }
  }

  /// 完成时播放颂钵提示音
  void playCompletionChime() {
    final chimeUrl = kIsWeb ? 'sounds/bowl.mp3' : 'assets/audio/bowl.mp3';
    _player.playChime(chimeUrl, volume: (_volume * 1.2).clamp(0.0, 1.0));
    notifyListeners();
  }
}
