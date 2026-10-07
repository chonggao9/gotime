/// 音频播放器接口存根（测试用）
class PlatformAudioPlayer {
  void play(String url, {bool loop = true, double volume = 0.6}) {}
  void stop() {}
  void setVolume(double volume) {}
  void playChime(String url, {double volume = 0.8}) {}
}
