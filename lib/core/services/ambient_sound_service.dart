import 'package:flutter/foundation.dart';

enum AmbientSoundType {
  none(
    name: '静音专注',
    iconEmoji: '🔇',
    description: '绝对安静，万物归一',
    themeColor: 0xFF64748B,
  ),
  rain(
    name: '淅淅春雨',
    iconEmoji: '🌧️',
    description: '窗外细雨，冲刷杂念',
    themeColor: 0xFF38BDF8,
  ),
  forest(
    name: '幽静森林',
    iconEmoji: '🌲',
    description: '林间微风，万木吐翠',
    themeColor: 0xFF10B981,
  ),
  waves(
    name: '舒缓潮汐',
    iconEmoji: '🌊',
    description: '深海呼吸，身心舒缓',
    themeColor: 0xFF6366F1,
  ),
  fire(
    name: '温暖壁炉',
    iconEmoji: '🔥',
    description: '柴火微响，沉浸专注',
    themeColor: 0xFFF97316,
  ),
  cafe(
    name: '街角咖啡',
    iconEmoji: '☕',
    description: '午后香气，高效思考',
    themeColor: 0xFFA855F7,
  );

  final String name;
  final String iconEmoji;
  final String description;
  final int themeColor;

  const AmbientSoundType({
    required this.name,
    required this.iconEmoji,
    required this.description,
    required this.themeColor,
  });
}

/// 跨平台白噪音与专注声学环境服务
class AmbientSoundService extends ChangeNotifier {
  AmbientSoundService._();
  static final AmbientSoundService instance = AmbientSoundService._();

  AmbientSoundType _currentSound = AmbientSoundType.none;
  double _volume = 0.6; // 0.0 - 1.0
  bool _isPlaying = false;

  AmbientSoundType get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  /// 切换背景音
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
    notifyListeners();
  }

  void play() {
    if (_currentSound == AmbientSoundType.none) return;
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
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

  /// 专注完成时的清脆颂钵禅鸣
  void playCompletionChime() {
    // 触发完成提示音
    notifyListeners();
  }
}

