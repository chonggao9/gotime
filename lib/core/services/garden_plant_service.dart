import 'package:flutter/foundation.dart';
import '../../models/habit.dart';

enum PlantType {
  succulent(name: '露珠多肉', icon: '🪴', desc: '温润小巧，随自律点滴饱满'),
  bamboo(name: '宁静青竹', icon: '🎋', desc: '虚怀若谷，心流坚韧不拔'),
  sunflower(name: '向阳向日葵', icon: '🌻', desc: '拥抱朝阳，活力与动能充沛'),
  evergreen(name: '智慧常青藤', icon: '🌿', desc: '蔓延生长，知识与灵感繁盛'),
  tomato(name: '心流番茄木', icon: '🍅', desc: '硕果累累，专注结出果实'),
  cherryBlossom(name: '治愈樱花树', icon: '🌸', desc: '烂漫自洽，生活芬芳优雅');

  final String name;
  final String icon;
  final String desc;

  const PlantType({
    required this.name,
    required this.icon,
    required this.desc,
  });
}

enum GrowthStage {
  seedling(name: '破土萌芽', emoji: '🌱', minVitality: 0),
  sprouting(name: '抽枝长叶', emoji: '🌿', minVitality: 25),
  budding(name: '孕育花苞', emoji: '🌸', minVitality: 65),
  blooming(name: '繁茂绽放', emoji: '🌳', minVitality: 85);

  final String name;
  final String emoji;
  final int minVitality;

  const GrowthStage({
    required this.name,
    required this.emoji,
    required this.minVitality,
  });
}

class GardenPlant {
  final String habitId;
  final String habitName;
  final String habitIcon;
  final PlantType plantType;
  double vitality; // 0.0 ~ 100.0
  GrowthStage stage;
  bool isResting; // 休眠静息态，绝无枯萎与死亡！
  int totalWateredCount;
  DateTime? lastWateredAt;

  GardenPlant({
    required this.habitId,
    required this.habitName,
    required this.habitIcon,
    required this.plantType,
    required this.vitality,
    required this.stage,
    this.isResting = false,
    this.totalWateredCount = 0,
    this.lastWateredAt,
  });

  String get stageName => stage.name;
  String get displayEmoji => stage == GrowthStage.blooming ? plantType.icon : stage.emoji;
}

/// 习惯疗愈花园服务
class GardenPlantService extends ChangeNotifier {
  GardenPlantService._();
  static final GardenPlantService instance = GardenPlantService._();

  final Map<String, GardenPlant> _plants = {};

  List<GardenPlant> get plants => _plants.values.toList();

  GardenPlant? getPlant(String habitId) => _plants[habitId];

  double get overallGardenVitality {
    if (_plants.isEmpty) return 0.0;
    final total = _plants.values.fold<double>(0.0, (sum, p) => sum + p.vitality);
    return total / _plants.length;
  }

  int get bloomingPlantCount =>
      _plants.values.where((p) => p.stage == GrowthStage.blooming).length;

  /// 同步花园植物
  void syncFromHabits({
    required List<Habit> habits,
    required Set<String> completedHabitIds,
    required Set<String> skippedHabitIds,
  }) {
    for (final habit in habits) {
      final isCompleted = completedHabitIds.contains(habit.id);
      final isSkipped = skippedHabitIds.contains(habit.id);

      if (!_plants.containsKey(habit.id)) {
        final type = _deducePlantType(habit);
        final initialVitality = isCompleted ? 40.0 : 20.0;
        _plants[habit.id] = GardenPlant(
          habitId: habit.id,
          habitName: habit.name,
          habitIcon: habit.iconEmoji,
          plantType: type,
          vitality: initialVitality,
          stage: _calculateStage(initialVitality),
          isResting: isSkipped,
          totalWateredCount: isCompleted ? 1 : 0,
          lastWateredAt: isCompleted ? DateTime.now() : null,
        );
      } else {
        final plant = _plants[habit.id]!;
        if (isCompleted) {
          plant.isResting = false;
          plant.vitality = (plant.vitality + 5.0).clamp(0.0, 100.0);
          plant.stage = _calculateStage(plant.vitality);
        } else if (isSkipped) {
          plant.isResting = true; // 进入静息修养状态，生机值永不衰退
        }
      }
    }

    notifyListeners();
  }

  /// 为习惯植物浇水
  GardenPlant? waterPlant(String habitId) {
    final plant = _plants[habitId];
    if (plant == null) return null;

    plant.vitality = (plant.vitality + 15.0).clamp(0.0, 100.0);
    plant.stage = _calculateStage(plant.vitality);
    plant.isResting = false;
    plant.totalWateredCount += 1;
    plant.lastWateredAt = DateTime.now();

    notifyListeners();
    return plant;
  }

  GrowthStage _calculateStage(double vitality) {
    if (vitality >= GrowthStage.blooming.minVitality) return GrowthStage.blooming;
    if (vitality >= GrowthStage.budding.minVitality) return GrowthStage.budding;
    if (vitality >= GrowthStage.sprouting.minVitality) return GrowthStage.sprouting;
    return GrowthStage.seedling;
  }

  PlantType _deducePlantType(Habit habit) {
    final name = habit.name.toLowerCase();
    if (name.contains('水') || name.contains('喝')) return PlantType.succulent;
    if (name.contains('冥想') || name.contains('戒') || name.contains('呼') || name.contains('静')) {
      return PlantType.bamboo;
    }
    if (name.contains('跑') || name.contains('动') || name.contains('练') || name.contains('健')) {
      return PlantType.sunflower;
    }
    if (name.contains('读') || name.contains('书') || name.contains('学') || name.contains('记')) {
      return PlantType.evergreen;
    }
    if (habit.type == HabitType.timer || name.contains('工') || name.contains('写')) {
      return PlantType.tomato;
    }
    return PlantType.cherryBlossom;
  }

  void resetGarden() {
    _plants.clear();
    notifyListeners();
  }
}
