import 'package:flutter/foundation.dart';
import 'ambient_sound_service.dart';
import 'audio_player/audio_player.dart';

class MixerPreset {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Map<AmbientSoundType, double> trackVolumes;

  const MixerPreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.trackVolumes,
  });
}

/// 48kHz 高保真多轨母带环境白噪音混音台服务 (Multi-Track Hi-Fi Soundscape Mixer)
class MultiTrackMixerService extends ChangeNotifier {
  MultiTrackMixerService._() {
    _initPlayers();
  }
  static final MultiTrackMixerService instance = MultiTrackMixerService._();

  final Map<AmbientSoundType, PlatformAudioPlayer> _players = {};
  final Map<AmbientSoundType, double> _trackVolumes = {};

  double _masterVolume = 0.8;
  bool _isPlaying = false;
  String? _activePresetId;

  static const List<MixerPreset> presets = [
    MixerPreset(
      id: 'forest_rain',
      name: '林间春雨',
      emoji: '🌧️🌲',
      description: '微风拂林伴随清幽细雨，抚平杂念',
      trackVolumes: {
        AmbientSoundType.forest: 0.7,
        AmbientSoundType.rain: 0.5,
      },
    ),
    MixerPreset(
      id: 'fireplace_reading',
      name: '炉边慢读',
      emoji: '🔥☕',
      description: '松木柴火爆裂微鸣与香醇咖啡馆',
      trackVolumes: {
        AmbientSoundType.fire: 0.7,
        AmbientSoundType.cafe: 0.4,
      },
    ),
    MixerPreset(
      id: 'ocean_breeze',
      name: '海浪松风',
      emoji: '🌊🌲',
      description: '深海潮涌与林海回响交织',
      trackVolumes: {
        AmbientSoundType.waves: 0.75,
        AmbientSoundType.forest: 0.35,
      },
    ),
  ];

  double get masterVolume => _masterVolume;
  bool get isPlaying => _isPlaying;
  String? get activePresetId => _activePresetId;

  Map<AmbientSoundType, double> get trackVolumes => Map.unmodifiable(_trackVolumes);

  void _initPlayers() {
    for (final type in AmbientSoundType.values) {
      if (type != AmbientSoundType.none) {
        _players[type] = PlatformAudioPlayer();
        _trackVolumes[type] = 0.0;
      }
    }
  }

  double getTrackVolume(AmbientSoundType type) => _trackVolumes[type] ?? 0.0;

  bool isTrackActive(AmbientSoundType type) => (_trackVolumes[type] ?? 0.0) > 0.0;

  void setTrackVolume(AmbientSoundType type, double volume) {
    if (type == AmbientSoundType.none) return;

    final clamped = volume.clamp(0.0, 1.0);
    _trackVolumes[type] = clamped;
    _activePresetId = null;

    final player = _players[type];
    final effectiveVol = (clamped * _masterVolume).clamp(0.0, 1.0);

    if (_isPlaying) {
      if (clamped > 0.0) {
        final url = type.soundUrl;
        if (url != null) {
          player?.play(url, loop: true, volume: effectiveVol);
        }
      } else {
        player?.stop();
      }
    }

    notifyListeners();
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);

    if (_isPlaying) {
      for (final entry in _players.entries) {
        final trackVol = _trackVolumes[entry.key] ?? 0.0;
        final effectiveVol = (trackVol * _masterVolume).clamp(0.0, 1.0);
        entry.value.setVolume(effectiveVol);
      }
    }

    notifyListeners();
  }

  void applyPreset(MixerPreset preset) {
    _activePresetId = preset.id;

    for (final type in _players.keys) {
      final vol = preset.trackVolumes[type] ?? 0.0;
      _trackVolumes[type] = vol;
    }

    if (_isPlaying) {
      _syncAllPlayingAudio();
    }

    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    _syncAllPlayingAudio();
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    for (final player in _players.values) {
      player.stop();
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      stop();
    } else {
      // 若当前没有音轨有音量，默认开启林间细雨
      final hasActive = _trackVolumes.values.any((v) => v > 0.0);
      if (!hasActive) {
        applyPreset(presets.first);
      }
      play();
    }
  }

  void _syncAllPlayingAudio() {
    for (final entry in _players.entries) {
      final type = entry.key;
      final player = entry.value;
      final vol = _trackVolumes[type] ?? 0.0;

      if (vol > 0.0) {
        final url = type.soundUrl;
        if (url != null) {
          player.play(url, loop: true, volume: (vol * _masterVolume).clamp(0.0, 1.0));
        }
      } else {
        player.stop();
      }
    }
  }

  void resetAll() {
    stop();
    for (final type in _players.keys) {
      _trackVolumes[type] = 0.0;
    }
    _activePresetId = null;
    notifyListeners();
  }
}
