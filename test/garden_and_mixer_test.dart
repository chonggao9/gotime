import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/core/services/ambient_sound_service.dart';
import 'package:gotime/core/services/garden_plant_service.dart';
import 'package:gotime/core/services/multi_track_mixer_service.dart';
import 'package:gotime/models/habit.dart';

void main() {
  group('GardenPlantService Tests (Healing Flora Ecosystem & Anti-Anxiety)', () {
    final habitWater = Habit(
      id: 'h_water',
      name: '每日喝水',
      iconEmoji: '💧',
      themeColor: '#34D399',
      type: HabitType.counter,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final habitRead = Habit(
      id: 'h_read',
      name: '阅读学习',
      iconEmoji: '📚',
      themeColor: '#60A5FA',
      type: HabitType.boolean,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    final habitFocus = Habit(
      id: 'h_focus',
      name: '番茄深度专注',
      iconEmoji: '🍅',
      themeColor: '#F87171',
      type: HabitType.timer,
      frequency: const {'type': 'daily'},
      updatedAt: DateTime.now(),
    );

    test('syncFromHabits converts habits to living plants without death mechanics', () {
      final garden = GardenPlantService.instance;
      garden.syncFromHabits(
        habits: [habitWater, habitRead, habitFocus],
        completedHabitIds: {'h_water'},
        skippedHabitIds: {'h_focus'},
      );

      expect(garden.plants.length, 3);

      final waterPlant = garden.getPlant('h_water');
      expect(waterPlant, isNotNull);
      expect(waterPlant!.vitality, greaterThanOrEqualTo(40.0));
      expect(waterPlant.isResting, isFalse);

      // 验证静息保护机制：休假/跳过只进入静养休眠，绝无枯萎或归零
      final focusPlant = garden.getPlant('h_focus');
      expect(focusPlant, isNotNull);
      expect(focusPlant!.isResting, isTrue);
      expect(focusPlant.vitality, greaterThan(0.0));
    });

    test('waterPlant nourishes plant, advances stages and wakes from rest', () {
      final garden = GardenPlantService.instance;
      garden.syncFromHabits(
        habits: [habitRead],
        completedHabitIds: {},
        skippedHabitIds: {'h_read'},
      );

      final plant = garden.getPlant('h_read')!;
      expect(plant.isResting, isTrue);
      final initialVitality = plant.vitality;

      // 浇灌滋养
      garden.waterPlant('h_read');
      expect(plant.vitality, initialVitality + 15.0);
      expect(plant.totalWateredCount, 1);
      expect(plant.isResting, isFalse); // 唤醒生机
      expect(plant.lastWateredAt, isNotNull);

      // 持续浇灌直至盛开
      for (int i = 0; i < 5; i++) {
        garden.waterPlant('h_read');
      }
      expect(plant.stage, GrowthStage.blooming);
      expect(plant.vitality, 100.0); // 活力上限保护
    });

    test('overallGardenVitality and bloomingPlantCount compute accurate statistics', () {
      final garden = GardenPlantService.instance;
      garden.syncFromHabits(
        habits: [habitWater, habitRead],
        completedHabitIds: {'h_water'},
        skippedHabitIds: {},
      );

      expect(garden.overallGardenVitality, greaterThan(0.0));
      expect(garden.overallGardenVitality, lessThanOrEqualTo(100.0));
    });
  });

  group('MultiTrackMixerService Tests (48kHz Hi-Fi Master Mixer)', () {
    final mixer = MultiTrackMixerService.instance;

    setUp(() {
      mixer.resetAll();
    });

    test('independent track volume adjustment and clamping', () {
      mixer.setTrackVolume(AmbientSoundType.rain, 0.65);
      expect(mixer.getTrackVolume(AmbientSoundType.rain), 0.65);
      expect(mixer.isTrackActive(AmbientSoundType.rain), isTrue);

      // 超出 1.0 时自动 clamp
      mixer.setTrackVolume(AmbientSoundType.waves, 1.5);
      expect(mixer.getTrackVolume(AmbientSoundType.waves), 1.0);

      // 小于 0.0 时自动 clamp
      mixer.setTrackVolume(AmbientSoundType.forest, -0.2);
      expect(mixer.getTrackVolume(AmbientSoundType.forest), 0.0);
      expect(mixer.isTrackActive(AmbientSoundType.forest), isFalse);
    });

    test('master volume scaling and clamping', () {
      mixer.setMasterVolume(0.5);
      expect(mixer.masterVolume, 0.5);

      mixer.setMasterVolume(2.0);
      expect(mixer.masterVolume, 1.0);

      mixer.setMasterVolume(-0.5);
      expect(mixer.masterVolume, 0.0);
    });

    test('applyPreset configures multi-track volumes and tracks active preset', () {
      final preset = MultiTrackMixerService.presets.firstWhere((p) => p.id == 'forest_rain');
      mixer.applyPreset(preset);

      expect(mixer.activePresetId, 'forest_rain');
      expect(mixer.getTrackVolume(AmbientSoundType.forest), 0.7);
      expect(mixer.getTrackVolume(AmbientSoundType.rain), 0.5);

      // 手动微调任一轨道后，预设标识自动转为自定义 (null)
      mixer.setTrackVolume(AmbientSoundType.rain, 0.4);
      expect(mixer.activePresetId, isNull);
    });

    test('playback state control and togglePlayPause behavior', () {
      expect(mixer.isPlaying, isFalse);

      mixer.togglePlayPause();
      expect(mixer.isPlaying, isTrue);

      mixer.togglePlayPause();
      expect(mixer.isPlaying, isFalse);

      mixer.play();
      expect(mixer.isPlaying, isTrue);

      mixer.stop();
      expect(mixer.isPlaying, isFalse);
    });

    test('resetAll silences all tracks and clears active preset', () {
      mixer.setTrackVolume(AmbientSoundType.fire, 0.8);
      mixer.play();

      mixer.resetAll();
      expect(mixer.isPlaying, isFalse);
      expect(mixer.getTrackVolume(AmbientSoundType.fire), 0.0);
      expect(mixer.activePresetId, isNull);
    });
  });
}
