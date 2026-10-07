import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/ambient_sound_service.dart';

void main() {
  group('高保真离线白噪音系统测试 (Hi-Fi Authentic Soundscape Tests)', () {
    test('全部声境类型均配置真实采风音频文件，拒绝算法合成', () {
      final realSounds = [
        AmbientSoundType.rain,
        AmbientSoundType.forest,
        AmbientSoundType.waves,
        AmbientSoundType.fire,
        AmbientSoundType.cafe,
      ];

      for (final sound in realSounds) {
        expect(sound.fileName, isNotNull);
        expect(sound.fileName!.endsWith('.mp3'), isTrue);
        expect(sound.soundUrl, isNotNull);
        expect(sound.soundUrl!.contains(sound.fileName!), isTrue);
        expect(sound.qualityLabel.contains('实录'), isTrue);
      }

      // 静音模式不应绑定音频文件
      expect(AmbientSoundType.none.fileName, isNull);
      expect(AmbientSoundType.none.soundUrl, isNull);
    });

    test('AmbientSoundService 能够正常切换高保真音源并控制播放状态', () {
      final service = AmbientSoundService.instance;

      // 切换到淅淅春雨
      service.setSound(AmbientSoundType.rain);
      expect(service.currentSound, AmbientSoundType.rain);
      expect(service.isPlaying, isTrue);

      // 暂停
      service.stop();
      expect(service.isPlaying, isFalse);

      // 切换到静音
      service.setSound(AmbientSoundType.none);
      expect(service.currentSound, AmbientSoundType.none);
      expect(service.isPlaying, isFalse);
    });

    test('AmbientSoundService 音量调节范围受 [0.0, 1.0] 安全保护', () {
      final service = AmbientSoundService.instance;

      service.setVolume(0.75);
      expect(service.volume, 0.75);

      // 超出上限截断
      service.setVolume(1.8);
      expect(service.volume, 1.0);

      // 低于下限截断
      service.setVolume(-0.3);
      expect(service.volume, 0.0);
    });

    test('播放颂钵完成提示音不抛出异常', () {
      final service = AmbientSoundService.instance;
      expect(() => service.playCompletionChime(), returnsNormally);
    });
  });
}
