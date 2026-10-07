import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/habit.dart';
import '../../../models/check_in.dart';
import '../../../core/database/sqlite_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  List<CheckIn> _historyLogs = [];
  bool _isLoading = true;
  
  // 假定热力图数据（真实情况需要根据 _historyLogs 计算，为了保证丝滑先用部分 Mock）
  final int _currentStreak = 12;
  final int _totalDays = 45;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // 这里真实逻辑是从数据库加载该习惯的所有 CheckIn
    // 并且筛选出带有 logText 的记录
    // 为了防止 Web 版报错，加入基础的 Mock 处理
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _historyLogs = [
        CheckIn(id: '1', habitId: widget.habit.id, date: '2024-10-06', status: CheckInStatus.completed, createdAt: DateTime.now()),
        CheckIn(id: '2', habitId: widget.habit.id, date: '2024-10-05', status: CheckInStatus.completed, createdAt: DateTime.now()),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = Color(int.parse(widget.habit.themeColor.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('数据分析'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: themeColor))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部卡片：名称与核心数据
                _buildHeaderCard(isDark, themeColor),
                const SizedBox(height: 32),
                
                // 单项热力图分析
                Text(
                  '最近 30 天表现',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMiniHeatmap(isDark, themeColor),
                const SizedBox(height: 32),

                // 日志流 (Timeline)
                Text(
                  '习惯日志与感悟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLogsTimeline(isDark, themeColor),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderCard(bool isDark, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: themeColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(widget.habit.iconEmoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建于 ${widget.habit.updatedAt.month}月${widget.habit.updatedAt.day}日',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('当前连胜', '$_currentStreak', '天', themeColor, isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.grey[800] : Colors.grey[200]),
              _buildStatItem('累计打卡', '$_totalDays', '次', isDark ? Colors.white : Colors.black87, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color valColor, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valColor),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniHeatmap(bool isDark, Color themeColor) {
    // 简单的 7x4 模拟热力方块
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 28,
        itemBuilder: (ctx, idx) {
          // 制造一些随机的深浅效果
          final opacity = (idx % 3 == 0) ? 0.05 : ((idx % 5 == 0) ? 1.0 : 0.4);
          return Container(
            decoration: BoxDecoration(
              color: opacity == 0.05 ? (isDark ? Colors.grey[800] : Colors.grey[300]) : themeColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogsTimeline(bool isDark, Color themeColor) {
    // 模拟的时间线日志
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // 演示3条
      itemBuilder: (ctx, idx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间轴
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: themeColor, width: 3),
                    ),
                  ),
                  if (idx != 2) // 不是最后一个则显示竖线
                    Container(
                      width: 2,
                      height: 80,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      margin: const EdgeInsets.only(top: 8),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 日志卡片
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '10月${6 - idx}日',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            idx == 0 ? '😎' : '🙂',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        idx == 0 
                            ? '今天状态极佳！毫不费力地完成了任务，感觉自己离目标更近了一步。继续保持这股冲劲！' 
                            : '虽然有点累，但还是坚持下来了。习惯的力量正在潜移默化地改变我。',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
