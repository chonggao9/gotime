import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/garden_plant_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';

class HabitGardenDialog extends StatefulWidget {
  final List<Habit> habits;
  final Set<String> completedHabitIds;
  final Set<String> skippedHabitIds;

  const HabitGardenDialog({
    super.key,
    required this.habits,
    required this.completedHabitIds,
    required this.skippedHabitIds,
  });

  static void show(
    BuildContext context, {
    required List<Habit> habits,
    required Set<String> completedHabitIds,
    required Set<String> skippedHabitIds,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitGardenDialog(
        habits: habits,
        completedHabitIds: completedHabitIds,
        skippedHabitIds: skippedHabitIds,
      ),
    );
  }

  @override
  State<HabitGardenDialog> createState() => _HabitGardenDialogState();
}

class _HabitGardenDialogState extends State<HabitGardenDialog> {
  final _service = GardenPlantService.instance;

  @override
  void initState() {
    super.initState();
    _service.syncFromHabits(
      habits: widget.habits,
      completedHabitIds: widget.completedHabitIds,
      skippedHabitIds: widget.skippedHabitIds,
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plants = _service.plants;
    final gardenVitality = _service.overallGardenVitality;
    final bloomingCount = _service.bloomingPlantCount;

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
          // 顶部手柄
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

          // 标题行与统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🏡 ', style: TextStyle(fontSize: 22)),
                      Text(
                        '自律疗愈微缩花园',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '生机值 ${(gardenVitality).toInt()}% · 已有 $bloomingCount 株繁茂盛开',
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
          const SizedBox(height: 12),

          // 心理学抗焦虑保障横幅
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Text('🌿', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '永不枯萎，休眠自愈：漏打卡或请假时植物安心休眠，等待下一次轻柔浇水唤醒。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 植物网格列表
          Expanded(
            child: plants.isEmpty
                ? Center(
                    child: Text(
                      '花园暂无植物，添加习惯即可孵化专属于你的微缩绿植 🌱',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return _buildPlantCard(plant, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(GardenPlant plant, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plant.isResting
              ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: plant.isResting ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 植物形象大容器
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: plant.isResting
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                  : AppTheme.mintGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              plant.displayEmoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(width: 14),

          // 植物信息与成长进度
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plant.plantType.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${plant.habitName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: plant.isResting
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                            : (isDark ? Colors.grey[800] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plant.isResting ? '🌙 静息休养中' : '${plant.stage.emoji} ${plant.stage.name}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: plant.isResting ? const Color(0xFF0284C7) : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '活力 ${plant.vitality.toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.mintGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 活力条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: plant.vitality / 100.0,
                    minHeight: 5,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      plant.isResting ? const Color(0xFF38BDF8) : AppTheme.mintGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 浇水按钮
          IconButton.filledTonal(
            tooltip: '浇水滋养 (+15活力)',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _service.waterPlant(plant.habitId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('💧 已为「${plant.plantType.name}」浇水注入生机！+15%'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Text('💧', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
