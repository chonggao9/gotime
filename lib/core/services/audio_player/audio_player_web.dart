// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// 网页端音频播放器
class PlatformAudioPlayer {
  html.AudioElement? _currentAudio;
  html.AudioElement? _chimeAudio;

  void play(String url, {bool loop = true, double volume = 0.6}) {
    stop();
    try {
      _currentAudio = html.AudioElement(url)
        ..loop = loop
        ..volume = volume.clamp(0.0, 1.0);
      _currentAudio?.play();
    } catch (_) {}
  }

  void stop() {
    try {
      _currentAudio?.pause();
      _currentAudio?.currentTime = 0;
      _currentAudio = null;
    } catch (_) {}
  }

  void setVolume(double volume) {
    try {
      if (_currentAudio != null) {
        _currentAudio?.volume = volume.clamp(0.0, 1.0);
      }
    } catch (_) {}
  }

  void playChime(String url, {double volume = 0.8}) {
    try {
      _chimeAudio?.pause();
      _chimeAudio = html.AudioElement(url)
        ..loop = false
        ..volume = volume.clamp(0.0, 1.0);
      _chimeAudio?.play();
    } catch (_) {}
  }
}
